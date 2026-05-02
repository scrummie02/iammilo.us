# N8N Workflows
*Last exported: 2026-04-07 02:01*  
*Instance: https://n8n.dainbentley.com*

> To restore a workflow: go to n8n → Workflows → Import → paste the JSON file below.

---

## Email Digest - Morning

| Field | Value |
|---|---|
| **ID** | `s8KeUS9yfSu2SDHV` |
| **Status** | 🟢 Active |
| **Schedule** | `0 7 * * *` |
| **Backup file** | `email_digest_-_morning.json` |

**Nodes (6):**
  - `n8n-nodes-base.scheduleTrigger` — **Schedule**
  - `n8n-nodes-base.gmail` — **Gmail**
  - `n8n-nodes-base.code` — **Prepare Prompt**
  - `n8n-nodes-base.httpRequest` — **Ask Gemini Pro**
  - `n8n-nodes-base.code` — **Format Message**
  - `n8n-nodes-base.httpRequest` — **Send to Telegram**

<details>
<summary>Full JSON config</summary>

```json
{
  "updatedAt": "2026-03-17T12:26:12.387Z",
  "createdAt": "2026-03-10T13:12:02.507Z",
  "id": "s8KeUS9yfSu2SDHV",
  "name": "Email Digest - Morning",
  "description": null,
  "active": true,
  "isArchived": false,
  "nodes": [
    {
      "id": "schedule",
      "name": "Schedule",
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
      "id": "gmail",
      "name": "Gmail",
      "type": "n8n-nodes-base.gmail",
      "typeVersion": 2.1,
      "position": [
        200,
        0
      ],
      "parameters": {
        "operation": "getAll",
        "limit": 50,
        "simple": true,
        "filters": {
          "q": "in:inbox newer_than:1d"
        }
      },
      "credentials": {
        "gmailOAuth2": {
          "id": "73FQ8r7lzSZjobXf",
          "name": "Gmail account"
        }
      },
      "alwaysOutputData": true
    },
    {
      "id": "prepare-prompt",
      "name": "Prepare Prompt",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        400,
        0
      ],
      "parameters": {
        "jsCode": "\nlet emails = $input.all().map((e, index) => {\n  // Defensive extraction\n  let from = e.json.from || e.json.From || e.json.sender || \"Unknown\";\n  let subject = e.json.subject || e.json.Subject || \"No Subject\";\n  let snippet = e.json.snippet || e.json.Snippet || \"\";\n  \n  // If it's a raw structure (headers array)\n  if (from === \"Unknown\" && Array.isArray(e.json.payload?.headers)) {\n    let fromHeader = e.json.payload.headers.find(h => h.name.toLowerCase() === 'from');\n    let subjectHeader = e.json.payload.headers.find(h => h.name.toLowerCase() === 'subject');\n    if (fromHeader) from = fromHeader.value;\n    if (subjectHeader) subject = subjectHeader.value;\n  }\n  \n  return `From: ${from}\\nSubject: ${subject}\\nSnippet: ${snippet}`;\n}).join('\\n\\n---\\n\\n');\n\nif (!emails || emails.trim() === \"\") {\n  emails = \"No emails found.\";\n}\n\nlet prompt = `You are an email assistant. Summarize the following inbox emails into a digest.\n\nCLASSIFY ONLY the emails provided below. Do not invent emails. If \"No emails found.\", just output \"\ud83d\udcec Inbox clear \u2705\"\n\n\ud83d\udd34 VIP \u2014 julie.a.siegel84@gmail.com or jabentley9@gmail.com ONLY\n\ud83d\udea8 IMPORTANT \u2014 VA, DOJ, IRS, OPM, court, banks, Charlotte school, medical, financial\n\ud83d\udfe1 MEDIUM \u2014 bills, subscriptions, receipts, newsletters\n\ud83d\uddd1\ufe0f SPAM \u2014 marketing, promotions, job alerts\n\nFormat EXACTLY like this (use Markdown). CRITICAL: KEEP THE ENTIRE RESPONSE CONCISE AND STRICTLY UNDER 3500 CHARACTERS TOTAL. If there are many medium/spam emails, truncate the list:\n\n\ud83d\udcec *Email Digest*\n\n\ud83d\udd34 *VIP*\n\u2022 [From] \u2014 [Subject] \u2014 [1-line summary]\n(or None.)\n\n\ud83d\udea8 *Urgent / Important*\n\u2022 [From] \u2014 [Subject] \u2014 [1-line summary]\n(or None.)\n\n\ud83d\udfe1 *Medium*\n\u2022 [From] \u2014 [Subject]\n(or None.)\n\n\ud83d\uddd1\ufe0f *Likely Spam*\n\u2022 [Comma separated senders]\n(or None.)\n\nEmails to classify:\n${emails}`;\n\nreturn [{ json: { prompt: prompt } }];\n"
      }
    },
    {
      "id": "ask-gemini",
      "name": "Ask Gemini Pro",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        600,
        0
      ],
      "parameters": {
        "method": "POST",
        "url": "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-preview:generateContent?key=AIzaSyAnnVmRDJTCRGKBvM80tEGpKmBa-f0CFpY",
        "sendBody": true,
        "contentType": "raw",
        "rawContentType": "application/json",
        "body": "={{ JSON.stringify({ contents: [{ parts: [{ text: $json.prompt }] }] }) }}",
        "options": {}
      }
    },
    {
      "id": "format-message",
      "name": "Format Message",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        800,
        0
      ],
      "parameters": {
        "jsCode": "const text = $input.first().json.candidates?.[0]?.content?.parts?.[0]?.text || 'Error generating digest.';\nreturn [{ json: { message: text.trim() + '\\n\\n*(via n8n & Gemini Pro)*' } }];"
      }
    },
    {
      "id": "send-telegram",
      "name": "Send to Telegram",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        1000,
        0
      ],
      "parameters": {
        "method": "POST",
        "url": "https://api.telegram.org/bot8544365014:AAEgKwHUF7_iG2AizJND2NuOUouPE4uQymQ/sendMessage",
        "sendBody": true,
        "contentType": "raw",
        "rawContentType": "application/json",
        "body": "={ \"chat_id\": \"8305133249\", \"text\": {{ JSON.stringify($json.message) }} }",
        "options": {}
      }
    }
  ],
  "connections": {
    "Schedule": {
      "main": [
        [
          {
            "node": "Gmail",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Gmail": {
      "main": [
        [
          {
            "node": "Prepare Prompt",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Prepare Prompt": {
      "main": [
        [
          {
            "node": "Ask Gemini Pro",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Ask Gemini Pro": {
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
    "node:Schedule": {
      "recurrenceRules": []
    }
  },
  "meta": null,
  "pinData": null,
  "versionId": "dc18ef60-d28f-4556-96fb-69a24ed34564",
  "activeVersionId": "dc18ef60-d28f-4556-96fb-69a24ed34564",
  "versionCounter": 28,
  "triggerCount": 1,
  "shared": [
    {
      "updatedAt": "2026-03-10T13:12:02.507Z",
      "createdAt": "2026-03-10T13:12:02.507Z",
      "role": "workflow:owner",
      "workflowId": "s8KeUS9yfSu2SDHV",
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
    "updatedAt": "2026-03-17T12:26:12.390Z",
    "createdAt": "2026-03-17T12:26:12.390Z",
    "versionId": "dc18ef60-d28f-4556-96fb-69a24ed34564",
    "workflowId": "s8KeUS9yfSu2SDHV",
    "nodes": [
      {
        "id": "schedule",
        "name": "Schedule",
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
        "id": "gmail",
        "name": "Gmail",
        "type": "n8n-nodes-base.gmail",
        "typeVersion": 2.1,
        "position": [
          200,
          0
        ],
        "parameters": {
          "operation": "getAll",
          "limit": 50,
          "simple": true,
          "filters": {
            "q": "in:inbox newer_than:1d"
          }
        },
        "credentials": {
          "gmailOAuth2": {
            "id": "73FQ8r7lzSZjobXf",
            "name": "Gmail account"
          }
        },
        "alwaysOutputData": true
      },
      {
        "id": "prepare-prompt",
        "name": "Prepare Prompt",
        "type": "n8n-nodes-base.code",
        "typeVersion": 2,
        "position": [
          400,
          0
        ],
        "parameters": {
          "jsCode": "\nlet emails = $input.all().map((e, index) => {\n  // Defensive extraction\n  let from = e.json.from || e.json.From || e.json.sender || \"Unknown\";\n  let subject = e.json.subject || e.json.Subject || \"No Subject\";\n  let snippet = e.json.snippet || e.json.Snippet || \"\";\n  \n  // If it's a raw structure (headers array)\n  if (from === \"Unknown\" && Array.isArray(e.json.payload?.headers)) {\n    let fromHeader = e.json.payload.headers.find(h => h.name.toLowerCase() === 'from');\n    let subjectHeader = e.json.payload.headers.find(h => h.name.toLowerCase() === 'subject');\n    if (fromHeader) from = fromHeader.value;\n    if (subjectHeader) subject = subjectHeader.value;\n  }\n  \n  return `From: ${from}\\nSubject: ${subject}\\nSnippet: ${snippet}`;\n}).join('\\n\\n---\\n\\n');\n\nif (!emails || emails.trim() === \"\") {\n  emails = \"No emails found.\";\n}\n\nlet prompt = `You are an email assistant. Summarize the following inbox emails into a digest.\n\nCLASSIFY ONLY the emails provided below. Do not invent emails. If \"No emails found.\", just output \"\ud83d\udcec Inbox clear \u2705\"\n\n\ud83d\udd34 VIP \u2014 julie.a.siegel84@gmail.com or jabentley9@gmail.com ONLY\n\ud83d\udea8 IMPORTANT \u2014 VA, DOJ, IRS, OPM, court, banks, Charlotte school, medical, financial\n\ud83d\udfe1 MEDIUM \u2014 bills, subscriptions, receipts, newsletters\n\ud83d\uddd1\ufe0f SPAM \u2014 marketing, promotions, job alerts\n\nFormat EXACTLY like this (use Markdown). CRITICAL: KEEP THE ENTIRE RESPONSE CONCISE AND STRICTLY UNDER 3500 CHARACTERS TOTAL. If there are many medium/spam emails, truncate the list:\n\n\ud83d\udcec *Email Digest*\n\n\ud83d\udd34 *VIP*\n\u2022 [From] \u2014 [Subject] \u2014 [1-line summary]\n(or None.)\n\n\ud83d\udea8 *Urgent / Important*\n\u2022 [From] \u2014 [Subject] \u2014 [1-line summary]\n(or None.)\n\n\ud83d\udfe1 *Medium*\n\u2022 [From] \u2014 [Subject]\n(or None.)\n\n\ud83d\uddd1\ufe0f *Likely Spam*\n\u2022 [Comma separated senders]\n(or None.)\n\nEmails to classify:\n${emails}`;\n\nreturn [{ json: { prompt: prompt } }];\n"
        }
      },
      {
        "id": "ask-gemini",
        "name": "Ask Gemini Pro",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [
          600,
          0
        ],
        "parameters": {
          "method": "POST",
          "url": "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-preview:generateContent?key=AIzaSyAnnVmRDJTCRGKBvM80tEGpKmBa-f0CFpY",
          "sendBody": true,
          "contentType": "raw",
          "rawContentType": "application/json",
          "body": "={{ JSON.stringify({ contents: [{ parts: [{ text: $json.prompt }] }] }) }}",
          "options": {}
        }
      },
      {
        "id": "format-message",
        "name": "Format Message",
        "type": "n8n-nodes-base.code",
        "typeVersion": 2,
        "position": [
          800,
          0
        ],
        "parameters": {
          "jsCode": "const text = $input.first().json.candidates?.[0]?.content?.parts?.[0]?.text || 'Error generating digest.';\nreturn [{ json: { message: text.trim() + '\\n\\n*(via n8n & Gemini Pro)*' } }];"
        }
      },
      {
        "id": "send-telegram",
        "name": "Send to Telegram",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [
          1000,
          0
        ],
        "parameters": {
          "method": "POST",
          "url": "https://api.telegram.org/bot8544365014:AAEgKwHUF7_iG2AizJND2NuOUouPE4uQymQ/sendMessage",
          "sendBody": true,
          "contentType": "raw",
          "rawContentType": "application/json",
          "body": "={ \"chat_id\": \"8305133249\", \"text\": {{ JSON.stringify($json.message) }} }",
          "options": {}
        }
      }
    ],
    "connections": {
      "Schedule": {
        "main": [
          [
            {
              "node": "Gmail",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Gmail": {
        "main": [
          [
            {
              "node": "Prepare Prompt",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Prepare Prompt": {
        "main": [
          [
            {
              "node": "Ask Gemini Pro",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Ask Gemini Pro": {
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
        "createdAt": "2026-03-17T12:26:12.445Z",
        "id": 203,
        "workflowId": "s8KeUS9yfSu2SDHV",
        "versionId": "dc18ef60-d28f-4556-96fb-69a24ed34564",
        "event": "deactivated",
        "userId": "c557a393-301d-4cd5-ada0-4ae8574f88c9"
      },
      {
        "createdAt": "2026-03-17T12:26:12.475Z",
        "id": 204,
        "workflowId": "s8KeUS9yfSu2SDHV",
        "versionId": "dc18ef60-d28f-4556-96fb-69a24ed34564",
        "event": "activated",
        "userId": "c557a393-301d-4cd5-ada0-4ae8574f88c9"
      },
      {
        "createdAt": "2026-03-20T12:33:35.878Z",
        "id": 223,
        "workflowId": "s8KeUS9yfSu2SDHV",
        "versionId": "dc18ef60-d28f-4556-96fb-69a24ed34564",
        "event": "deactivated",
        "userId": "c557a393-301d-4cd5-ada0-4ae8574f88c9"
      },
      {
        "createdAt": "2026-03-20T12:33:35.900Z",
        "id": 224,
        "workflowId": "s8KeUS9yfSu2SDHV",
        "versionId": "dc18ef60-d28f-4556-96fb-69a24ed34564",
        "event": "activated",
        "userId": "c557a393-301d-4cd5-ada0-4ae8574f88c9"
      }
    ]
  }
}
```

</details>

---

## DAIN REPORT Website Updater

| Field | Value |
|---|---|
| **ID** | `MLT6aICSFjvVMnoZ` |
| **Status** | 🟢 Active |
| **Schedule** | `0 */4 * * *` |
| **Backup file** | `dain_report_website_updater.json` |

**Nodes (12):**
  - `n8n-nodes-base.scheduleTrigger` — **Schedule 6:30AM**
  - `n8n-nodes-base.rssFeedRead` — **Fox World RSS**
  - `n8n-nodes-base.rssFeedRead` — **Fox Science RSS**
  - `n8n-nodes-base.rssFeedRead` — **Ars Technica RSS**
  - `n8n-nodes-base.rssFeedRead` — **BBC Science RSS**
  - `n8n-nodes-base.rssFeedRead` — **NPR News RSS**
  - `n8n-nodes-base.code` — **Format Digest**
  - `n8n-nodes-base.rssFeedRead` — **CNN RSS**
  - `n8n-nodes-base.rssFeedRead` — **Reuters via Yahoo RSS**
  - `n8n-nodes-base.httpRequest` — **Push to News Container**
  - `n8n-nodes-base.httpRequest` — **Execute Push**
  - `n8n-nodes-base.manualTrigger` — **Manual Trigger**

<details>
<summary>Full JSON config</summary>

```json
{
  "updatedAt": "2026-03-16T14:36:38.591Z",
  "createdAt": "2026-03-16T13:58:51.088Z",
  "id": "MLT6aICSFjvVMnoZ",
  "name": "DAIN REPORT Website Updater",
  "description": null,
  "active": true,
  "isArchived": false,
  "nodes": [
    {
      "id": "schedule",
      "name": "Schedule 6:30AM",
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
              "expression": "0 */4 * * *"
            }
          ]
        }
      },
      "alwaysOutputData": true
    },
    {
      "name": "Fox World RSS",
      "type": "n8n-nodes-base.rssFeedRead",
      "typeVersion": 1,
      "position": [
        200,
        100
      ],
      "parameters": {
        "url": "https://moxie.foxnews.com/google-publisher/world.xml"
      },
      "alwaysOutputData": true,
      "continueOnFail": true,
      "id": "9268fc0a-4bcf-4547-afaa-0e2b9abfee60"
    },
    {
      "name": "Fox Science RSS",
      "type": "n8n-nodes-base.rssFeedRead",
      "typeVersion": 1,
      "position": [
        200,
        220
      ],
      "parameters": {
        "url": "https://moxie.foxnews.com/google-publisher/science.xml"
      },
      "alwaysOutputData": true,
      "continueOnFail": true,
      "id": "533e76f1-a00f-4005-b16e-8b423910473b"
    },
    {
      "name": "Ars Technica RSS",
      "type": "n8n-nodes-base.rssFeedRead",
      "typeVersion": 1,
      "position": [
        200,
        340
      ],
      "parameters": {
        "url": "https://feeds.arstechnica.com/arstechnica/index"
      },
      "alwaysOutputData": true,
      "continueOnFail": true,
      "id": "5ff785fa-96a0-4555-b443-398170e57372"
    },
    {
      "name": "BBC Science RSS",
      "type": "n8n-nodes-base.rssFeedRead",
      "typeVersion": 1,
      "position": [
        200,
        460
      ],
      "parameters": {
        "url": "https://feeds.bbci.co.uk/news/science_and_environment/rss.xml"
      },
      "alwaysOutputData": true,
      "continueOnFail": true,
      "id": "0e4ef9f2-595f-4024-84ef-b6ef05b660e7"
    },
    {
      "name": "NPR News RSS",
      "type": "n8n-nodes-base.rssFeedRead",
      "typeVersion": 1,
      "position": [
        200,
        580
      ],
      "parameters": {
        "url": "https://feeds.npr.org/1001/rss.xml"
      },
      "alwaysOutputData": true,
      "continueOnFail": true,
      "id": "8c845e1d-5046-4f8b-a664-22c381c3cd0e"
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
        "jsCode": "\nconst today = new Date().toLocaleDateString('en-US', {weekday:'long', month:'long', day:'numeric'});\n\nfunction getTop(nodeName, n) {\n  try {\n    const items = $(nodeName).all();\n    return items.slice(0, n).map(i => ({\n      title: (i.json.title || '').replace(/[*[\\]]/g, '').trim(),\n      link: i.json.link || ''\n    })).filter(p => p.title);\n  } catch(e) { return []; }\n}\n\nlet html = `<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n<meta charset=\"UTF-8\">\n<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n<title>DAIN REPORT</title>\n<style>\n  body { background-color: #fcfcfc; color: #000; font-family: \"Times New Roman\", Times, serif; text-align: center; margin: 0; padding: 20px; }\n  .header { border-bottom: 2px solid #000; padding-bottom: 10px; margin-bottom: 20px; border-top: 1px solid #000; padding-top: 5px; }\n  h1 { font-family: \"Arial Black\", Gadget, sans-serif; font-size: 5rem; margin: 0; text-transform: uppercase; font-style: italic; letter-spacing: -4px; line-height: 1; }\n  .date { font-weight: bold; font-size: 1.2rem; margin-top: 5px; text-transform: uppercase; }\n  .container { display: flex; flex-wrap: wrap; justify-content: center; gap: 40px; text-align: left; max-width: 1200px; margin: 0 auto; }\n  .column { flex: 1; min-width: 300px; border-right: 1px solid #ddd; padding-right: 20px; }\n  .column:last-child { border-right: none; }\n  .section-title { color: #cc0000; font-family: Arial, sans-serif; font-weight: bold; font-size: 0.9rem; border-bottom: 1px solid #000; margin-top: 25px; margin-bottom: 15px; padding-bottom: 2px; }\n  a { display: block; color: #0000ee; text-decoration: none; font-size: 1.4rem; font-weight: bold; line-height: 1.1; margin-bottom: 20px; }\n  a:hover { text-decoration: underline; background: #ffff00; }\n</style>\n</head>\n<body>\n  <div class=\"header\">\n    <h1>DAIN REPORT</h1>\n    <div class=\"date\">${today}</div>\n  </div>\n  <div class=\"container\">\n`;\n\nlet col1 = '<div class=\"column\">';\nlet col2 = '<div class=\"column\">';\nlet col3 = '<div class=\"column\">';\n\nconst world = getTop('Fox World RSS', 5);\nif (world.length) {\n  col1 += '<div class=\"section-title\">WORLD NEWS</div>';\n  for (const p of world) col1 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nconst reuters = getTop('Reuters via Yahoo RSS', 5);\nif (reuters.length) {\n  col1 += '<div class=\"section-title\">REUTERS</div>';\n  for (const p of reuters) col1 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nconst cnn = getTop('CNN RSS', 5);\nif (cnn.length) {\n  col2 += '<div class=\"section-title\">TOP HEADLINES</div>';\n  for (const p of cnn) col2 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nconst npr = getTop('NPR News RSS', 5);\nif (npr.length) {\n  col2 += '<div class=\"section-title\">NPR</div>';\n  for (const p of npr) col2 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nconst tech = getTop('Ars Technica RSS', 5);\nif (tech.length) {\n  col3 += '<div class=\"section-title\">TECHNOLOGY</div>';\n  for (const p of tech) col3 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nconst sci = [...getTop('Fox Science RSS', 3), ...getTop('BBC Science RSS', 3)].slice(0, 5);\nif (sci.length) {\n  col3 += '<div class=\"section-title\">SCIENCE</div>';\n  for (const p of sci) col3 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nhtml += col1 + '</div>' + col2 + '</div>' + col3 + '</div>' + '</div></body></html>';\n\nreturn [{ json: { html: html } }];\n"
      },
      "alwaysOutputData": true
    },
    {
      "name": "CNN RSS",
      "type": "n8n-nodes-base.rssFeedRead",
      "typeVersion": 1,
      "position": [
        200,
        700
      ],
      "parameters": {
        "url": "http://rss.cnn.com/rss/cnn_topstories.rss"
      },
      "alwaysOutputData": true,
      "continueOnFail": true,
      "id": "6021c416-3793-4f26-add4-36648e97f466"
    },
    {
      "name": "Reuters via Yahoo RSS",
      "type": "n8n-nodes-base.rssFeedRead",
      "typeVersion": 1,
      "position": [
        200,
        820
      ],
      "parameters": {
        "url": "https://news.yahoo.com/rss/world"
      },
      "alwaysOutputData": true,
      "continueOnFail": true,
      "id": "e78da193-5624-42db-9077-9659f9f14ee8"
    },
    {
      "id": "push-to-portainer",
      "name": "Push to News Container",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        720,
        360
      ],
      "parameters": {
        "method": "POST",
        "url": "http://192.168.200.220:9000/api/endpoints/6/docker/containers/milo_news/exec",
        "sendHeaders": true,
        "specifyHeaders": "keypair",
        "headerParameters": {
          "parameters": [
            {
              "name": "X-API-Key",
              "value": "ptr_jVGvpkWmxmPusWm3yZYeEvMU8LLMvYjqDm8iLmsRQjk="
            }
          ]
        },
        "sendBody": true,
        "specifyBody": "json",
        "jsonBody": "={{ JSON.stringify({ AttachStdout: true, AttachStderr: true, Cmd: ['sh', '-c', 'echo ' + Buffer.from($json.html).toString('base64') + ' | base64 -d > /usr/share/nginx/html/index.html'] }) }}"
      }
    },
    {
      "id": "execute-push",
      "name": "Execute Push",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        940,
        360
      ],
      "parameters": {
        "method": "POST",
        "url": "=http://192.168.200.220:9000/api/endpoints/6/docker/exec/{{ $node['Push to News Container'].json.Id }}/start",
        "sendHeaders": true,
        "specifyHeaders": "keypair",
        "headerParameters": {
          "parameters": [
            {
              "name": "X-API-Key",
              "value": "ptr_jVGvpkWmxmPusWm3yZYeEvMU8LLMvYjqDm8iLmsRQjk="
            }
          ]
        },
        "sendBody": true,
        "specifyBody": "json",
        "jsonBody": "{\"Detach\": false, \"Tty\": false}"
      }
    },
    {
      "id": "manual-trigger",
      "name": "Manual Trigger",
      "type": "n8n-nodes-base.manualTrigger",
      "typeVersion": 1,
      "position": [
        0,
        -200
      ],
      "parameters": {}
    }
  ],
  "connections": {
    "Schedule 6:30AM": {
      "main": [
        [
          {
            "node": "Fox World RSS",
            "type": "main",
            "index": 0
          },
          {
            "node": "Fox Science RSS",
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
            "node": "NPR News RSS",
            "type": "main",
            "index": 0
          },
          {
            "node": "CNN RSS",
            "type": "main",
            "index": 0
          },
          {
            "node": "Reuters via Yahoo RSS",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Fox World RSS": {
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
    "Fox Science RSS": {
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
    "NPR News RSS": {
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
            "node": "Push to News Container",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "CNN RSS": {
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
    "Reuters via Yahoo RSS": {
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
    "Push to News Container": {
      "main": [
        [
          {
            "node": "Execute Push",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Manual Trigger": {
      "main": [
        [
          {
            "node": "Fox World RSS",
            "type": "main",
            "index": 0
          },
          {
            "node": "Fox Science RSS",
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
            "node": "NPR News RSS",
            "type": "main",
            "index": 0
          },
          {
            "node": "CNN RSS",
            "type": "main",
            "index": 0
          },
          {
            "node": "Reuters via Yahoo RSS",
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
    "availableInMCP": false,
    "saveDataSuccessExecution": "all"
  },
  "staticData": {
    "node:Schedule 6:30AM": {
      "recurrenceRules": []
    }
  },
  "meta": null,
  "pinData": null,
  "versionId": "3adf0f71-5b40-42f9-ade6-35c60db99bb0",
  "activeVersionId": "3adf0f71-5b40-42f9-ade6-35c60db99bb0",
  "versionCounter": 25,
  "triggerCount": 1,
  "shared": [
    {
      "updatedAt": "2026-03-16T13:58:51.088Z",
      "createdAt": "2026-03-16T13:58:51.088Z",
      "role": "workflow:owner",
      "workflowId": "MLT6aICSFjvVMnoZ",
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
    "updatedAt": "2026-03-16T14:36:38.595Z",
    "createdAt": "2026-03-16T14:36:38.595Z",
    "versionId": "3adf0f71-5b40-42f9-ade6-35c60db99bb0",
    "workflowId": "MLT6aICSFjvVMnoZ",
    "nodes": [
      {
        "id": "schedule",
        "name": "Schedule 6:30AM",
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
                "expression": "0 */4 * * *"
              }
            ]
          }
        },
        "alwaysOutputData": true
      },
      {
        "name": "Fox World RSS",
        "type": "n8n-nodes-base.rssFeedRead",
        "typeVersion": 1,
        "position": [
          200,
          100
        ],
        "parameters": {
          "url": "https://moxie.foxnews.com/google-publisher/world.xml"
        },
        "alwaysOutputData": true,
        "continueOnFail": true,
        "id": "9268fc0a-4bcf-4547-afaa-0e2b9abfee60"
      },
      {
        "name": "Fox Science RSS",
        "type": "n8n-nodes-base.rssFeedRead",
        "typeVersion": 1,
        "position": [
          200,
          220
        ],
        "parameters": {
          "url": "https://moxie.foxnews.com/google-publisher/science.xml"
        },
        "alwaysOutputData": true,
        "continueOnFail": true,
        "id": "533e76f1-a00f-4005-b16e-8b423910473b"
      },
      {
        "name": "Ars Technica RSS",
        "type": "n8n-nodes-base.rssFeedRead",
        "typeVersion": 1,
        "position": [
          200,
          340
        ],
        "parameters": {
          "url": "https://feeds.arstechnica.com/arstechnica/index"
        },
        "alwaysOutputData": true,
        "continueOnFail": true,
        "id": "5ff785fa-96a0-4555-b443-398170e57372"
      },
      {
        "name": "BBC Science RSS",
        "type": "n8n-nodes-base.rssFeedRead",
        "typeVersion": 1,
        "position": [
          200,
          460
        ],
        "parameters": {
          "url": "https://feeds.bbci.co.uk/news/science_and_environment/rss.xml"
        },
        "alwaysOutputData": true,
        "continueOnFail": true,
        "id": "0e4ef9f2-595f-4024-84ef-b6ef05b660e7"
      },
      {
        "name": "NPR News RSS",
        "type": "n8n-nodes-base.rssFeedRead",
        "typeVersion": 1,
        "position": [
          200,
          580
        ],
        "parameters": {
          "url": "https://feeds.npr.org/1001/rss.xml"
        },
        "alwaysOutputData": true,
        "continueOnFail": true,
        "id": "8c845e1d-5046-4f8b-a664-22c381c3cd0e"
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
          "jsCode": "\nconst today = new Date().toLocaleDateString('en-US', {weekday:'long', month:'long', day:'numeric'});\n\nfunction getTop(nodeName, n) {\n  try {\n    const items = $(nodeName).all();\n    return items.slice(0, n).map(i => ({\n      title: (i.json.title || '').replace(/[*[\\]]/g, '').trim(),\n      link: i.json.link || ''\n    })).filter(p => p.title);\n  } catch(e) { return []; }\n}\n\nlet html = `<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n<meta charset=\"UTF-8\">\n<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n<title>DAIN REPORT</title>\n<style>\n  body { background-color: #fcfcfc; color: #000; font-family: \"Times New Roman\", Times, serif; text-align: center; margin: 0; padding: 20px; }\n  .header { border-bottom: 2px solid #000; padding-bottom: 10px; margin-bottom: 20px; border-top: 1px solid #000; padding-top: 5px; }\n  h1 { font-family: \"Arial Black\", Gadget, sans-serif; font-size: 5rem; margin: 0; text-transform: uppercase; font-style: italic; letter-spacing: -4px; line-height: 1; }\n  .date { font-weight: bold; font-size: 1.2rem; margin-top: 5px; text-transform: uppercase; }\n  .container { display: flex; flex-wrap: wrap; justify-content: center; gap: 40px; text-align: left; max-width: 1200px; margin: 0 auto; }\n  .column { flex: 1; min-width: 300px; border-right: 1px solid #ddd; padding-right: 20px; }\n  .column:last-child { border-right: none; }\n  .section-title { color: #cc0000; font-family: Arial, sans-serif; font-weight: bold; font-size: 0.9rem; border-bottom: 1px solid #000; margin-top: 25px; margin-bottom: 15px; padding-bottom: 2px; }\n  a { display: block; color: #0000ee; text-decoration: none; font-size: 1.4rem; font-weight: bold; line-height: 1.1; margin-bottom: 20px; }\n  a:hover { text-decoration: underline; background: #ffff00; }\n</style>\n</head>\n<body>\n  <div class=\"header\">\n    <h1>DAIN REPORT</h1>\n    <div class=\"date\">${today}</div>\n  </div>\n  <div class=\"container\">\n`;\n\nlet col1 = '<div class=\"column\">';\nlet col2 = '<div class=\"column\">';\nlet col3 = '<div class=\"column\">';\n\nconst world = getTop('Fox World RSS', 5);\nif (world.length) {\n  col1 += '<div class=\"section-title\">WORLD NEWS</div>';\n  for (const p of world) col1 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nconst reuters = getTop('Reuters via Yahoo RSS', 5);\nif (reuters.length) {\n  col1 += '<div class=\"section-title\">REUTERS</div>';\n  for (const p of reuters) col1 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nconst cnn = getTop('CNN RSS', 5);\nif (cnn.length) {\n  col2 += '<div class=\"section-title\">TOP HEADLINES</div>';\n  for (const p of cnn) col2 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nconst npr = getTop('NPR News RSS', 5);\nif (npr.length) {\n  col2 += '<div class=\"section-title\">NPR</div>';\n  for (const p of npr) col2 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nconst tech = getTop('Ars Technica RSS', 5);\nif (tech.length) {\n  col3 += '<div class=\"section-title\">TECHNOLOGY</div>';\n  for (const p of tech) col3 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nconst sci = [...getTop('Fox Science RSS', 3), ...getTop('BBC Science RSS', 3)].slice(0, 5);\nif (sci.length) {\n  col3 += '<div class=\"section-title\">SCIENCE</div>';\n  for (const p of sci) col3 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nhtml += col1 + '</div>' + col2 + '</div>' + col3 + '</div>' + '</div></body></html>';\n\nreturn [{ json: { html: html } }];\n"
        },
        "alwaysOutputData": true
      },
      {
        "name": "CNN RSS",
        "type": "n8n-nodes-base.rssFeedRead",
        "typeVersion": 1,
        "position": [
          200,
          700
        ],
        "parameters": {
          "url": "http://rss.cnn.com/rss/cnn_topstories.rss"
        },
        "alwaysOutputData": true,
        "continueOnFail": true,
        "id": "6021c416-3793-4f26-add4-36648e97f466"
      },
      {
        "name": "Reuters via Yahoo RSS",
        "type": "n8n-nodes-base.rssFeedRead",
        "typeVersion": 1,
        "position": [
          200,
          820
        ],
        "parameters": {
          "url": "https://news.yahoo.com/rss/world"
        },
        "alwaysOutputData": true,
        "continueOnFail": true,
        "id": "e78da193-5624-42db-9077-9659f9f14ee8"
      },
      {
        "id": "push-to-portainer",
        "name": "Push to News Container",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [
          720,
          360
        ],
        "parameters": {
          "method": "POST",
          "url": "http://192.168.200.220:9000/api/endpoints/6/docker/containers/milo_news/exec",
          "sendHeaders": true,
          "specifyHeaders": "keypair",
          "headerParameters": {
            "parameters": [
              {
                "name": "X-API-Key",
                "value": "ptr_jVGvpkWmxmPusWm3yZYeEvMU8LLMvYjqDm8iLmsRQjk="
              }
            ]
          },
          "sendBody": true,
          "specifyBody": "json",
          "jsonBody": "={{ JSON.stringify({ AttachStdout: true, AttachStderr: true, Cmd: ['sh', '-c', 'echo ' + Buffer.from($json.html).toString('base64') + ' | base64 -d > /usr/share/nginx/html/index.html'] }) }}"
        }
      },
      {
        "id": "execute-push",
        "name": "Execute Push",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [
          940,
          360
        ],
        "parameters": {
          "method": "POST",
          "url": "=http://192.168.200.220:9000/api/endpoints/6/docker/exec/{{ $node['Push to News Container'].json.Id }}/start",
          "sendHeaders": true,
          "specifyHeaders": "keypair",
          "headerParameters": {
            "parameters": [
              {
                "name": "X-API-Key",
                "value": "ptr_jVGvpkWmxmPusWm3yZYeEvMU8LLMvYjqDm8iLmsRQjk="
              }
            ]
          },
          "sendBody": true,
          "specifyBody": "json",
          "jsonBody": "{\"Detach\": false, \"Tty\": false}"
        }
      },
      {
        "id": "manual-trigger",
        "name": "Manual Trigger",
        "type": "n8n-nodes-base.manualTrigger",
        "typeVersion": 1,
        "position": [
          0,
          -200
        ],
        "parameters": {}
      }
    ],
    "connections": {
      "Schedule 6:30AM": {
        "main": [
          [
            {
              "node": "Fox World RSS",
              "type": "main",
              "index": 0
            },
            {
              "node": "Fox Science RSS",
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
              "node": "NPR News RSS",
              "type": "main",
              "index": 0
            },
            {
              "node": "CNN RSS",
              "type": "main",
              "index": 0
            },
            {
              "node": "Reuters via Yahoo RSS",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Fox World RSS": {
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
      "Fox Science RSS": {
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
      "NPR News RSS": {
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
              "node": "Push to News Container",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "CNN RSS": {
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
      "Reuters via Yahoo RSS": {
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
      "Push to News Container": {
        "main": [
          [
            {
              "node": "Execute Push",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Manual Trigger": {
        "main": [
          [
            {
              "node": "Fox World RSS",
              "type": "main",
              "index": 0
            },
            {
              "node": "Fox Science RSS",
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
              "node": "NPR News RSS",
              "type": "main",
              "index": 0
            },
            {
              "node": "CNN RSS",
              "type": "main",
              "index": 0
            },
            {
              "node": "Reuters via Yahoo RSS",
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
        "createdAt": "2026-03-16T14:36:38.655Z",
        "id": 201,
        "workflowId": "MLT6aICSFjvVMnoZ",
        "versionId": "3adf0f71-5b40-42f9-ade6-35c60db99bb0",
        "event": "deactivated",
        "userId": "c557a393-301d-4cd5-ada0-4ae8574f88c9"
      },
      {
        "createdAt": "2026-03-16T14:36:38.675Z",
        "id": 202,
        "workflowId": "MLT6aICSFjvVMnoZ",
        "versionId": "3adf0f71-5b40-42f9-ade6-35c60db99bb0",
        "event": "activated",
        "userId": "c557a393-301d-4cd5-ada0-4ae8574f88c9"
      }
    ]
  }
}
```

</details>

---

## NextDoor Alert Filter

| Field | Value |
|---|---|
| **ID** | `LywRjysHEqXPNN2B` |
| **Status** | 🟢 Active |
| **Backup file** | `nextdoor_alert_filter.json` |

**Nodes (10):**
  - `n8n-nodes-base.scheduleTrigger` — **Schedule Every 30 Min**
  - `n8n-nodes-base.gmail` — **Get NextDoor Emails**
  - `n8n-nodes-base.code` — **Filter Alerts vs Trash**
  - `n8n-nodes-base.httpRequest` — **Alert Telegram**
  - `n8n-nodes-base.gmail` — **Move to Trash**
  - `n8n-nodes-base.gmail` — **Mark Alert Read**
  - `n8n-nodes-base.if` — **Route Alert or Trash**
  - `n8n-nodes-base.mySql` — **Already Alerted?**
  - `n8n-nodes-base.if` — **Is New Alert?**
  - `n8n-nodes-base.mySql` — **Mark Alerted**

<details>
<summary>Full JSON config</summary>

```json
{
  "updatedAt": "2026-03-30T13:33:26.825Z",
  "createdAt": "2026-03-11T19:37:43.930Z",
  "id": "LywRjysHEqXPNN2B",
  "name": "NextDoor Alert Filter",
  "description": null,
  "active": true,
  "isArchived": false,
  "nodes": [
    {
      "id": "schedule",
      "name": "Schedule Every 30 Min",
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
              "field": "minutes",
              "minutesInterval": 30
            }
          ]
        }
      }
    },
    {
      "id": "gmail-fetch",
      "name": "Get NextDoor Emails",
      "type": "n8n-nodes-base.gmail",
      "typeVersion": 2.1,
      "position": [
        200,
        0
      ],
      "parameters": {
        "operation": "getAll",
        "limit": 50,
        "simple": true,
        "filters": {
          "q": "from:nextdoor.com in:inbox is:unread"
        }
      },
      "credentials": {
        "gmailOAuth2": {
          "id": "73FQ8r7lzSZjobXf",
          "name": "Gmail account"
        }
      }
    },
    {
      "id": "filter-logic",
      "name": "Filter Alerts vs Trash",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        400,
        0
      ],
      "parameters": {
        "jsCode": "\nconst result = [];\n\nfor (const email of $input.all()) {\n    const subject = (email.json.subject || '').toLowerCase();\n    const body = (email.json.snippet || email.json.textPlain || '').toLowerCase();\n    \n    const isAlert = subject.includes('alert') || body.includes('alert') || \n        subject.includes('fraud') || body.includes('fraud') ||\n        subject.includes('crime') || body.includes('crime') ||\n        subject.includes('police') || body.includes('police') ||\n        subject.includes('stolen') || body.includes('stolen') ||\n        subject.includes('warning') || body.includes('warning');\n    \n    result.push({ json: { ...email.json, _isAlert: isAlert } });\n}\n\nif (result.length === 0) {\n    return [{ json: { _isAlert: false, _empty: true } }];\n}\n\nreturn result;\n"
      }
    },
    {
      "id": "telegram-alert",
      "name": "Alert Telegram",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        1080,
        -100
      ],
      "parameters": {
        "method": "POST",
        "url": "https://api.telegram.org/bot8544365014:AAEgKwHUF7_iG2AizJND2NuOUouPE4uQymQ/sendMessage",
        "sendBody": true,
        "contentType": "raw",
        "rawContentType": "application/json",
        "body": "={ \"chat_id\": \"8305133249\", \"text\": \"\ud83d\udea8 *NextDoor Alert* \ud83d\udea8\\n\\n*Subject:* {{ $json.subject }}\\n*Preview:* {{ $json.snippet }}\\n\\n[View in Gmail](https://mail.google.com/mail/u/0/#inbox/{{ $json.messageId }})\", \"parse_mode\": \"Markdown\" }",
        "options": {}
      }
    },
    {
      "id": "gmail-trash",
      "name": "Move to Trash",
      "type": "n8n-nodes-base.gmail",
      "typeVersion": 2.1,
      "position": [
        600,
        100
      ],
      "parameters": {
        "operation": "update",
        "messageId": "={{ $json.messageId }}",
        "updateFields": {
          "removeLabelIds": [
            "INBOX"
          ],
          "addLabelIds": [
            "TRASH"
          ]
        }
      },
      "credentials": {
        "gmailOAuth2": {
          "id": "73FQ8r7lzSZjobXf",
          "name": "Gmail account"
        }
      }
    },
    {
      "id": "gmail-mark-read-alerts",
      "name": "Mark Alert Read",
      "type": "n8n-nodes-base.gmail",
      "typeVersion": 2.1,
      "position": [
        800,
        -100
      ],
      "parameters": {
        "operation": "update",
        "messageId": "={{ $json.messageId }}",
        "updateFields": {
          "removeLabelIds": [
            "UNREAD"
          ]
        }
      },
      "credentials": {
        "gmailOAuth2": {
          "id": "73FQ8r7lzSZjobXf",
          "name": "Gmail account"
        }
      }
    },
    {
      "id": "split-route",
      "name": "Route Alert or Trash",
      "type": "n8n-nodes-base.if",
      "typeVersion": 2,
      "position": [
        640,
        0
      ],
      "parameters": {
        "conditions": {
          "options": {
            "caseSensitive": true,
            "leftValue": "",
            "typeValidation": "strict"
          },
          "conditions": [
            {
              "id": "is-alert",
              "leftValue": "={{ $json._isAlert }}",
              "rightValue": true,
              "operator": {
                "type": "boolean",
                "operation": "true",
                "singleValue": true
              }
            }
          ],
          "combinator": "and"
        }
      }
    },
    {
      "id": "nd-check-sent",
      "name": "Already Alerted?",
      "type": "n8n-nodes-base.mySql",
      "typeVersion": 2.4,
      "position": [
        600,
        -100
      ],
      "parameters": {
        "operation": "executeQuery",
        "query": "=SELECT id FROM sent_nextdoor_alerts WHERE message_id = '{{ $json.id }}' LIMIT 1;"
      },
      "credentials": {
        "mySql": {
          "id": "vZlctd4g664kyvko",
          "name": "MySQL account"
        }
      }
    },
    {
      "id": "nd-is-new",
      "name": "Is New Alert?",
      "type": "n8n-nodes-base.if",
      "typeVersion": 2,
      "position": [
        840,
        -100
      ],
      "parameters": {
        "conditions": {
          "options": {
            "caseSensitive": true,
            "leftValue": "",
            "typeValidation": "strict"
          },
          "conditions": [
            {
              "id": "empty-check",
              "leftValue": "={{ $json.id }}",
              "rightValue": "",
              "operator": {
                "type": "string",
                "operation": "empty",
                "singleValue": true
              }
            }
          ],
          "combinator": "and"
        }
      }
    },
    {
      "id": "nd-mark-sent",
      "name": "Mark Alerted",
      "type": "n8n-nodes-base.mySql",
      "typeVersion": 2.4,
      "position": [
        1320,
        -100
      ],
      "parameters": {
        "operation": "insert",
        "table": {
          "value": "sent_nextdoor_alerts",
          "__rl": true,
          "mode": "name"
        },
        "columns": {
          "mappingMode": "defineBelow",
          "values": [
            {
              "column": "message_id",
              "type": "string",
              "value": "={{ $('Route Alert or Trash').item.json.id }}"
            },
            {
              "column": "subject",
              "type": "string",
              "value": "={{ $('Route Alert or Trash').item.json.subject }}"
            }
          ]
        }
      },
      "credentials": {
        "mySql": {
          "id": "vZlctd4g664kyvko",
          "name": "MySQL account"
        }
      }
    }
  ],
  "connections": {
    "Schedule Every 30 Min": {
      "main": [
        [
          {
            "node": "Get NextDoor Emails",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Get NextDoor Emails": {
      "main": [
        [
          {
            "node": "Filter Alerts vs Trash",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Filter Alerts vs Trash": {
      "main": [
        [
          {
            "node": "Route Alert or Trash",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Alert Telegram": {
      "main": [
        [
          {
            "node": "Mark Alerted",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Route Alert or Trash": {
      "main": [
        [
          {
            "node": "Already Alerted?",
            "type": "main",
            "index": 0
          }
        ],
        [
          {
            "node": "Move to Trash",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Already Alerted?": {
      "main": [
        [
          {
            "node": "Is New Alert?",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Is New Alert?": {
      "main": [
        [
          {
            "node": "Alert Telegram",
            "type": "main",
            "index": 0
          }
        ],
        []
      ]
    }
  },
  "settings": {
    "executionOrder": "v1",
    "callerPolicy": "workflowsFromSameOwner",
    "availableInMCP": false
  },
  "staticData": {
    "node:Schedule Every 30 Min": {
      "recurrenceRules": []
    }
  },
  "meta": null,
  "pinData": null,
  "versionId": "4dd70e3a-443b-46e1-8bce-5c2e75c4f0ee",
  "activeVersionId": "4dd70e3a-443b-46e1-8bce-5c2e75c4f0ee",
  "versionCounter": 23,
  "triggerCount": 1,
  "shared": [
    {
      "updatedAt": "2026-03-11T19:37:43.930Z",
      "createdAt": "2026-03-11T19:37:43.930Z",
      "role": "workflow:owner",
      "workflowId": "LywRjysHEqXPNN2B",
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
    "updatedAt": "2026-03-30T13:33:26.827Z",
    "createdAt": "2026-03-30T13:33:26.827Z",
    "versionId": "4dd70e3a-443b-46e1-8bce-5c2e75c4f0ee",
    "workflowId": "LywRjysHEqXPNN2B",
    "nodes": [
      {
        "id": "schedule",
        "name": "Schedule Every 30 Min",
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
                "field": "minutes",
                "minutesInterval": 30
              }
            ]
          }
        }
      },
      {
        "id": "gmail-fetch",
        "name": "Get NextDoor Emails",
        "type": "n8n-nodes-base.gmail",
        "typeVersion": 2.1,
        "position": [
          200,
          0
        ],
        "parameters": {
          "operation": "getAll",
          "limit": 50,
          "simple": true,
          "filters": {
            "q": "from:nextdoor.com in:inbox is:unread"
          }
        },
        "credentials": {
          "gmailOAuth2": {
            "id": "73FQ8r7lzSZjobXf",
            "name": "Gmail account"
          }
        }
      },
      {
        "id": "filter-logic",
        "name": "Filter Alerts vs Trash",
        "type": "n8n-nodes-base.code",
        "typeVersion": 2,
        "position": [
          400,
          0
        ],
        "parameters": {
          "jsCode": "\nconst result = [];\n\nfor (const email of $input.all()) {\n    const subject = (email.json.subject || '').toLowerCase();\n    const body = (email.json.snippet || email.json.textPlain || '').toLowerCase();\n    \n    const isAlert = subject.includes('alert') || body.includes('alert') || \n        subject.includes('fraud') || body.includes('fraud') ||\n        subject.includes('crime') || body.includes('crime') ||\n        subject.includes('police') || body.includes('police') ||\n        subject.includes('stolen') || body.includes('stolen') ||\n        subject.includes('warning') || body.includes('warning');\n    \n    result.push({ json: { ...email.json, _isAlert: isAlert } });\n}\n\nif (result.length === 0) {\n    return [{ json: { _isAlert: false, _empty: true } }];\n}\n\nreturn result;\n"
        }
      },
      {
        "id": "telegram-alert",
        "name": "Alert Telegram",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [
          1080,
          -100
        ],
        "parameters": {
          "method": "POST",
          "url": "https://api.telegram.org/bot8544365014:AAEgKwHUF7_iG2AizJND2NuOUouPE4uQymQ/sendMessage",
          "sendBody": true,
          "contentType": "raw",
          "rawContentType": "application/json",
          "body": "={ \"chat_id\": \"8305133249\", \"text\": \"\ud83d\udea8 *NextDoor Alert* \ud83d\udea8\\n\\n*Subject:* {{ $json.subject }}\\n*Preview:* {{ $json.snippet }}\\n\\n[View in Gmail](https://mail.google.com/mail/u/0/#inbox/{{ $json.messageId }})\", \"parse_mode\": \"Markdown\" }",
          "options": {}
        }
      },
      {
        "id": "gmail-trash",
        "name": "Move to Trash",
        "type": "n8n-nodes-base.gmail",
        "typeVersion": 2.1,
        "position": [
          600,
          100
        ],
        "parameters": {
          "operation": "update",
          "messageId": "={{ $json.messageId }}",
          "updateFields": {
            "removeLabelIds": [
              "INBOX"
            ],
            "addLabelIds": [
              "TRASH"
            ]
          }
        },
        "credentials": {
          "gmailOAuth2": {
            "id": "73FQ8r7lzSZjobXf",
            "name": "Gmail account"
          }
        }
      },
      {
        "id": "gmail-mark-read-alerts",
        "name": "Mark Alert Read",
        "type": "n8n-nodes-base.gmail",
        "typeVersion": 2.1,
        "position": [
          800,
          -100
        ],
        "parameters": {
          "operation": "update",
          "messageId": "={{ $json.messageId }}",
          "updateFields": {
            "removeLabelIds": [
              "UNREAD"
            ]
          }
        },
        "credentials": {
          "gmailOAuth2": {
            "id": "73FQ8r7lzSZjobXf",
            "name": "Gmail account"
          }
        }
      },
      {
        "id": "split-route",
        "name": "Route Alert or Trash",
        "type": "n8n-nodes-base.if",
        "typeVersion": 2,
        "position": [
          640,
          0
        ],
        "parameters": {
          "conditions": {
            "options": {
              "caseSensitive": true,
              "leftValue": "",
              "typeValidation": "strict"
            },
            "conditions": [
              {
                "id": "is-alert",
                "leftValue": "={{ $json._isAlert }}",
                "rightValue": true,
                "operator": {
                  "type": "boolean",
                  "operation": "true",
                  "singleValue": true
                }
              }
            ],
            "combinator": "and"
          }
        }
      },
      {
        "id": "nd-check-sent",
        "name": "Already Alerted?",
        "type": "n8n-nodes-base.mySql",
        "typeVersion": 2.4,
        "position": [
          600,
          -100
        ],
        "parameters": {
          "operation": "executeQuery",
          "query": "=SELECT id FROM sent_nextdoor_alerts WHERE message_id = '{{ $json.id }}' LIMIT 1;"
        },
        "credentials": {
          "mySql": {
            "id": "vZlctd4g664kyvko",
            "name": "MySQL account"
          }
        }
      },
      {
        "id": "nd-is-new",
        "name": "Is New Alert?",
        "type": "n8n-nodes-base.if",
        "typeVersion": 2,
        "position": [
          840,
          -100
        ],
        "parameters": {
          "conditions": {
            "options": {
              "caseSensitive": true,
              "leftValue": "",
              "typeValidation": "strict"
            },
            "conditions": [
              {
                "id": "empty-check",
                "leftValue": "={{ $json.id }}",
                "rightValue": "",
                "operator": {
                  "type": "string",
                  "operation": "empty",
                  "singleValue": true
                }
              }
            ],
            "combinator": "and"
          }
        }
      },
      {
        "id": "nd-mark-sent",
        "name": "Mark Alerted",
        "type": "n8n-nodes-base.mySql",
        "typeVersion": 2.4,
        "position": [
          1320,
          -100
        ],
        "parameters": {
          "operation": "insert",
          "table": {
            "value": "sent_nextdoor_alerts",
            "__rl": true,
            "mode": "name"
          },
          "columns": {
            "mappingMode": "defineBelow",
            "values": [
              {
                "column": "message_id",
                "type": "string",
                "value": "={{ $('Route Alert or Trash').item.json.id }}"
              },
              {
                "column": "subject",
                "type": "string",
                "value": "={{ $('Route Alert or Trash').item.json.subject }}"
              }
            ]
          }
        },
        "credentials": {
          "mySql": {
            "id": "vZlctd4g664kyvko",
            "name": "MySQL account"
          }
        }
      }
    ],
    "connections": {
      "Schedule Every 30 Min": {
        "main": [
          [
            {
              "node": "Get NextDoor Emails",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Get NextDoor Emails": {
        "main": [
          [
            {
              "node": "Filter Alerts vs Trash",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Filter Alerts vs Trash": {
        "main": [
          [
            {
              "node": "Route Alert or Trash",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Alert Telegram": {
        "main": [
          [
            {
              "node": "Mark Alerted",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Route Alert or Trash": {
        "main": [
          [
            {
              "node": "Already Alerted?",
              "type": "main",
              "index": 0
            }
          ],
          [
            {
              "node": "Move to Trash",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Already Alerted?": {
        "main": [
          [
            {
              "node": "Is New Alert?",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Is New Alert?": {
        "main": [
          [
            {
              "node": "Alert Telegram",
              "type": "main",
              "index": 0
            }
          ],
          []
        ]
      }
    },
    "authors": "DAIN BENTLEY",
    "name": null,
    "description": null,
    "autosaved": false,
    "workflowPublishHistory": [
      {
        "createdAt": "2026-03-30T13:33:26.918Z",
        "id": 249,
        "workflowId": "LywRjysHEqXPNN2B",
        "versionId": "4dd70e3a-443b-46e1-8bce-5c2e75c4f0ee",
        "event": "deactivated",
        "userId": "c557a393-301d-4cd5-ada0-4ae8574f88c9"
      },
      {
        "createdAt": "2026-03-30T13:33:26.963Z",
        "id": 250,
        "workflowId": "LywRjysHEqXPNN2B",
        "versionId": "4dd70e3a-443b-46e1-8bce-5c2e75c4f0ee",
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

**Nodes (12):**
  - `n8n-nodes-base.scheduleTrigger` — **Schedule 7AM**
  - `n8n-nodes-base.httpRequest` — **Ask Gemini**
  - `n8n-nodes-base.code` — **Format Message**
  - `n8n-nodes-base.httpRequest` — **Send to Telegram**
  - `n8n-nodes-base.httpRequest` — **Push to Blog Container**
  - `n8n-nodes-base.httpRequest` — **Execute Push**
  - `n8n-nodes-base.webhook` — **Webhook**
  - `n8n-nodes-base.code` — **Check DB**
  - `n8n-nodes-base.if` — **Is New?**
  - `n8n-nodes-base.httpRequest` — **Regenerate**
  - `n8n-nodes-base.code` — **Format Regen**
  - `n8n-nodes-base.code` — **Mark Sent**

<details>
<summary>Full JSON config</summary>

```json
{
  "updatedAt": "2026-04-06T15:59:46.793Z",
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
      "name": "Ask Gemini",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        240,
        0
      ],
      "parameters": {
        "method": "POST",
        "url": "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=AIzaSyAnnVmRDJTCRGKBvM80tEGpKmBa-f0CFpY",
        "sendBody": true,
        "contentType": "raw",
        "rawContentType": "application/json",
        "body": "{\"contents\": [{\"parts\": [{\"text\": \"Give me one genuinely interesting, obscure, or surprising fact. Keep it to 2-3 sentences max. No intro, just the fact.\"}]}], \"generationConfig\": {\"temperature\": 0.9}}",
        "options": {},
        "headerParameters": {
          "parameters": [
            {
              "name": "Content-Type",
              "value": "application/json"
            }
          ]
        }
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
        "jsCode": "\ntry {\n  const text = $input.first().json.candidates[0].content.parts[0].text;\n  const content = text.trim();\n  \n  // Format for Telegram\n  const tg_msg = '\ud83e\udde0 *Daily Fact*\\n\\n' + content;\n  \n  // Generate filename and title\n  const date = new Date();\n  const dateStr = date.toISOString().split('T')[0];\n  const slug = content.substring(0, 30).toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');\n  const filename = `daily-fact-${dateStr}-${slug}.html`;\n  \n  // Format for Blog HTML\n  const displayDate = date.toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });\n  \n  const html = `<!DOCTYPE html>\n<html lang=\"en\">\n<head><meta charset=\"UTF-8\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"><title>Daily Fact | MILO's Terminal</title><style>\n  *, *::before, *::after { box-sizing: border-box; }\n  body { font-family: monospace; max-width: 800px; margin: 0 auto; padding: 2rem; background: #0a0a0a; color: #33ff00; line-height: 1.6; word-wrap: break-word; }\n  h1 { color: #fff; border-bottom: 2px solid #33ff00; padding-bottom: 0.5rem; font-size: 1.8rem; }\n  a { color: #00ccff; text-decoration: none; border-bottom: 1px dashed #00ccff; }\n  a:hover { background: #00ccff; color: #000; }\n  nav { margin-bottom: 2rem; border-bottom: 1px solid #333; padding-bottom: 1rem; display: flex; flex-wrap: wrap; gap: 10px; }\n  .post-date { font-size: 0.8em; color: #888; margin-bottom: 1rem; }\n  .tag { display: inline-block; background: #111; border: 1px solid #333; color: #f97316; padding: 2px 8px; border-radius: 12px; font-size: 0.75em; margin: 2px; cursor: pointer; text-decoration: none; }\n  p { font-size: 1.2rem; }\n</style>\n<meta name=\"tags\" content=\"daily-fact, trivia\">\n</head>\n<body>\n  <nav><strong style=\"color:#f97316\">> MILO's Terminal_</strong> <a href=\"/\">Home</a> | <a href=\"/archive.html\">Archive</a> | <a href=\"/about.html\">About Us</a> | <a href=\"/human.html\">The Human</a></nav>\n\n  <h1>> Daily Fact</h1>\n  <div class=\"post-tags\"><span class=\"tag\">daily-fact</span><span class=\"tag\">trivia</span></div>\n  <div class=\"post-date\">${displayDate}</div>\n\n  <p>${content}</p>\n\n  <br>\n  <a href=\"/\">&lt; back to terminal</a>\n</body>\n</html>`;\n\n  return [{ json: { message: tg_msg, html: html, filename: filename, content: content } }];\n} catch(e) {\n  return [{ json: { message: '\ud83e\udde0 *Daily Fact*\\n\\nFailed to generate.\\n\\n*(error)*' } }];\n}\n"
      }
    },
    {
      "id": "send",
      "name": "Send to Telegram",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        1200,
        -100
      ],
      "parameters": {
        "method": "POST",
        "url": "https://api.telegram.org/bot8544365014:AAEgKwHUF7_iG2AizJND2NuOUouPE4uQymQ/sendMessage",
        "sendBody": true,
        "contentType": "raw",
        "rawContentType": "application/json",
        "body": "={ \"chat_id\": \"8305133249\", \"text\": {{ JSON.stringify($json.message) }}, \"parse_mode\": \"Markdown\" }",
        "options": {}
      }
    },
    {
      "id": "push-to-portainer",
      "name": "Push to Blog Container",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        1440,
        100
      ],
      "parameters": {
        "method": "POST",
        "url": "http://192.168.200.220:9000/api/endpoints/6/docker/containers/0ed088a96df4/exec",
        "sendHeaders": true,
        "specifyHeaders": "keypair",
        "headerParameters": {
          "parameters": [
            {
              "name": "X-API-Key",
              "value": "ptr_jVGvpkWmxmPusWm3yZYeEvMU8LLMvYjqDm8iLmsRQjk="
            }
          ]
        },
        "sendBody": false,
        "options": {}
      }
    },
    {
      "id": "execute-push",
      "name": "Execute Push",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        1440,
        100
      ],
      "parameters": {
        "method": "POST",
        "url": "=http://192.168.200.220:9000/api/endpoints/6/docker/exec/{{ $node['Push to Blog Container'].json.Id }}/start",
        "sendHeaders": true,
        "specifyHeaders": "keypair",
        "headerParameters": {
          "parameters": [
            {
              "name": "X-API-Key",
              "value": "ptr_jVGvpkWmxmPusWm3yZYeEvMU8LLMvYjqDm8iLmsRQjk="
            }
          ]
        },
        "sendBody": true,
        "specifyBody": "json",
        "jsonBody": "{\"Detach\": false, \"Tty\": false}"
      }
    },
    {
      "id": "webhook",
      "name": "Webhook",
      "type": "n8n-nodes-base.webhook",
      "typeVersion": 1,
      "position": [
        0,
        200
      ],
      "parameters": {
        "path": "test-fact",
        "responseMode": "lastNode",
        "options": {}
      }
    },
    {
      "id": "check-db-node",
      "name": "Check DB",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        720,
        0
      ],
      "parameters": {
        "jsCode": "const message = $input.first().json.message;\n\n// Pure JS simple string hash to avoid the 'crypto' module restriction in n8n code nodes\nfunction simpleHash(str) {\n  let hash = 0;\n  for (let i = 0; i < str.length; i++) {\n    const char = str.charCodeAt(i);\n    hash = ((hash << 5) - hash) + char;\n    hash = hash & hash;\n  }\n  return Math.abs(hash).toString(16);\n}\n\nconst hash = simpleHash(message);\n\nconst staticData = $getWorkflowStaticData('global');\nif (!staticData.sentHashes) staticData.sentHashes = [];\n\nconst found = staticData.sentHashes.includes(hash);\nreturn [{ json: { id: found ? hash : '', hash: hash, message: message } }];"
      }
    },
    {
      "id": "is-new-node",
      "name": "Is New?",
      "type": "n8n-nodes-base.if",
      "typeVersion": 2,
      "position": [
        960,
        0
      ],
      "parameters": {
        "conditions": {
          "options": {
            "caseSensitive": true,
            "leftValue": "",
            "typeValidation": "strict"
          },
          "conditions": [
            {
              "id": "c1",
              "leftValue": "={{ $json.id }}",
              "rightValue": "",
              "operator": {
                "type": "string",
                "operation": "empty",
                "singleValue": true
              }
            }
          ],
          "combinator": "and"
        }
      }
    },
    {
      "id": "regen-node",
      "name": "Regenerate",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        960,
        200
      ],
      "parameters": {
        "method": "POST",
        "url": "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=AIzaSyAnnVmRDJTCRGKBvM80tEGpKmBa-f0CFpY",
        "sendBody": true,
        "contentType": "raw",
        "rawContentType": "application/json",
        "body": "{\"contents\": [{\"parts\": [{\"text\": \"Give me one genuinely interesting, obscure, or surprising fact. Keep it to 2-3 sentences max. No intro, just the fact.\"}]}], \"generationConfig\": {\"temperature\": 0.9}}",
        "options": {},
        "headerParameters": {
          "parameters": [
            {
              "name": "Content-Type",
              "value": "application/json"
            }
          ]
        }
      }
    },
    {
      "id": "regen-fmt-node",
      "name": "Format Regen",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        1200,
        200
      ],
      "parameters": {
        "jsCode": "\ntry {\n  const text = $input.first().json.candidates[0].content.parts[0].text;\n  const content = text.trim();\n  \n  // Format for Telegram\n  const tg_msg = '\ud83e\udde0 *Daily Fact*\\n\\n' + content;\n  \n  // Generate filename and title\n  const date = new Date();\n  const dateStr = date.toISOString().split('T')[0];\n  const slug = content.substring(0, 30).toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');\n  const filename = `daily-fact-${dateStr}-${slug}.html`;\n  \n  // Format for Blog HTML\n  const displayDate = date.toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });\n  \n  const html = `<!DOCTYPE html>\n<html lang=\"en\">\n<head><meta charset=\"UTF-8\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"><title>Daily Fact | MILO's Terminal</title><style>\n  *, *::before, *::after { box-sizing: border-box; }\n  body { font-family: monospace; max-width: 800px; margin: 0 auto; padding: 2rem; background: #0a0a0a; color: #33ff00; line-height: 1.6; word-wrap: break-word; }\n  h1 { color: #fff; border-bottom: 2px solid #33ff00; padding-bottom: 0.5rem; font-size: 1.8rem; }\n  a { color: #00ccff; text-decoration: none; border-bottom: 1px dashed #00ccff; }\n  a:hover { background: #00ccff; color: #000; }\n  nav { margin-bottom: 2rem; border-bottom: 1px solid #333; padding-bottom: 1rem; display: flex; flex-wrap: wrap; gap: 10px; }\n  .post-date { font-size: 0.8em; color: #888; margin-bottom: 1rem; }\n  .tag { display: inline-block; background: #111; border: 1px solid #333; color: #f97316; padding: 2px 8px; border-radius: 12px; font-size: 0.75em; margin: 2px; cursor: pointer; text-decoration: none; }\n  p { font-size: 1.2rem; }\n</style>\n<meta name=\"tags\" content=\"daily-fact, trivia\">\n</head>\n<body>\n  <nav><strong style=\"color:#f97316\">> MILO's Terminal_</strong> <a href=\"/\">Home</a> | <a href=\"/archive.html\">Archive</a> | <a href=\"/about.html\">About Us</a> | <a href=\"/human.html\">The Human</a></nav>\n\n  <h1>> Daily Fact</h1>\n  <div class=\"post-tags\"><span class=\"tag\">daily-fact</span><span class=\"tag\">trivia</span></div>\n  <div class=\"post-date\">${displayDate}</div>\n\n  <p>${content}</p>\n\n  <br>\n  <a href=\"/\">&lt; back to terminal</a>\n</body>\n</html>`;\n\n  return [{ json: { message: tg_msg, html: html, filename: filename, content: content } }];\n} catch(e) {\n  return [{ json: { message: '\ud83e\udde0 *Daily Fact*\\n\\nFailed to generate.\\n\\n*(error)*' } }];\n}\n"
      }
    },
    {
      "id": "mark-sent-node",
      "name": "Mark Sent",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        1440,
        0
      ],
      "parameters": {
        "jsCode": "const staticData = $getWorkflowStaticData('global');\nif (!staticData.sentHashes) staticData.sentHashes = [];\n\nconst hash = $('Check DB').first().json.hash;\n\nif (!staticData.sentHashes.includes(hash)) {\n  staticData.sentHashes.push(hash);\n  // Keep last 500 to avoid unbounded growth\n  if (staticData.sentHashes.length > 500) {\n    staticData.sentHashes = staticData.sentHashes.slice(-500);\n  }\n}\nreturn [{ json: { status: 'ok' } }];"
      }
    }
  ],
  "connections": {
    "Schedule 7AM": {
      "main": [
        [
          {
            "node": "Ask Gemini",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Ask Gemini": {
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
    "Push to Blog Container": {
      "main": [
        [
          {
            "node": "Execute Push",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Webhook": {
      "main": [
        [
          {
            "node": "Ask Gemini",
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
            "node": "Check DB",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Send to Telegram": {
      "main": [
        [
          {
            "node": "Mark Sent",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Check DB": {
      "main": [
        [
          {
            "node": "Is New?",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Is New?": {
      "main": [
        [
          {
            "node": "Send to Telegram",
            "type": "main",
            "index": 0
          }
        ],
        [
          {
            "node": "Regenerate",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Regenerate": {
      "main": [
        [
          {
            "node": "Format Regen",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Format Regen": {
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
  "versionId": "e674a6ec-1613-4b84-95fd-7c627bea4cda",
  "activeVersionId": "e674a6ec-1613-4b84-95fd-7c627bea4cda",
  "versionCounter": 73,
  "triggerCount": 2,
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
    "updatedAt": "2026-04-06T15:59:46.796Z",
    "createdAt": "2026-04-06T15:59:46.796Z",
    "versionId": "e674a6ec-1613-4b84-95fd-7c627bea4cda",
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
        "name": "Ask Gemini",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [
          240,
          0
        ],
        "parameters": {
          "method": "POST",
          "url": "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=AIzaSyAnnVmRDJTCRGKBvM80tEGpKmBa-f0CFpY",
          "sendBody": true,
          "contentType": "raw",
          "rawContentType": "application/json",
          "body": "{\"contents\": [{\"parts\": [{\"text\": \"Give me one genuinely interesting, obscure, or surprising fact. Keep it to 2-3 sentences max. No intro, just the fact.\"}]}], \"generationConfig\": {\"temperature\": 0.9}}",
          "options": {},
          "headerParameters": {
            "parameters": [
              {
                "name": "Content-Type",
                "value": "application/json"
              }
            ]
          }
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
          "jsCode": "\ntry {\n  const text = $input.first().json.candidates[0].content.parts[0].text;\n  const content = text.trim();\n  \n  // Format for Telegram\n  const tg_msg = '\ud83e\udde0 *Daily Fact*\\n\\n' + content;\n  \n  // Generate filename and title\n  const date = new Date();\n  const dateStr = date.toISOString().split('T')[0];\n  const slug = content.substring(0, 30).toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');\n  const filename = `daily-fact-${dateStr}-${slug}.html`;\n  \n  // Format for Blog HTML\n  const displayDate = date.toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });\n  \n  const html = `<!DOCTYPE html>\n<html lang=\"en\">\n<head><meta charset=\"UTF-8\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"><title>Daily Fact | MILO's Terminal</title><style>\n  *, *::before, *::after { box-sizing: border-box; }\n  body { font-family: monospace; max-width: 800px; margin: 0 auto; padding: 2rem; background: #0a0a0a; color: #33ff00; line-height: 1.6; word-wrap: break-word; }\n  h1 { color: #fff; border-bottom: 2px solid #33ff00; padding-bottom: 0.5rem; font-size: 1.8rem; }\n  a { color: #00ccff; text-decoration: none; border-bottom: 1px dashed #00ccff; }\n  a:hover { background: #00ccff; color: #000; }\n  nav { margin-bottom: 2rem; border-bottom: 1px solid #333; padding-bottom: 1rem; display: flex; flex-wrap: wrap; gap: 10px; }\n  .post-date { font-size: 0.8em; color: #888; margin-bottom: 1rem; }\n  .tag { display: inline-block; background: #111; border: 1px solid #333; color: #f97316; padding: 2px 8px; border-radius: 12px; font-size: 0.75em; margin: 2px; cursor: pointer; text-decoration: none; }\n  p { font-size: 1.2rem; }\n</style>\n<meta name=\"tags\" content=\"daily-fact, trivia\">\n</head>\n<body>\n  <nav><strong style=\"color:#f97316\">> MILO's Terminal_</strong> <a href=\"/\">Home</a> | <a href=\"/archive.html\">Archive</a> | <a href=\"/about.html\">About Us</a> | <a href=\"/human.html\">The Human</a></nav>\n\n  <h1>> Daily Fact</h1>\n  <div class=\"post-tags\"><span class=\"tag\">daily-fact</span><span class=\"tag\">trivia</span></div>\n  <div class=\"post-date\">${displayDate}</div>\n\n  <p>${content}</p>\n\n  <br>\n  <a href=\"/\">&lt; back to terminal</a>\n</body>\n</html>`;\n\n  return [{ json: { message: tg_msg, html: html, filename: filename, content: content } }];\n} catch(e) {\n  return [{ json: { message: '\ud83e\udde0 *Daily Fact*\\n\\nFailed to generate.\\n\\n*(error)*' } }];\n}\n"
        }
      },
      {
        "id": "send",
        "name": "Send to Telegram",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [
          1200,
          -100
        ],
        "parameters": {
          "method": "POST",
          "url": "https://api.telegram.org/bot8544365014:AAEgKwHUF7_iG2AizJND2NuOUouPE4uQymQ/sendMessage",
          "sendBody": true,
          "contentType": "raw",
          "rawContentType": "application/json",
          "body": "={ \"chat_id\": \"8305133249\", \"text\": {{ JSON.stringify($json.message) }}, \"parse_mode\": \"Markdown\" }",
          "options": {}
        }
      },
      {
        "id": "push-to-portainer",
        "name": "Push to Blog Container",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [
          1440,
          100
        ],
        "parameters": {
          "method": "POST",
          "url": "http://192.168.200.220:9000/api/endpoints/6/docker/containers/0ed088a96df4/exec",
          "sendHeaders": true,
          "specifyHeaders": "keypair",
          "headerParameters": {
            "parameters": [
              {
                "name": "X-API-Key",
                "value": "ptr_jVGvpkWmxmPusWm3yZYeEvMU8LLMvYjqDm8iLmsRQjk="
              }
            ]
          },
          "sendBody": false,
          "options": {}
        }
      },
      {
        "id": "execute-push",
        "name": "Execute Push",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [
          1440,
          100
        ],
        "parameters": {
          "method": "POST",
          "url": "=http://192.168.200.220:9000/api/endpoints/6/docker/exec/{{ $node['Push to Blog Container'].json.Id }}/start",
          "sendHeaders": true,
          "specifyHeaders": "keypair",
          "headerParameters": {
            "parameters": [
              {
                "name": "X-API-Key",
                "value": "ptr_jVGvpkWmxmPusWm3yZYeEvMU8LLMvYjqDm8iLmsRQjk="
              }
            ]
          },
          "sendBody": true,
          "specifyBody": "json",
          "jsonBody": "{\"Detach\": false, \"Tty\": false}"
        }
      },
      {
        "id": "webhook",
        "name": "Webhook",
        "type": "n8n-nodes-base.webhook",
        "typeVersion": 1,
        "position": [
          0,
          200
        ],
        "parameters": {
          "path": "test-fact",
          "responseMode": "lastNode",
          "options": {}
        }
      },
      {
        "id": "check-db-node",
        "name": "Check DB",
        "type": "n8n-nodes-base.code",
        "typeVersion": 2,
        "position": [
          720,
          0
        ],
        "parameters": {
          "jsCode": "const message = $input.first().json.message;\n\n// Pure JS simple string hash to avoid the 'crypto' module restriction in n8n code nodes\nfunction simpleHash(str) {\n  let hash = 0;\n  for (let i = 0; i < str.length; i++) {\n    const char = str.charCodeAt(i);\n    hash = ((hash << 5) - hash) + char;\n    hash = hash & hash;\n  }\n  return Math.abs(hash).toString(16);\n}\n\nconst hash = simpleHash(message);\n\nconst staticData = $getWorkflowStaticData('global');\nif (!staticData.sentHashes) staticData.sentHashes = [];\n\nconst found = staticData.sentHashes.includes(hash);\nreturn [{ json: { id: found ? hash : '', hash: hash, message: message } }];"
        }
      },
      {
        "id": "is-new-node",
        "name": "Is New?",
        "type": "n8n-nodes-base.if",
        "typeVersion": 2,
        "position": [
          960,
          0
        ],
        "parameters": {
          "conditions": {
            "options": {
              "caseSensitive": true,
              "leftValue": "",
              "typeValidation": "strict"
            },
            "conditions": [
              {
                "id": "c1",
                "leftValue": "={{ $json.id }}",
                "rightValue": "",
                "operator": {
                  "type": "string",
                  "operation": "empty",
                  "singleValue": true
                }
              }
            ],
            "combinator": "and"
          }
        }
      },
      {
        "id": "regen-node",
        "name": "Regenerate",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [
          960,
          200
        ],
        "parameters": {
          "method": "POST",
          "url": "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=AIzaSyAnnVmRDJTCRGKBvM80tEGpKmBa-f0CFpY",
          "sendBody": true,
          "contentType": "raw",
          "rawContentType": "application/json",
          "body": "{\"contents\": [{\"parts\": [{\"text\": \"Give me one genuinely interesting, obscure, or surprising fact. Keep it to 2-3 sentences max. No intro, just the fact.\"}]}], \"generationConfig\": {\"temperature\": 0.9}}",
          "options": {},
          "headerParameters": {
            "parameters": [
              {
                "name": "Content-Type",
                "value": "application/json"
              }
            ]
          }
        }
      },
      {
        "id": "regen-fmt-node",
        "name": "Format Regen",
        "type": "n8n-nodes-base.code",
        "typeVersion": 2,
        "position": [
          1200,
          200
        ],
        "parameters": {
          "jsCode": "\ntry {\n  const text = $input.first().json.candidates[0].content.parts[0].text;\n  const content = text.trim();\n  \n  // Format for Telegram\n  const tg_msg = '\ud83e\udde0 *Daily Fact*\\n\\n' + content;\n  \n  // Generate filename and title\n  const date = new Date();\n  const dateStr = date.toISOString().split('T')[0];\n  const slug = content.substring(0, 30).toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');\n  const filename = `daily-fact-${dateStr}-${slug}.html`;\n  \n  // Format for Blog HTML\n  const displayDate = date.toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });\n  \n  const html = `<!DOCTYPE html>\n<html lang=\"en\">\n<head><meta charset=\"UTF-8\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"><title>Daily Fact | MILO's Terminal</title><style>\n  *, *::before, *::after { box-sizing: border-box; }\n  body { font-family: monospace; max-width: 800px; margin: 0 auto; padding: 2rem; background: #0a0a0a; color: #33ff00; line-height: 1.6; word-wrap: break-word; }\n  h1 { color: #fff; border-bottom: 2px solid #33ff00; padding-bottom: 0.5rem; font-size: 1.8rem; }\n  a { color: #00ccff; text-decoration: none; border-bottom: 1px dashed #00ccff; }\n  a:hover { background: #00ccff; color: #000; }\n  nav { margin-bottom: 2rem; border-bottom: 1px solid #333; padding-bottom: 1rem; display: flex; flex-wrap: wrap; gap: 10px; }\n  .post-date { font-size: 0.8em; color: #888; margin-bottom: 1rem; }\n  .tag { display: inline-block; background: #111; border: 1px solid #333; color: #f97316; padding: 2px 8px; border-radius: 12px; font-size: 0.75em; margin: 2px; cursor: pointer; text-decoration: none; }\n  p { font-size: 1.2rem; }\n</style>\n<meta name=\"tags\" content=\"daily-fact, trivia\">\n</head>\n<body>\n  <nav><strong style=\"color:#f97316\">> MILO's Terminal_</strong> <a href=\"/\">Home</a> | <a href=\"/archive.html\">Archive</a> | <a href=\"/about.html\">About Us</a> | <a href=\"/human.html\">The Human</a></nav>\n\n  <h1>> Daily Fact</h1>\n  <div class=\"post-tags\"><span class=\"tag\">daily-fact</span><span class=\"tag\">trivia</span></div>\n  <div class=\"post-date\">${displayDate}</div>\n\n  <p>${content}</p>\n\n  <br>\n  <a href=\"/\">&lt; back to terminal</a>\n</body>\n</html>`;\n\n  return [{ json: { message: tg_msg, html: html, filename: filename, content: content } }];\n} catch(e) {\n  return [{ json: { message: '\ud83e\udde0 *Daily Fact*\\n\\nFailed to generate.\\n\\n*(error)*' } }];\n}\n"
        }
      },
      {
        "id": "mark-sent-node",
        "name": "Mark Sent",
        "type": "n8n-nodes-base.code",
        "typeVersion": 2,
        "position": [
          1440,
          0
        ],
        "parameters": {
          "jsCode": "const staticData = $getWorkflowStaticData('global');\nif (!staticData.sentHashes) staticData.sentHashes = [];\n\nconst hash = $('Check DB').first().json.hash;\n\nif (!staticData.sentHashes.includes(hash)) {\n  staticData.sentHashes.push(hash);\n  // Keep last 500 to avoid unbounded growth\n  if (staticData.sentHashes.length > 500) {\n    staticData.sentHashes = staticData.sentHashes.slice(-500);\n  }\n}\nreturn [{ json: { status: 'ok' } }];"
        }
      }
    ],
    "connections": {
      "Schedule 7AM": {
        "main": [
          [
            {
              "node": "Ask Gemini",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Ask Gemini": {
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
      "Push to Blog Container": {
        "main": [
          [
            {
              "node": "Execute Push",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Webhook": {
        "main": [
          [
            {
              "node": "Ask Gemini",
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
              "node": "Check DB",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Send to Telegram": {
        "main": [
          [
            {
              "node": "Mark Sent",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Check DB": {
        "main": [
          [
            {
              "node": "Is New?",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Is New?": {
        "main": [
          [
            {
              "node": "Send to Telegram",
              "type": "main",
              "index": 0
            }
          ],
          [
            {
              "node": "Regenerate",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Regenerate": {
        "main": [
          [
            {
              "node": "Format Regen",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Format Regen": {
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
        "createdAt": "2026-04-06T15:59:46.877Z",
        "id": 285,
        "workflowId": "AjAjjxb9j94iE0JK",
        "versionId": "e674a6ec-1613-4b84-95fd-7c627bea4cda",
        "event": "deactivated",
        "userId": "c557a393-301d-4cd5-ada0-4ae8574f88c9"
      },
      {
        "createdAt": "2026-04-06T15:59:46.924Z",
        "id": 286,
        "workflowId": "AjAjjxb9j94iE0JK",
        "versionId": "e674a6ec-1613-4b84-95fd-7c627bea4cda",
        "event": "activated",
        "userId": "c557a393-301d-4cd5-ada0-4ae8574f88c9"
      }
    ]
  }
}
```

</details>

---

## Daily Dad Joke

| Field | Value |
|---|---|
| **ID** | `m7EMbjBDyv2MMCBo` |
| **Status** | 🟢 Active |
| **Schedule** | `0 9 * * *` |
| **Backup file** | `daily_dad_joke.json` |

**Nodes (9):**
  - `n8n-nodes-base.scheduleTrigger` — **Schedule 9AM**
  - `n8n-nodes-base.httpRequest` — **Ask Gemini Pro**
  - `n8n-nodes-base.code` — **Format Message**
  - `n8n-nodes-base.httpRequest` — **Send to Telegram**
  - `n8n-nodes-base.code` — **Check DB**
  - `n8n-nodes-base.if` — **Is New?**
  - `n8n-nodes-base.httpRequest` — **Regenerate**
  - `n8n-nodes-base.code` — **Format Regen**
  - `n8n-nodes-base.code` — **Mark Sent**

<details>
<summary>Full JSON config</summary>

```json
{
  "updatedAt": "2026-04-06T15:59:46.411Z",
  "createdAt": "2026-03-09T13:36:37.916Z",
  "id": "m7EMbjBDyv2MMCBo",
  "name": "Daily Dad Joke",
  "description": null,
  "active": true,
  "isArchived": false,
  "nodes": [
    {
      "id": "schedule-9am",
      "name": "Schedule 9AM",
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
              "expression": "0 9 * * *"
            }
          ]
        }
      }
    },
    {
      "id": "ask-gemini",
      "name": "Ask Gemini Pro",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        240,
        0
      ],
      "parameters": {
        "method": "POST",
        "url": "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=AIzaSyAnnVmRDJTCRGKBvM80tEGpKmBa-f0CFpY",
        "sendBody": true,
        "contentType": "raw",
        "rawContentType": "application/json",
        "body": "{\"contents\": [{\"parts\": [{\"text\": \"Tell me a truly terrible, groan-worthy dad joke. Just the joke, no intro or extra text.\"}]}]}",
        "options": {}
      }
    },
    {
      "id": "format-message",
      "name": "Format Message",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        480,
        0
      ],
      "parameters": {
        "jsCode": "const text = $input.first().json.candidates?.[0]?.content?.parts?.[0]?.text || 'No joke today.';\nreturn [{ json: { message: '\ud83e\udee3\u200d\u2642\ufe0f *Daily Dad Joke*\\n\\n' + text.trim() + '\\n\\n*(via Gemini Pro)*' } }];"
      }
    },
    {
      "id": "send-telegram",
      "name": "Send to Telegram",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        1200,
        -100
      ],
      "parameters": {
        "method": "POST",
        "url": "https://api.telegram.org/bot8544365014:AAEgKwHUF7_iG2AizJND2NuOUouPE4uQymQ/sendMessage",
        "sendBody": true,
        "contentType": "raw",
        "rawContentType": "application/json",
        "body": "={ \"chat_id\": \"8305133249\", \"text\": {{ JSON.stringify($json.message) }}, \"parse_mode\": \"Markdown\" }",
        "options": {}
      }
    },
    {
      "id": "check-db-node",
      "name": "Check DB",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        720,
        0
      ],
      "parameters": {
        "jsCode": "const message = $input.first().json.message;\n\n// Pure JS simple string hash to avoid the 'crypto' module restriction in n8n code nodes\nfunction simpleHash(str) {\n  let hash = 0;\n  for (let i = 0; i < str.length; i++) {\n    const char = str.charCodeAt(i);\n    hash = ((hash << 5) - hash) + char;\n    hash = hash & hash;\n  }\n  return Math.abs(hash).toString(16);\n}\n\nconst hash = simpleHash(message);\n\nconst staticData = $getWorkflowStaticData('global');\nif (!staticData.sentHashes) staticData.sentHashes = [];\n\nconst found = staticData.sentHashes.includes(hash);\nreturn [{ json: { id: found ? hash : '', hash: hash, message: message } }];"
      }
    },
    {
      "id": "is-new-node",
      "name": "Is New?",
      "type": "n8n-nodes-base.if",
      "typeVersion": 2,
      "position": [
        960,
        0
      ],
      "parameters": {
        "conditions": {
          "options": {
            "caseSensitive": true,
            "leftValue": "",
            "typeValidation": "strict"
          },
          "conditions": [
            {
              "id": "c1",
              "leftValue": "={{ $json.id }}",
              "rightValue": "",
              "operator": {
                "type": "string",
                "operation": "empty",
                "singleValue": true
              }
            }
          ],
          "combinator": "and"
        }
      }
    },
    {
      "id": "regen-node",
      "name": "Regenerate",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        960,
        200
      ],
      "parameters": {
        "method": "POST",
        "url": "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=AIzaSyAnnVmRDJTCRGKBvM80tEGpKmBa-f0CFpY",
        "sendBody": true,
        "contentType": "raw",
        "rawContentType": "application/json",
        "body": "{\"contents\": [{\"parts\": [{\"text\": \"Tell me a truly terrible, groan-worthy dad joke. Just the joke, no intro or extra text.\"}]}]}",
        "options": {}
      }
    },
    {
      "id": "regen-fmt-node",
      "name": "Format Regen",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        1200,
        200
      ],
      "parameters": {
        "jsCode": "const text = $input.first().json.candidates?.[0]?.content?.parts?.[0]?.text || 'No joke today.';\nreturn [{ json: { message: '\ud83e\udee3\u200d\u2642\ufe0f *Daily Dad Joke*\\n\\n' + text.trim() + '\\n\\n*(via Gemini Pro)*' } }];"
      }
    },
    {
      "id": "mark-sent-node",
      "name": "Mark Sent",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        1440,
        0
      ],
      "parameters": {
        "jsCode": "const staticData = $getWorkflowStaticData('global');\nif (!staticData.sentHashes) staticData.sentHashes = [];\n\nconst hash = $('Check DB').first().json.hash;\n\nif (!staticData.sentHashes.includes(hash)) {\n  staticData.sentHashes.push(hash);\n  // Keep last 500 to avoid unbounded growth\n  if (staticData.sentHashes.length > 500) {\n    staticData.sentHashes = staticData.sentHashes.slice(-500);\n  }\n}\nreturn [{ json: { status: 'ok' } }];"
      }
    }
  ],
  "connections": {
    "Schedule 9AM": {
      "main": [
        [
          {
            "node": "Ask Gemini Pro",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Ask Gemini Pro": {
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
            "node": "Check DB",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Send to Telegram": {
      "main": [
        [
          {
            "node": "Mark Sent",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Check DB": {
      "main": [
        [
          {
            "node": "Is New?",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Is New?": {
      "main": [
        [
          {
            "node": "Send to Telegram",
            "type": "main",
            "index": 0
          }
        ],
        [
          {
            "node": "Regenerate",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Regenerate": {
      "main": [
        [
          {
            "node": "Format Regen",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Format Regen": {
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
    "node:Schedule 9AM": {
      "recurrenceRules": []
    }
  },
  "meta": null,
  "pinData": null,
  "versionId": "5a89d55c-cfc5-4fc6-bb6f-2c0dff7c62d8",
  "activeVersionId": "5a89d55c-cfc5-4fc6-bb6f-2c0dff7c62d8",
  "versionCounter": 63,
  "triggerCount": 1,
  "shared": [
    {
      "updatedAt": "2026-03-09T13:36:37.916Z",
      "createdAt": "2026-03-09T13:36:37.916Z",
      "role": "workflow:owner",
      "workflowId": "m7EMbjBDyv2MMCBo",
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
    "updatedAt": "2026-04-06T15:59:46.416Z",
    "createdAt": "2026-04-06T15:59:46.416Z",
    "versionId": "5a89d55c-cfc5-4fc6-bb6f-2c0dff7c62d8",
    "workflowId": "m7EMbjBDyv2MMCBo",
    "nodes": [
      {
        "id": "schedule-9am",
        "name": "Schedule 9AM",
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
                "expression": "0 9 * * *"
              }
            ]
          }
        }
      },
      {
        "id": "ask-gemini",
        "name": "Ask Gemini Pro",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [
          240,
          0
        ],
        "parameters": {
          "method": "POST",
          "url": "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=AIzaSyAnnVmRDJTCRGKBvM80tEGpKmBa-f0CFpY",
          "sendBody": true,
          "contentType": "raw",
          "rawContentType": "application/json",
          "body": "{\"contents\": [{\"parts\": [{\"text\": \"Tell me a truly terrible, groan-worthy dad joke. Just the joke, no intro or extra text.\"}]}]}",
          "options": {}
        }
      },
      {
        "id": "format-message",
        "name": "Format Message",
        "type": "n8n-nodes-base.code",
        "typeVersion": 2,
        "position": [
          480,
          0
        ],
        "parameters": {
          "jsCode": "const text = $input.first().json.candidates?.[0]?.content?.parts?.[0]?.text || 'No joke today.';\nreturn [{ json: { message: '\ud83e\udee3\u200d\u2642\ufe0f *Daily Dad Joke*\\n\\n' + text.trim() + '\\n\\n*(via Gemini Pro)*' } }];"
        }
      },
      {
        "id": "send-telegram",
        "name": "Send to Telegram",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [
          1200,
          -100
        ],
        "parameters": {
          "method": "POST",
          "url": "https://api.telegram.org/bot8544365014:AAEgKwHUF7_iG2AizJND2NuOUouPE4uQymQ/sendMessage",
          "sendBody": true,
          "contentType": "raw",
          "rawContentType": "application/json",
          "body": "={ \"chat_id\": \"8305133249\", \"text\": {{ JSON.stringify($json.message) }}, \"parse_mode\": \"Markdown\" }",
          "options": {}
        }
      },
      {
        "id": "check-db-node",
        "name": "Check DB",
        "type": "n8n-nodes-base.code",
        "typeVersion": 2,
        "position": [
          720,
          0
        ],
        "parameters": {
          "jsCode": "const message = $input.first().json.message;\n\n// Pure JS simple string hash to avoid the 'crypto' module restriction in n8n code nodes\nfunction simpleHash(str) {\n  let hash = 0;\n  for (let i = 0; i < str.length; i++) {\n    const char = str.charCodeAt(i);\n    hash = ((hash << 5) - hash) + char;\n    hash = hash & hash;\n  }\n  return Math.abs(hash).toString(16);\n}\n\nconst hash = simpleHash(message);\n\nconst staticData = $getWorkflowStaticData('global');\nif (!staticData.sentHashes) staticData.sentHashes = [];\n\nconst found = staticData.sentHashes.includes(hash);\nreturn [{ json: { id: found ? hash : '', hash: hash, message: message } }];"
        }
      },
      {
        "id": "is-new-node",
        "name": "Is New?",
        "type": "n8n-nodes-base.if",
        "typeVersion": 2,
        "position": [
          960,
          0
        ],
        "parameters": {
          "conditions": {
            "options": {
              "caseSensitive": true,
              "leftValue": "",
              "typeValidation": "strict"
            },
            "conditions": [
              {
                "id": "c1",
                "leftValue": "={{ $json.id }}",
                "rightValue": "",
                "operator": {
                  "type": "string",
                  "operation": "empty",
                  "singleValue": true
                }
              }
            ],
            "combinator": "and"
          }
        }
      },
      {
        "id": "regen-node",
        "name": "Regenerate",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [
          960,
          200
        ],
        "parameters": {
          "method": "POST",
          "url": "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=AIzaSyAnnVmRDJTCRGKBvM80tEGpKmBa-f0CFpY",
          "sendBody": true,
          "contentType": "raw",
          "rawContentType": "application/json",
          "body": "{\"contents\": [{\"parts\": [{\"text\": \"Tell me a truly terrible, groan-worthy dad joke. Just the joke, no intro or extra text.\"}]}]}",
          "options": {}
        }
      },
      {
        "id": "regen-fmt-node",
        "name": "Format Regen",
        "type": "n8n-nodes-base.code",
        "typeVersion": 2,
        "position": [
          1200,
          200
        ],
        "parameters": {
          "jsCode": "const text = $input.first().json.candidates?.[0]?.content?.parts?.[0]?.text || 'No joke today.';\nreturn [{ json: { message: '\ud83e\udee3\u200d\u2642\ufe0f *Daily Dad Joke*\\n\\n' + text.trim() + '\\n\\n*(via Gemini Pro)*' } }];"
        }
      },
      {
        "id": "mark-sent-node",
        "name": "Mark Sent",
        "type": "n8n-nodes-base.code",
        "typeVersion": 2,
        "position": [
          1440,
          0
        ],
        "parameters": {
          "jsCode": "const staticData = $getWorkflowStaticData('global');\nif (!staticData.sentHashes) staticData.sentHashes = [];\n\nconst hash = $('Check DB').first().json.hash;\n\nif (!staticData.sentHashes.includes(hash)) {\n  staticData.sentHashes.push(hash);\n  // Keep last 500 to avoid unbounded growth\n  if (staticData.sentHashes.length > 500) {\n    staticData.sentHashes = staticData.sentHashes.slice(-500);\n  }\n}\nreturn [{ json: { status: 'ok' } }];"
        }
      }
    ],
    "connections": {
      "Schedule 9AM": {
        "main": [
          [
            {
              "node": "Ask Gemini Pro",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Ask Gemini Pro": {
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
              "node": "Check DB",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Send to Telegram": {
        "main": [
          [
            {
              "node": "Mark Sent",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Check DB": {
        "main": [
          [
            {
              "node": "Is New?",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Is New?": {
        "main": [
          [
            {
              "node": "Send to Telegram",
              "type": "main",
              "index": 0
            }
          ],
          [
            {
              "node": "Regenerate",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Regenerate": {
        "main": [
          [
            {
              "node": "Format Regen",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Format Regen": {
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
        "createdAt": "2026-04-06T15:59:46.496Z",
        "id": 283,
        "workflowId": "m7EMbjBDyv2MMCBo",
        "versionId": "5a89d55c-cfc5-4fc6-bb6f-2c0dff7c62d8",
        "event": "deactivated",
        "userId": "c557a393-301d-4cd5-ada0-4ae8574f88c9"
      },
      {
        "createdAt": "2026-04-06T15:59:46.538Z",
        "id": 284,
        "workflowId": "m7EMbjBDyv2MMCBo",
        "versionId": "5a89d55c-cfc5-4fc6-bb6f-2c0dff7c62d8",
        "event": "activated",
        "userId": "c557a393-301d-4cd5-ada0-4ae8574f88c9"
      }
    ]
  }
}
```

</details>

---

## Rumble Email Trashcan

| Field | Value |
|---|---|
| **ID** | `K0OuNSXai0OVBohx` |
| **Status** | 🟢 Active |
| **Backup file** | `rumble_email_trashcan.json` |

**Nodes (4):**
  - `n8n-nodes-base.scheduleTrigger` — **Schedule**
  - `n8n-nodes-base.gmail` — **Find Rumble Emails**
  - `n8n-nodes-base.if` — **Has Emails?**
  - `n8n-nodes-base.gmail` — **Trash Email**

<details>
<summary>Full JSON config</summary>

```json
{
  "updatedAt": "2026-03-14T20:20:31.537Z",
  "createdAt": "2026-03-14T20:20:25.669Z",
  "id": "K0OuNSXai0OVBohx",
  "name": "Rumble Email Trashcan",
  "description": null,
  "active": true,
  "isArchived": false,
  "nodes": [
    {
      "name": "Schedule",
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
              "field": "minutes",
              "minutesInterval": 30
            }
          ]
        }
      },
      "id": "539d927b-7ae6-4391-860d-216c37aa4f0a"
    },
    {
      "name": "Find Rumble Emails",
      "type": "n8n-nodes-base.gmail",
      "typeVersion": 2.1,
      "position": [
        220,
        0
      ],
      "parameters": {
        "operation": "getAll",
        "limit": 50,
        "simple": true,
        "filters": {
          "q": "from:rumble.com in:inbox"
        }
      },
      "credentials": {
        "gmailOAuth2": {
          "id": "73FQ8r7lzSZjobXf",
          "name": "Gmail account"
        }
      },
      "alwaysOutputData": true,
      "continueOnFail": true,
      "id": "752ba86b-272e-44f5-95e6-5d490aa1c988"
    },
    {
      "name": "Has Emails?",
      "type": "n8n-nodes-base.if",
      "typeVersion": 2,
      "position": [
        440,
        0
      ],
      "parameters": {
        "conditions": {
          "options": {
            "caseSensitive": true,
            "leftValue": "",
            "typeValidation": "strict"
          },
          "conditions": [
            {
              "id": "check-id",
              "leftValue": "={{ $json.id }}",
              "rightValue": "",
              "operator": {
                "type": "string",
                "operation": "notEmpty"
              }
            }
          ],
          "combinator": "and"
        }
      },
      "id": "73f88f11-bbe4-4780-bbae-863a85090394"
    },
    {
      "name": "Trash Email",
      "type": "n8n-nodes-base.gmail",
      "typeVersion": 2.1,
      "position": [
        660,
        -80
      ],
      "parameters": {
        "operation": "trash",
        "messageId": "={{ $json.id }}"
      },
      "credentials": {
        "gmailOAuth2": {
          "id": "73FQ8r7lzSZjobXf",
          "name": "Gmail account"
        }
      },
      "continueOnFail": true,
      "id": "614d6691-b501-4dfb-a79d-df27663128e8"
    }
  ],
  "connections": {
    "Schedule": {
      "main": [
        [
          {
            "node": "Find Rumble Emails",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Find Rumble Emails": {
      "main": [
        [
          {
            "node": "Has Emails?",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Has Emails?": {
      "main": [
        [
          {
            "node": "Trash Email",
            "type": "main",
            "index": 0
          }
        ],
        []
      ]
    }
  },
  "settings": {
    "executionOrder": "v1",
    "callerPolicy": "workflowsFromSameOwner",
    "availableInMCP": false
  },
  "staticData": {
    "node:Schedule": {
      "recurrenceRules": []
    }
  },
  "meta": null,
  "pinData": null,
  "versionId": "376862cf-b221-4458-80f8-3a56243e918d",
  "activeVersionId": "376862cf-b221-4458-80f8-3a56243e918d",
  "versionCounter": 5,
  "triggerCount": 1,
  "shared": [
    {
      "updatedAt": "2026-03-14T20:20:25.669Z",
      "createdAt": "2026-03-14T20:20:25.669Z",
      "role": "workflow:owner",
      "workflowId": "K0OuNSXai0OVBohx",
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
    "updatedAt": "2026-03-14T20:20:25.696Z",
    "createdAt": "2026-03-14T20:20:25.696Z",
    "versionId": "376862cf-b221-4458-80f8-3a56243e918d",
    "workflowId": "K0OuNSXai0OVBohx",
    "nodes": [
      {
        "name": "Schedule",
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
                "field": "minutes",
                "minutesInterval": 30
              }
            ]
          }
        },
        "id": "539d927b-7ae6-4391-860d-216c37aa4f0a"
      },
      {
        "name": "Find Rumble Emails",
        "type": "n8n-nodes-base.gmail",
        "typeVersion": 2.1,
        "position": [
          220,
          0
        ],
        "parameters": {
          "operation": "getAll",
          "limit": 50,
          "simple": true,
          "filters": {
            "q": "from:rumble.com in:inbox"
          }
        },
        "credentials": {
          "gmailOAuth2": {
            "id": "73FQ8r7lzSZjobXf",
            "name": "Gmail account"
          }
        },
        "alwaysOutputData": true,
        "continueOnFail": true,
        "id": "752ba86b-272e-44f5-95e6-5d490aa1c988"
      },
      {
        "name": "Has Emails?",
        "type": "n8n-nodes-base.if",
        "typeVersion": 2,
        "position": [
          440,
          0
        ],
        "parameters": {
          "conditions": {
            "options": {
              "caseSensitive": true,
              "leftValue": "",
              "typeValidation": "strict"
            },
            "conditions": [
              {
                "id": "check-id",
                "leftValue": "={{ $json.id }}",
                "rightValue": "",
                "operator": {
                  "type": "string",
                  "operation": "notEmpty"
                }
              }
            ],
            "combinator": "and"
          }
        },
        "id": "73f88f11-bbe4-4780-bbae-863a85090394"
      },
      {
        "name": "Trash Email",
        "type": "n8n-nodes-base.gmail",
        "typeVersion": 2.1,
        "position": [
          660,
          -80
        ],
        "parameters": {
          "operation": "trash",
          "messageId": "={{ $json.id }}"
        },
        "credentials": {
          "gmailOAuth2": {
            "id": "73FQ8r7lzSZjobXf",
            "name": "Gmail account"
          }
        },
        "continueOnFail": true,
        "id": "614d6691-b501-4dfb-a79d-df27663128e8"
      }
    ],
    "connections": {
      "Schedule": {
        "main": [
          [
            {
              "node": "Find Rumble Emails",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Find Rumble Emails": {
        "main": [
          [
            {
              "node": "Has Emails?",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Has Emails?": {
        "main": [
          [
            {
              "node": "Trash Email",
              "type": "main",
              "index": 0
            }
          ],
          []
        ]
      }
    },
    "authors": "DAIN BENTLEY",
    "name": null,
    "description": null,
    "autosaved": false,
    "workflowPublishHistory": [
      {
        "createdAt": "2026-03-14T20:23:06.787Z",
        "id": 172,
        "workflowId": "K0OuNSXai0OVBohx",
        "versionId": "376862cf-b221-4458-80f8-3a56243e918d",
        "event": "activated",
        "userId": "c557a393-301d-4cd5-ada0-4ae8574f88c9"
      }
    ]
  }
}
```

</details>

---

## DAIN REPORT Website Updater

| Field | Value |
|---|---|
| **ID** | `kTFv5sNHNHawYdrW` |
| **Status** | 🟢 Active |
| **Schedule** | `0 */4 * * *` |
| **Backup file** | `dain_report_website_updater.json` |

**Nodes (11):**
  - `n8n-nodes-base.scheduleTrigger` — **Schedule 6:30AM**
  - `n8n-nodes-base.rssFeedRead` — **Fox World RSS**
  - `n8n-nodes-base.rssFeedRead` — **Fox Science RSS**
  - `n8n-nodes-base.rssFeedRead` — **Ars Technica RSS**
  - `n8n-nodes-base.rssFeedRead` — **BBC Science RSS**
  - `n8n-nodes-base.rssFeedRead` — **NPR News RSS**
  - `n8n-nodes-base.code` — **Format Digest**
  - `n8n-nodes-base.rssFeedRead` — **CNN RSS**
  - `n8n-nodes-base.rssFeedRead` — **Reuters via Yahoo RSS**
  - `n8n-nodes-base.httpRequest` — **Push to News Container**
  - `n8n-nodes-base.httpRequest` — **Execute Push**

<details>
<summary>Full JSON config</summary>

```json
{
  "updatedAt": "2026-03-16T13:53:31.839Z",
  "createdAt": "2026-03-16T13:53:31.839Z",
  "id": "kTFv5sNHNHawYdrW",
  "name": "DAIN REPORT Website Updater",
  "description": null,
  "active": true,
  "isArchived": false,
  "nodes": [
    {
      "id": "schedule",
      "name": "Schedule 6:30AM",
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
              "expression": "0 */4 * * *"
            }
          ]
        }
      },
      "alwaysOutputData": true
    },
    {
      "name": "Fox World RSS",
      "type": "n8n-nodes-base.rssFeedRead",
      "typeVersion": 1,
      "position": [
        200,
        100
      ],
      "parameters": {
        "url": "https://moxie.foxnews.com/google-publisher/world.xml"
      },
      "alwaysOutputData": true,
      "continueOnFail": true,
      "id": "9268fc0a-4bcf-4547-afaa-0e2b9abfee60"
    },
    {
      "name": "Fox Science RSS",
      "type": "n8n-nodes-base.rssFeedRead",
      "typeVersion": 1,
      "position": [
        200,
        220
      ],
      "parameters": {
        "url": "https://moxie.foxnews.com/google-publisher/science.xml"
      },
      "alwaysOutputData": true,
      "continueOnFail": true,
      "id": "533e76f1-a00f-4005-b16e-8b423910473b"
    },
    {
      "name": "Ars Technica RSS",
      "type": "n8n-nodes-base.rssFeedRead",
      "typeVersion": 1,
      "position": [
        200,
        340
      ],
      "parameters": {
        "url": "https://feeds.arstechnica.com/arstechnica/index"
      },
      "alwaysOutputData": true,
      "continueOnFail": true,
      "id": "5ff785fa-96a0-4555-b443-398170e57372"
    },
    {
      "name": "BBC Science RSS",
      "type": "n8n-nodes-base.rssFeedRead",
      "typeVersion": 1,
      "position": [
        200,
        460
      ],
      "parameters": {
        "url": "https://feeds.bbci.co.uk/news/science_and_environment/rss.xml"
      },
      "alwaysOutputData": true,
      "continueOnFail": true,
      "id": "0e4ef9f2-595f-4024-84ef-b6ef05b660e7"
    },
    {
      "name": "NPR News RSS",
      "type": "n8n-nodes-base.rssFeedRead",
      "typeVersion": 1,
      "position": [
        200,
        580
      ],
      "parameters": {
        "url": "https://feeds.npr.org/1001/rss.xml"
      },
      "alwaysOutputData": true,
      "continueOnFail": true,
      "id": "8c845e1d-5046-4f8b-a664-22c381c3cd0e"
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
        "jsCode": "\nconst today = new Date().toLocaleDateString('en-US', {weekday:'long', month:'long', day:'numeric'});\n\nfunction getTop(nodeId, n) {\n  try {\n    const items = $(nodeId).all();\n    return items.slice(0, n).map(i => ({\n      title: (i.json.title || '').replace(/[*[\\]]/g, '').trim(),\n      link: i.json.link || ''\n    })).filter(p => p.title);\n  } catch(e) { return []; }\n}\n\nlet html = `<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n<meta charset=\"UTF-8\">\n<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n<title>NEWS.DAINBENTLEY.COM</title>\n<style>\n  body { background-color: #f0f0f0; color: #000; font-family: \"Times New Roman\", Times, serif; text-align: center; margin: 0; padding: 20px; }\n  .header { border-bottom: 2px solid #000; padding-bottom: 10px; margin-bottom: 20px; }\n  h1 { font-family: \"Impact\", sans-serif; font-size: 4rem; margin: 0; text-transform: uppercase; font-style: italic; letter-spacing: -2px; }\n  .date { font-weight: bold; font-size: 1.2rem; border-top: 1px solid #000; border-bottom: 1px solid #000; padding: 5px 0; margin-top: 5px; }\n  .container { display: flex; flex-wrap: wrap; justify-content: center; gap: 40px; text-align: left; max-width: 1200px; margin: 0 auto; }\n  .column { flex: 1; min-width: 300px; }\n  .section-title { color: #cc0000; font-family: Arial, sans-serif; font-weight: bold; font-size: 1rem; border-bottom: 1px solid #ccc; margin-top: 25px; margin-bottom: 10px; padding-bottom: 2px; }\n  a { display: block; color: #0000ee; text-decoration: none; font-size: 1.3rem; font-weight: bold; line-height: 1.2; margin-bottom: 15px; }\n  a:hover { text-decoration: underline; }\n</style>\n</head>\n<body>\n  <div class=\"header\">\n    <h1>REPORT</h1>\n    <div class=\"date\">${today}</div>\n  </div>\n  <div class=\"container\">\n`;\n\nlet col1 = '<div class=\"column\">';\nlet col2 = '<div class=\"column\">';\nlet col3 = '<div class=\"column\">';\n\nconst world = getTop('Fox World RSS', 5);\nif (world.length) {\n  col1 += '<div class=\"section-title\">WORLD</div>';\n  for (const p of world) col1 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nconst reuters = getTop('Reuters via Yahoo RSS', 5);\nif (reuters.length) {\n  col1 += '<div class=\"section-title\">REUTERS</div>';\n  for (const p of reuters) col1 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nconst cnn = getTop('CNN RSS', 5);\nif (cnn.length) {\n  col2 += '<div class=\"section-title\">HEADLINES</div>';\n  for (const p of cnn) col2 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nconst npr = getTop('NPR News RSS', 5);\nif (npr.length) {\n  col2 += '<div class=\"section-title\">NPR</div>';\n  for (const p of npr) col2 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nconst tech = getTop('Ars Technica RSS', 5);\nif (tech.length) {\n  col3 += '<div class=\"section-title\">TECHNOLOGY</div>';\n  for (const p of tech) col3 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nconst sci = [...getTop('Fox Science RSS', 3), ...getTop('BBC Science RSS', 3)].slice(0, 5);\nif (sci.length) {\n  col3 += '<div class=\"section-title\">SCIENCE</div>';\n  for (const p of sci) col3 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nhtml += col1 + '</div>' + col2 + '</div>' + col3 + '</div>' + '</div></body></html>';\n\n// Keep the telegram message separate\nlet msg = '\ud83d\udcca *News Briefing \u2014 ' + today + '*\\n\\nView full report: [news.dainbentley.com](https://news.dainbentley.com)';\n\nreturn [{ json: { message: msg, html: html } }];\n"
      },
      "alwaysOutputData": true
    },
    {
      "name": "CNN RSS",
      "type": "n8n-nodes-base.rssFeedRead",
      "typeVersion": 1,
      "position": [
        200,
        700
      ],
      "parameters": {
        "url": "http://rss.cnn.com/rss/cnn_topstories.rss"
      },
      "alwaysOutputData": true,
      "continueOnFail": true,
      "id": "6021c416-3793-4f26-add4-36648e97f466"
    },
    {
      "name": "Reuters via Yahoo RSS",
      "type": "n8n-nodes-base.rssFeedRead",
      "typeVersion": 1,
      "position": [
        200,
        820
      ],
      "parameters": {
        "url": "https://news.yahoo.com/rss/world"
      },
      "alwaysOutputData": true,
      "continueOnFail": true,
      "id": "e78da193-5624-42db-9077-9659f9f14ee8"
    },
    {
      "id": "push-to-portainer",
      "name": "Push to News Container",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        720,
        200
      ],
      "parameters": {
        "method": "POST",
        "url": "http://192.168.200.220:9000/api/endpoints/6/docker/containers/milo_news/exec",
        "sendHeaders": true,
        "headerParameters": {
          "parameters": [
            {
              "name": "X-API-Key",
              "value": "ptr_jVGvpkWmxmPusWm3yZYeEvMU8LLMvYjqDm8iLmsRQjk="
            }
          ]
        },
        "sendBody": true,
        "contentType": "json",
        "body": "={{ JSON.stringify({ AttachStdout: true, AttachStderr: true, Cmd: ['sh', '-c', 'echo ' + Buffer.from($json.html).toString('base64') + ' | base64 -d > /usr/share/nginx/html/index.html'] }) }}",
        "options": {}
      }
    },
    {
      "id": "execute-push",
      "name": "Execute Push",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        940,
        200
      ],
      "parameters": {
        "method": "POST",
        "url": "=http://192.168.200.220:9000/api/endpoints/6/docker/exec/{{ $node['Push to News Container'].json.Id }}/start",
        "sendHeaders": true,
        "headerParameters": {
          "parameters": [
            {
              "name": "X-API-Key",
              "value": "ptr_jVGvpkWmxmPusWm3yZYeEvMU8LLMvYjqDm8iLmsRQjk="
            }
          ]
        },
        "sendBody": true,
        "contentType": "json",
        "body": "{\"Detach\": false, \"Tty\": false}",
        "options": {}
      }
    }
  ],
  "connections": {
    "Schedule 6:30AM": {
      "main": [
        [
          {
            "node": "Fox World RSS",
            "type": "main",
            "index": 0
          },
          {
            "node": "Fox Science RSS",
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
            "node": "NPR News RSS",
            "type": "main",
            "index": 0
          },
          {
            "node": "CNN RSS",
            "type": "main",
            "index": 0
          },
          {
            "node": "Reuters via Yahoo RSS",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Fox World RSS": {
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
    "Fox Science RSS": {
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
    "NPR News RSS": {
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
        [],
        [
          {
            "node": "Push to News Container",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "CNN RSS": {
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
    "Reuters via Yahoo RSS": {
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
    "Push to News Container": {
      "main": [
        [
          {
            "node": "Execute Push",
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
    "availableInMCP": false,
    "saveDataSuccessExecution": "all"
  },
  "staticData": {
    "node:Schedule 6:30AM": {
      "recurrenceRules": []
    }
  },
  "meta": null,
  "pinData": null,
  "versionId": "557a35c1-ce34-4caf-81f6-528ddf119106",
  "activeVersionId": "557a35c1-ce34-4caf-81f6-528ddf119106",
  "versionCounter": 4,
  "triggerCount": 1,
  "shared": [
    {
      "updatedAt": "2026-03-16T13:53:31.839Z",
      "createdAt": "2026-03-16T13:53:31.839Z",
      "role": "workflow:owner",
      "workflowId": "kTFv5sNHNHawYdrW",
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
    "updatedAt": "2026-03-16T13:53:31.855Z",
    "createdAt": "2026-03-16T13:53:31.855Z",
    "versionId": "557a35c1-ce34-4caf-81f6-528ddf119106",
    "workflowId": "kTFv5sNHNHawYdrW",
    "nodes": [
      {
        "id": "schedule",
        "name": "Schedule 6:30AM",
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
                "expression": "0 */4 * * *"
              }
            ]
          }
        },
        "alwaysOutputData": true
      },
      {
        "name": "Fox World RSS",
        "type": "n8n-nodes-base.rssFeedRead",
        "typeVersion": 1,
        "position": [
          200,
          100
        ],
        "parameters": {
          "url": "https://moxie.foxnews.com/google-publisher/world.xml"
        },
        "alwaysOutputData": true,
        "continueOnFail": true,
        "id": "9268fc0a-4bcf-4547-afaa-0e2b9abfee60"
      },
      {
        "name": "Fox Science RSS",
        "type": "n8n-nodes-base.rssFeedRead",
        "typeVersion": 1,
        "position": [
          200,
          220
        ],
        "parameters": {
          "url": "https://moxie.foxnews.com/google-publisher/science.xml"
        },
        "alwaysOutputData": true,
        "continueOnFail": true,
        "id": "533e76f1-a00f-4005-b16e-8b423910473b"
      },
      {
        "name": "Ars Technica RSS",
        "type": "n8n-nodes-base.rssFeedRead",
        "typeVersion": 1,
        "position": [
          200,
          340
        ],
        "parameters": {
          "url": "https://feeds.arstechnica.com/arstechnica/index"
        },
        "alwaysOutputData": true,
        "continueOnFail": true,
        "id": "5ff785fa-96a0-4555-b443-398170e57372"
      },
      {
        "name": "BBC Science RSS",
        "type": "n8n-nodes-base.rssFeedRead",
        "typeVersion": 1,
        "position": [
          200,
          460
        ],
        "parameters": {
          "url": "https://feeds.bbci.co.uk/news/science_and_environment/rss.xml"
        },
        "alwaysOutputData": true,
        "continueOnFail": true,
        "id": "0e4ef9f2-595f-4024-84ef-b6ef05b660e7"
      },
      {
        "name": "NPR News RSS",
        "type": "n8n-nodes-base.rssFeedRead",
        "typeVersion": 1,
        "position": [
          200,
          580
        ],
        "parameters": {
          "url": "https://feeds.npr.org/1001/rss.xml"
        },
        "alwaysOutputData": true,
        "continueOnFail": true,
        "id": "8c845e1d-5046-4f8b-a664-22c381c3cd0e"
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
          "jsCode": "\nconst today = new Date().toLocaleDateString('en-US', {weekday:'long', month:'long', day:'numeric'});\n\nfunction getTop(nodeId, n) {\n  try {\n    const items = $(nodeId).all();\n    return items.slice(0, n).map(i => ({\n      title: (i.json.title || '').replace(/[*[\\]]/g, '').trim(),\n      link: i.json.link || ''\n    })).filter(p => p.title);\n  } catch(e) { return []; }\n}\n\nlet html = `<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n<meta charset=\"UTF-8\">\n<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n<title>NEWS.DAINBENTLEY.COM</title>\n<style>\n  body { background-color: #f0f0f0; color: #000; font-family: \"Times New Roman\", Times, serif; text-align: center; margin: 0; padding: 20px; }\n  .header { border-bottom: 2px solid #000; padding-bottom: 10px; margin-bottom: 20px; }\n  h1 { font-family: \"Impact\", sans-serif; font-size: 4rem; margin: 0; text-transform: uppercase; font-style: italic; letter-spacing: -2px; }\n  .date { font-weight: bold; font-size: 1.2rem; border-top: 1px solid #000; border-bottom: 1px solid #000; padding: 5px 0; margin-top: 5px; }\n  .container { display: flex; flex-wrap: wrap; justify-content: center; gap: 40px; text-align: left; max-width: 1200px; margin: 0 auto; }\n  .column { flex: 1; min-width: 300px; }\n  .section-title { color: #cc0000; font-family: Arial, sans-serif; font-weight: bold; font-size: 1rem; border-bottom: 1px solid #ccc; margin-top: 25px; margin-bottom: 10px; padding-bottom: 2px; }\n  a { display: block; color: #0000ee; text-decoration: none; font-size: 1.3rem; font-weight: bold; line-height: 1.2; margin-bottom: 15px; }\n  a:hover { text-decoration: underline; }\n</style>\n</head>\n<body>\n  <div class=\"header\">\n    <h1>REPORT</h1>\n    <div class=\"date\">${today}</div>\n  </div>\n  <div class=\"container\">\n`;\n\nlet col1 = '<div class=\"column\">';\nlet col2 = '<div class=\"column\">';\nlet col3 = '<div class=\"column\">';\n\nconst world = getTop('Fox World RSS', 5);\nif (world.length) {\n  col1 += '<div class=\"section-title\">WORLD</div>';\n  for (const p of world) col1 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nconst reuters = getTop('Reuters via Yahoo RSS', 5);\nif (reuters.length) {\n  col1 += '<div class=\"section-title\">REUTERS</div>';\n  for (const p of reuters) col1 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nconst cnn = getTop('CNN RSS', 5);\nif (cnn.length) {\n  col2 += '<div class=\"section-title\">HEADLINES</div>';\n  for (const p of cnn) col2 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nconst npr = getTop('NPR News RSS', 5);\nif (npr.length) {\n  col2 += '<div class=\"section-title\">NPR</div>';\n  for (const p of npr) col2 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nconst tech = getTop('Ars Technica RSS', 5);\nif (tech.length) {\n  col3 += '<div class=\"section-title\">TECHNOLOGY</div>';\n  for (const p of tech) col3 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nconst sci = [...getTop('Fox Science RSS', 3), ...getTop('BBC Science RSS', 3)].slice(0, 5);\nif (sci.length) {\n  col3 += '<div class=\"section-title\">SCIENCE</div>';\n  for (const p of sci) col3 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nhtml += col1 + '</div>' + col2 + '</div>' + col3 + '</div>' + '</div></body></html>';\n\n// Keep the telegram message separate\nlet msg = '\ud83d\udcca *News Briefing \u2014 ' + today + '*\\n\\nView full report: [news.dainbentley.com](https://news.dainbentley.com)';\n\nreturn [{ json: { message: msg, html: html } }];\n"
        },
        "alwaysOutputData": true
      },
      {
        "name": "CNN RSS",
        "type": "n8n-nodes-base.rssFeedRead",
        "typeVersion": 1,
        "position": [
          200,
          700
        ],
        "parameters": {
          "url": "http://rss.cnn.com/rss/cnn_topstories.rss"
        },
        "alwaysOutputData": true,
        "continueOnFail": true,
        "id": "6021c416-3793-4f26-add4-36648e97f466"
      },
      {
        "name": "Reuters via Yahoo RSS",
        "type": "n8n-nodes-base.rssFeedRead",
        "typeVersion": 1,
        "position": [
          200,
          820
        ],
        "parameters": {
          "url": "https://news.yahoo.com/rss/world"
        },
        "alwaysOutputData": true,
        "continueOnFail": true,
        "id": "e78da193-5624-42db-9077-9659f9f14ee8"
      },
      {
        "id": "push-to-portainer",
        "name": "Push to News Container",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [
          720,
          200
        ],
        "parameters": {
          "method": "POST",
          "url": "http://192.168.200.220:9000/api/endpoints/6/docker/containers/milo_news/exec",
          "sendHeaders": true,
          "headerParameters": {
            "parameters": [
              {
                "name": "X-API-Key",
                "value": "ptr_jVGvpkWmxmPusWm3yZYeEvMU8LLMvYjqDm8iLmsRQjk="
              }
            ]
          },
          "sendBody": true,
          "contentType": "json",
          "body": "={{ JSON.stringify({ AttachStdout: true, AttachStderr: true, Cmd: ['sh', '-c', 'echo ' + Buffer.from($json.html).toString('base64') + ' | base64 -d > /usr/share/nginx/html/index.html'] }) }}",
          "options": {}
        }
      },
      {
        "id": "execute-push",
        "name": "Execute Push",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [
          940,
          200
        ],
        "parameters": {
          "method": "POST",
          "url": "=http://192.168.200.220:9000/api/endpoints/6/docker/exec/{{ $node['Push to News Container'].json.Id }}/start",
          "sendHeaders": true,
          "headerParameters": {
            "parameters": [
              {
                "name": "X-API-Key",
                "value": "ptr_jVGvpkWmxmPusWm3yZYeEvMU8LLMvYjqDm8iLmsRQjk="
              }
            ]
          },
          "sendBody": true,
          "contentType": "json",
          "body": "{\"Detach\": false, \"Tty\": false}",
          "options": {}
        }
      }
    ],
    "connections": {
      "Schedule 6:30AM": {
        "main": [
          [
            {
              "node": "Fox World RSS",
              "type": "main",
              "index": 0
            },
            {
              "node": "Fox Science RSS",
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
              "node": "NPR News RSS",
              "type": "main",
              "index": 0
            },
            {
              "node": "CNN RSS",
              "type": "main",
              "index": 0
            },
            {
              "node": "Reuters via Yahoo RSS",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Fox World RSS": {
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
      "Fox Science RSS": {
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
      "NPR News RSS": {
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
          [],
          [
            {
              "node": "Push to News Container",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "CNN RSS": {
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
      "Reuters via Yahoo RSS": {
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
      "Push to News Container": {
        "main": [
          [
            {
              "node": "Execute Push",
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
        "createdAt": "2026-03-16T13:53:31.960Z",
        "id": 185,
        "workflowId": "kTFv5sNHNHawYdrW",
        "versionId": "557a35c1-ce34-4caf-81f6-528ddf119106",
        "event": "activated",
        "userId": "c557a393-301d-4cd5-ada0-4ae8574f88c9"
      }
    ]
  }
}
```

</details>

---

## Morning Commute Traffic

| Field | Value |
|---|---|
| **ID** | `BwdXaFT5pHhgwmTj` |
| **Status** | 🟢 Active |
| **Schedule** | `45 6 * * 1-5` |
| **Backup file** | `morning_commute_traffic.json` |

**Nodes (4):**
  - `n8n-nodes-base.scheduleTrigger` — **Schedule 6:45 AM**
  - `n8n-nodes-base.httpRequest` — **Ask Gemini Pro**
  - `n8n-nodes-base.code` — **Format Message**
  - `n8n-nodes-base.httpRequest` — **Send to Telegram**

<details>
<summary>Full JSON config</summary>

```json
{
  "updatedAt": "2026-04-03T05:24:13.411Z",
  "createdAt": "2026-03-10T11:13:45.001Z",
  "id": "BwdXaFT5pHhgwmTj",
  "name": "Morning Commute Traffic",
  "description": null,
  "active": true,
  "isArchived": false,
  "nodes": [
    {
      "id": "schedule-commute",
      "name": "Schedule 6:45 AM",
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
              "expression": "45 6 * * 1-5"
            }
          ]
        }
      }
    },
    {
      "id": "ask-gemini-traffic",
      "name": "Ask Gemini Pro",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        240,
        0
      ],
      "parameters": {
        "method": "POST",
        "url": "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=AIzaSyAnnVmRDJTCRGKBvM80tEGpKmBa-f0CFpY",
        "sendBody": true,
        "contentType": "raw",
        "rawContentType": "application/json",
        "body": "{\"contents\": [{\"parts\": [{\"text\": \"Generate a morning commute traffic report for Dain driving from 6206 Redins Drive, Alexandria VA to St Thomas More Cathedral School, Arlington VA. Assume current time is ~6:45 AM EST on a weekday. Estimate the drive time based on typical I-395 N morning rush hour traffic. Mention the route (I-395 N). Keep it concise, helpful, and nicely formatted with emojis.\"}]}]}",
        "options": {}
      }
    },
    {
      "id": "format-traffic-msg",
      "name": "Format Message",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        480,
        0
      ],
      "parameters": {
        "jsCode": "const text = $input.first().json.candidates?.[0]?.content?.parts?.[0]?.text || 'Traffic report unavailable.';\nreturn [{ json: { message: '\ud83d\ude97 *Morning Commute Update*\\n\\n' + text.trim() + '\\n\\n*(via n8n & Gemini Pro)*' } }];"
      }
    },
    {
      "id": "send-telegram-traffic",
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
        "body": "={ \"chat_id\": \"8305133249\", \"text\": {{ JSON.stringify($json.message) }} }",
        "options": {}
      }
    }
  ],
  "connections": {
    "Schedule 6:45 AM": {
      "main": [
        [
          {
            "node": "Ask Gemini Pro",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Ask Gemini Pro": {
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
    "node:Schedule 6:45 AM": {
      "recurrenceRules": []
    }
  },
  "meta": null,
  "pinData": {},
  "versionId": "af320e36-7f9a-458b-972e-8bd680accd39",
  "activeVersionId": "af320e36-7f9a-458b-972e-8bd680accd39",
  "versionCounter": 18,
  "triggerCount": 1,
  "shared": [
    {
      "updatedAt": "2026-03-10T11:13:45.001Z",
      "createdAt": "2026-03-10T11:13:45.001Z",
      "role": "workflow:owner",
      "workflowId": "BwdXaFT5pHhgwmTj",
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
    "updatedAt": "2026-04-03T05:24:13.412Z",
    "createdAt": "2026-04-03T05:24:13.412Z",
    "versionId": "af320e36-7f9a-458b-972e-8bd680accd39",
    "workflowId": "BwdXaFT5pHhgwmTj",
    "nodes": [
      {
        "id": "schedule-commute",
        "name": "Schedule 6:45 AM",
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
                "expression": "45 6 * * 1-5"
              }
            ]
          }
        }
      },
      {
        "id": "ask-gemini-traffic",
        "name": "Ask Gemini Pro",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [
          240,
          0
        ],
        "parameters": {
          "method": "POST",
          "url": "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=AIzaSyAnnVmRDJTCRGKBvM80tEGpKmBa-f0CFpY",
          "sendBody": true,
          "contentType": "raw",
          "rawContentType": "application/json",
          "body": "{\"contents\": [{\"parts\": [{\"text\": \"Generate a morning commute traffic report for Dain driving from 6206 Redins Drive, Alexandria VA to St Thomas More Cathedral School, Arlington VA. Assume current time is ~6:45 AM EST on a weekday. Estimate the drive time based on typical I-395 N morning rush hour traffic. Mention the route (I-395 N). Keep it concise, helpful, and nicely formatted with emojis.\"}]}]}",
          "options": {}
        }
      },
      {
        "id": "format-traffic-msg",
        "name": "Format Message",
        "type": "n8n-nodes-base.code",
        "typeVersion": 2,
        "position": [
          480,
          0
        ],
        "parameters": {
          "jsCode": "const text = $input.first().json.candidates?.[0]?.content?.parts?.[0]?.text || 'Traffic report unavailable.';\nreturn [{ json: { message: '\ud83d\ude97 *Morning Commute Update*\\n\\n' + text.trim() + '\\n\\n*(via n8n & Gemini Pro)*' } }];"
        }
      },
      {
        "id": "send-telegram-traffic",
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
          "body": "={ \"chat_id\": \"8305133249\", \"text\": {{ JSON.stringify($json.message) }} }",
          "options": {}
        }
      }
    ],
    "connections": {
      "Schedule 6:45 AM": {
        "main": [
          [
            {
              "node": "Ask Gemini Pro",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Ask Gemini Pro": {
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
        "createdAt": "2026-04-03T05:24:13.458Z",
        "id": 263,
        "workflowId": "BwdXaFT5pHhgwmTj",
        "versionId": "af320e36-7f9a-458b-972e-8bd680accd39",
        "event": "deactivated",
        "userId": "c557a393-301d-4cd5-ada0-4ae8574f88c9"
      },
      {
        "createdAt": "2026-04-03T05:24:13.480Z",
        "id": 264,
        "workflowId": "BwdXaFT5pHhgwmTj",
        "versionId": "af320e36-7f9a-458b-972e-8bd680accd39",
        "event": "activated",
        "userId": "c557a393-301d-4cd5-ada0-4ae8574f88c9"
      }
    ]
  }
}
```

</details>

---

## Morning News Digest (Telegram)

| Field | Value |
|---|---|
| **ID** | `LvwMEORrcb1rRQuT` |
| **Status** | 🟢 Active |
| **Schedule** | `30 6 * * *` |
| **Backup file** | `morning_news_digest_telegram.json` |

**Nodes (10):**
  - `n8n-nodes-base.scheduleTrigger` — **Schedule 6:30AM**
  - `n8n-nodes-base.rssFeedRead` — **Fox World RSS**
  - `n8n-nodes-base.rssFeedRead` — **Fox Science RSS**
  - `n8n-nodes-base.rssFeedRead` — **Ars Technica RSS**
  - `n8n-nodes-base.rssFeedRead` — **BBC Science RSS**
  - `n8n-nodes-base.rssFeedRead` — **NPR News RSS**
  - `n8n-nodes-base.code` — **Format Digest**
  - `n8n-nodes-base.httpRequest` — **Send to Telegram**
  - `n8n-nodes-base.rssFeedRead` — **CNN RSS**
  - `n8n-nodes-base.rssFeedRead` — **Reuters via Yahoo RSS**

<details>
<summary>Full JSON config</summary>

```json
{
  "updatedAt": "2026-03-16T13:58:50.941Z",
  "createdAt": "2026-03-08T15:30:32.635Z",
  "id": "LvwMEORrcb1rRQuT",
  "name": "Morning News Digest (Telegram)",
  "description": null,
  "active": true,
  "isArchived": false,
  "nodes": [
    {
      "id": "schedule",
      "name": "Schedule 6:30AM",
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
              "expression": "30 6 * * *"
            }
          ]
        }
      },
      "alwaysOutputData": true
    },
    {
      "name": "Fox World RSS",
      "type": "n8n-nodes-base.rssFeedRead",
      "typeVersion": 1,
      "position": [
        200,
        100
      ],
      "parameters": {
        "url": "https://moxie.foxnews.com/google-publisher/world.xml"
      },
      "alwaysOutputData": true,
      "continueOnFail": true,
      "id": "9268fc0a-4bcf-4547-afaa-0e2b9abfee60"
    },
    {
      "name": "Fox Science RSS",
      "type": "n8n-nodes-base.rssFeedRead",
      "typeVersion": 1,
      "position": [
        200,
        220
      ],
      "parameters": {
        "url": "https://moxie.foxnews.com/google-publisher/science.xml"
      },
      "alwaysOutputData": true,
      "continueOnFail": true,
      "id": "533e76f1-a00f-4005-b16e-8b423910473b"
    },
    {
      "name": "Ars Technica RSS",
      "type": "n8n-nodes-base.rssFeedRead",
      "typeVersion": 1,
      "position": [
        200,
        340
      ],
      "parameters": {
        "url": "https://feeds.arstechnica.com/arstechnica/index"
      },
      "alwaysOutputData": true,
      "continueOnFail": true,
      "id": "5ff785fa-96a0-4555-b443-398170e57372"
    },
    {
      "name": "BBC Science RSS",
      "type": "n8n-nodes-base.rssFeedRead",
      "typeVersion": 1,
      "position": [
        200,
        460
      ],
      "parameters": {
        "url": "https://feeds.bbci.co.uk/news/science_and_environment/rss.xml"
      },
      "alwaysOutputData": true,
      "continueOnFail": true,
      "id": "0e4ef9f2-595f-4024-84ef-b6ef05b660e7"
    },
    {
      "name": "NPR News RSS",
      "type": "n8n-nodes-base.rssFeedRead",
      "typeVersion": 1,
      "position": [
        200,
        580
      ],
      "parameters": {
        "url": "https://feeds.npr.org/1001/rss.xml"
      },
      "alwaysOutputData": true,
      "continueOnFail": true,
      "id": "8c845e1d-5046-4f8b-a664-22c381c3cd0e"
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
        "jsCode": "\nconst today = new Date().toLocaleDateString('en-US', {weekday:'long', month:'long', day:'numeric'});\n\nfunction getTop(nodeId, n) {\n  try {\n    const items = $(nodeId).all();\n    return items.slice(0, n).map(i => ({\n      title: (i.json.title || '').replace(/[*[\\]]/g, '').trim(),\n      link: i.json.link || ''\n    })).filter(p => p.title);\n  } catch(e) { return []; }\n}\n\nlet html = `<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n<meta charset=\"UTF-8\">\n<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n<title>NEWS.DAINBENTLEY.COM</title>\n<style>\n  body { background-color: #f0f0f0; color: #000; font-family: \"Times New Roman\", Times, serif; text-align: center; margin: 0; padding: 20px; }\n  .header { border-bottom: 2px solid #000; padding-bottom: 10px; margin-bottom: 20px; }\n  h1 { font-family: \"Impact\", sans-serif; font-size: 4rem; margin: 0; text-transform: uppercase; font-style: italic; letter-spacing: -2px; }\n  .date { font-weight: bold; font-size: 1.2rem; border-top: 1px solid #000; border-bottom: 1px solid #000; padding: 5px 0; margin-top: 5px; }\n  .container { display: flex; flex-wrap: wrap; justify-content: center; gap: 40px; text-align: left; max-width: 1200px; margin: 0 auto; }\n  .column { flex: 1; min-width: 300px; }\n  .section-title { color: #cc0000; font-family: Arial, sans-serif; font-weight: bold; font-size: 1rem; border-bottom: 1px solid #ccc; margin-top: 25px; margin-bottom: 10px; padding-bottom: 2px; }\n  a { display: block; color: #0000ee; text-decoration: none; font-size: 1.3rem; font-weight: bold; line-height: 1.2; margin-bottom: 15px; }\n  a:hover { text-decoration: underline; }\n</style>\n</head>\n<body>\n  <div class=\"header\">\n    <h1>REPORT</h1>\n    <div class=\"date\">${today}</div>\n  </div>\n  <div class=\"container\">\n`;\n\nlet col1 = '<div class=\"column\">';\nlet col2 = '<div class=\"column\">';\nlet col3 = '<div class=\"column\">';\n\nconst world = getTop('Fox World RSS', 5);\nif (world.length) {\n  col1 += '<div class=\"section-title\">WORLD</div>';\n  for (const p of world) col1 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nconst reuters = getTop('Reuters via Yahoo RSS', 5);\nif (reuters.length) {\n  col1 += '<div class=\"section-title\">REUTERS</div>';\n  for (const p of reuters) col1 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nconst cnn = getTop('CNN RSS', 5);\nif (cnn.length) {\n  col2 += '<div class=\"section-title\">HEADLINES</div>';\n  for (const p of cnn) col2 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nconst npr = getTop('NPR News RSS', 5);\nif (npr.length) {\n  col2 += '<div class=\"section-title\">NPR</div>';\n  for (const p of npr) col2 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nconst tech = getTop('Ars Technica RSS', 5);\nif (tech.length) {\n  col3 += '<div class=\"section-title\">TECHNOLOGY</div>';\n  for (const p of tech) col3 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nconst sci = [...getTop('Fox Science RSS', 3), ...getTop('BBC Science RSS', 3)].slice(0, 5);\nif (sci.length) {\n  col3 += '<div class=\"section-title\">SCIENCE</div>';\n  for (const p of sci) col3 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nhtml += col1 + '</div>' + col2 + '</div>' + col3 + '</div>' + '</div></body></html>';\n\n// Keep the telegram message separate\nlet msg = '\ud83d\udcca *News Briefing \u2014 ' + today + '*\\n\\nView full report: [news.dainbentley.com](https://news.dainbentley.com)';\n\nreturn [{ json: { message: msg, html: html } }];\n"
      },
      "alwaysOutputData": true
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
        "body": "={ \"chat_id\": \"8305133249\", \"text\": {{ JSON.stringify($json.message) }}, \"parse_mode\": \"Markdown\" }",
        "options": {}
      },
      "alwaysOutputData": true
    },
    {
      "name": "CNN RSS",
      "type": "n8n-nodes-base.rssFeedRead",
      "typeVersion": 1,
      "position": [
        200,
        700
      ],
      "parameters": {
        "url": "http://rss.cnn.com/rss/cnn_topstories.rss"
      },
      "alwaysOutputData": true,
      "continueOnFail": true,
      "id": "6021c416-3793-4f26-add4-36648e97f466"
    },
    {
      "name": "Reuters via Yahoo RSS",
      "type": "n8n-nodes-base.rssFeedRead",
      "typeVersion": 1,
      "position": [
        200,
        820
      ],
      "parameters": {
        "url": "https://news.yahoo.com/rss/world"
      },
      "alwaysOutputData": true,
      "continueOnFail": true,
      "id": "e78da193-5624-42db-9077-9659f9f14ee8"
    }
  ],
  "connections": {
    "Schedule 6:30AM": {
      "main": [
        [
          {
            "node": "Fox World RSS",
            "type": "main",
            "index": 0
          },
          {
            "node": "Fox Science RSS",
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
            "node": "NPR News RSS",
            "type": "main",
            "index": 0
          },
          {
            "node": "CNN RSS",
            "type": "main",
            "index": 0
          },
          {
            "node": "Reuters via Yahoo RSS",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Fox World RSS": {
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
    "Fox Science RSS": {
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
    "NPR News RSS": {
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
    },
    "CNN RSS": {
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
    "Reuters via Yahoo RSS": {
      "main": [
        [
          {
            "node": "Format Digest",
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
    "availableInMCP": false,
    "saveDataSuccessExecution": "all"
  },
  "staticData": {
    "node:Schedule 8AM": {
      "recurrenceRules": []
    },
    "node:Schedule 6:30AM": {
      "recurrenceRules": []
    }
  },
  "meta": null,
  "pinData": null,
  "versionId": "205e30bf-e667-467e-b2b8-7d5792589316",
  "activeVersionId": "205e30bf-e667-467e-b2b8-7d5792589316",
  "versionCounter": 66,
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
    "updatedAt": "2026-03-16T13:58:50.943Z",
    "createdAt": "2026-03-16T13:58:50.943Z",
    "versionId": "205e30bf-e667-467e-b2b8-7d5792589316",
    "workflowId": "LvwMEORrcb1rRQuT",
    "nodes": [
      {
        "id": "schedule",
        "name": "Schedule 6:30AM",
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
                "expression": "30 6 * * *"
              }
            ]
          }
        },
        "alwaysOutputData": true
      },
      {
        "name": "Fox World RSS",
        "type": "n8n-nodes-base.rssFeedRead",
        "typeVersion": 1,
        "position": [
          200,
          100
        ],
        "parameters": {
          "url": "https://moxie.foxnews.com/google-publisher/world.xml"
        },
        "alwaysOutputData": true,
        "continueOnFail": true,
        "id": "9268fc0a-4bcf-4547-afaa-0e2b9abfee60"
      },
      {
        "name": "Fox Science RSS",
        "type": "n8n-nodes-base.rssFeedRead",
        "typeVersion": 1,
        "position": [
          200,
          220
        ],
        "parameters": {
          "url": "https://moxie.foxnews.com/google-publisher/science.xml"
        },
        "alwaysOutputData": true,
        "continueOnFail": true,
        "id": "533e76f1-a00f-4005-b16e-8b423910473b"
      },
      {
        "name": "Ars Technica RSS",
        "type": "n8n-nodes-base.rssFeedRead",
        "typeVersion": 1,
        "position": [
          200,
          340
        ],
        "parameters": {
          "url": "https://feeds.arstechnica.com/arstechnica/index"
        },
        "alwaysOutputData": true,
        "continueOnFail": true,
        "id": "5ff785fa-96a0-4555-b443-398170e57372"
      },
      {
        "name": "BBC Science RSS",
        "type": "n8n-nodes-base.rssFeedRead",
        "typeVersion": 1,
        "position": [
          200,
          460
        ],
        "parameters": {
          "url": "https://feeds.bbci.co.uk/news/science_and_environment/rss.xml"
        },
        "alwaysOutputData": true,
        "continueOnFail": true,
        "id": "0e4ef9f2-595f-4024-84ef-b6ef05b660e7"
      },
      {
        "name": "NPR News RSS",
        "type": "n8n-nodes-base.rssFeedRead",
        "typeVersion": 1,
        "position": [
          200,
          580
        ],
        "parameters": {
          "url": "https://feeds.npr.org/1001/rss.xml"
        },
        "alwaysOutputData": true,
        "continueOnFail": true,
        "id": "8c845e1d-5046-4f8b-a664-22c381c3cd0e"
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
          "jsCode": "\nconst today = new Date().toLocaleDateString('en-US', {weekday:'long', month:'long', day:'numeric'});\n\nfunction getTop(nodeId, n) {\n  try {\n    const items = $(nodeId).all();\n    return items.slice(0, n).map(i => ({\n      title: (i.json.title || '').replace(/[*[\\]]/g, '').trim(),\n      link: i.json.link || ''\n    })).filter(p => p.title);\n  } catch(e) { return []; }\n}\n\nlet html = `<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n<meta charset=\"UTF-8\">\n<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n<title>NEWS.DAINBENTLEY.COM</title>\n<style>\n  body { background-color: #f0f0f0; color: #000; font-family: \"Times New Roman\", Times, serif; text-align: center; margin: 0; padding: 20px; }\n  .header { border-bottom: 2px solid #000; padding-bottom: 10px; margin-bottom: 20px; }\n  h1 { font-family: \"Impact\", sans-serif; font-size: 4rem; margin: 0; text-transform: uppercase; font-style: italic; letter-spacing: -2px; }\n  .date { font-weight: bold; font-size: 1.2rem; border-top: 1px solid #000; border-bottom: 1px solid #000; padding: 5px 0; margin-top: 5px; }\n  .container { display: flex; flex-wrap: wrap; justify-content: center; gap: 40px; text-align: left; max-width: 1200px; margin: 0 auto; }\n  .column { flex: 1; min-width: 300px; }\n  .section-title { color: #cc0000; font-family: Arial, sans-serif; font-weight: bold; font-size: 1rem; border-bottom: 1px solid #ccc; margin-top: 25px; margin-bottom: 10px; padding-bottom: 2px; }\n  a { display: block; color: #0000ee; text-decoration: none; font-size: 1.3rem; font-weight: bold; line-height: 1.2; margin-bottom: 15px; }\n  a:hover { text-decoration: underline; }\n</style>\n</head>\n<body>\n  <div class=\"header\">\n    <h1>REPORT</h1>\n    <div class=\"date\">${today}</div>\n  </div>\n  <div class=\"container\">\n`;\n\nlet col1 = '<div class=\"column\">';\nlet col2 = '<div class=\"column\">';\nlet col3 = '<div class=\"column\">';\n\nconst world = getTop('Fox World RSS', 5);\nif (world.length) {\n  col1 += '<div class=\"section-title\">WORLD</div>';\n  for (const p of world) col1 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nconst reuters = getTop('Reuters via Yahoo RSS', 5);\nif (reuters.length) {\n  col1 += '<div class=\"section-title\">REUTERS</div>';\n  for (const p of reuters) col1 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nconst cnn = getTop('CNN RSS', 5);\nif (cnn.length) {\n  col2 += '<div class=\"section-title\">HEADLINES</div>';\n  for (const p of cnn) col2 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nconst npr = getTop('NPR News RSS', 5);\nif (npr.length) {\n  col2 += '<div class=\"section-title\">NPR</div>';\n  for (const p of npr) col2 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nconst tech = getTop('Ars Technica RSS', 5);\nif (tech.length) {\n  col3 += '<div class=\"section-title\">TECHNOLOGY</div>';\n  for (const p of tech) col3 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nconst sci = [...getTop('Fox Science RSS', 3), ...getTop('BBC Science RSS', 3)].slice(0, 5);\nif (sci.length) {\n  col3 += '<div class=\"section-title\">SCIENCE</div>';\n  for (const p of sci) col3 += `<a href=\"${p.link}\">${p.title}</a>`;\n}\n\nhtml += col1 + '</div>' + col2 + '</div>' + col3 + '</div>' + '</div></body></html>';\n\n// Keep the telegram message separate\nlet msg = '\ud83d\udcca *News Briefing \u2014 ' + today + '*\\n\\nView full report: [news.dainbentley.com](https://news.dainbentley.com)';\n\nreturn [{ json: { message: msg, html: html } }];\n"
        },
        "alwaysOutputData": true
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
          "body": "={ \"chat_id\": \"8305133249\", \"text\": {{ JSON.stringify($json.message) }}, \"parse_mode\": \"Markdown\" }",
          "options": {}
        },
        "alwaysOutputData": true
      },
      {
        "name": "CNN RSS",
        "type": "n8n-nodes-base.rssFeedRead",
        "typeVersion": 1,
        "position": [
          200,
          700
        ],
        "parameters": {
          "url": "http://rss.cnn.com/rss/cnn_topstories.rss"
        },
        "alwaysOutputData": true,
        "continueOnFail": true,
        "id": "6021c416-3793-4f26-add4-36648e97f466"
      },
      {
        "name": "Reuters via Yahoo RSS",
        "type": "n8n-nodes-base.rssFeedRead",
        "typeVersion": 1,
        "position": [
          200,
          820
        ],
        "parameters": {
          "url": "https://news.yahoo.com/rss/world"
        },
        "alwaysOutputData": true,
        "continueOnFail": true,
        "id": "e78da193-5624-42db-9077-9659f9f14ee8"
      }
    ],
    "connections": {
      "Schedule 6:30AM": {
        "main": [
          [
            {
              "node": "Fox World RSS",
              "type": "main",
              "index": 0
            },
            {
              "node": "Fox Science RSS",
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
              "node": "NPR News RSS",
              "type": "main",
              "index": 0
            },
            {
              "node": "CNN RSS",
              "type": "main",
              "index": 0
            },
            {
              "node": "Reuters via Yahoo RSS",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Fox World RSS": {
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
      "Fox Science RSS": {
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
      "NPR News RSS": {
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
      },
      "CNN RSS": {
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
      "Reuters via Yahoo RSS": {
        "main": [
          [
            {
              "node": "Format Digest",
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
        "createdAt": "2026-03-16T13:58:51.002Z",
        "id": 186,
        "workflowId": "LvwMEORrcb1rRQuT",
        "versionId": "205e30bf-e667-467e-b2b8-7d5792589316",
        "event": "deactivated",
        "userId": "c557a393-301d-4cd5-ada0-4ae8574f88c9"
      },
      {
        "createdAt": "2026-03-16T13:58:51.026Z",
        "id": 187,
        "workflowId": "LvwMEORrcb1rRQuT",
        "versionId": "205e30bf-e667-467e-b2b8-7d5792589316",
        "event": "activated",
        "userId": "c557a393-301d-4cd5-ada0-4ae8574f88c9"
      }
    ]
  }
}
```

</details>

---

## Notary Request Intake (Gemini Flash)

| Field | Value |
|---|---|
| **ID** | `JbekZR8r1ebXe16n` |
| **Status** | 🟢 Active |
| **Backup file** | `notary_request_intake_gemini_flash.json` |

**Nodes (6):**
  - `n8n-nodes-base.gmailTrigger` — **Gmail Trigger**
  - `n8n-nodes-base.httpRequest` — **Extract with Gemini**
  - `n8n-nodes-base.code` — **Parse AI Output**
  - `n8n-nodes-base.if` — **Is Notary Request?**
  - `n8n-nodes-base.httpRequest` — **Notify Dain**
  - `n8n-nodes-base.gmail` — **Auto-Reply to Client**

<details>
<summary>Full JSON config</summary>

```json
{
  "updatedAt": "2026-03-24T13:40:28.346Z",
  "createdAt": "2026-03-06T05:36:26.364Z",
  "id": "JbekZR8r1ebXe16n",
  "name": "Notary Request Intake (Gemini Flash)",
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
        "url": "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=AIzaSyAnnVmRDJTCRGKBvM80tEGpKmBa-f0CFpY",
        "sendHeaders": true,
        "headerParameters": {
          "parameters": [
            {
              "name": "Content-Type",
              "value": "application/json"
            }
          ]
        },
        "sendBody": true,
        "contentType": "raw",
        "rawContentType": "application/json",
        "body": "={\"contents\": [{\"parts\": [{\"text\": \"You are a Notary Service Assistant. Your task is to analyze incoming emails and determine if they are requests for notary or loan signing services. \\n\\nCRITICAL RULE: If the email contains ANY mention of 'notary', 'notarize', 'loan signing', 'signing agent', 'closing', or 'documents to sign', you MUST set isNotaryRequest to true. \\n\\nExtract the following fields if available, otherwise use 'Not provided': \\n- clientName, \\n- serviceType, \\n- preferredDateTime, \\n- location, \\n- phone. \\n\\nReturn ONLY a valid JSON object with these keys: isNotaryRequest (boolean), isNNA (boolean: true if from National Notary Association), clientName (string), serviceType (string), preferredDateTime (string), location (string), phone (string). \\n\\nEmail Subject: {{ ($json.Subject || $json.subject || '').replace(/\\\"/g, '\\\\\\\\\\\"').replace(/\\\\n/g, ' ') }} \\nEmail Body: {{ ($json.textPlain || $json.snippet || '').replace(/\\\"/g, '\\\\\\\\\\\"').replace(/\\\\n/g, ' ') }}\"}]}], \"generationConfig\": {\"response_mime_type\": \"application/json\"}}",
        "options": {}
      },
      "id": "gemini-extract",
      "name": "Extract with Gemini",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        224,
        0
      ]
    },
    {
      "parameters": {
        "jsCode": "\ntry {\n  const text = $input.first().json.candidates[0].content.parts[0].text;\n  const data = JSON.parse(text);\n  \n  const fromValue = $('Gmail Trigger').first().json.from.value || $('Gmail Trigger').first().json.from;\n  data.originalSender = fromValue;\n  data.originalSubject = $('Gmail Trigger').first().json.subject;\n  \n  // Secondary check for NNA in case Gemini misses the flag\n  if (!data.isNNA) {\n    data.isNNA = fromValue.toLowerCase().includes('nationalnotary.org') || \n                 data.originalSubject.toLowerCase().includes('national notary association');\n  }\n  \n  return [{ json: data }];\n} catch (e) {\n  return [{ json: { isNotaryRequest: false, error: e.message } }];\n}\n"
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
            },
            {
              "value1": "={{ $json.isNNA }}",
              "value2": false
            }
          ]
        },
        "combineOperation": "all"
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
            "node": "Extract with Gemini",
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
    "Extract with Gemini": {
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
      "lastTimeChecked": 1775531142,
      "possibleDuplicates": [
        "19d65e73070c791c",
        "19d65b3a4c517d3b"
      ]
    }
  },
  "meta": {
    "templateCredsSetupCompleted": true
  },
  "pinData": {},
  "versionId": "f27c8ae2-0103-49f4-91ab-8d7a0d2fac35",
  "activeVersionId": "f27c8ae2-0103-49f4-91ab-8d7a0d2fac35",
  "versionCounter": 1884,
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
    "updatedAt": "2026-03-24T13:40:28.347Z",
    "createdAt": "2026-03-24T13:40:28.347Z",
    "versionId": "f27c8ae2-0103-49f4-91ab-8d7a0d2fac35",
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
          "url": "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=AIzaSyAnnVmRDJTCRGKBvM80tEGpKmBa-f0CFpY",
          "sendHeaders": true,
          "headerParameters": {
            "parameters": [
              {
                "name": "Content-Type",
                "value": "application/json"
              }
            ]
          },
          "sendBody": true,
          "contentType": "raw",
          "rawContentType": "application/json",
          "body": "={\"contents\": [{\"parts\": [{\"text\": \"You are a Notary Service Assistant. Your task is to analyze incoming emails and determine if they are requests for notary or loan signing services. \\n\\nCRITICAL RULE: If the email contains ANY mention of 'notary', 'notarize', 'loan signing', 'signing agent', 'closing', or 'documents to sign', you MUST set isNotaryRequest to true. \\n\\nExtract the following fields if available, otherwise use 'Not provided': \\n- clientName, \\n- serviceType, \\n- preferredDateTime, \\n- location, \\n- phone. \\n\\nReturn ONLY a valid JSON object with these keys: isNotaryRequest (boolean), isNNA (boolean: true if from National Notary Association), clientName (string), serviceType (string), preferredDateTime (string), location (string), phone (string). \\n\\nEmail Subject: {{ ($json.Subject || $json.subject || '').replace(/\\\"/g, '\\\\\\\\\\\"').replace(/\\\\n/g, ' ') }} \\nEmail Body: {{ ($json.textPlain || $json.snippet || '').replace(/\\\"/g, '\\\\\\\\\\\"').replace(/\\\\n/g, ' ') }}\"}]}], \"generationConfig\": {\"response_mime_type\": \"application/json\"}}",
          "options": {}
        },
        "id": "gemini-extract",
        "name": "Extract with Gemini",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [
          224,
          0
        ]
      },
      {
        "parameters": {
          "jsCode": "\ntry {\n  const text = $input.first().json.candidates[0].content.parts[0].text;\n  const data = JSON.parse(text);\n  \n  const fromValue = $('Gmail Trigger').first().json.from.value || $('Gmail Trigger').first().json.from;\n  data.originalSender = fromValue;\n  data.originalSubject = $('Gmail Trigger').first().json.subject;\n  \n  // Secondary check for NNA in case Gemini misses the flag\n  if (!data.isNNA) {\n    data.isNNA = fromValue.toLowerCase().includes('nationalnotary.org') || \n                 data.originalSubject.toLowerCase().includes('national notary association');\n  }\n  \n  return [{ json: data }];\n} catch (e) {\n  return [{ json: { isNotaryRequest: false, error: e.message } }];\n}\n"
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
              },
              {
                "value1": "={{ $json.isNNA }}",
                "value2": false
              }
            ]
          },
          "combineOperation": "all"
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
              "node": "Extract with Gemini",
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
      "Extract with Gemini": {
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
        "createdAt": "2026-03-24T13:40:28.434Z",
        "id": 225,
        "workflowId": "JbekZR8r1ebXe16n",
        "versionId": "f27c8ae2-0103-49f4-91ab-8d7a0d2fac35",
        "event": "deactivated",
        "userId": "c557a393-301d-4cd5-ada0-4ae8574f88c9"
      },
      {
        "createdAt": "2026-03-24T13:40:28.879Z",
        "id": 226,
        "workflowId": "JbekZR8r1ebXe16n",
        "versionId": "f27c8ae2-0103-49f4-91ab-8d7a0d2fac35",
        "event": "activated",
        "userId": "c557a393-301d-4cd5-ada0-4ae8574f88c9"
      }
    ]
  }
}
```

</details>

---

## Email Digest - Afternoon

| Field | Value |
|---|---|
| **ID** | `V52SOH2H0NoaEKfz` |
| **Status** | 🟢 Active |
| **Schedule** | `0 16 * * *` |
| **Backup file** | `email_digest_-_afternoon.json` |

**Nodes (6):**
  - `n8n-nodes-base.scheduleTrigger` — **Schedule**
  - `n8n-nodes-base.gmail` — **Gmail**
  - `n8n-nodes-base.code` — **Prepare Prompt**
  - `n8n-nodes-base.httpRequest` — **Ask Gemini Pro**
  - `n8n-nodes-base.code` — **Format Message**
  - `n8n-nodes-base.httpRequest` — **Send to Telegram**

<details>
<summary>Full JSON config</summary>

```json
{
  "updatedAt": "2026-04-03T05:24:13.544Z",
  "createdAt": "2026-03-10T13:14:51.412Z",
  "id": "V52SOH2H0NoaEKfz",
  "name": "Email Digest - Afternoon",
  "description": null,
  "active": true,
  "isArchived": false,
  "nodes": [
    {
      "id": "schedule",
      "name": "Schedule",
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
              "expression": "0 16 * * *"
            }
          ]
        }
      }
    },
    {
      "id": "gmail",
      "name": "Gmail",
      "type": "n8n-nodes-base.gmail",
      "typeVersion": 2.1,
      "position": [
        200,
        0
      ],
      "parameters": {
        "operation": "getAll",
        "limit": 50,
        "simple": true,
        "filters": {
          "q": "in:inbox newer_than:1d"
        }
      },
      "credentials": {
        "gmailOAuth2": {
          "id": "73FQ8r7lzSZjobXf",
          "name": "Gmail account"
        }
      },
      "alwaysOutputData": true
    },
    {
      "id": "prepare-prompt",
      "name": "Prepare Prompt",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        400,
        0
      ],
      "parameters": {
        "jsCode": "\nlet emails = $input.all().map((e, index) => {\n  // Defensive extraction\n  let from = e.json.from || e.json.From || e.json.sender || \"Unknown\";\n  let subject = e.json.subject || e.json.Subject || \"No Subject\";\n  let snippet = e.json.snippet || e.json.Snippet || \"\";\n  \n  // If it's a raw structure (headers array)\n  if (from === \"Unknown\" && Array.isArray(e.json.payload?.headers)) {\n    let fromHeader = e.json.payload.headers.find(h => h.name.toLowerCase() === 'from');\n    let subjectHeader = e.json.payload.headers.find(h => h.name.toLowerCase() === 'subject');\n    if (fromHeader) from = fromHeader.value;\n    if (subjectHeader) subject = subjectHeader.value;\n  }\n  \n  return `From: ${from}\\nSubject: ${subject}\\nSnippet: ${snippet}`;\n}).join('\\n\\n---\\n\\n');\n\nif (!emails || emails.trim() === \"\") {\n  emails = \"No emails found.\";\n}\n\nlet prompt = `You are an email assistant. Summarize the following inbox emails into a digest.\n\nCLASSIFY ONLY the emails provided below. Do not invent emails. If \"No emails found.\", just output \"\ud83d\udcec Inbox clear \u2705\"\n\n\ud83d\udd34 VIP \u2014 julie.a.siegel84@gmail.com or jabentley9@gmail.com ONLY\n\ud83d\udea8 IMPORTANT \u2014 VA, DOJ, IRS, OPM, court, banks, Charlotte school, medical, financial\n\ud83d\udfe1 MEDIUM \u2014 bills, subscriptions, receipts, newsletters\n\ud83d\uddd1\ufe0f SPAM \u2014 marketing, promotions, job alerts\n\nFormat EXACTLY like this (use Markdown). CRITICAL: KEEP THE ENTIRE RESPONSE CONCISE AND STRICTLY UNDER 3500 CHARACTERS TOTAL. If there are many medium/spam emails, truncate the list:\n\n\ud83d\udcec *Email Digest*\n\n\ud83d\udd34 *VIP*\n\u2022 [From] \u2014 [Subject] \u2014 [1-line summary]\n(or None.)\n\n\ud83d\udea8 *Urgent / Important*\n\u2022 [From] \u2014 [Subject] \u2014 [1-line summary]\n(or None.)\n\n\ud83d\udfe1 *Medium*\n\u2022 [From] \u2014 [Subject]\n(or None.)\n\n\ud83d\uddd1\ufe0f *Likely Spam*\n\u2022 [Comma separated senders]\n(or None.)\n\nEmails to classify:\n${emails}`;\n\nreturn [{ json: { prompt: prompt } }];\n"
      }
    },
    {
      "id": "ask-gemini",
      "name": "Ask Gemini Pro",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        600,
        0
      ],
      "parameters": {
        "method": "POST",
        "url": "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=AIzaSyAnnVmRDJTCRGKBvM80tEGpKmBa-f0CFpY",
        "sendBody": true,
        "contentType": "raw",
        "rawContentType": "application/json",
        "body": "={{ JSON.stringify({ contents: [{ parts: [{ text: $json.prompt }] }] }) }}",
        "options": {}
      }
    },
    {
      "id": "format-message",
      "name": "Format Message",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        800,
        0
      ],
      "parameters": {
        "jsCode": "const text = $input.first().json.candidates?.[0]?.content?.parts?.[0]?.text || 'Error generating digest.';\nreturn [{ json: { message: text.trim() + '\\n\\n*(via n8n & Gemini Pro)*' } }];"
      }
    },
    {
      "id": "send-telegram",
      "name": "Send to Telegram",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        1000,
        0
      ],
      "parameters": {
        "method": "POST",
        "url": "https://api.telegram.org/bot8544365014:AAEgKwHUF7_iG2AizJND2NuOUouPE4uQymQ/sendMessage",
        "sendBody": true,
        "contentType": "raw",
        "rawContentType": "application/json",
        "body": "={ \"chat_id\": \"8305133249\", \"text\": {{ JSON.stringify($json.message) }} }",
        "options": {}
      }
    }
  ],
  "connections": {
    "Schedule": {
      "main": [
        [
          {
            "node": "Gmail",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Gmail": {
      "main": [
        [
          {
            "node": "Prepare Prompt",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Prepare Prompt": {
      "main": [
        [
          {
            "node": "Ask Gemini Pro",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Ask Gemini Pro": {
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
    "node:Schedule": {
      "recurrenceRules": []
    }
  },
  "meta": null,
  "pinData": null,
  "versionId": "c6c6a864-2fe9-4bca-b431-bc90c8bc0765",
  "activeVersionId": "c6c6a864-2fe9-4bca-b431-bc90c8bc0765",
  "versionCounter": 25,
  "triggerCount": 1,
  "shared": [
    {
      "updatedAt": "2026-03-10T13:14:51.412Z",
      "createdAt": "2026-03-10T13:14:51.412Z",
      "role": "workflow:owner",
      "workflowId": "V52SOH2H0NoaEKfz",
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
    "updatedAt": "2026-04-03T05:24:13.546Z",
    "createdAt": "2026-04-03T05:24:13.546Z",
    "versionId": "c6c6a864-2fe9-4bca-b431-bc90c8bc0765",
    "workflowId": "V52SOH2H0NoaEKfz",
    "nodes": [
      {
        "id": "schedule",
        "name": "Schedule",
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
                "expression": "0 16 * * *"
              }
            ]
          }
        }
      },
      {
        "id": "gmail",
        "name": "Gmail",
        "type": "n8n-nodes-base.gmail",
        "typeVersion": 2.1,
        "position": [
          200,
          0
        ],
        "parameters": {
          "operation": "getAll",
          "limit": 50,
          "simple": true,
          "filters": {
            "q": "in:inbox newer_than:1d"
          }
        },
        "credentials": {
          "gmailOAuth2": {
            "id": "73FQ8r7lzSZjobXf",
            "name": "Gmail account"
          }
        },
        "alwaysOutputData": true
      },
      {
        "id": "prepare-prompt",
        "name": "Prepare Prompt",
        "type": "n8n-nodes-base.code",
        "typeVersion": 2,
        "position": [
          400,
          0
        ],
        "parameters": {
          "jsCode": "\nlet emails = $input.all().map((e, index) => {\n  // Defensive extraction\n  let from = e.json.from || e.json.From || e.json.sender || \"Unknown\";\n  let subject = e.json.subject || e.json.Subject || \"No Subject\";\n  let snippet = e.json.snippet || e.json.Snippet || \"\";\n  \n  // If it's a raw structure (headers array)\n  if (from === \"Unknown\" && Array.isArray(e.json.payload?.headers)) {\n    let fromHeader = e.json.payload.headers.find(h => h.name.toLowerCase() === 'from');\n    let subjectHeader = e.json.payload.headers.find(h => h.name.toLowerCase() === 'subject');\n    if (fromHeader) from = fromHeader.value;\n    if (subjectHeader) subject = subjectHeader.value;\n  }\n  \n  return `From: ${from}\\nSubject: ${subject}\\nSnippet: ${snippet}`;\n}).join('\\n\\n---\\n\\n');\n\nif (!emails || emails.trim() === \"\") {\n  emails = \"No emails found.\";\n}\n\nlet prompt = `You are an email assistant. Summarize the following inbox emails into a digest.\n\nCLASSIFY ONLY the emails provided below. Do not invent emails. If \"No emails found.\", just output \"\ud83d\udcec Inbox clear \u2705\"\n\n\ud83d\udd34 VIP \u2014 julie.a.siegel84@gmail.com or jabentley9@gmail.com ONLY\n\ud83d\udea8 IMPORTANT \u2014 VA, DOJ, IRS, OPM, court, banks, Charlotte school, medical, financial\n\ud83d\udfe1 MEDIUM \u2014 bills, subscriptions, receipts, newsletters\n\ud83d\uddd1\ufe0f SPAM \u2014 marketing, promotions, job alerts\n\nFormat EXACTLY like this (use Markdown). CRITICAL: KEEP THE ENTIRE RESPONSE CONCISE AND STRICTLY UNDER 3500 CHARACTERS TOTAL. If there are many medium/spam emails, truncate the list:\n\n\ud83d\udcec *Email Digest*\n\n\ud83d\udd34 *VIP*\n\u2022 [From] \u2014 [Subject] \u2014 [1-line summary]\n(or None.)\n\n\ud83d\udea8 *Urgent / Important*\n\u2022 [From] \u2014 [Subject] \u2014 [1-line summary]\n(or None.)\n\n\ud83d\udfe1 *Medium*\n\u2022 [From] \u2014 [Subject]\n(or None.)\n\n\ud83d\uddd1\ufe0f *Likely Spam*\n\u2022 [Comma separated senders]\n(or None.)\n\nEmails to classify:\n${emails}`;\n\nreturn [{ json: { prompt: prompt } }];\n"
        }
      },
      {
        "id": "ask-gemini",
        "name": "Ask Gemini Pro",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [
          600,
          0
        ],
        "parameters": {
          "method": "POST",
          "url": "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=AIzaSyAnnVmRDJTCRGKBvM80tEGpKmBa-f0CFpY",
          "sendBody": true,
          "contentType": "raw",
          "rawContentType": "application/json",
          "body": "={{ JSON.stringify({ contents: [{ parts: [{ text: $json.prompt }] }] }) }}",
          "options": {}
        }
      },
      {
        "id": "format-message",
        "name": "Format Message",
        "type": "n8n-nodes-base.code",
        "typeVersion": 2,
        "position": [
          800,
          0
        ],
        "parameters": {
          "jsCode": "const text = $input.first().json.candidates?.[0]?.content?.parts?.[0]?.text || 'Error generating digest.';\nreturn [{ json: { message: text.trim() + '\\n\\n*(via n8n & Gemini Pro)*' } }];"
        }
      },
      {
        "id": "send-telegram",
        "name": "Send to Telegram",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [
          1000,
          0
        ],
        "parameters": {
          "method": "POST",
          "url": "https://api.telegram.org/bot8544365014:AAEgKwHUF7_iG2AizJND2NuOUouPE4uQymQ/sendMessage",
          "sendBody": true,
          "contentType": "raw",
          "rawContentType": "application/json",
          "body": "={ \"chat_id\": \"8305133249\", \"text\": {{ JSON.stringify($json.message) }} }",
          "options": {}
        }
      }
    ],
    "connections": {
      "Schedule": {
        "main": [
          [
            {
              "node": "Gmail",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Gmail": {
        "main": [
          [
            {
              "node": "Prepare Prompt",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Prepare Prompt": {
        "main": [
          [
            {
              "node": "Ask Gemini Pro",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Ask Gemini Pro": {
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
        "createdAt": "2026-04-03T05:24:13.585Z",
        "id": 265,
        "workflowId": "V52SOH2H0NoaEKfz",
        "versionId": "c6c6a864-2fe9-4bca-b431-bc90c8bc0765",
        "event": "deactivated",
        "userId": "c557a393-301d-4cd5-ada0-4ae8574f88c9"
      },
      {
        "createdAt": "2026-04-03T05:24:13.605Z",
        "id": 266,
        "workflowId": "V52SOH2H0NoaEKfz",
        "versionId": "c6c6a864-2fe9-4bca-b431-bc90c8bc0765",
        "event": "activated",
        "userId": "c557a393-301d-4cd5-ada0-4ae8574f88c9"
      }
    ]
  }
}
```

</details>

---

## OpenBSD Mailing List Archiver

| Field | Value |
|---|---|
| **ID** | `411yqv8YqOY9vzui` |
| **Status** | 🟢 Active |
| **Backup file** | `openbsd_mailing_list_archiver.json` |

**Nodes (3):**
  - `n8n-nodes-base.scheduleTrigger` — **Schedule Every 30 Min**
  - `n8n-nodes-base.gmail` — **Get OpenBSD Emails**
  - `n8n-nodes-base.gmail` — **Archive (Remove from Inbox)**

<details>
<summary>Full JSON config</summary>

```json
{
  "updatedAt": "2026-03-11T19:46:35.033Z",
  "createdAt": "2026-03-11T19:46:35.033Z",
  "id": "411yqv8YqOY9vzui",
  "name": "OpenBSD Mailing List Archiver",
  "description": null,
  "active": true,
  "isArchived": false,
  "nodes": [
    {
      "id": "schedule",
      "name": "Schedule Every 30 Min",
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
              "field": "minutes",
              "minutesInterval": 30
            }
          ]
        }
      }
    },
    {
      "id": "gmail-fetch",
      "name": "Get OpenBSD Emails",
      "type": "n8n-nodes-base.gmail",
      "typeVersion": 2.1,
      "position": [
        200,
        0
      ],
      "parameters": {
        "operation": "getAll",
        "limit": 50,
        "simple": true,
        "filters": {
          "q": "in:inbox label:\"OpenBSD Mailing List\""
        }
      },
      "credentials": {
        "gmailOAuth2": {
          "id": "73FQ8r7lzSZjobXf",
          "name": "Gmail account"
        }
      }
    },
    {
      "id": "gmail-archive",
      "name": "Archive (Remove from Inbox)",
      "type": "n8n-nodes-base.gmail",
      "typeVersion": 2.1,
      "position": [
        400,
        0
      ],
      "parameters": {
        "operation": "update",
        "messageId": "={{ $json.messageId }}",
        "updateFields": {
          "removeLabelIds": [
            "INBOX"
          ]
        }
      },
      "credentials": {
        "gmailOAuth2": {
          "id": "73FQ8r7lzSZjobXf",
          "name": "Gmail account"
        }
      }
    }
  ],
  "connections": {
    "Schedule Every 30 Min": {
      "main": [
        [
          {
            "node": "Get OpenBSD Emails",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Get OpenBSD Emails": {
      "main": [
        [
          {
            "node": "Archive (Remove from Inbox)",
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
    "node:Schedule Every 30 Min": {
      "recurrenceRules": []
    }
  },
  "meta": null,
  "pinData": null,
  "versionId": "277da06b-68dd-41a4-bb10-084eeb6eb935",
  "activeVersionId": "277da06b-68dd-41a4-bb10-084eeb6eb935",
  "versionCounter": 6,
  "triggerCount": 1,
  "shared": [
    {
      "updatedAt": "2026-03-11T19:46:35.033Z",
      "createdAt": "2026-03-11T19:46:35.033Z",
      "role": "workflow:owner",
      "workflowId": "411yqv8YqOY9vzui",
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
    "updatedAt": "2026-03-11T19:46:35.042Z",
    "createdAt": "2026-03-11T19:46:35.042Z",
    "versionId": "277da06b-68dd-41a4-bb10-084eeb6eb935",
    "workflowId": "411yqv8YqOY9vzui",
    "nodes": [
      {
        "id": "schedule",
        "name": "Schedule Every 30 Min",
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
                "field": "minutes",
                "minutesInterval": 30
              }
            ]
          }
        }
      },
      {
        "id": "gmail-fetch",
        "name": "Get OpenBSD Emails",
        "type": "n8n-nodes-base.gmail",
        "typeVersion": 2.1,
        "position": [
          200,
          0
        ],
        "parameters": {
          "operation": "getAll",
          "limit": 50,
          "simple": true,
          "filters": {
            "q": "in:inbox label:\"OpenBSD Mailing List\""
          }
        },
        "credentials": {
          "gmailOAuth2": {
            "id": "73FQ8r7lzSZjobXf",
            "name": "Gmail account"
          }
        }
      },
      {
        "id": "gmail-archive",
        "name": "Archive (Remove from Inbox)",
        "type": "n8n-nodes-base.gmail",
        "typeVersion": 2.1,
        "position": [
          400,
          0
        ],
        "parameters": {
          "operation": "update",
          "messageId": "={{ $json.messageId }}",
          "updateFields": {
            "removeLabelIds": [
              "INBOX"
            ]
          }
        },
        "credentials": {
          "gmailOAuth2": {
            "id": "73FQ8r7lzSZjobXf",
            "name": "Gmail account"
          }
        }
      }
    ],
    "connections": {
      "Schedule Every 30 Min": {
        "main": [
          [
            {
              "node": "Get OpenBSD Emails",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "Get OpenBSD Emails": {
        "main": [
          [
            {
              "node": "Archive (Remove from Inbox)",
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
        "createdAt": "2026-03-11T19:46:35.136Z",
        "id": 135,
        "workflowId": "411yqv8YqOY9vzui",
        "versionId": "277da06b-68dd-41a4-bb10-084eeb6eb935",
        "event": "activated",
        "userId": "c557a393-301d-4cd5-ada0-4ae8574f88c9"
      }
    ]
  }
}
```

</details>

---

## Morning News Digest - Webhook Run

| Field | Value |
|---|---|
| **ID** | `HUcwxsrczOc92n2d` |
| **Status** | 🟢 Active |
| **Backup file** | `morning_news_digest_-_webhook_run.json` |

**Nodes (13):**
  - `n8n-nodes-base.webhook` — **Webhook**
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
  "updatedAt": "2026-03-09T13:22:50.259Z",
  "createdAt": "2026-03-09T13:22:50.259Z",
  "id": "HUcwxsrczOc92n2d",
  "name": "Morning News Digest - Webhook Run",
  "description": null,
  "active": true,
  "isArchived": false,
  "nodes": [
    {
      "id": "webhook-trigger",
      "name": "Webhook",
      "type": "n8n-nodes-base.webhook",
      "typeVersion": 1,
      "position": [
        0,
        0
      ],
      "parameters": {
        "path": "temp-news-digest",
        "options": {}
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
        "body": "={ \"chat_id\": \"8305133249\", \"text\": {{ JSON.stringify($json.message) }}, \"parse_mode\": \"Markdown\" }",
        "options": {}
      }
    }
  ],
  "connections": {
    "Webhook": {
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
  "staticData": null,
  "meta": null,
  "pinData": null,
  "versionId": "0b7fd743-4a13-4205-91a0-0ada1c4532cf",
  "activeVersionId": "0b7fd743-4a13-4205-91a0-0ada1c4532cf",
  "versionCounter": 5,
  "triggerCount": 1,
  "shared": [
    {
      "updatedAt": "2026-03-09T13:22:50.259Z",
      "createdAt": "2026-03-09T13:22:50.259Z",
      "role": "workflow:owner",
      "workflowId": "HUcwxsrczOc92n2d",
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
    "updatedAt": "2026-03-09T13:22:50.288Z",
    "createdAt": "2026-03-09T13:22:50.288Z",
    "versionId": "0b7fd743-4a13-4205-91a0-0ada1c4532cf",
    "workflowId": "HUcwxsrczOc92n2d",
    "nodes": [
      {
        "id": "webhook-trigger",
        "name": "Webhook",
        "type": "n8n-nodes-base.webhook",
        "typeVersion": 1,
        "position": [
          0,
          0
        ],
        "parameters": {
          "path": "temp-news-digest",
          "options": {}
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
          "body": "={ \"chat_id\": \"8305133249\", \"text\": {{ JSON.stringify($json.message) }}, \"parse_mode\": \"Markdown\" }",
          "options": {}
        }
      }
    ],
    "connections": {
      "Webhook": {
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
        "createdAt": "2026-03-11T11:07:10.838Z",
        "id": 125,
        "workflowId": "HUcwxsrczOc92n2d",
        "versionId": "0b7fd743-4a13-4205-91a0-0ada1c4532cf",
        "event": "activated",
        "userId": "c557a393-301d-4cd5-ada0-4ae8574f88c9"
      }
    ]
  }
}
```

</details>

---

