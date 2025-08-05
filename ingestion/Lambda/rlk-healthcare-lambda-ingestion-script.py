import json
import boto3
from boto3.dynamodb.conditions import Key
import os
from datetime import datetime
import gdown

# Setup
dynamodb = boto3.resource('dynamodb')
s3 = boto3.client('s3')

# Redirect the standard gdown cache folder to /tmp
os.environ["GDOWN_CACHE_DIR"] = "/tmp/gdown"

DYNAMO_TABLE = os.environ['DYNAMO_TABLE']
S3_BUCKET = os.environ['S3_BUCKET']
S3_PREFIX = os.environ.get('S3_PREFIX', 'bronze/')

# Function to download a file using gdown
def download_file_from_gdrive(file_id, output_name):
    try:
        os.makedirs("/tmp/gdown", exist_ok=True)
        gdown.cache_dir = "/tmp/gdown"  # Explicit override
        url = f"https://drive.google.com/uc?id={file_id}"
        gdown.download(url, output_name, quiet=False, use_cookies=False) # disable cookies
        return True
    except Exception as e:
        print(f"Error downloading file '{output_name}': {e}")
        return False

def update_dynamodb(table, file_name, timestamp):
    try:
        table.put_item(Item={
            'filename': file_name,
            'timestamp': timestamp,
            'status': 'uploaded'
        })
        print(f"File '{file_name}' status updated in DynamoDB.")
        
    except Exception as e:
        print(f"Error updating DynamoDB: {e}")

def lambda_handler(event, context):
    files_to_check = [
        {"id": "1sQh2zP1Yowi7wVlhSjJUPlTNQaSsh1vM", "name": "FY_2024_SNF_VBP_Aggregate_Performance.csv"},
        {"id": "1KJbBI7wNU163cOCaeLz2Iu_hyPPcOkSw", "name": "FY_2024_SNF_VBP_Facility_Performance.csv"},
        {"id": "1blwumBQa4kgX4UqAo0nY0S1eESqFNGNF", "name": "NH_CitationDescriptions_Oct2024.csv"},
        {"id": "1QEPlAxIVMDqliOM2YxuAIFqXZJBptf9e", "name": "NH_CovidVaxAverages_20241027.csv"},
        {"id": "1Azs8_9yP2ioY3Bv1M4HYuXotEpqd561u", "name": "NH_CovidVaxProvider_20241027.csv"},
        {"id": "1rJOayIyLak0y9H8eWuTT2OqyJE68hqjp", "name": "NH_DataCollectionIntervals_Oct2024.csv"},
        {"id": "14Q2I7CtABLUVFeppbDYa6XRVEMQ-R_jv", "name": "NH_FireSafetyCitations_Oct2024.csv"},
        {"id": "1e4TeLCwzysxPa7Tiyo9eMSTHNSo-WEqH", "name": "NH_HealthCitations_Oct2024.csv"},
        {"id": "1h4YvjQedYTfGWzeZSy5F900dv8GU0Tpt", "name": "NH_HlthInspecCutpointsState_Oct2024.csv"},
        {"id": "1yd1JP6VLLcTmmBcdQc5gRzP6gzHUBRni", "name": "NH_Ownership_Oct2024.csv"},
        {"id": "1Sg41xoG-NIN49m5MAZX65voXOSdFoG87", "name": "NH_Penalties_Oct2024.csv"},
        {"id": "16SGHRYFnUcOKBsJ2ke44mVo5bzsKSOiP", "name": "NH_ProviderInfo_Oct2024.csv"},
        {"id": "1rWUhpQURulQ51JWHwIrKmDj02U04BGk5", "name": "NH_QualityMsr_Claims_Oct2024.csv"},
        {"id": "109tqn9NQqUKLL94I7r-L8D9JtxOyPtKi", "name": "NH_QualityMsr_MDS_Oct2024.csv"},
        {"id": "1fOTocxIKSTCiTxHke-ovP0wtoUMO4sgV", "name": "NH_StateUSAverages_Oct2024.csv"},
        {"id": "1y_sMYElanANOdUD30ioOWTTGcQXwDNl9", "name": "NH_SurveyDates_Oct2024.csv"},
        {"id": "1M9N0i4YYwPJ7POsD453N0Gi2A6kpdke1", "name": "NH_SurveySummary_Oct2024.csv"},
        {"id": "1FodVUQDrGoX_yGkjVziIGtXDI3ldWDsu", "name": "PBJ_Daily_Nurse_Staffing_Q2_2024.csv"},
        {"id": "1kGDezdFNCTRP7LhAq3NFJnUSahLHGiJq", "name": "Skilled_Nursing_Facility_Quality_Reporting_Program_National_Data_Oct2024.csv"},
        {"id": "1Fv0GlY-w9k4OuMsf7jQPhz0daiGkPqPR", "name": "Skilled_Nursing_Facility_Quality_Reporting_Program_Provider_Data_Oct2024.csv"},
        {"id": "1zIlouwBdGc-anE6BmQ0sI1M-yftSQxfq", "name": "Swing_Bed_SNF_data_Oct2024.csv"}
    ]

    table = dynamodb.Table(DYNAMO_TABLE)
    timestamp = datetime.utcnow().strftime('%Y%m%d%H%M%S')

    try:
        for file in files_to_check:
            file_id = file["id"]
            file_name = file["name"]
            s3_key = f"{S3_PREFIX}{timestamp}_{file_name}"

            # Check if file already exists in DynamoDB
            try:
                result = table.query(
                    KeyConditionExpression=Key('filename').eq(file_name)
                )
                if result.get('Items'):
                    print(f"File '{file_name}' already ingested. Skipping...")
                    continue
            except Exception as e:
                print(f"Error checking DynamoDB: {e}")
                continue
            

            # Download file
            if download_file_from_gdrive(file_id, f"/tmp/{file_name}"):
                # Upload file to S3
                try:
                    s3.upload_file(f"/tmp/{file_name}", S3_BUCKET, s3_key)
                    print(f"File '{file_name}' uploaded to S3 successfully.")
                    update_dynamodb(table, file_name, timestamp)
                    os.remove(f"/tmp/{file_name}")

                except Exception as e:
                    print(f"Error uploading file '{file_name}' to S3: {e}")
                    continue

            # # Update DynamoDB
            # try:
            #     table.put_item(Item={
            #         'filename': file_name,
            #         'timestamp': timestamp,
            #         'status': 'uploaded'
            #     })
            #     print(f"File '{file_name}' status updated in DynamoDB.")
            # except Exception as e:
            #     print(f"Error updating DynamoDB: {e}")
            #     continue
    except Exception as e:
        print(f"Error processing files: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps('Error processing files')
        }

        

