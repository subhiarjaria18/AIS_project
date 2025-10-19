# AIS Data NLP Query Prototype

<div align="center">

**Natural Language Processing for Vessel Movement Analysis**

[![Python 3.8+](https://img.shields.io/badge/Python-3.8+-blue.svg)](https://www.python.org/downloads/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

[About](#about) • [Installation](#installation) • [Usage](#usage) • [Examples](#examples) • [How It Works](#how-it-works)

</div>

---

## About

This project implements a **Natural Language Processing (NLP) system** that interprets user queries about vessel movements from the Automatic Identification System (AIS) dataset and returns analytical or predictive outputs.

The system accepts plain English queries like:
- "Show the last known position of INS Kolkata"
- "Predict where MSC Flaminia will be after 30 minutes"
- "Check if the latest position of Ever Given is consistent with its past movement"

And returns structured responses with vessel positions, predictions, and behavioral analysis.

---

## Installation

### Prerequisites
- Python 3.8+
- pip

### Setup

```bash
# Clone the repository
git clone https://github.com/subhiarjaria18/AIS_project.git
cd AIS_project

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Download spaCy model
python -m spacy download en_core_web_sm
```

### Requirements
- pandas
- numpy
- spacy
- rapidfuzz
- geopy
- folium
- matplotlib

---

## Usage

### Quick Start

```python
from ais_nlp_intent import parse_query_with_dataset_names, handle_predict, get_latest_position
import pandas as pd

# Load AIS data
df = pd.read_csv("data/AIS_2020_01_01.csv")
df['VesselName'] = df['VesselName'].astype(str).str.strip().str.upper()
df['BaseDateTime'] = pd.to_datetime(df['BaseDateTime'])

# Parse query
query = "Predict where RAINBOW will be after 30 minutes"
parsed = parse_query_with_dataset_names(query)

print(f"Intent: {parsed['intent']}")
print(f"Vessel: {parsed['vessel_name']}")
print(f"Time Horizon: {parsed['time_horizon_mins']} minutes")

# Process query
if parsed["vessel_name"]:
    if parsed["intent"] == "show":
        result = get_latest_position(df, parsed["vessel_name"])
    elif parsed["intent"] == "predict":
        result = handle_predict(df, parsed["vessel_name"], parsed["time_horizon_mins"] or 30)
```

### Running the Notebook

```bash
jupyter notebook ais_nlp_intent.ipynb
```

---

## Examples

### Example 1: Show Position
```
Query: "Where is Titan right now?"

Output:
Intent: show
Vessel: TITAN
Position: 41.64°N, -70.91°E
Speed: 7.1 knots
```

### Example 2: Predict Position
```
Query: "Predict where RAINBOW will be after 30 minutes"

Output:
Intent: predict
Vessel: RAINBOW
Current Position: 41.64°N, -70.91°E
Predicted Position: 41.70°N, -70.85°E (after 30 min)
```

### Example 3: Verify Movement
```
Query: "Check if Ever Given's movement is consistent"

Output:
Intent: verify
Vessel: EVER LUCID (fuzzy matched)
Status: CONSISTENT
Speeds: 1.2-3.4 knots (normal range)
Heading changes: 5-8° (smooth turns)
```

---

## How It Works

### 1. NLP Query Parsing

The system uses multi-layered extraction:

**Intent Detection** (Keyword-based)
- "predict", "forecast" → PREDICT
- "show", "where" → SHOW
- "check", "verify", "consistent" → VERIFY

**Vessel Name Extraction** (Multi-tier)
1. spaCy NER - Named entity recognition
2. Fuzzy matching (RapidFuzz) - Handles typos and abbreviations
3. Regex patterns - Quoted strings and special cases

Example: "Ever-Given" → fuzzy matched to "EVER LUCID" (95% confidence)

**Time Extraction** (Regex-based)
- "30 minutes" → 30 mins
- "1 hour" → 60 mins

### 2. Intent-Specific Processing

| Intent | Operation | Output |
|--------|-----------|--------|
| **SHOW** | Query latest AIS record | lat, lon, speed, course, time |
| **PREDICT** | Apply great-circle distance formula | future lat/lon at T+X minutes |
| **VERIFY** | Analyze last 3 points for anomalies | consistency status + flags |

### 3. Position Prediction

Uses **Haversine great-circle distance** formula for accuracy:

```python
def predict_position(lat, lon, sog_knots, cog_deg, minutes):
    speed_km_min = sog_knots * 1.852 / 60.0
    distance_km = speed_km_min * minutes
    
    # Great-circle calculation
    lat2 = asin(sin(lat1)*cos(distance/R) + cos(lat1)*sin(distance/R)*cos(bearing))
    lon2 = lon1 + atan2(sin(bearing)*sin(distance/R)*cos(lat1), ...)
    
    return lat2, lon2
```

Accounts for Earth's curvature. Valid for 30-60 minute horizons assuming constant speed/course.

### 4. Anomaly Detection

Flags inconsistent movement if:
- Speed > 50 knots (unrealistic for commercial vessels)
- Heading change > 90° between consecutive points (indicates error or emergency maneuver)
- Based on last 3 AIS records

---

## Project Structure

```
AIS_project/
├── ais_nlp_intent.ipynb       # Main implementation & examples
├── requirements.txt            # Dependencies
├── README.md                   # This file
├── data/
│   └── AIS_2020_01_01.csv     # Sample AIS dataset
└── vessel_map.html            # Output map visualization
```

---

## API Reference

### `parse_query_with_dataset_names(query: str) → dict`
Extracts intent, vessel name, and time horizon from query.

**Returns:**
```python
{
    "intent": "show" | "predict" | "verify" | "unknown",
    "vessel_name": str or None,
    "time_horizon_mins": int or None,
    "vessel_match_score": int (0-100),
    "candidates": [str]
}
```

### `get_latest_position(df, vessel_name) → dict`
Retrieves most recent position record.

**Returns:** `{"lat": float, "lon": float, "sog": float, "cog": float, "time": datetime}`

### `predict_position(lat, lon, sog_knots, cog_deg, minutes) → tuple`
Predicts position after time interval.

**Returns:** `(predicted_lat, predicted_lon)`

### `handle_verify(df, vessel_name) → dict`
Analyzes movement consistency.

**Returns:** `{"status": "consistent" | "inconsistent", "speeds": [float], "turns": [float]}`

---

## Key Design Decisions

### Why Rule-Based NLP + Fuzzy Matching?

**Advantages:**
- Fast inference (<50ms per query)
- Interpretable (easy to debug)
- No GPU required
- No heavy LLM dependency

**Trade-offs:**
- Limited semantic understanding
- Requires manual threshold tuning
- Works best with structured queries

### Why Great-Circle Distance?

- Accounts for Earth's curvature
- Standard in maritime navigation
- More accurate than flat-earth approximation
- Error margin <0.1% for typical voyages

### Why Last 3 Points for Anomaly Detection?

- Captures immediate behavioral shifts
- Computationally efficient
- Balances sensitivity vs. false positives

---

## Limitations

- Single-vessel queries only (no multi-vessel comparison)
- Assumes constant speed/course (valid for ~30-60 min predictions)
- Hardcoded anomaly thresholds (not ML-calibrated)
- Requires exact vessel name in dataset (fuzzy matching helps but not guaranteed)

---

## Dataset

**Source:** NOAA AIS data - https://coast.noaa.gov/htdata/CMSP/AISDataHandler/2020/index.html

**Key Columns:**
- MMSI: Maritime identifier
- BaseDateTime: UTC timestamp
- LAT, LON: Position
- SOG: Speed over ground (knots)
- COG: Course over ground (degrees)
- VesselName: Vessel identifier
- Status: Navigation status

---

## Testing

Test cases included in notebook cover:
- Exact vessel name matching
- Fuzzy matching with typos
- Multi-word vessel names
- Time extraction (hours/minutes)
- Intent classification
- Great-circle distance calculations
- Anomaly detection edge cases

```bash
# Run notebook for interactive testing
jupyter notebook ais_nlp_intent.ipynb
```

---

## Author

[Subhi Arjaria](https://github.com/subhiarjaria18)

---

## License

MIT License - see LICENSE file for details

---

## References

- **NLP Framework:** [spaCy](https://spacy.io)
- **Fuzzy Matching:** [RapidFuzz](https://github.com/maxbachmann/RapidFuzz)
- **Geospatial:** [GeoPy](https://geopy.readthedocs.io/)
- **AIS Data:** [NOAA](https://coast.noaa.gov/)
