# N8N Workflows
*Last exported: 2026-03-08 22:37*  
*Instance: https://n8n.dainbentley.com*

> To restore a workflow: go to n8n → Workflows → Import → paste the JSON file below.

---

## Notary Request Intake (Gemma Local)

| Field | Value |
|---|---|
| **ID** | `JbekZR8r1ebXe16n` |
| **Status** | 🟢 Active |
| **Backup file** | `notary_request_intake_gemma_local.json` |

**Nodes (6):**
  - `n8n-nodes-base.gmailTrigger` — **Gmail Trigger**
  - `n8n-nodes-base.httpRequest` — **Extract with Gemma**
  - `n8n-nodes-base.code` — **Parse AI Output**
  - `n8n-nodes-base.if` — **Is Notary Request?**
  - `n8n-nodes-base.httpRequest` — **Notify Dain**
  - `n8n-nodes-base.gmail` — **Auto-Reply to Client**

<details>
<summary>Full JSON config</summary>

```json
{
  "updatedAt": "2026-03-06T14:10:00.624Z",
  "createdAt": "2026-03-06T05:36:26.364Z",
  "id": "JbekZR8r1ebXe16n",
  "name": "Notary Request Intake (Gemma Local)",
  "description": null,
  "active": true,
  "isArchived": false,
  "nodes": [
    {
      "parameters": {
        "pollTimes": {
          "item": [
            {
              "mode": "everyMinute"
            }
          ]
        },
        "filters": {
          "q": "is:unread -from:me"
        }
      },
      "id": "trigger-gmail",
      "name": "Gmail Trigger",
      "type": "n8n-nodes-base.gmailTrigger",
      "typeVersion": 1,
      "position": [
        0,
        0
      ],
      "credentials": {
        "gmailOAuth2": {
          "id": "73FQ8r7lzSZjobXf",
          "name": "Gmail account"
        }
      }
    },
    {
      "parameters": {
        "method": "POST",
        "url": "http://192.168.200.240:11434/api/generate",
        "sendHeaders": true,
        "headerParameters": {
          "parameters": [
            {}
          ]
        },
        "sendBody": true,
        "contentType": "raw",
        "rawContentType": "application/json",
        "body": "={\n  \"model\": \"gemma3:12b\",\n  \"prompt\": \"You are a Notary Service Assistant. Your task is to analyze incoming emails and determine if they are requests for notary or loan signing services. CRITICAL RULE: If the email contains ANY mention of 'notary', 'notarize', 'loan signing', 'signing agent', 'closing', or 'documents to sign', you MUST set isNotaryRequest to true. Extract the following fields if available, otherwise use 'Not provided': - clientName, - serviceType, - preferredDateTime, - location, - phone. Return ONLY a valid JSON object with these keys: isNotaryRequest (boolean), clientName (string), serviceType (string), preferredDateTime (string), location (string), phone (string). Email Subject: {{ ($json.Subject || $json.subject || '').replace(/\"/g, '\\\\\"').replace(/\\n/g, ' ') }} Email Body: {{ ($json.textPlain || $json.snippet || '').replace(/\"/g, '\\\\\"').replace(/\\n/g, ' ') }}\",\n  \"format\": \"json\",\n  \"stream\": false\n}",
        "options": {}
      },
      "id": "gemini-extract",
      "name": "Extract with Gemma",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        224,
        0
      ]
    },
    {
      "parameters": {
        "jsCode": "try {\n  return $input.all().map((item) => {\n    const text = item.json.response;\n    const data = JSON.parse(text);\n    const triggerData = $('Gmail Trigger').all()[item.pairedItem.item].json;\n    const subject = (triggerData.Subject || triggerData.subject || '').toLowerCase();\n    const body = (triggerData.textPlain || triggerData.snippet || '').toLowerCase();\n    const keywords = ['notary', 'notarize', 'loan signing', 'signing agent', 'closing'];\n    if (!data.isNotaryRequest) {\n      if (keywords.some(k => subject.includes(k) || body.includes(k))) {\n        data.isNotaryRequest = true;\n      }\n    }\n    // Extract sender name from From field as fallback\n    const fromRaw = triggerData.From?.value || triggerData.From || triggerData.from?.value || triggerData.from || '';\n    const fromStr = typeof fromRaw === 'string' ? fromRaw : (fromRaw[0]?.name || fromRaw[0]?.address || '');\n    const nameMatch = fromStr.match(/^([^<]+)</  );\n    const senderName = nameMatch ? nameMatch[1].trim() : fromStr.split('@')[0];\n    if (!data.clientName || data.clientName === 'Not provided') {\n      data.clientName = senderName || 'Not provided';\n    }\n    data.originalSender = fromStr;\n    data.originalSubject = triggerData.Subject || triggerData.subject;\n    return { json: data };\n  });\n} catch (e) {\n  return [{ json: { isNotaryRequest: false, error: e.message } }];\n}"
      },
      "id": "parse-json",
      "name": "Parse AI Output",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        448,
        0
      ]
    },
    {
      "parameters": {
        "conditions": {
          "boolean": [
            {
              "value1": "={{ $json.isNotaryRequest }}",
              "value2": true
            }
          ]
        }
      },
      "id": "check-if-notary",
      "name": "Is Notary Request?",
      "type": "n8n-nodes-base.if",
      "typeVersion": 1,
      "position": [
        672,
        0
      ]
    },
    {
      "parameters": {
        "method": "POST",
        "url": "https://api.telegram.org/bot8544365014:AAEgKwHUF7_iG2AizJND2NuOUouPE4uQymQ/sendMessage",
        "sendBody": true,
        "contentType": "raw",
        "rawContentType": "application/json",
        "body": "={\"chat_id\":\"8305133249\",\"text\":\"\ud83d\udea8 *New Notary Request* \ud83d\udea8\\n\\n*Client:* {{ $json.clientName }}\\n*Service:* {{ $json.serviceType }}\\n*When:* {{ $json.preferredDateTime }}\\n*Where:* {{ $json.location }}\\n*Phone:* {{ $json.phone }}\\n\\n_Auto-reply has been sent._\",\"parse_mode\":\"Markdown\"}",
        "options": {}
      },
      "id": "notify-telegram",
      "name": "Notify Dain",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        912,
        -96
      ]
    },
    {
      "parameters": {
        "sendTo": "={{ $json.originalSender }}",
        "subject": "=Re: {{ $json.originalSubject }}",
        "message": "Hi {{ $json.clientName !== 'Not provided' ? $json.clientName : 'there' }},\n\nThank you for reaching out to Dain Bentley Management.\n\nI have received your request for notary services. I will review your details and get back to you shortly to confirm our appointment.\n\nBest regards,\n\nDain Bentley\nDain Bentley Management LLC",
        "options": {}
      },
      "id": "auto-reply",
      "name": "Auto-Reply to Client",
      "type": "n8n-nodes-base.gmail",
      "typeVersion": 2.1,
      "position": [
        912,
        112
      ],
      "webhookId": "199ebec3-ef73-4c7d-b903-1996aae3a633",
      "credentials": {
        "gmailOAuth2": {
          "id": "73FQ8r7lzSZjobXf",
          "name": "Gmail account"
        }
      }
    }
  ],
  "connections": {
    "Gmail Trigger": {
      "main": [
        [
          {
            "node": "Extract with Gemma",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Parse AI Output": {
      "main": [
        [
          {
            "node": "Is Notary Request?",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Is Notary Request?": {
      "main": [
        [
          {
            "node": "Notify Dain",
            "type": "main",
            "index": 0
          },
          {
            "node": "Auto-Reply to Client",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Extract with Gemma": {
      "main": [
        [
          {
            "node": "Parse AI Output",
            "type": "main",
            "index": 0
          }
        ]
      ]
    }
  },
  "settings": {
    "callerPolicy": "workflowsFromSameOwner",
    "availableInMCP": false
  },
  "staticData": {
    "node:Gmail Trigger": {
      "lastTimeChecked": 1772982174,
      "possibleDuplicates": [
        "19ccdf91075ff098",
        "19cc8ad703f98c56"
      ]
    }
  },
  "meta": {
    "templateCredsSetupCompleted": true
  },
  "pinData": {},
  "versionId": "7dd2d500-087e-4bd8-b253-786ca2780090",
  "activeVersionId": "7dd2d500-087e-4bd8-b253-786ca2780090",
  "versionCounter": 163,
  "triggerCount": 1,
  "shared": [
    {
      "updatedAt": "2026-03-06T05:36:26.364Z",
      "createdAt": "2026-03-06T05:36:26.364Z",
      "role": "workflow:owner",
      "workflowId": "JbekZR8r1ebXe16n",
      "projectId": "5DJBfZzzizP5frZB",
      "project": {
        "updatedAt": "2026-03-06T04:53:21.134Z",
        "createdAt": "2026-03-06T04:52:56.613Z",
        "id": "5DJBfZzzizP5frZB",
        "name": "DAIN BENTLEY <dain.bentley@gmail.com>",
        "type": "personal",
        "icon": null,
        "description": null,
        "creatorId": "c557a393-301d-4cd5-ada0-4ae8574f88c9"
      }
    }
  ],
  "tags": [],
  "activeVersion": {
    "updatedAt": "2026-03-06T14:10:00.630Z",
    "createdAt": "2026-03-06T14:10:00.630Z",
    "versionId": "7dd2d500-087e-4bd8-b253-786ca2780090",
    "workflowId": "JbekZR8r1ebXe16n",
    "nodes": [
      {
        "parameters": {
          "pollTimes": {
            "item": [
              {
                "mode": "everyMinute"
              }
            ]
          },
          "filters": {
            "q": "is:unread -from:me"
          }
        },
        "id": "trigger-gmail",
        "name": "Gmail Trigger",
        "type": "n8n-nodes-base.gmailTrigger",
        "typeVersion": 1,
        "position": [
          0,
          0
        ],
        "credentials": {
          "gmailOAuth2": {
            "id": "73FQ8r7lzSZjobXf",
            "name": "Gmail account"
          }
        }
      },
      {
        "parameters": {
          "method": "POST",
          "url": "http://192.168.200.240:11434/api/generate",
          "sendHeaders": true,
          "headerParameters": {
            "parameters": [
              {}
            ]
          },
          "sendBody": true,
          "contentType": "raw",
          "rawContentType": "application/json",
          "body": "={\n  \"model\": \"gemma3:12b\",\n  \"prompt\": \"You are a Notary Service Assistant. Your task is to analyze incoming emails and determine if they are requests for notary or loan signing services. CRITICAL RULE: If the email contains ANY mention of 'notary', 'notarize', 'loan signing', 'signing agent', 'closing', or 'documents to sign', you MUST set isNotaryRequest to true. Extract the following fields if available, otherwise use 'Not provided': - clientName, - serviceType, - preferredDateTime, - location, - phone. Return ONLY a valid JSON object with these keys: isNotaryRequest (boolean), clientName (string), serviceType (string), preferredDateTime (string), location (string), phone (string). Email Subject: {{ ($json.Subject || $json.subject || '').replace(/\"/g, '\\\\\"').replace(/\\n/g, ' ') }} Email Body: {{ ($json.textPlain || $json.snippet || '').replace(/\"/g, '\\\\\"').replace(/\\n/g, ' ') }}\",\n  \"format\": \"json\",\n  \"stream\": false\n}",
          "options": {}
        },
        "id": "gemini-extract",
        "name": "Extract with Gemma",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [
          224,
          0
        ]
      },
      {
        "parameters": {
          "jsCode": "try {\n  return $input.all().map((item) => {\n    const text = item.json.response;\n    const data = JSON.parse(text);\n    const triggerData = $('Gmail Trigger').all()[item.pairedItem.item].json;\n    const subject = (triggerData.Subject || triggerData.subject || '').toLowerCase();\n    const body = (triggerData.textPlain || triggerData.snippet || '').toLowerCase();\n    const keywords = ['notary', 'notarize', 'loan signing', 'signing agent', 'closing'];\n    if (!data.isNotaryRequest) {\n      if (keywords.some(k => subject.includes(k) || body.includes(k))) {\n        data.isNotaryRequest = true;\n      }\n    }\n    // Extract sender name from From field as fallback\n    const fromRaw = triggerData.From?.value || triggerData.From || triggerData.from?.value || triggerData.from || '';\n    const fromStr = typeof fromRaw === 'string' ? fromRaw : (fromRaw[0]?.name || fromRaw[0]?.address || '');\n    const nameMatch = fromStr.match(/^([^<]+)</  );\n    const senderName = nameMatch ? nameMatch[1].trim() : fromStr.split('@')[0];\n    if (!data.clientName || data.clientName === 'Not provided') {\n      data.clientName = senderName || 'Not provided';\n    }\n    data.originalSender = fromStr;\n    data.originalSubject = triggerData.Subject || triggerData.subject;\n    return { json: data };\n  });\n} catch (e) {\n  return [{ json: { isNotaryRequest: false, error: e.message } }];\n}"
        },
        "id": "parse-json",
        "name": "Parse AI Output",
        "type": "n8n-nodes-base.code",
        "typeVersion": 2,
        "position": [
          448,
          0
        ]
      },
      {
        "parameters": {
          "conditions": {
            "boolean": [
              {
                "value1": "={{ $json.isNotaryRequest }}",
                "value2": true
              }
            ]
          }
        },
        "id": "check-if-notary",
        "name": "Is Notary Request?",
        "type": "n8n-nodes-base.if",
        "typeVersion": 1,
        "position": [
          672,
          0
        ]
      },
      {
        "parameters": {
          "method": "POST",
          "url": "https://api.telegram.org/bot8544365014:AAEgKwHUF7_iG2AizJND2NuOUouPE4uQymQ/sendMessage",
          "sendBody": true,
          "contentType": "raw",
          "rawContentType": "application/json",
          "body": "={\"chat_id\":\"8305133249\",\"text\":\"\ud83d\udea8 *New Notary Request* \ud83d\udea8\\n\\n*Client:* {{ $json.clientName }}\\n*Service:* {{ $json.serviceType }}\\n*When:* {{ $json.preferredDateTime }}\\n*Where:* {{ $json.location }}\\n*Phone:* {{ $json.phone }}\\n\\n_Auto-reply has been sent._\",\"parse_mode\":\"Markdown\"}",
          "options": {}
        },
        "id": "notify-telegram",
        "name": "Notify Dain",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [
          912,
          -96
        ]
      },
      {
        "parameters": {
          "sendTo": "={{ $json.originalSender }}",
          "subject": "=Re: {{ $json.originalSubject }}",
          "message": "Hi {{ $json.clientName !== 'Not provided' ? $json.clientName : 'there' }},\n\nThank you for reaching out to Dain Bentley Management.\n\nI have received your request for notary services. I will review your details and get back to you shortly to confirm our appointment.\n\nBest regards,\n\nDain Bentley\nDain Bentley Management LLC",
          "options": {}
        },
        "id": "auto-reply",
        "name": "Auto-Reply to Client",
        "type": "n8n-nodes-base.gmail",
        "typeVersion": 2.1,
        "position": [
          912,
          112
        ],
        "webhookId": "199ebec3-ef73-4c7d-b903-1996aae3a633",
        "credentials": {
          "gmailOAuth2": {
            "id": "73FQ8r7lzSZjobXf",
            "name": "Gmail account"
          }
        }
      }
    ],
    "connections": {
      "Gmail Trigger": {
        "main": [
          [
            {
              "node": "Extract with Gemma",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Parse AI Output": {
        "main": [
          [
            {
              "node": "Is Notary Request?",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Is Notary Request?": {
        "main": [
          [
            {
              "node": "Notify Dain",
              "type": "main",
              "index": 0
            },
            {
              "node": "Auto-Reply to Client",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Extract with Gemma": {
        "main": [
          [
            {
              "node": "Parse AI Output",
              "type": "main",
              "index": 0
            }
          ]
        ]
      }
    },
    "authors": "DAIN BENTLEY",
    "name": null,
    "description": null,
    "autosaved": false,
    "workflowPublishHistory": [
      {
        "createdAt": "2026-03-06T14:10:08.825Z",
        "id": 86,
        "workflowId": "JbekZR8r1ebXe16n",
        "versionId": "7dd2d500-087e-4bd8-b253-786ca2780090",
        "event": "deactivated",
        "userId": "c557a393-301d-4cd5-ada0-4ae8574f88c9"
      },
      {
        "createdAt": "2026-03-06T14:10:00.709Z",
        "id": 84,
        "workflowId": "JbekZR8r1ebXe16n",
        "versionId": "7dd2d500-087e-4bd8-b253-786ca2780090",
        "event": "deactivated",
        "userId": "c557a393-301d-4cd5-ada0-4ae8574f88c9"
      },
      {
        "createdAt": "2026-03-06T14:10:01.300Z",
        "id": 85,
        "workflowId": "JbekZR8r1ebXe16n",
        "versionId": "7dd2d500-087e-4bd8-b253-786ca2780090",
        "event": "activated",
        "userId": "c557a393-301d-4cd5-ada0-4ae8574f88c9"
      },
      {
        "createdAt": "2026-03-06T14:10:09.379Z",
        "id": 87,
        "workflowId": "JbekZR8r1ebXe16n",
        "versionId": "7dd2d500-087e-4bd8-b253-786ca2780090",
        "event": "activated",
        "userId": "c557a393-301d-4cd5-ada0-4ae8574f88c9"
      }
    ]
  }
}
```

</details>

---

## Morning News Digest

| Field | Value |
|---|---|
| **ID** | `LvwMEORrcb1rRQuT` |
| **Status** | 🟢 Active |
| **Schedule** | `0 8 * * *` |
| **Backup file** | `morning_news_digest.json` |

**Nodes (13):**
  - `n8n-nodes-base.scheduleTrigger` — **Schedule 8AM**
  - `n8n-nodes-base.rssFeedRead` — **AP World RSS**
  - `n8n-nodes-base.rssFeedRead` — **AP Science RSS**
  - `n8n-nodes-base.rssFeedRead` — **Ars Technica RSS**
  - `n8n-nodes-base.rssFeedRead` — **BBC Science RSS**
  - `n8n-nodes-base.httpRequest` — **Reddit r/nova**
  - `n8n-nodes-base.httpRequest` — **Reddit r/worldnews**
  - `n8n-nodes-base.httpRequest` — **Reddit r/conservative**
  - `n8n-nodes-base.httpRequest` — **Reddit r/politics**
  - `n8n-nodes-base.httpRequest` — **Reddit r/linux**
  - `n8n-nodes-base.httpRequest` — **Reddit r/fednews**
  - `n8n-nodes-base.code` — **Format Digest**
  - `n8n-nodes-base.httpRequest` — **Send to Telegram**

<details>
<summary>Full JSON config</summary>

```json
{
  "updatedAt": "2026-03-08T15:30:32.635Z",
  "createdAt": "2026-03-08T15:30:32.635Z",
  "id": "LvwMEORrcb1rRQuT",
  "name": "Morning News Digest",
  "description": null,
  "active": true,
  "isArchived": false,
  "nodes": [
    {
      "id": "schedule",
      "name": "Schedule 8AM",
      "type": "n8n-nodes-base.scheduleTrigger",
      "typeVersion": 1.2,
      "position": [
        0,
        0
      ],
      "parameters": {
        "rule": {
          "interval": [
            {
              "field": "cronExpression",
              "expression": "0 8 * * *"
            }
          ]
        }
      }
    },
    {
      "id": "rss-ap-world",
      "name": "AP World RSS",
      "type": "n8n-nodes-base.rssFeedRead",
      "typeVersion": 1,
      "position": [
        220,
        -400
      ],
      "parameters": {
        "url": "https://feeds.apnews.com/rss/apf-topnews"
      }
    },
    {
      "id": "rss-ap-sci",
      "name": "AP Science RSS",
      "type": "n8n-nodes-base.rssFeedRead",
      "typeVersion": 1,
      "position": [
        220,
        -200
      ],
      "parameters": {
        "url": "https://feeds.apnews.com/rss/apf-science"
      }
    },
    {
      "id": "rss-ars",
      "name": "Ars Technica RSS",
      "type": "n8n-nodes-base.rssFeedRead",
      "typeVersion": 1,
      "position": [
        220,
        0
      ],
      "parameters": {
        "url": "https://feeds.arstechnica.com/arstechnica/index"
      }
    },
    {
      "id": "rss-bbc",
      "name": "BBC Science RSS",
      "type": "n8n-nodes-base.rssFeedRead",
      "typeVersion": 1,
      "position": [
        220,
        200
      ],
      "parameters": {
        "url": "https://feeds.bbci.co.uk/news/science_and_environment/rss.xml"
      }
    },
    {
      "id": "reddit-nova",
      "name": "Reddit r/nova",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        220,
        420
      ],
      "parameters": {
        "method": "GET",
        "url": "https://www.reddit.com/r/nova/hot.json?limit=3",
        "sendHeaders": true,
        "headerParameters": {
          "parameters": [
            {
              "name": "User-Agent",
              "value": "MiloNewsBot/1.0"
            }
          ]
        },
        "options": {}
      }
    },
    {
      "id": "reddit-worldnews",
      "name": "Reddit r/worldnews",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        220,
        560
      ],
      "parameters": {
        "method": "GET",
        "url": "https://www.reddit.com/r/worldnews/hot.json?limit=3",
        "sendHeaders": true,
        "headerParameters": {
          "parameters": [
            {
              "name": "User-Agent",
              "value": "MiloNewsBot/1.0"
            }
          ]
        },
        "options": {}
      }
    },
    {
      "id": "reddit-conservative",
      "name": "Reddit r/conservative",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        220,
        700
      ],
      "parameters": {
        "method": "GET",
        "url": "https://www.reddit.com/r/conservative/hot.json?limit=3",
        "sendHeaders": true,
        "headerParameters": {
          "parameters": [
            {
              "name": "User-Agent",
              "value": "MiloNewsBot/1.0"
            }
          ]
        },
        "options": {}
      }
    },
    {
      "id": "reddit-politics",
      "name": "Reddit r/politics",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        220,
        840
      ],
      "parameters": {
        "method": "GET",
        "url": "https://www.reddit.com/r/politics/hot.json?limit=3",
        "sendHeaders": true,
        "headerParameters": {
          "parameters": [
            {
              "name": "User-Agent",
              "value": "MiloNewsBot/1.0"
            }
          ]
        },
        "options": {}
      }
    },
    {
      "id": "reddit-linux",
      "name": "Reddit r/linux",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        220,
        980
      ],
      "parameters": {
        "method": "GET",
        "url": "https://www.reddit.com/r/linux/hot.json?limit=3",
        "sendHeaders": true,
        "headerParameters": {
          "parameters": [
            {
              "name": "User-Agent",
              "value": "MiloNewsBot/1.0"
            }
          ]
        },
        "options": {}
      }
    },
    {
      "id": "reddit-fednews",
      "name": "Reddit r/fednews",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        220,
        1120
      ],
      "parameters": {
        "method": "GET",
        "url": "https://www.reddit.com/r/fednews/hot.json?limit=3",
        "sendHeaders": true,
        "headerParameters": {
          "parameters": [
            {
              "name": "User-Agent",
              "value": "MiloNewsBot/1.0"
            }
          ]
        },
        "options": {}
      }
    },
    {
      "id": "format",
      "name": "Format Digest",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        520,
        360
      ],
      "parameters": {
        "jsCode": "const today = new Date().toLocaleDateString('en-US', {weekday:'long', month:'long', day:'numeric'});\n\nfunction getTop(nodeId, label, n) {\n  try {\n    const items = $(nodeId).all();\n    return items.slice(0, n).map(i => ({\n      title: (i.json.title || '').replace(/[*[\\]]/g, '').trim(),\n      link: i.json.link || ''\n    }));\n  } catch(e) { return []; }\n}\n\nfunction getRedditTop(nodeId, sub) {\n  try {\n    const data = $(nodeId).first().json;\n    const posts = data?.data?.children || [];\n    const p = posts.find(c => !c.data.stickied)?.data;\n    if (!p) return null;\n    return {\n      title: (p.title || '').replace(/[*[\\]]/g, '').slice(0, 90),\n      link: 'https://reddit.com' + p.permalink\n    };\n  } catch(e) { return null; }\n}\n\nlet msg = '\\u{1F4F0} *News Briefing \\u2014 ' + today + '*\\n\\n';\n\n// World\nconst world = getTop('AP World RSS', '', 3);\nif (world.length) {\n  msg += '\\u{1F30D} *World* (AP News)\\n';\n  for (const p of world) msg += `\\u2022 [${p.title}](${p.link})\\n`;\n  msg += '\\n';\n}\n\n// Tech\nconst tech = getTop('Ars Technica RSS', '', 3);\nif (tech.length) {\n  msg += '\\u{1F4BB} *Tech* (Ars Technica)\\n';\n  for (const p of tech) msg += `\\u2022 [${p.title}](${p.link})\\n`;\n  msg += '\\n';\n}\n\n// Science (AP + BBC combined)\nconst sciAP = getTop('AP Science RSS', '', 2);\nconst sciBBC = getTop('BBC Science RSS', '', 2);\nconst sci = [...sciAP, ...sciBBC].slice(0, 3);\nif (sci.length) {\n  msg += '\\u{1F52C} *Science*\\n';\n  for (const p of sci) msg += `\\u2022 [${p.title}](${p.link})\\n`;\n  msg += '\\n';\n}\n\n// Reddit\nconst redditSubs = [\n  ['Reddit r/nova', 'nova'],\n  ['Reddit r/worldnews', 'worldnews'],\n  ['Reddit r/conservative', 'conservative'],\n  ['Reddit r/politics', 'politics'],\n  ['Reddit r/linux', 'linux'],\n  ['Reddit r/fednews', 'fednews'],\n];\nconst redditPosts = redditSubs.map(([nid, sub]) => ({ sub, post: getRedditTop(nid, sub) })).filter(x => x.post);\nif (redditPosts.length) {\n  msg += '\\u{1F47E} *Reddit Highlights*\\n';\n  for (const {sub, post} of redditPosts) {\n    msg += `r/${sub} \\u2014 [${post.title}](${post.link})\\n`;\n  }\n}\n\nreturn [{ json: { message: msg.trim() } }];"
      }
    },
    {
      "id": "send",
      "name": "Send to Telegram",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        760,
        360
      ],
      "parameters": {
        "method": "POST",
        "url": "https://api.telegram.org/bot8544365014:AAEgKwHUF7_iG2AizJND2NuOUouPE4uQymQ/sendMessage",
        "sendBody": true,
        "contentType": "raw",
        "rawContentType": "application/json",
        "body": "{\"chat_id\":\"8305133249\",\"text\":\"={{ $json.message }}\",\"parse_mode\":\"Markdown\",\"disable_web_page_preview\":true}",
        "options": {}
      }
    }
  ],
  "connections": {
    "Schedule 8AM": {
      "main": [
        [
          {
            "node": "AP World RSS",
            "type": "main",
            "index": 0
          },
          {
            "node": "AP Science RSS",
            "type": "main",
            "index": 0
          },
          {
            "node": "Ars Technica RSS",
            "type": "main",
            "index": 0
          },
          {
            "node": "BBC Science RSS",
            "type": "main",
            "index": 0
          },
          {
            "node": "Reddit r/nova",
            "type": "main",
            "index": 0
          },
          {
            "node": "Reddit r/worldnews",
            "type": "main",
            "index": 0
          },
          {
            "node": "Reddit r/conservative",
            "type": "main",
            "index": 0
          },
          {
            "node": "Reddit r/politics",
            "type": "main",
            "index": 0
          },
          {
            "node": "Reddit r/linux",
            "type": "main",
            "index": 0
          },
          {
            "node": "Reddit r/fednews",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "AP World RSS": {
      "main": [
        [
          {
            "node": "Format Digest",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "AP Science RSS": {
      "main": [
        [
          {
            "node": "Format Digest",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Ars Technica RSS": {
      "main": [
        [
          {
            "node": "Format Digest",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "BBC Science RSS": {
      "main": [
        [
          {
            "node": "Format Digest",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Reddit r/nova": {
      "main": [
        [
          {
            "node": "Format Digest",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Reddit r/worldnews": {
      "main": [
        [
          {
            "node": "Format Digest",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Reddit r/conservative": {
      "main": [
        [
          {
            "node": "Format Digest",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Reddit r/politics": {
      "main": [
        [
          {
            "node": "Format Digest",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Reddit r/linux": {
      "main": [
        [
          {
            "node": "Format Digest",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Reddit r/fednews": {
      "main": [
        [
          {
            "node": "Format Digest",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Format Digest": {
      "main": [
        [
          {
            "node": "Send to Telegram",
            "type": "main",
            "index": 0
          }
        ]
      ]
    }
  },
  "settings": {
    "executionOrder": "v1",
    "callerPolicy": "workflowsFromSameOwner",
    "availableInMCP": false
  },
  "staticData": {
    "node:Schedule 8AM": {
      "recurrenceRules": []
    }
  },
  "meta": null,
  "pinData": null,
  "versionId": "38cb7208-1ef8-49f7-a8d3-e4f921e1aa5e",
  "activeVersionId": "38cb7208-1ef8-49f7-a8d3-e4f921e1aa5e",
  "versionCounter": 4,
  "triggerCount": 1,
  "shared": [
    {
      "updatedAt": "2026-03-08T15:30:32.635Z",
      "createdAt": "2026-03-08T15:30:32.635Z",
      "role": "workflow:owner",
      "workflowId": "LvwMEORrcb1rRQuT",
      "projectId": "5DJBfZzzizP5frZB",
      "project": {
        "updatedAt": "2026-03-06T04:53:21.134Z",
        "createdAt": "2026-03-06T04:52:56.613Z",
        "id": "5DJBfZzzizP5frZB",
        "name": "DAIN BENTLEY <dain.bentley@gmail.com>",
        "type": "personal",
        "icon": null,
        "description": null,
        "creatorId": "c557a393-301d-4cd5-ada0-4ae8574f88c9"
      }
    }
  ],
  "tags": [],
  "activeVersion": {
    "updatedAt": "2026-03-08T15:30:32.644Z",
    "createdAt": "2026-03-08T15:30:32.644Z",
    "versionId": "38cb7208-1ef8-49f7-a8d3-e4f921e1aa5e",
    "workflowId": "LvwMEORrcb1rRQuT",
    "nodes": [
      {
        "id": "schedule",
        "name": "Schedule 8AM",
        "type": "n8n-nodes-base.scheduleTrigger",
        "typeVersion": 1.2,
        "position": [
          0,
          0
        ],
        "parameters": {
          "rule": {
            "interval": [
              {
                "field": "cronExpression",
                "expression": "0 8 * * *"
              }
            ]
          }
        }
      },
      {
        "id": "rss-ap-world",
        "name": "AP World RSS",
        "type": "n8n-nodes-base.rssFeedRead",
        "typeVersion": 1,
        "position": [
          220,
          -400
        ],
        "parameters": {
          "url": "https://feeds.apnews.com/rss/apf-topnews"
        }
      },
      {
        "id": "rss-ap-sci",
        "name": "AP Science RSS",
        "type": "n8n-nodes-base.rssFeedRead",
        "typeVersion": 1,
        "position": [
          220,
          -200
        ],
        "parameters": {
          "url": "https://feeds.apnews.com/rss/apf-science"
        }
      },
      {
        "id": "rss-ars",
        "name": "Ars Technica RSS",
        "type": "n8n-nodes-base.rssFeedRead",
        "typeVersion": 1,
        "position": [
          220,
          0
        ],
        "parameters": {
          "url": "https://feeds.arstechnica.com/arstechnica/index"
        }
      },
      {
        "id": "rss-bbc",
        "name": "BBC Science RSS",
        "type": "n8n-nodes-base.rssFeedRead",
        "typeVersion": 1,
        "position": [
          220,
          200
        ],
        "parameters": {
          "url": "https://feeds.bbci.co.uk/news/science_and_environment/rss.xml"
        }
      },
      {
        "id": "reddit-nova",
        "name": "Reddit r/nova",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [
          220,
          420
        ],
        "parameters": {
          "method": "GET",
          "url": "https://www.reddit.com/r/nova/hot.json?limit=3",
          "sendHeaders": true,
          "headerParameters": {
            "parameters": [
              {
                "name": "User-Agent",
                "value": "MiloNewsBot/1.0"
              }
            ]
          },
          "options": {}
        }
      },
      {
        "id": "reddit-worldnews",
        "name": "Reddit r/worldnews",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [
          220,
          560
        ],
        "parameters": {
          "method": "GET",
          "url": "https://www.reddit.com/r/worldnews/hot.json?limit=3",
          "sendHeaders": true,
          "headerParameters": {
            "parameters": [
              {
                "name": "User-Agent",
                "value": "MiloNewsBot/1.0"
              }
            ]
          },
          "options": {}
        }
      },
      {
        "id": "reddit-conservative",
        "name": "Reddit r/conservative",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [
          220,
          700
        ],
        "parameters": {
          "method": "GET",
          "url": "https://www.reddit.com/r/conservative/hot.json?limit=3",
          "sendHeaders": true,
          "headerParameters": {
            "parameters": [
              {
                "name": "User-Agent",
                "value": "MiloNewsBot/1.0"
              }
            ]
          },
          "options": {}
        }
      },
      {
        "id": "reddit-politics",
        "name": "Reddit r/politics",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [
          220,
          840
        ],
        "parameters": {
          "method": "GET",
          "url": "https://www.reddit.com/r/politics/hot.json?limit=3",
          "sendHeaders": true,
          "headerParameters": {
            "parameters": [
              {
                "name": "User-Agent",
                "value": "MiloNewsBot/1.0"
              }
            ]
          },
          "options": {}
        }
      },
      {
        "id": "reddit-linux",
        "name": "Reddit r/linux",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [
          220,
          980
        ],
        "parameters": {
          "method": "GET",
          "url": "https://www.reddit.com/r/linux/hot.json?limit=3",
          "sendHeaders": true,
          "headerParameters": {
            "parameters": [
              {
                "name": "User-Agent",
                "value": "MiloNewsBot/1.0"
              }
            ]
          },
          "options": {}
        }
      },
      {
        "id": "reddit-fednews",
        "name": "Reddit r/fednews",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [
          220,
          1120
        ],
        "parameters": {
          "method": "GET",
          "url": "https://www.reddit.com/r/fednews/hot.json?limit=3",
          "sendHeaders": true,
          "headerParameters": {
            "parameters": [
              {
                "name": "User-Agent",
                "value": "MiloNewsBot/1.0"
              }
            ]
          },
          "options": {}
        }
      },
      {
        "id": "format",
        "name": "Format Digest",
        "type": "n8n-nodes-base.code",
        "typeVersion": 2,
        "position": [
          520,
          360
        ],
        "parameters": {
          "jsCode": "const today = new Date().toLocaleDateString('en-US', {weekday:'long', month:'long', day:'numeric'});\n\nfunction getTop(nodeId, label, n) {\n  try {\n    const items = $(nodeId).all();\n    return items.slice(0, n).map(i => ({\n      title: (i.json.title || '').replace(/[*[\\]]/g, '').trim(),\n      link: i.json.link || ''\n    }));\n  } catch(e) { return []; }\n}\n\nfunction getRedditTop(nodeId, sub) {\n  try {\n    const data = $(nodeId).first().json;\n    const posts = data?.data?.children || [];\n    const p = posts.find(c => !c.data.stickied)?.data;\n    if (!p) return null;\n    return {\n      title: (p.title || '').replace(/[*[\\]]/g, '').slice(0, 90),\n      link: 'https://reddit.com' + p.permalink\n    };\n  } catch(e) { return null; }\n}\n\nlet msg = '\\u{1F4F0} *News Briefing \\u2014 ' + today + '*\\n\\n';\n\n// World\nconst world = getTop('AP World RSS', '', 3);\nif (world.length) {\n  msg += '\\u{1F30D} *World* (AP News)\\n';\n  for (const p of world) msg += `\\u2022 [${p.title}](${p.link})\\n`;\n  msg += '\\n';\n}\n\n// Tech\nconst tech = getTop('Ars Technica RSS', '', 3);\nif (tech.length) {\n  msg += '\\u{1F4BB} *Tech* (Ars Technica)\\n';\n  for (const p of tech) msg += `\\u2022 [${p.title}](${p.link})\\n`;\n  msg += '\\n';\n}\n\n// Science (AP + BBC combined)\nconst sciAP = getTop('AP Science RSS', '', 2);\nconst sciBBC = getTop('BBC Science RSS', '', 2);\nconst sci = [...sciAP, ...sciBBC].slice(0, 3);\nif (sci.length) {\n  msg += '\\u{1F52C} *Science*\\n';\n  for (const p of sci) msg += `\\u2022 [${p.title}](${p.link})\\n`;\n  msg += '\\n';\n}\n\n// Reddit\nconst redditSubs = [\n  ['Reddit r/nova', 'nova'],\n  ['Reddit r/worldnews', 'worldnews'],\n  ['Reddit r/conservative', 'conservative'],\n  ['Reddit r/politics', 'politics'],\n  ['Reddit r/linux', 'linux'],\n  ['Reddit r/fednews', 'fednews'],\n];\nconst redditPosts = redditSubs.map(([nid, sub]) => ({ sub, post: getRedditTop(nid, sub) })).filter(x => x.post);\nif (redditPosts.length) {\n  msg += '\\u{1F47E} *Reddit Highlights*\\n';\n  for (const {sub, post} of redditPosts) {\n    msg += `r/${sub} \\u2014 [${post.title}](${post.link})\\n`;\n  }\n}\n\nreturn [{ json: { message: msg.trim() } }];"
        }
      },
      {
        "id": "send",
        "name": "Send to Telegram",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [
          760,
          360
        ],
        "parameters": {
          "method": "POST",
          "url": "https://api.telegram.org/bot8544365014:AAEgKwHUF7_iG2AizJND2NuOUouPE4uQymQ/sendMessage",
          "sendBody": true,
          "contentType": "raw",
          "rawContentType": "application/json",
          "body": "{\"chat_id\":\"8305133249\",\"text\":\"={{ $json.message }}\",\"parse_mode\":\"Markdown\",\"disable_web_page_preview\":true}",
          "options": {}
        }
      }
    ],
    "connections": {
      "Schedule 8AM": {
        "main": [
          [
            {
              "node": "AP World RSS",
              "type": "main",
              "index": 0
            },
            {
              "node": "AP Science RSS",
              "type": "main",
              "index": 0
            },
            {
              "node": "Ars Technica RSS",
              "type": "main",
              "index": 0
            },
            {
              "node": "BBC Science RSS",
              "type": "main",
              "index": 0
            },
            {
              "node": "Reddit r/nova",
              "type": "main",
              "index": 0
            },
            {
              "node": "Reddit r/worldnews",
              "type": "main",
              "index": 0
            },
            {
              "node": "Reddit r/conservative",
              "type": "main",
              "index": 0
            },
            {
              "node": "Reddit r/politics",
              "type": "main",
              "index": 0
            },
            {
              "node": "Reddit r/linux",
              "type": "main",
              "index": 0
            },
            {
              "node": "Reddit r/fednews",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "AP World RSS": {
        "main": [
          [
            {
              "node": "Format Digest",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "AP Science RSS": {
        "main": [
          [
            {
              "node": "Format Digest",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Ars Technica RSS": {
        "main": [
          [
            {
              "node": "Format Digest",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "BBC Science RSS": {
        "main": [
          [
            {
              "node": "Format Digest",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Reddit r/nova": {
        "main": [
          [
            {
              "node": "Format Digest",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Reddit r/worldnews": {
        "main": [
          [
            {
              "node": "Format Digest",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Reddit r/conservative": {
        "main": [
          [
            {
              "node": "Format Digest",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Reddit r/politics": {
        "main": [
          [
            {
              "node": "Format Digest",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Reddit r/linux": {
        "main": [
          [
            {
              "node": "Format Digest",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Reddit r/fednews": {
        "main": [
          [
            {
              "node": "Format Digest",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Format Digest": {
        "main": [
          [
            {
              "node": "Send to Telegram",
              "type": "main",
              "index": 0
            }
          ]
        ]
      }
    },
    "authors": "DAIN BENTLEY",
    "name": null,
    "description": null,
    "autosaved": false,
    "workflowPublishHistory": [
      {
        "createdAt": "2026-03-08T15:30:32.755Z",
        "id": 89,
        "workflowId": "LvwMEORrcb1rRQuT",
        "versionId": "38cb7208-1ef8-49f7-a8d3-e4f921e1aa5e",
        "event": "activated",
        "userId": "c557a393-301d-4cd5-ada0-4ae8574f88c9"
      }
    ]
  }
}
```

</details>

---

## Daily Fact

| Field | Value |
|---|---|
| **ID** | `AjAjjxb9j94iE0JK` |
| **Status** | 🟢 Active |
| **Schedule** | `0 7 * * *` |
| **Backup file** | `daily_fact.json` |

**Nodes (4):**
  - `n8n-nodes-base.scheduleTrigger` — **Schedule 7AM**
  - `n8n-nodes-base.httpRequest` — **Ask Ollama**
  - `n8n-nodes-base.code` — **Format Message**
  - `n8n-nodes-base.httpRequest` — **Send to Telegram**

<details>
<summary>Full JSON config</summary>

```json
{
  "updatedAt": "2026-03-09T02:30:44.241Z",
  "createdAt": "2026-03-09T02:30:44.241Z",
  "id": "AjAjjxb9j94iE0JK",
  "name": "Daily Fact",
  "description": null,
  "active": true,
  "isArchived": false,
  "nodes": [
    {
      "id": "schedule",
      "name": "Schedule 7AM",
      "type": "n8n-nodes-base.scheduleTrigger",
      "typeVersion": 1.2,
      "position": [
        0,
        0
      ],
      "parameters": {
        "rule": {
          "interval": [
            {
              "field": "cronExpression",
              "expression": "0 7 * * *"
            }
          ]
        }
      }
    },
    {
      "id": "ollama",
      "name": "Ask Ollama",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        240,
        0
      ],
      "parameters": {
        "method": "POST",
        "url": "http://192.168.200.240:11434/api/generate",
        "sendBody": true,
        "contentType": "raw",
        "rawContentType": "application/json",
        "body": "{\"model\":\"gemma3:12b\",\"prompt\":\"Give me one genuinely interesting, obscure, or surprising fact. Keep it to 2-3 sentences max. No intro, just the fact.\",\"stream\":false}",
        "options": {}
      }
    },
    {
      "id": "format",
      "name": "Format Message",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        480,
        0
      ],
      "parameters": {
        "jsCode": "const fact = $input.first().json.response || 'No fact today.';\nreturn [{ json: { message: '\ud83e\udde0 *Daily Fact*\\n\\n' + fact + '\\n\\n*(via gemma3:12b)*' } }];"
      }
    },
    {
      "id": "send",
      "name": "Send to Telegram",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        720,
        0
      ],
      "parameters": {
        "method": "POST",
        "url": "https://api.telegram.org/bot8544365014:AAEgKwHUF7_iG2AizJND2NuOUouPE4uQymQ/sendMessage",
        "sendBody": true,
        "contentType": "raw",
        "rawContentType": "application/json",
        "body": "{\"chat_id\":\"8305133249\",\"text\":\"={{ $json.message }}\",\"parse_mode\":\"Markdown\"}",
        "options": {}
      }
    }
  ],
  "connections": {
    "Schedule 7AM": {
      "main": [
        [
          {
            "node": "Ask Ollama",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Ask Ollama": {
      "main": [
        [
          {
            "node": "Format Message",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Format Message": {
      "main": [
        [
          {
            "node": "Send to Telegram",
            "type": "main",
            "index": 0
          }
        ]
      ]
    }
  },
  "settings": {
    "executionOrder": "v1",
    "callerPolicy": "workflowsFromSameOwner",
    "availableInMCP": false
  },
  "staticData": {
    "node:Schedule 7AM": {
      "recurrenceRules": []
    }
  },
  "meta": null,
  "pinData": null,
  "versionId": "cc0582d5-7220-4a82-b29e-383fab53506e",
  "activeVersionId": "cc0582d5-7220-4a82-b29e-383fab53506e",
  "versionCounter": 4,
  "triggerCount": 1,
  "shared": [
    {
      "updatedAt": "2026-03-09T02:30:44.241Z",
      "createdAt": "2026-03-09T02:30:44.241Z",
      "role": "workflow:owner",
      "workflowId": "AjAjjxb9j94iE0JK",
      "projectId": "5DJBfZzzizP5frZB",
      "project": {
        "updatedAt": "2026-03-06T04:53:21.134Z",
        "createdAt": "2026-03-06T04:52:56.613Z",
        "id": "5DJBfZzzizP5frZB",
        "name": "DAIN BENTLEY <dain.bentley@gmail.com>",
        "type": "personal",
        "icon": null,
        "description": null,
        "creatorId": "c557a393-301d-4cd5-ada0-4ae8574f88c9"
      }
    }
  ],
  "tags": [],
  "activeVersion": {
    "updatedAt": "2026-03-09T02:30:44.267Z",
    "createdAt": "2026-03-09T02:30:44.267Z",
    "versionId": "cc0582d5-7220-4a82-b29e-383fab53506e",
    "workflowId": "AjAjjxb9j94iE0JK",
    "nodes": [
      {
        "id": "schedule",
        "name": "Schedule 7AM",
        "type": "n8n-nodes-base.scheduleTrigger",
        "typeVersion": 1.2,
        "position": [
          0,
          0
        ],
        "parameters": {
          "rule": {
            "interval": [
              {
                "field": "cronExpression",
                "expression": "0 7 * * *"
              }
            ]
          }
        }
      },
      {
        "id": "ollama",
        "name": "Ask Ollama",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [
          240,
          0
        ],
        "parameters": {
          "method": "POST",
          "url": "http://192.168.200.240:11434/api/generate",
          "sendBody": true,
          "contentType": "raw",
          "rawContentType": "application/json",
          "body": "{\"model\":\"gemma3:12b\",\"prompt\":\"Give me one genuinely interesting, obscure, or surprising fact. Keep it to 2-3 sentences max. No intro, just the fact.\",\"stream\":false}",
          "options": {}
        }
      },
      {
        "id": "format",
        "name": "Format Message",
        "type": "n8n-nodes-base.code",
        "typeVersion": 2,
        "position": [
          480,
          0
        ],
        "parameters": {
          "jsCode": "const fact = $input.first().json.response || 'No fact today.';\nreturn [{ json: { message: '\ud83e\udde0 *Daily Fact*\\n\\n' + fact + '\\n\\n*(via gemma3:12b)*' } }];"
        }
      },
      {
        "id": "send",
        "name": "Send to Telegram",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [
          720,
          0
        ],
        "parameters": {
          "method": "POST",
          "url": "https://api.telegram.org/bot8544365014:AAEgKwHUF7_iG2AizJND2NuOUouPE4uQymQ/sendMessage",
          "sendBody": true,
          "contentType": "raw",
          "rawContentType": "application/json",
          "body": "{\"chat_id\":\"8305133249\",\"text\":\"={{ $json.message }}\",\"parse_mode\":\"Markdown\"}",
          "options": {}
        }
      }
    ],
    "connections": {
      "Schedule 7AM": {
        "main": [
          [
            {
              "node": "Ask Ollama",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Ask Ollama": {
        "main": [
          [
            {
              "node": "Format Message",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Format Message": {
        "main": [
          [
            {
              "node": "Send to Telegram",
              "type": "main",
              "index": 0
            }
          ]
        ]
      }
    },
    "authors": "DAIN BENTLEY",
    "name": null,
    "description": null,
    "autosaved": false,
    "workflowPublishHistory": [
      {
        "createdAt": "2026-03-09T02:30:44.433Z",
        "id": 90,
        "workflowId": "AjAjjxb9j94iE0JK",
        "versionId": "cc0582d5-7220-4a82-b29e-383fab53506e",
        "event": "activated",
        "userId": "c557a393-301d-4cd5-ada0-4ae8574f88c9"
      }
    ]
  }
}
```

</details>

---

