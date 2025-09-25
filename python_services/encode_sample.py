#!/usr/bin/env python3
"""
Sample script to encode face images and store them in the database.
This script demonstrates how to use the face service to generate encodings.
"""

import requests
import base64
import json
import sys
from pathlib import Path

def encode_image_file(image_path, service_url="http://localhost:8001"):
    """
    Encode a face image file using the face service
    """
    try:
        # Read and encode image
        with open(image_path, 'rb') as f:
            image_data = base64.b64encode(f.read()).decode('utf-8')
        
        # Call the encoding service
        response = requests.post(
            f"{service_url}/encode",
            json={"image_base64": f"data:image/jpeg;base64,{image_data}"},
            headers={"Content-Type": "application/json"}
        )
        
        if response.status_code == 200:
            result = response.json()
            if result.get("success"):
                return result.get("encoding")
            else:
                print(f"Encoding failed: {result.get('error')}")
                return None
        else:
            print(f"HTTP Error: {response.status_code}")
            return None
            
    except Exception as e:
        print(f"Error encoding image: {e}")
        return None

def main():
    if len(sys.argv) != 2:
        print("Usage: python encode_sample.py <image_path>")
        print("Example: python encode_sample.py /path/to/face_photo.jpg")
        sys.exit(1)
    
    image_path = sys.argv[1]
    
    if not Path(image_path).exists():
        print(f"Image file not found: {image_path}")
        sys.exit(1)
    
    print(f"Encoding face from: {image_path}")
    encoding = encode_image_file(image_path)
    
    if encoding:
        print("✓ Face encoding successful!")
        print(f"Encoding length: {len(encoding)} dimensions")
        print("Sample encoding (first 10 values):", encoding[:10])
        
        # Save to file for manual database insertion
        output_file = "face_encoding.json"
        with open(output_file, 'w') as f:
            json.dump(encoding, f)
        print(f"Encoding saved to: {output_file}")
        
        print("\nTo add this to a user in Rails console:")
        print(f"user = User.find_by(email: 'user@company.com')")
        print(f"user.face_encoding_data = File.read('{output_file}')")
        print(f"user.save!")
    else:
        print("✗ Face encoding failed!")
        sys.exit(1)

if __name__ == "__main__":
    main()
