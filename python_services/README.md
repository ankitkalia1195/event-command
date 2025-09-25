Python services

Setup
- Create virtual environment
  - python3 -m venv venv
  - source venv/bin/activate
- Install dependencies
  - pip install -r requirements.txt

Run FastAPI dev server (template)
- uvicorn face_service.api:app --reload --host 0.0.0.0 --port 8001

Structure
- face_service/
  - face_service.py  # example Haar cascade script
  - api.py           # FastAPI app (template to implement)
