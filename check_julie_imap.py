#!/usr/bin/env python3
"""Check Gmail via IMAP for unread emails from Julie."""
import imaplib
import email
import os
import sys
from datetime import datetime, timedelta

# App password approach - check if we have stored credentials
creds_file = '/home/dain/.openclaw/workspace/.gmail_app_password'

if not os.path.exists(creds_file):
    print("NO_CREDS: No Gmail app password found at .gmail_app_password")
    sys.exit(1)

with open(creds_file) as f:
    lines = f.read().strip().split('\n')
    if len(lines) >= 2:
        username = lines[0].strip()
        password = lines[1].strip()
    else:
        print("NO_CREDS: Invalid credentials file format")
        sys.exit(1)

try:
    mail = imaplib.IMAP4_SSL('imap.gmail.com')
    mail.login(username, password)
    mail.select('inbox')
    
    # Search for unread emails from Julie in last hour
    # IMAP doesn't have a "newer_than:1h" equivalent directly
    # We'll search for unread from address and filter by date
    status, messages = mail.search(None, 'UNSEEN FROM "julie.a.siegel84@gmail.com"')
    
    if status != 'OK' or not messages[0]:
        print("NO_EMAILS")
        mail.logout()
        sys.exit(0)
    
    msg_ids = messages[0].split()
    found = []
    cutoff = datetime.now() - timedelta(hours=1)
    
    for msg_id in msg_ids:
        status, msg_data = mail.fetch(msg_id, '(RFC822)')
        if status != 'OK':
            continue
        
        raw_email = msg_data[0][1]
        msg = email.message_from_bytes(raw_email)
        
        # Parse date
        date_str = msg.get('Date', '')
        try:
            msg_date = email.utils.parsedate_to_datetime(date_str)
            if msg_date.tzinfo is None:
                msg_date = msg_date.replace(tzinfo=cutoff.tzinfo)
        except:
            msg_date = datetime.now()
        
        if msg_date < cutoff:
            continue
        
        subject = msg.get('Subject', 'No subject')
        from_addr = msg.get('From', '')
        
        # Get body
        body = ""
        if msg.is_multipart():
            for part in msg.walk():
                content_type = part.get_content_type()
                if content_type == 'text/plain':
                    try:
                        body = part.get_payload(decode=True).decode('utf-8', errors='ignore')
                        break
                    except:
                        pass
        else:
            try:
                body = msg.get_payload(decode=True).decode('utf-8', errors='ignore')
            except:
                body = msg.get_payload() or ""
        
        found.append({
            'id': msg_id.decode(),
            'subject': subject,
            'from': from_addr,
            'body_preview': body[:300].replace('\n', ' '),
            'date': date_str
        })
    
    mail.logout()
    
    if not found:
        print("NO_EMAILS")
        sys.exit(0)
    
    print(f"FOUND:{len(found)}")
    for msg in found:
        print(f"ID:{msg['id']}|SUBJ:{msg['subject']}|FROM:{msg['from']}|SNIP:{msg['body_preview']}")

except Exception as e:
    print(f"ERROR:{e}")
    sys.exit(1)
