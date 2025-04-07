

```markdown
# 🚲 RideSafe: Helmet Detection and Traffic Violation Recognition System 

## 📘 Overview

RideSafe is a computer vision-based system designed to enhance road safety by identifying whether motorbike riders are wearing helmets and detecting traffic signal violations in real-time. Leveraging advanced deep learning models, RideSafe aims to improve traffic compliance and reduce accidents.

## 📁 Project Structure

```
RideSafe/

│

├── yolov8_helmet_violation/

│   ├── helmet_violation.py         # Core detection and tracking logic

│   ├── video_processing.py         # Video stream handling

│   ├── utils/

│   │   └── draw_utils.py           # Drawing bounding boxes and labels

│   ├── model/

│   │   └── best.pt                 # Trained YOLOv8 model

│   └── ...

│

├── test_videos/

│   └── sample_footage.mp4          # Sample test video

│

├── results/

│   └── output_demo.mp4             # Output video with visualized results

│

├── requirements.txt                # Dependencies

└── README.md                       # Project documentation
```

## 🚀 Features

- 🪖 Helmet Detection: Detects riders without helmets on two-wheelers.
- 🚦 Traffic Signal Violation Detection: Recognizes vehicles violating red lights.
- 📍 Vehicle Tracking: Uses DeepSORT for tracking individual riders across frames.
- 🎥 Video Input/Output: Processes input video streams and exports annotated results.

## 🛠 Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/AppuzMathew9/RideSafe.git
    cd RideSafe
    ```
2. Create a virtual environment (optional but recommended):
    ```bash
    python -m venv venv
    source venv/bin/activate  # On Windows: venv\Scripts\activate
    ```
3. Install dependencies:
    ```bash
    pip install -r requirements.txt
    ```
4. Download the YOLOv8 model weights and place them in the `model/` directory.

## 📸 Usage

To run the system on a video:
```bash
python yolov8_helmet_violation/helmet_violation.py --input test_videos/sample_footage.mp4 --output results/output_demo.mp4
```
Parameters:
- `--input`: Path to input video file.
- `--output`: Path to save the processed video.

## 🧠 Model Details

- **Object Detection**: YOLOv8 (custom trained on helmet/no-helmet classes).
- **Tracking**: DeepSORT for multi-object tracking across frames.
- **Violation Detection**: Uses traffic signal recognition and ROI logic.

## 📊 Results

RideSafe achieved promising results on various real-world traffic footage, detecting violations with high accuracy and minimal false positives.

## 📌 Future Improvements

- Integrate license plate recognition (ANPR).
- Extend detection to other types of violations.
- Add real-time alerting and dashboard interface.

## 📄 License

This project is licensed under the MIT License.
```

Feel free to further customize this README file according to your project's specific needs and details!
