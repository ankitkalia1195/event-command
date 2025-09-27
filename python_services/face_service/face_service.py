import cv2
import numpy as np
from typing import Optional, List, Dict, Any
import base64
import io
from PIL import Image

try:
    import face_recognition
    USE_FACE_RECOGNITION = True
except ImportError:
    USE_FACE_RECOGNITION = False
    from sklearn.metrics.pairwise import cosine_similarity

class FaceService:
    """Face recognition service with fallback implementation"""
    
    def __init__(self, tolerance: float = 0.75):
        self.tolerance = tolerance
        # Initialize Haar cascade for face detection (used in fallback mode)
        self.face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
    
    def encode_face(self, image_data: str) -> Optional[List[float]]:
        """
        Extract face encoding from base64 image
        Uses face_recognition library if available, otherwise falls back to OpenCV
        """
        try:
            # Decode base64 image
            if image_data.startswith("data:"):
                image_data = image_data.split(",", 1)[1]
            
            image_bytes = base64.b64decode(image_data)
            image = Image.open(io.BytesIO(image_bytes)).convert("RGB") 
            image_np = np.array(image)
            
            if USE_FACE_RECOGNITION:
                return self._encode_with_face_recognition(image_np)
            else:
                return self._encode_with_opencv(image_np)
                
        except Exception as e:
            print(f"Error encoding face: {e}")
            return None
    
    def _encode_with_face_recognition(self, image_np: np.ndarray) -> Optional[List[float]]:
        """Use face_recognition library for encoding (recommended)"""
        try:
            # Find face locations
            face_locations = face_recognition.face_locations(image_np)
            
            if len(face_locations) == 0:
                return None
            
            # Get face encodings (use first face if multiple detected)
            face_encodings = face_recognition.face_encodings(image_np, face_locations)

            print(face_encodings)
            
            if len(face_encodings) == 0:
                return None
                
            return face_encodings[0].tolist()
            
        except Exception as e:
            print(f"Error in face_recognition encoding: {e}")
            return None
    
    def _encode_with_opencv(self, image_np: np.ndarray) -> Optional[List[float]]:
        """Fallback OpenCV-based encoding"""
        try:
            # Convert to grayscale for face detection
            gray = cv2.cvtColor(image_np, cv2.COLOR_RGB2GRAY)
            
            # Detect faces with better parameters
            faces = self.face_cascade.detectMultiScale(
                gray, 
                scaleFactor=1.05,
                minNeighbors=5,
                minSize=(100, 100),
                maxSize=(500, 500)
            )
            
            if len(faces) == 0:
                return None
                
            # Use the largest face
            face = max(faces, key=lambda x: x[2] * x[3])  # x, y, w, h
            x, y, w, h = face
            
            # Add padding around face
            padding = int(0.2 * min(w, h))
            x = max(0, x - padding)
            y = max(0, y - padding)
            w = min(gray.shape[1] - x, w + 2 * padding)
            h = min(gray.shape[0] - y, h + 2 * padding)
            
            # Extract face region
            face_roi = gray[y:y+h, x:x+w]
            
            # Normalize and resize
            face_roi = cv2.equalizeHist(face_roi)
            face_roi = cv2.resize(face_roi, (128, 128))
            
            # Enhanced feature extraction
            features = []
            
            # 1. Histogram features
            hist = cv2.calcHist([face_roi], [0], None, [32], [0, 256])
            hist = hist.flatten() / (hist.sum() + 1e-7)
            features.extend(hist)
            
            # 2. Gradient features
            grad_x = cv2.Sobel(face_roi, cv2.CV_64F, 1, 0, ksize=3)
            grad_y = cv2.Sobel(face_roi, cv2.CV_64F, 0, 1, ksize=3)
            
            grad_features = [
                grad_x.mean(), grad_x.std(), grad_x.min(), grad_x.max(),
                grad_y.mean(), grad_y.std(), grad_y.min(), grad_y.max()
            ]
            features.extend(grad_features)
            
            # 3. LBP (Local Binary Pattern) features
            lbp_features = self._compute_lbp_features(face_roi)
            features.extend(lbp_features)
            
            # 4. Eigenface-like features (PCA on patches)
            patch_features = self._compute_patch_features(face_roi)
            features.extend(patch_features)
            
            # Ensure consistent dimensionality
            target_dim = 256
            if len(features) < target_dim:
                features.extend([0.0] * (target_dim - len(features)))
            else:
                features = features[:target_dim]
            
            return features
            
        except Exception as e:
            print(f"Error in OpenCV encoding: {e}")
            return None
    
    def _compute_lbp_features(self, face_roi: np.ndarray) -> List[float]:
        """Compute Local Binary Pattern features"""
        lbp_values = []
        height, width = face_roi.shape
        
        for i in range(1, height - 1):
            for j in range(1, width - 1):
                center = face_roi[i, j]
                code = 0
                for k, (di, dj) in enumerate([(-1,-1), (-1,0), (-1,1), (0,1), (1,1), (1,0), (1,-1), (0,-1)]):
                    if face_roi[i+di, j+dj] > center:
                        code += 2 ** k
                lbp_values.append(code)
        
        # Create histogram of LBP values
        hist, _ = np.histogram(lbp_values, bins=32, range=(0, 256))
        hist = hist / (hist.sum() + 1e-7)
        return hist.tolist()
    
    def _compute_patch_features(self, face_roi: np.ndarray) -> List[float]:
        """Compute patch-based features"""
        patches = []
        patch_size = 16
        height, width = face_roi.shape
        
        for i in range(0, height - patch_size, patch_size // 2):
            for j in range(0, width - patch_size, patch_size // 2):
                patch = face_roi[i:i+patch_size, j:j+patch_size]
                if patch.shape == (patch_size, patch_size):
                    # Simple statistics for each patch
                    patches.extend([
                        patch.mean(),
                        patch.std(),
                        patch.min(),
                        patch.max()
                    ])
        
        # Limit to reasonable number of features
        return patches[:64]
    
    def compare_faces(self, known_encoding: List[float], unknown_encoding: List[float]) -> Dict[str, Any]:
        """
        Compare two face encodings
        Uses appropriate comparison method based on encoding type
        """
        try:
            if USE_FACE_RECOGNITION and len(known_encoding) == 128:
                return self._compare_with_face_recognition(known_encoding, unknown_encoding)
            else:
                return self._compare_with_cosine_similarity(known_encoding, unknown_encoding)
                
        except Exception as e:
            print(f"Error comparing faces: {e}")
            return {
                "match": False,
                "confidence": 0.0,
                "distance": 1.0
            }
    
    def _compare_with_face_recognition(self, known_encoding: List[float], unknown_encoding: List[float]) -> Dict[str, Any]:
        """Use face_recognition library for comparison"""
        try:
            known_np = np.array([known_encoding])
            unknown_np = np.array(unknown_encoding)
            
            # Use face_recognition's built-in comparison
            matches = face_recognition.compare_faces(known_np, unknown_np, tolerance=self.tolerance)
            distances = face_recognition.face_distance(known_np, unknown_np)
            
            match = matches[0] if matches else False
            distance = float(distances[0]) if distances.size > 0 else 1.0
            confidence = max(0, 1 - distance)
            
            return {
                "match": match,
                "confidence": confidence,
                "distance": distance
            }
            
        except Exception as e:
            print(f"Error in face_recognition comparison: {e}")
            return self._compare_with_cosine_similarity(known_encoding, unknown_encoding)
    
    def _compare_with_cosine_similarity(self, known_encoding: List[float], unknown_encoding: List[float]) -> Dict[str, Any]:
        """Fallback cosine similarity comparison"""
        try:
            # Handle dimension mismatch
            known = np.array(known_encoding)
            unknown = np.array(unknown_encoding)
            
            if len(known) != len(unknown):
                target_dim = max(len(known), len(unknown))
                if len(known) < target_dim:
                    known = np.pad(known, (0, target_dim - len(known)), 'constant')
                else:
                    known = known[:target_dim]
                    
                if len(unknown) < target_dim:
                    unknown = np.pad(unknown, (0, target_dim - len(unknown)), 'constant')
                else:
                    unknown = unknown[:target_dim]
            
            # Manual cosine similarity to avoid sklearn dependency issues
            dot_product = np.dot(known, unknown)
            norm_known = np.linalg.norm(known)
            norm_unknown = np.linalg.norm(unknown)
            
            if norm_known == 0 or norm_unknown == 0:
                similarity = 0
            else:
                similarity = dot_product / (norm_known * norm_unknown)
            
            distance = 1 - similarity
            confidence = max(0, similarity)
            
            # Adjust threshold for OpenCV features
            threshold = 0.3 if USE_FACE_RECOGNITION else 0.7
            match = confidence >= threshold
            
            return {
                "match": match,
                "confidence": float(confidence),
                "distance": float(distance)
            }
            
        except Exception as e:
            print(f"Error in cosine similarity comparison: {e}")
            return {
                "match": False,
                "confidence": 0.0,
                "distance": 1.0
            }
    
    def authenticate_face(self, probe_image: str, known_encodings: List[Dict[str, Any]]) -> Dict[str, Any]:
        """
        Authenticate a face against multiple known encodings
        Returns authentication result with best match
        """
        try:
            # Encode the probe image
            probe_encoding = self.encode_face(probe_image)
            if probe_encoding is None:
                return {
                    "success": False,
                    "error": "No face detected in probe image"
                }
            
            if not known_encodings:
                return {
                    "success": False,
                    "error": "No known faces to compare against"
                }
            
            best_match = None
            best_confidence = 0.0
            
            print(f"Comparing against {len(known_encodings)} known faces")
            
            # Compare against all known faces
            for i, known_face in enumerate(known_encodings):
                if 'encoding' not in known_face or 'user_id' not in known_face:
                    continue
                
                try:
                    comparison = self.compare_faces(known_face['encoding'], probe_encoding)
                    print(f"User {known_face['user_id']}: confidence={comparison['confidence']:.3f}, match={comparison['match']}")
                    
                    if comparison['match'] and comparison['confidence'] > best_confidence:
                        best_match = {
                            "user_id": known_face['user_id'],
                            "confidence": comparison['confidence'],
                            "distance": comparison['distance']
                        }
                        best_confidence = comparison['confidence']
                except Exception as e:
                    print(f"Error comparing with user {known_face.get('user_id', 'unknown')}: {e}")
                    continue
            
            if best_match:
                print(f"Best match: User {best_match['user_id']} with confidence {best_match['confidence']:.3f}")
                return {
                    "success": True,
                    "authenticated": True,
                    "user_id": best_match['user_id'],
                    "confidence": best_match['confidence'],
                    "distance": best_match['distance']
                }
            else:
                print("No matching face found")
                return {
                    "success": True,
                    "authenticated": False,
                    "error": "No matching face found"
                }
                
        except Exception as e:
            print(f"Error in face authentication: {e}")
            return {
                "success": False,
                "error": f"Authentication failed: {str(e)}"
            }