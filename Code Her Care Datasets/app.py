from flask import Flask, jsonify
import pandas as pd

app = Flask(__name__)

# Load the excel file at startup
df = pd.read_excel("Code Her Care Datasets\Treatment Costs Sheet.xlsx")

# for fast lookups:
unique_facilities = df['Facility'].unique().tolist()

@app.route('/hospitals', methods=['GET'])
def list_facilities():
    """
    List all facilities with price data
    """
    return jsonify(unique_facilities)

@app.route('/hospital/<facility>', methods=['GET'])
def facility_prices(facility):
    """
    Get all services and prices for a specific facility
    """
    # case-insensitive match
    facility_df = df[df['Facility'].str.lower() == facility.lower()]
    if facility_df.empty:
        return jsonify({"error": "Facility not found"}), 404
    
    services = []
    for _, row in facility_df.iterrows():
        services.append({
            "service": row['Service'],
            "category": row['Category'],
            "base_cost": row['Base Cost (KES)'],
            "nhif": row['NHIF Covered'],
            "copay": row['Insurance Copay (KES)'],
            "out_of_pocket": row['Out-of-Pocket (KES)'],
        })
    
    return jsonify({
        "facility": facility,
        "region": facility_df.iloc[0]['Region'],
        "services": services
    })

@app.route('/search/<region>', methods=['GET'])
def search_by_region(region):
    """
    Search hospitals by region
    """
    regional = df[df['Region'].str.lower() == region.lower()]['Facility'].unique().tolist()
    return jsonify(regional)

if __name__ == "__main__":
    app.run(debug=True)
