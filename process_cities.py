import json
from datetime import datetime

def process_cities():
    # Read the raw cities data
    with open('cities_raw.json', 'r', encoding='utf-8') as f:
        cities = json.load(f)
    
    # Process cities into our format
    processed_cities = []
    seen_cities = set()  # To avoid duplicates
    
    for city in cities:
        # Create a unique ID for the city
        city_id = f"{city['name']}_{city['country']}"
        
        # Skip if we've seen this city before
        if city_id in seen_cities:
            continue
        seen_cities.add(city_id)
        
        # Only include cities with coordinates
        if not city.get('lat') or not city.get('lng'):
            continue
            
        processed_city = {
            "id": city_id,
            "name": city['name'],
            "countryCode": city['country'],
            "coordinates": {
                "latitude": float(city['lat']),
                "longitude": float(city['lng'])
            },
            "population": None,  # This dataset doesn't include population
            "region": None  # This dataset doesn't include region
        }
        processed_cities.append(processed_city)
    
    # Create the final output structure
    output = {
        "metadata": {
            "version": "1.0",
            "lastUpdated": datetime.now().strftime("%Y-%m-%d"),
            "source": "Cities Database"
        },
        "cities": processed_cities
    }
    
    # Write the processed data
    with open('Stamps/Resources/cities.json', 'w', encoding='utf-8') as f:
        json.dump(output, f, ensure_ascii=False, indent=2)
    
    print(f"Processed {len(processed_cities)} cities")

if __name__ == '__main__':
    process_cities() 