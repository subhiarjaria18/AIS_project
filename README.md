
# 🚢 Vessel Movement NLP Prototype

## Introduction
This project is a hands-on demonstration of how Natural Language Processing (NLP) can be used to interact with maritime data. It lets you ask questions about vessel movements in plain English and get analytical or predictive answers using real AIS (Automatic Identification System) data.

**Example queries:**
- "Show the last known position of INS Kolkata."
- "Predict where MSC Flaminia will be after 30 minutes."
- "Check if the latest position of Ever Given is consistent with its past movement."

## What Does It Do?
1. **Understands your query:** Uses spaCy and keyword mapping to extract the intent (show, predict, verify), vessel name (with fuzzy matching), and time horizon (if present).
2. **Processes AIS data:** Reads vessel movement data from a CSV file and analyzes it according to your query.
3. **Returns answers and visualizations:** Provides clear text answers and optional maps/plots for deeper insight.

## Features
- **NLP Query Parsing:** Lightweight spaCy-based logic to extract intent, vessel name, and time horizon from natural language.
- **Data Analysis:**
  - *Show*: Returns the latest known position (latitude/longitude) for a vessel.
  - *Predict*: Estimates the vessel's future position after X minutes, assuming constant speed and course.
  - *Verify*: Checks if the vessel's recent movement is smooth and realistic (no sudden jumps or sharp turns).
- **Visualizations:**
  - Interactive vessel track map (Folium)
  - Track and speed profile plots (Matplotlib)

## Project Structure
- `ais_nlp_intent.ipynb` — Main notebook with all code and visualizations
- `data/AIS_2020_01_01.csv` — AIS dataset (vessel movement records)
- `requirements.txt` — Python dependencies
- `setup_env.ps1` — PowerShell script for easy environment setup
- `vessel_map.html` — Example output map

## Getting Started
### 1. Environment Setup
Run the setup script to create a virtual environment, install dependencies, and download the spaCy model:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
./setup_env.ps1 -PythonExe "C:\Users\HP\AppData\Local\Programs\Python\Python312\python.exe"
```

### 2. Open the Notebook
Open `ais_nlp_intent.ipynb` in VS Code. Select the kernel named `Python (nlp-assignment)`.

### 3. Run and Explore
Step through the notebook cells:
- Load the AIS data
- Enter your natural language query
- View the parsed intent, vessel name, and time horizon
- See the analytical or predictive output
- Explore visualizations (track map, speed profile)

## Example Workflow
1. **Query:** `Predict where RAINBOW will be after 30 minutes.`
2. **NLP Output:**
   - Intent: predict
   - Vessel: RAINBOW
   - Time horizon: 30 minutes
3. **Result:**
   - `Predicted position of RAINBOW after 30 minutes: 12.92N, 80.55E.`
4. **Visualization:**
   - Track map and speed profile plot for RAINBOW

## Requirements
- Python 3.9+
- See `requirements.txt` for all required packages
- Windows PowerShell (for setup script)

## Troubleshooting & Tips
- If you get errors about missing packages, re-run the setup script.
- Make sure your CSV path is correct: `data/AIS_2020_01_01.csv`
- For best results, use VS Code with the recommended kernel.

## Extending the Project
- Swap in new AIS datasets for other regions or dates
- Add more NLP intents or query types
- Integrate with web dashboards or APIs

## License & Credits
This project is for educational and prototyping purposes. AIS data and code are provided as-is for experimentation.
