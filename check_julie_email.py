#!/usr/bin/env python3
"""Quick script to check Gmail for unread emails from Julie using gog/gws credentials."""

import json
import os
import sys

# Use the gws credentials which has a refresh token
creds_file = '/home/dain/.config/gws/credentials.json'

if not os.path.exists(creds_file):
    print("NO_TOKEN: No stored credentials found.")
    sys.exit(1)

from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
import google.auth.transport.requests

with open(creds_file) as f:
    creds_data = json.load(f)

creds = Credentials(
    None,  # No access token initially
    refresh_token=creds_data['refresh_token'],
    token_uri=creds_data.get('token_uri', 'https://oauth2.googleapis.com/token'),
    client_id=creds_data['client_id'],
    client_secret=creds_data['client_secret'],
    scopes=['https://www.googleapis.com/auth/gmail.modify']
)

# Refresh the token
request = google.auth.transport.requests.Request()
creds.refresh(request)

service = build('gmail', 'v1', credentials=creds)

# Search for unread emails from Julie in last hour
results = service.users().messages().list(
    userId='me',
    q='from:julie.a.siegel84@gmail.com is:unread newer_than:1h'
).execute()

messages = results.get('messages', [])
if not messages:
    print("NO_EMAILS")
    sys.exit(0)

print(f"FOUND:{len(messages)}")
for msg in messages[:5]:
    m = service.users().messages().get(userId='me', id=msg['id'], format='full').execute()
    headers = {h['name']: h['value'] for h in m['payload']['headers']}
    subject = headers.get('Subject', 'No subject')
    from_addr = headers.get('From', '')
    # Get body snippet
    snippet = m.get('snippet', '')
    print(f"ID:{msg['id']}|SUBJ:{subject}|FROM:{from_addr}|SNIP:{snippet[:200]}")
