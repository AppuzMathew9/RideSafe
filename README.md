🚲 RideSafe: Helmet Detection and Traffic Violation Recognition System \n
📘 Overview
RideSafe is a computer vision-based system designed to enhance road safety by identifying whether motorbike riders are wearing helmets and detecting traffic signal violations in real-time. Leveraging YOLOv8 for object detection and DeepSORT for tracking, RideSafe offers a practical solution for monitoring road rule compliance in urban environments.

📁 Project Structure
bash
Copy
Edit
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
🚀 Features
🪖 Helmet Detection: Detects riders without helmets on two-wheelers.

🚦 Traffic Signal Violation Detection: Recognizes vehicles violating red lights.

📍 Vehicle Tracking: Uses DeepSORT for tracking individual riders across frames.

🎥 Video Input/Output: Processes input video streams and exports annotated results.

🛠 Installation
Clone the repository:

bash
Copy
Edit
git clone https://github.com/yourusername/RideSafe.git
cd RideSafe
Create a virtual environment (optional but recommended):

bash
Copy
Edit
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
Install dependencies:

bash
Copy
Edit
pip install -r requirements.txt
Download the YOLOv8 model weights and place them in model/.

📸 Usage
To run the system on a video:

bash
Copy
Edit
python helmet_violation.py --input test_videos/sample_footage.mp4 --output results/output_demo.mp4
Parameters:

--input: Path to input video file.

--output: Path to save the processed video.

🧠 Model Details
Object Detection: YOLOv8 (custom trained on helmet/no-helmet classes).

Tracking: DeepSORT for multi-object tracking across frames.

Violation Detection: Uses traffic signal recognition and ROI logic.

📊 Results
RideSafe achieved promising results on various real-world traffic footage, detecting violations with high accuracy and minimal false positives.

📌 Future Improvements
Integrate license plate recognition (ANPR).

Extend detection to other types of violations.

Add real-time alerting and dashboard interface.

📄 License
This project is licensed under the MIT License.
