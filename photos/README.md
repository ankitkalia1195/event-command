# Photos Directory

This directory is used for batch processing face photos for user authentication.

## How to Use

1. **Add photos to this directory** with filenames matching user email addresses
2. **Supported formats**: .jpg, .jpeg, .png, .gif, .bmp, .tiff, .webp
3. **Run the processing command**: `rails face:process_photos`

## Example

```
photos/
├── john.doe@company.com.jpg
├── jane.smith@company.com.png
├── admin@company.com.jpeg
└── README.md
```

## Commands

```bash
# Process all photos in this directory
rails face:process_photos

# List users with face encodings
rails face:list_encodings

# Test face authentication
rails face:test_auth
```

## Notes

- Photos should be clear, well-lit face photos
- Avoid photos with multiple people
- Face should be clearly visible and centered
- Recommended size: at least 200x200 pixels
