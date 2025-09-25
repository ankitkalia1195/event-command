import face_recognition
import numpy as np
from typing import Optional, List, Dict, Any
import base64
import io
from PIL import Image


class FaceService:
    """Face recognition service for authentication"""
    
    def __init__(self, tolerance: float = 0.6):
        self.tolerance = tolerance
    
    def encode_face(self, image_data: str) -> Optional[List[float]]:
        """
        Encode a face from base64 image data
        Returns 128-dimensional face encoding or None if no face found
        """
        try:
            # Decode base64 image
            if image_data.startswith("data:"):
                image_data = image_data.split(",", 1)[1]
            
            image_bytes = base64.b64decode(image_data)
            image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
            image_np = np.array(image)
            
            # Get face encodings
            face_locations = face_recognition.face_locations(image_np)
            if not face_locations:
                return None
                
            face_encodings = face_recognition.face_encodings(image_np, face_locations)
            if not face_encodings:
                return None
                
            # Return first face encoding
            return face_encodings[0].tolist()
            
        except Exception as e:
            print(f"Error encoding face: {e}")
            return None
    
    def compare_faces(self, known_encoding: List[float], unknown_encoding: List[float]) -> Dict[str, Any]:
        """
        Compare two face encodings
        Returns dict with match status and distance
        """
        try:
            known_np = np.array(known_encoding)
            unknown_np = np.array(unknown_encoding)
            
            # Calculate face distance
            distance = face_recognition.face_distance([known_np], unknown_np)[0]
            match = distance <= self.tolerance
            confidence = max(0.0, 1.0 - distance)
            
            return {
                "match": bool(match),
                "distance": float(distance),
                "confidence": float(confidence)
            }
            
        except Exception as e:
            print(f"Error comparing faces: {e}")
            return {
                "match": False,
                "distance": 1.0,
                "confidence": 0.0
            }
    
    def authenticate_face(self, probe_image: str, known_encodings: List[Dict[str, Any]]) -> Dict[str, Any]:
        """
        Authenticate a face against known encodings
        known_encodings should be list of dicts with 'user_id' and 'encoding' keys
        Returns best match or None
        """
        try:
            # Encode the probe image
            probe_encoding = self.encode_face(probe_image)
            if probe_encoding is None:
                return {
                    "success": False,
                    "error": "No face detected in image"
                }
            
            if not known_encodings:
                return {
                    "success": False,
                    "error": "No known faces to compare against"
                }
            
            best_match = None
            best_confidence = 0.0
            
            # Compare against all known faces
            for known_face in known_encodings:
                if 'encoding' not in known_face or 'user_id' not in known_face:
                    continue
                    
                comparison = self.compare_faces(known_face['encoding'], probe_encoding)
                
                if comparison['match'] and comparison['confidence'] > best_confidence:
                    best_match = {
                        "user_id": known_face['user_id'],
                        "confidence": comparison['confidence'],
                        "distance": comparison['distance']
                    }
                    best_confidence = comparison['confidence']
            
            if best_match:
                return {
                    "success": True,
                    "authenticated": True,
                    "user_id": best_match['user_id'],
                    "confidence": best_match['confidence'],
                    "distance": best_match['distance']
                }
            else:
                return {
                    "success": True,
                    "authenticated": False,
                    "error": "No matching face found"
                }
                
        except Exception as e:
            return {
                "success": False,
                "error": f"Authentication error: {str(e)}"
            }