from __future__ import print_function
import os
import pandas as pd
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
import pickle

# If modifying these SCOPES, delete the token.pickle or token.json file.
SCOPES = ['https://www.googleapis.com/auth/drive.metadata.readonly']

def authenticate_drive_api():
    creds = None
    # Load token from previous session if available
    if os.path.exists('token.json'):
        from google.oauth2.credentials import Credentials
        creds = Credentials.from_authorized_user_file('token.json', SCOPES)
    # If no valid token is found, run the OAuth flow
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file('credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)
        # Save the credentials
        with open('token.json', 'w') as token:
            token.write(creds.to_json())
    return build('drive', 'v3', credentials=creds)

def generate_manifest(service):
    print("Fetching CSV files from Google Drive...")

    folder_id = "1x2FPUKYBmK9Dov_Had5LOi9AipOuqyX3"  # rawdata folder

    # results = service.files().list(
    #     q="mimeType='text/csv'",
    #     pageSize=1000,
    #     fields="files(id, name, modifiedTime)").execute()
    # items = results.get('files', [])

    results = service.files().list(
        q=f"'{folder_id}' in parents and mimeType='text/csv'",
        fields="files(id, name, modifiedTime)",
        pageSize=1000
    ).execute()
    items = results.get('files', [])

    if not items:
        print('No CSV files found.')
        return

    # Create a manifest DataFrame
    manifest = pd.DataFrame([{
        'filename': item['name'],
        'file_id': item['id'],
        'modified_time': item['modifiedTime']
    } for item in items])

    # Sort by filename or timestamp as needed
    manifest = manifest.sort_values(by='filename')

    # Save to CSV
    manifest.to_csv('file_manifest.csv', index=False)
    print("✅ Manifest saved to file_manifest.csv")

def main():
    service = authenticate_drive_api()
    generate_manifest(service)

if __name__ == '__main__':
    main()

