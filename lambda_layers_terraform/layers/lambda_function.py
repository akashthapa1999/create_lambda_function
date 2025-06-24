import json
import requests
import numpy as np

def lambda_handler(event, context):
    # Example: Using requests library
    response = requests.get("https://api.github.com")
    
    # Example: Using numpy library
    array = np.array([1, 2, 3])
    squared = array ** 2
    
    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Lambda using Layers executed successfully!",
            "github_status": response.status_code,
            "squared_numbers": squared.tolist()
        })
    }
