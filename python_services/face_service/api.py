from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import base64, io, os
from typing import Optional, List, Dict, Any
from PIL import Image
import numpy as np
import cv2
from .face_service import FaceService

app = FastAPI(title="Face Service Template")

# Initialize services
face_service = FaceService()

# Initialize Haar cascade once
HAAR_PATH = os.path.join(cv2.data.haarcascades, "haarcascade_frontalface_default.xml")
CASCADE = cv2.CascadeClassifier(HAAR_PATH)
if CASCADE.empty():
    raise RuntimeError(f"Failed to load Haar cascade at {HAAR_PATH}")

class EncodeRequest(BaseModel):
    image_base64: str

class EncodeResponse(BaseModel):
    success: bool
    encoding: Optional[List[float]] = None
    error: Optional[str] = None

class AuthenticateRequest(BaseModel):
    image_base64: str
    known_encodings: List[Dict[str, Any]]  # List of {user_id: int, encoding: List[float]}

class AuthenticateResponse(BaseModel):
    success: bool
    authenticated: bool
    user_id: Optional[int] = None
    confidence: Optional[float] = None
    distance: Optional[float] = None
    error: Optional[str] = None

class DetectRequest(BaseModel):
    image_base64: str
    return_crops: bool = False

class FaceBox(BaseModel):
    x: int
    y: int
    w: int
    h: int

class DetectResponse(BaseModel):
    success: bool
    count: int
    faces: List[FaceBox]
    crops: Optional[List[str]] = None
    error: Optional[str] = None

@app.get("/health")
async def health():
    return {"status": "ok"}

@app.post("/encode", response_model=EncodeResponse)
async def encode_face(req: EncodeRequest):
    """Generate face encoding from base64 image"""
    try:
        encoding = face_service.encode_face(req.image_base64)
        if encoding is None:
            return EncodeResponse(success=False, error="No face detected in image")
        return EncodeResponse(success=True, encoding=encoding)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.post("/authenticate", response_model=AuthenticateResponse)
async def authenticate_face(req: AuthenticateRequest):
    """Authenticate a face against known encodings"""
    try:
        print("coming here with known encodings:", len(req.known_encodings)) 
        result = face_service.authenticate_face(req.image_base64, req.known_encodings)
        
        if not result["success"]:
            return AuthenticateResponse(success=False, authenticated=False, error=result.get("error"))
        
        return AuthenticateResponse(
            success=True,
            authenticated=result.get("authenticated", False),
            user_id=result.get("user_id"),
            confidence=result.get("confidence"),
            distance=result.get("distance"),
            error=result.get("error")
        )
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.post("/detect", response_model=DetectResponse)
async def detect_faces(req: DetectRequest):
    try:
        data = req.image_base64
        if data.startswith("data:"):
            data = data.split(",", 1)[1]
        img = Image.open(io.BytesIO(base64.b64decode(data))).convert("RGB")
        img_np = np.array(img)

        # OpenCV expects grayscale for Haar detection
        gray = cv2.cvtColor(img_np, cv2.COLOR_RGB2GRAY)
        faces = CASCADE.detectMultiScale(
            gray, scaleFactor=1.05, minNeighbors=2, minSize=(100, 100)
        )

        boxes: List[FaceBox] = []
        crops_b64: List[str] = []
        for (x, y, w, h) in faces:
            boxes.append(FaceBox(x=int(x), y=int(y), w=int(w), h=int(h)))
            if req.return_crops:
                crop = img_np[y:y+h, x:x+w]  # still RGB
                pil = Image.fromarray(crop)
                buf = io.BytesIO()
                pil.save(buf, format="JPEG", quality=90)
                b64 = base64.b64encode(buf.getvalue()).decode("utf-8")
                crops_b64.append(f"data:image/jpeg;base64,{b64}")

        return DetectResponse(
            success=True,
            count=len(boxes),
            faces=boxes,
            crops=crops_b64 if req.return_crops else None,
        )
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)
