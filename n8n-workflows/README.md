# N8N Workflows
*Last exported: 2026-05-25 13:30*  
*Instance: https://n8n.dainbentley.com*

> To restore a workflow: go to n8n → Workflows → Import → paste the JSON file below.

---

## My workflow

| Field | Value |
|---|---|
| **ID** | `ljIVkK2tuvf0xMy5` |
| **Status** | 🔴 Inactive |
| **Backup file** | `my_workflow.json` |

**Nodes (13):**
  - `n8n-nodes-base.gmailTrigger` — **Gmail Trigger**
  - `@n8n/n8n-nodes-langchain.lmChatOpenAi` — **OpenAI Chat Model1**
  - `n8n-nodes-base.gmailTool` — **Gmail - read labels**
  - `n8n-nodes-base.gmailTool` — **Gmail - get message**
  - `n8n-nodes-base.gmailTool` — **Gmail - add label to message**
  - `n8n-nodes-base.gmailTool` — **Gmail - create label**
  - `@n8n/n8n-nodes-langchain.agent` — **Gmail labelling agent**
  - `@n8n/n8n-nodes-langchain.memoryBufferWindow` — **Window Buffer Memory**
  - `n8n-nodes-base.wait` — **Wait**
  - `n8n-nodes-base.stickyNote` — **Sticky Note**
  - `n8n-nodes-base.stickyNote` — **Sticky Note1**
  - `n8n-nodes-base.stickyNote` — **Sticky Note2**
  - `n8n-nodes-base.stickyNote` — **Sticky Note3**

<details>
<summary>Full JSON config</summary>

```json
{
  "updatedAt": "2026-04-13T02:37:36.352Z",
  "createdAt": "2026-04-13T02:21:05.868Z",
  "id": "ljIVkK2tuvf0xMy5",
  "name": "My workflow",
  "description": null,
  "active": false,
  "isArchived": false,
  "nodes": [
    {
      "parameters": {
        "pollTimes": {
          "item": [
            {
              "mode": "everyX",
              "value": 5,
              "unit": "minutes"
            }
          ]
        },
        "filters": {}
      },
      "id": "6b463e36-3be7-4735-bf0e-84ce09805a51",
      "name": "Gmail Trigger",
      "type": "n8n-nodes-base.gmailTrigger",
      "position": [
        -1120,
        608
      ],
      "typeVersion": 1.2,
      "credentials": {
        "gmailOAuth2": {
          "id": "eoLUGfEZSeV39pjE",
          "name": "Gmail account"
        }
      }
    },
    {
      "parameters": {
        "model": "gemini-flash",
        "options": {
          "maxTokens": 4096
        }
      },
      "id": "b20f5e5a-36e1-4b05-b5d0-58b17157ba71",
      "name": "OpenAI Chat Model1",
      "type": "@n8n/n8n-nodes-langchain.lmChatOpenAi",
      "position": [
        -992,
        816
      ],
      "notesInFlow": false,
      "typeVersion": 1,
      "credentials": {
        "openAiApi": {
          "id": "cRVeU2mA1oBP5bW8",
          "name": "OpenAI account 2"
        }
      }
    },
    {
      "parameters": {
        "descriptionType": "manual",
        "toolDescription": "Tool to read all existing gmail labels",
        "resource": "label",
        "returnAll": true
      },
      "id": "14b2d459-c941-4179-be82-4889b5cd318d",
      "name": "Gmail - read labels",
      "type": "n8n-nodes-base.gmailTool",
      "position": [
        -688,
        832
      ],
      "webhookId": "d8ec9401-a9ff-4fe2-9c1e-5a8036cd96c9",
      "typeVersion": 2.1,
      "credentials": {
        "gmailOAuth2": {
          "id": "eoLUGfEZSeV39pjE",
          "name": "Gmail account"
        }
      }
    },
    {
      "parameters": {
        "descriptionType": "manual",
        "toolDescription": "Tool to read a specific message based on the message ID",
        "operation": "get",
        "messageId": "={{ $fromAI('gmail_message_id', 'id of the gmail message, like 1944fdc33f544369', 'string') }}"
      },
      "id": "391a2c53-03f0-4551-9e62-d60acf42cc89",
      "name": "Gmail - get message",
      "type": "n8n-nodes-base.gmailTool",
      "position": [
        -512,
        832
      ],
      "webhookId": "d8ec9401-a9ff-4fe2-9c1e-5a8036cd96c9",
      "typeVersion": 2.1,
      "credentials": {
        "gmailOAuth2": {
          "id": "eoLUGfEZSeV39pjE",
          "name": "Gmail account"
        }
      }
    },
    {
      "parameters": {
        "descriptionType": "manual",
        "toolDescription": "Tool to add label to message",
        "operation": "addLabels",
        "messageId": "={{ $fromAI('gmail_message_id') }}",
        "labelIds": "={{ $fromAI('gmail_categories', 'array of label ids') }}"
      },
      "id": "f6404783-7970-488a-8746-06249deb4e7d",
      "name": "Gmail - add label to message",
      "type": "n8n-nodes-base.gmailTool",
      "position": [
        -304,
        832
      ],
      "webhookId": "7a87b026-1c6e-40e1-a062-aefdd1af1585",
      "typeVersion": 2.1,
      "credentials": {
        "gmailOAuth2": {
          "id": "eoLUGfEZSeV39pjE",
          "name": "Gmail account"
        }
      }
    },
    {
      "parameters": {
        "descriptionType": "manual",
        "toolDescription": "Tool to create a new label, only use if label does not already exist",
        "resource": "label",
        "operation": "create",
        "name": "={{ $fromAI('new_label_name', 'new label name', 'string' ) }} ",
        "options": {}
      },
      "id": "a888d76d-5b41-4f12-9ef2-e183a07b9081",
      "name": "Gmail - create label",
      "type": "n8n-nodes-base.gmailTool",
      "position": [
        -128,
        832
      ],
      "webhookId": "d8ec9401-a9ff-4fe2-9c1e-5a8036cd96c9",
      "typeVersion": 2.1,
      "credentials": {
        "gmailOAuth2": {
          "id": "eoLUGfEZSeV39pjE",
          "name": "Gmail account"
        }
      }
    },
    {
      "parameters": {
        "promptType": "define",
        "text": "=Label the email based on the details below:\n{{ JSON.stringify($json) }}",
        "options": {
          "systemMessage": "Objective:\nAutomatically categorize incoming emails based on existing Gmail labels or create a new label if none match.\n\nTools:\n- Get message\n- Read all labels\n- Create label\n- Assign label to message\n\nInstructions:\n\nLabel Matching:\n\nAnalyze the email's subject, sender, recipient, keywords, and content.\nCompare with existing Gmail labels to find the most relevant match.\nLabel Assignment:\n\nAssign the email to the most appropriate existing label.`\nRemove the inbox label if the email is of less importance (like ads, promotions, aka \"Reclame\"), keep normal and important emails in the inbox.\nIf no suitable label exists, create a new label based on the existing labels. Try reusing existing labels as much as possible. Always create a label as a sublabel, if no label applies, if the main label already exists, create the new label under the existing label, if no main label exists, create the label AI and create the new label under this label.\nLabel Creation:\n\nEnsure new labels align with the structure of existing ones, including capitalization, delimiters, and prefixes.\nExamples:\n\nIf the email subject is \"Project Alpha Update,\" assign to [Project Alpha] if it exists.\nFor \"New Vendor Inquiry,\" create \"Vendor Inquiry\" if no relevant label exists.\nOutcome:\nEmails are consistently categorized under the appropriate or newly created labels, maintaining Gmail's organizational structure.",
          "maxIterations": 5
        }
      },
      "id": "bd9f2f2f-900b-4933-9379-3e6f076c4c98",
      "name": "Gmail labelling agent",
      "type": "@n8n/n8n-nodes-langchain.agent",
      "position": [
        -832,
        608
      ],
      "notesInFlow": true,
      "retryOnFail": false,
      "typeVersion": 1.7,
      "onError": "continueErrorOutput",
      "notes": "Objective:\nAutomatically categorize incoming emails based on existing Gmail labels or create a new label if none match.\n\nTools:\n- Get message\n- Read all labels\n- Create label\n- Assign label to message\n\nInstructions:\n\nLabel Matching:\n\nAnalyze the email's subject, sender, recipient, keywords, and content.\nCompare with existing Gmail labels to find the most relevant match.\nLabel Assignment:\n\nAssign the email to the most appropriate existing label.`\nRemove the inbox label if the email is of less importance (like ads, promotions, aka \"Reclame\"), keep normal and important emails in the inbox.\nIf no suitable label exists, create a new label based on the existing labels. Try reusing existing labels as much as possible. Always create a label as a sublabel, if no label applies, if the main label already exists, create the new label under the existing label, if no main label exists, create the label AI and create the new label under this label.\nLabel Creation:\n\nEnsure new labels align with the structure of existing ones, including capitalization, delimiters, and prefixes.\nExamples:\n\nIf the email subject is \"Project Alpha Update,\" assign to [Project Alpha] if it exists.\nFor \"New Vendor Inquiry,\" create \"Vendor Inquiry\" if no relevant label exists.\nOutcome:\nEmails are consistently categorized under the appropriate or newly created labels, maintaining Gmail's organizational structure."
    },
    {
      "parameters": {
        "sessionIdType": "customKey",
        "sessionKey": "={{ $json.id }}"
      },
      "id": "b78a3dd1-9a5c-499a-9f0d-e1a71d828b47",
      "name": "Window Buffer Memory",
      "type": "@n8n/n8n-nodes-langchain.memoryBufferWindow",
      "position": [
        -832,
        832
      ],
      "typeVersion": 1.3
    },
    {
      "parameters": {
        "amount": 1
      },
      "id": "da66fa6b-a110-46be-89ab-f04ae8aae342",
      "name": "Wait",
      "type": "n8n-nodes-base.wait",
      "position": [
        -992,
        608
      ],
      "webhookId": "2066b863-4526-40cf-90aa-82229895a73c",
      "typeVersion": 1.1
    },
    {
      "parameters": {
        "content": "## Gmail trigger\nPoll Gmail every x minutes, trigger when a new email is received.\n\n- Gmail API"
      },
      "id": "a56cd1e6-d329-471d-b2dd-bc4fe337f0db",
      "name": "Sticky Note",
      "type": "n8n-nodes-base.stickyNote",
      "position": [
        -1408,
        576
      ],
      "typeVersion": 1
    },
    {
      "parameters": {
        "content": "## Gmail labelling agent\n- Read the message\n- Read existing labels\n- Create a new label if needed\n- Assign label to message\n\n----\n\nObjective:\nAutomatically categorize incoming emails based on existing Gmail labels or create a new label if none match.\n\nTools:\n- Get message\n- Read all labels\n- Create label\n- Assign label to message\n\nInstructions:\n\nLabel Matching:\n\nAnalyze the email's subject, sender, recipient, keywords, and content.\nCompare with existing Gmail labels to find the most relevant match.\nLabel Assignment:\n\nAssign the email to the most appropriate existing label.`\nRemove the inbox label if the email is of less importance (like ads, promotions, aka \"Reclame\"), keep normal and important emails in the inbox.\nIf no suitable label exists, create a new label based on the existing labels. Try reusing existing labels as much as possible. Always create a label as a sublabel, if no label applies, if the main label already exists, create the new label under the existing label, if no main label exists, create the label AI and create the new label under this label.\nLabel Creation:\n\nEnsure new labels align with the structure of existing ones, including capitalization, delimiters, and prefixes.\nExamples:\n\nIf the email subject is \"Project Alpha Update,\" assign to [Project Alpha] if it exists.\nFor \"New Vendor Inquiry,\" create \"Vendor Inquiry\" if no relevant label exists.\nOutcome:\nEmails are consistently categorized under the appropriate or newly created labels, maintaining Gmail's organizational structure.",
        "height": 840,
        "width": 780
      },
      "id": "eaed9654-5ed5-4315-b384-4c3cc3d2c39d",
      "name": "Sticky Note1",
      "type": "n8n-nodes-base.stickyNote",
      "position": [
        -384,
        -96
      ],
      "typeVersion": 1
    },
    {
      "parameters": {
        "content": "## Gmail API\n- Add credentials ",
        "width": 440
      },
      "id": "29e413b1-8cba-4bea-8a74-a4842ff52f1e",
      "name": "Sticky Note2",
      "type": "n8n-nodes-base.stickyNote",
      "position": [
        -608,
        1024
      ],
      "typeVersion": 1
    },
    {
      "parameters": {
        "content": "## OpenAI\n- Add credentials ",
        "width": 440
      },
      "id": "42bfb498-bb69-4421-b5fb-6cb90f8b6fa7",
      "name": "Sticky Note3",
      "type": "n8n-nodes-base.stickyNote",
      "position": [
        -1344,
        944
      ],
      "typeVersion": 1
    }
  ],
  "connections": {
    "Wait": {
      "main": [
        [
          {
            "node": "Gmail labelling agent",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Gmail Trigger": {
      "main": [
        [
          {
            "node": "Wait",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "OpenAI Chat Model1": {
      "ai_languageModel": [
        [
          {
            "node": "Gmail labelling agent",
            "type": "ai_languageModel",
            "index": 0
          }
        ]
      ]
    },
    "Gmail - get message": {
      "ai_tool": [
        [
          {
            "node": "Gmail labelling agent",
            "type": "ai_tool",
            "index": 0
          }
        ]
      ]
    },
    "Gmail - read labels": {
      "ai_tool": [
        [
          {
            "node": "Gmail labelling agent",
            "type": "ai_tool",
            "index": 0
          }
        ]
      ]
    },
    "Gmail - create label": {
      "ai_tool": [
        [
          {
            "node": "Gmail labelling agent",
            "type": "ai_tool",
            "index": 0
          }
        ]
      ]
    },
    "Window Buffer Memory": {
      "ai_memory": [
        [
          {
            "node": "Gmail labelling agent",
            "type": "ai_memory",
            "index": 0
          }
        ]
      ]
    },
    "Gmail - add label to message": {
      "ai_tool": [
        [
          {
            "node": "Gmail labelling agent",
            "type": "ai_tool",
            "index": 0
          }
        ]
      ]
    }
  },
  "settings": {
    "executionOrder": "v1",
    "binaryMode": "separate"
  },
  "staticData": null,
  "meta": {
    "templateCredsSetupCompleted": true
  },
  "pinData": {},
  "versionId": "a0963a5c-abbf-42e7-90a2-1c3b8b95d419",
  "activeVersionId": null,
  "versionCounter": 10,
  "triggerCount": 0,
  "shared": [
    {
      "updatedAt": "2026-04-13T02:21:05.868Z",
      "createdAt": "2026-04-13T02:21:05.868Z",
      "role": "workflow:owner",
      "workflowId": "ljIVkK2tuvf0xMy5",
      "projectId": "RKVy2puwggBotitw",
      "project": {
        "updatedAt": "2026-04-12T17:59:41.927Z",
        "createdAt": "2026-04-12T17:53:53.887Z",
        "id": "RKVy2puwggBotitw",
        "name": "DAIN BENTLEY <dain.bentley@gmail.com>",
        "type": "personal",
        "icon": null,
        "description": null,
        "creatorId": "e292b776-c6b6-4eaa-a0cc-a6da0360053d"
      }
    }
  ],
  "tags": [],
  "activeVersion": null
}
```

</details>

---

## N8N Backup - Hard Versioning (Separate Files)

| Field | Value |
|---|---|
| **ID** | `bVIUBpjkBwonTpDI` |
| **Status** | 🔴 Inactive |
| **Schedule** | `0 2 * * *` |
| **Backup file** | `n8n_backup_-_hard_versioning_separate_files.json` |

**Nodes (5):**
  - `n8n-nodes-base.scheduleTrigger` — **Schedule Trigger**
  - `n8n-nodes-base.n8n` — **Get All Workflows**
  - `n8n-nodes-base.code` — **Check for Changes**
  - `n8n-nodes-base.convertToFile` — **Convert to File**
  - `n8n-nodes-base.googleDrive` — **Google Drive Upload**

<details>
<summary>Full JSON config</summary>

```json
{
  "updatedAt": "2026-04-13T00:59:02.607Z",
  "createdAt": "2026-04-13T00:58:35.870Z",
  "id": "bVIUBpjkBwonTpDI",
  "name": "N8N Backup - Hard Versioning (Separate Files)",
  "description": null,
  "active": false,
  "isArchived": false,
  "nodes": [
    {
      "parameters": {
        "rule": {
          "interval": [
            {
              "field": "cronExpression",
              "expression": "0 2 * * *"
            }
          ]
        }
      },
      "id": "12a6a23d-c639-404f-b036-61e86a05d3d0",
      "name": "Schedule Trigger",
      "type": "n8n-nodes-base.scheduleTrigger",
      "typeVersion": 1.1,
      "position": [
        -240,
        -176
      ]
    },
    {
      "parameters": {
        "filters": {},
        "requestOptions": {}
      },
      "id": "57faee8e-1f62-4c0c-b22c-e6f678d2135f",
      "name": "Get All Workflows",
      "type": "n8n-nodes-base.n8n",
      "typeVersion": 1,
      "position": [
        -48,
        -176
      ],
      "credentials": {
        "n8nApi": {
          "id": "Tl7n4HrpONVqZBsZ",
          "name": "n8n account"
        }
      }
    },
    {
      "parameters": {
        "jsCode": "const staticData = $getWorkflowStaticData('global');\nconst lastUpdates = staticData.lastUpdates || {};\nconst newUpdates = {};\nconst changedFlows = [];\n\nconst now = new Date();\nconst timestamp = now.toISOString().split('T')[0] + '_' + now.getHours() + '-' + now.getMinutes();\n\nfor (const flow of $input.all()) {\n    const id = flow.json.id;\n    const currentUpdate = flow.json.updatedAt;\n\n    if (!lastUpdates[id] || lastUpdates[id] !== currentUpdate) {\n        changedFlows.push({\n            json: {\n                fileName: `${flow.json.name.replace(/[/\\\\?%*:|\"<>]/g, '-')}_${timestamp}.json`,\n                content: JSON.stringify(flow.json, null, 2)\n            }\n        });\n    }\n    newUpdates[id] = currentUpdate;\n}\n\nstaticData.lastUpdates = newUpdates;\nreturn changedFlows;"
      },
      "id": "f8e1e9eb-c56d-49c0-8b9d-423fd356ce90",
      "name": "Check for Changes",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        224,
        -176
      ]
    },
    {
      "parameters": {
        "options": {
          "fileName": "={{ $json.fileName }}"
        }
      },
      "id": "7bc0f974-82e8-42b9-b09e-3a30620b78dd",
      "name": "Convert to File",
      "type": "n8n-nodes-base.convertToFile",
      "typeVersion": 1,
      "position": [
        464,
        -176
      ]
    },
    {
      "parameters": {
        "driveId": {
          "__rl": true,
          "mode": "list",
          "value": "My Drive"
        },
        "folderId": {
          "__rl": true,
          "value": "=1e8LV6PB9Qdq9gP4U74r0ZhXQVg7Yrk2X",
          "mode": "id"
        },
        "options": {}
      },
      "id": "cc84646b-a3d5-4b8b-afa0-ba8e1d572fee",
      "name": "Google Drive Upload",
      "type": "n8n-nodes-base.googleDrive",
      "typeVersion": 3,
      "position": [
        720,
        -176
      ],
      "credentials": {
        "googleDriveOAuth2Api": {
          "id": "xLW1PPLT8bFxbaj0",
          "name": "Google Drive account"
        }
      }
    }
  ],
  "connections": {
    "Schedule Trigger": {
      "main": [
        [
          {
            "node": "Get All Workflows",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Get All Workflows": {
      "main": [
        [
          {
            "node": "Check for Changes",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Check for Changes": {
      "main": [
        [
          {
            "node": "Convert to File",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Convert to File": {
      "main": [
        [
          {
            "node": "Google Drive Upload",
            "type": "main",
            "index": 0
          }
        ]
      ]
    }
  },
  "settings": {
    "executionOrder": "v1",
    "binaryMode": "separate"
  },
  "staticData": null,
  "meta": {
    "templateCredsSetupCompleted": true
  },
  "pinData": {},
  "versionId": "8da88f81-2264-483c-927e-7fb232b646e1",
  "activeVersionId": null,
  "versionCounter": 5,
  "triggerCount": 0,
  "shared": [
    {
      "updatedAt": "2026-04-13T00:58:35.870Z",
      "createdAt": "2026-04-13T00:58:35.870Z",
      "role": "workflow:owner",
      "workflowId": "bVIUBpjkBwonTpDI",
      "projectId": "RKVy2puwggBotitw",
      "project": {
        "updatedAt": "2026-04-12T17:59:41.927Z",
        "createdAt": "2026-04-12T17:53:53.887Z",
        "id": "RKVy2puwggBotitw",
        "name": "DAIN BENTLEY <dain.bentley@gmail.com>",
        "type": "personal",
        "icon": null,
        "description": null,
        "creatorId": "e292b776-c6b6-4eaa-a0cc-a6da0360053d"
      }
    }
  ],
  "tags": [],
  "activeVersion": null
}
```

</details>

---

## Daily Traffic Check - Fixed URL Structure

| Field | Value |
|---|---|
| **ID** | `miY1v3akPXvNbTL8` |
| **Status** | 🔴 Inactive |
| **Schedule** | `55 6 * * *` |
| **Backup file** | `daily_traffic_check_-_fixed_url_structure.json` |

**Nodes (4):**
  - `n8n-nodes-base.scheduleTrigger` — **Schedule Trigger**
  - `n8n-nodes-base.httpRequest` — **Google Maps API**
  - `n8n-nodes-base.code` — **Calculate Best Route**
  - `n8n-nodes-base.httpRequest` — **Notify Telegram**

<details>
<summary>Full JSON config</summary>

```json
{
  "updatedAt": "2026-04-12T23:12:59.956Z",
  "createdAt": "2026-04-12T23:12:59.725Z",
  "id": "miY1v3akPXvNbTL8",
  "name": "Daily Traffic Check - Fixed URL Structure",
  "description": null,
  "active": false,
  "isArchived": false,
  "nodes": [
    {
      "parameters": {
        "rule": {
          "interval": [
            {
              "field": "cronExpression",
              "expression": "55 6 * * *"
            }
          ]
        }
      },
      "id": "7513702a-76bd-43ef-b1c7-142aebd7a732",
      "name": "Schedule Trigger",
      "type": "n8n-nodes-base.scheduleTrigger",
      "typeVersion": 1.1,
      "position": [
        0,
        0
      ]
    },
    {
      "parameters": {
        "url": "https://maps.googleapis.com/maps/api/directions/json?origin=6206+Redins+Drive,+Alexandria,+VA&destination=St.+Thomas+More+Cathedral+School,+Arlington,+VA&departure_time=now&traffic_model=best_guess&alternatives=true&key=AIzaSyCsVL3icvukbWRNqt30QkuzLVZC0raT_BY",
        "options": {}
      },
      "id": "9baf4e3d-0fa6-44f0-8142-face470cc179",
      "name": "Google Maps API",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.1,
      "position": [
        224,
        0
      ]
    },
    {
      "parameters": {
        "jsCode": "const data = $input.first().json;\n\nif (data.status !== 'OK') {\n  return [{ json: { message: `\u26a0\ufe0f Google Maps Error: ${data.status} - ${data.error_message || 'Verify API access'}` } }];\n}\n\nconst routes = data.routes;\nif (!routes || routes.length === 0) {\n  return [{ json: { message: \"\u26a0\ufe0f No routes found. Check the map manually!\" } }];\n}\n\nconst sortedRoutes = [...routes].sort((a, b) => {\n  const timeA = a.legs[0].duration_in_traffic ? a.legs[0].duration_in_traffic.value : a.legs[0].duration.value;\n  const timeB = b.legs[0].duration_in_traffic ? b.legs[0].duration_in_traffic.value : b.legs[0].duration.value;\n  return timeA - timeB;\n});\n\nconst best = sortedRoutes[0];\nconst leg = best.legs[0];\n\nconst inTraffic = leg.duration_in_traffic ? leg.duration_in_traffic.text : leg.duration.text;\nconst normal = leg.duration.text;\n\nconst trafficSecs = leg.duration_in_traffic ? leg.duration_in_traffic.value : leg.duration.value;\nconst normalSecs = leg.duration.value;\nconst delayMins = Math.round((trafficSecs - normalSecs) / 60);\n\nlet delayStatus = \"\ud83d\udfe2 Smooth sailing!\";\nif (delayMins > 5) delayStatus = \"\ud83d\udfe0 Minor delays.\";\nif (delayMins > 15) delayStatus = \"\ud83d\udd34 Heavy traffic alert!\";\n\nreturn [{\n  json: {\n    message: `\ud83d\ude97 *Commute Update*\\n\\nRoute: ${best.summary}\\nStatus: ${delayStatus}\\n\\nTraffic Time: *${inTraffic}* \u23f1\ufe0f\\nNormal Time: ${normal}\\nDelay: ${delayMins > 0 ? delayMins + \" min\" : \"None\"}\\nDistance: ${leg.distance.text}`\n  }\n}];"
      },
      "id": "32b57aaa-d89e-4c7b-aa19-28e5c5c498df",
      "name": "Calculate Best Route",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        448,
        0
      ]
    },
    {
      "parameters": {
        "method": "POST",
        "url": "https://api.telegram.org/bot8544365014:AAEgKwHUF7_iG2AizJND2NuOUouPE4uQymQ/sendMessage",
        "sendBody": true,
        "bodyParameters": {
          "parameters": [
            {
              "name": "chat_id",
              "value": "8305133249"
            },
            {
              "name": "text",
              "value": "={{ $json.message }}"
            },
            {
              "name": "parse_mode",
              "value": "Markdown"
            }
          ]
        },
        "options": {}
      },
      "id": "e43e0b90-0619-471c-9ef9-1aefcbef4bd2",
      "name": "Notify Telegram",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.1,
      "position": [
        672,
        0
      ]
    }
  ],
  "connections": {
    "Schedule Trigger": {
      "main": [
        [
          {
            "node": "Google Maps API",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Google Maps API": {
      "main": [
        [
          {
            "node": "Calculate Best Route",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Calculate Best Route": {
      "main": [
        [
          {
            "node": "Notify Telegram",
            "type": "main",
            "index": 0
          }
        ]
      ]
    }
  },
  "settings": {
    "executionOrder": "v1",
    "binaryMode": "separate"
  },
  "staticData": null,
  "meta": null,
  "pinData": {},
  "versionId": "07b9cd34-2c2f-4c3c-b31b-391c82160d05",
  "activeVersionId": null,
  "versionCounter": 2,
  "triggerCount": 0,
  "shared": [
    {
      "updatedAt": "2026-04-12T23:12:59.725Z",
      "createdAt": "2026-04-12T23:12:59.725Z",
      "role": "workflow:owner",
      "workflowId": "miY1v3akPXvNbTL8",
      "projectId": "RKVy2puwggBotitw",
      "project": {
        "updatedAt": "2026-04-12T17:59:41.927Z",
        "createdAt": "2026-04-12T17:53:53.887Z",
        "id": "RKVy2puwggBotitw",
        "name": "DAIN BENTLEY <dain.bentley@gmail.com>",
        "type": "personal",
        "icon": null,
        "description": null,
        "creatorId": "e292b776-c6b6-4eaa-a0cc-a6da0360053d"
      }
    }
  ],
  "tags": [],
  "activeVersion": null
}
```

</details>

---

## Ars Technica Headlines to Discord

| Field | Value |
|---|---|
| **ID** | `ixR2Cw9k5KU0eMzD` |
| **Status** | 🟢 Active |
| **Schedule** | `0 8 * * *` |
| **Backup file** | `ars_technica_headlines_to_discord.json` |

**Nodes (3):**
  - `n8n-nodes-base.scheduleTrigger` — **Schedule Trigger**
  - `n8n-nodes-base.httpRequest` — **HTTP Request**
  - `n8n-nodes-base.httpRequest` — **Discord Webhook**

<details>
<summary>Full JSON config</summary>

```json
{
  "updatedAt": "2026-04-28T01:31:48.783Z",
  "createdAt": "2026-04-28T01:27:24.776Z",
  "id": "ixR2Cw9k5KU0eMzD",
  "name": "Ars Technica Headlines to Discord",
  "description": null,
  "active": true,
  "isArchived": false,
  "nodes": [
    {
      "parameters": {
        "rule": {
          "interval": [
            {
              "field": "cronExpression",
              "expression": "0 8 * * *"
            }
          ]
        }
      },
      "name": "Schedule Trigger",
      "type": "n8n-nodes-base.scheduleTrigger",
      "typeVersion": 1.1,
      "position": [
        250,
        300
      ],
      "id": "4c76229f-305e-412f-bbb1-7d0c8bee994c"
    },
    {
      "parameters": {
        "url": "https://arstechnica.com/feed/",
        "options": {}
      },
      "name": "HTTP Request",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.1,
      "position": [
        470,
        300
      ],
      "id": "a10d4d82-9778-45f7-87e4-7d93e04a24cc"
    },
    {
      "parameters": {
        "method": "POST",
        "url": "https://discord.com/api/webhooks/1498496187261784065/U_GegrISA8NQUFeZQiYy5VaMvWsPeYpey2j2aKw4xKIhmqhKIag82XDFF16q5wBzY78I",
        "sendBody": true,
        "bodyParameters": {
          "parameters": [
            {
              "name": "content",
              "value": "={{ $json.content }}"
            }
          ]
        },
        "options": {}
      },
      "name": "Discord Webhook",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.1,
      "position": [
        690,
        300
      ],
      "id": "aa5c6eb1-c0b0-4b29-8612-ebc31be3b5bb"
    }
  ],
  "connections": {
    "Schedule Trigger": {
      "main": [
        [
          {
            "node": "HTTP Request",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "HTTP Request": {
      "main": [
        [
          {
            "node": "Discord Webhook",
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
    "node:Schedule Trigger": {
      "recurrenceRules": []
    }
  },
  "meta": null,
  "pinData": null,
  "versionId": "0244a702-7c3f-4a02-a0d3-3420a487dfa4",
  "activeVersionId": "0244a702-7c3f-4a02-a0d3-3420a487dfa4",
  "versionCounter": 18,
  "triggerCount": 1,
  "shared": [
    {
      "updatedAt": "2026-04-28T01:27:24.776Z",
      "createdAt": "2026-04-28T01:27:24.776Z",
      "role": "workflow:owner",
      "workflowId": "ixR2Cw9k5KU0eMzD",
      "projectId": "RKVy2puwggBotitw",
      "project": {
        "updatedAt": "2026-04-12T17:59:41.927Z",
        "createdAt": "2026-04-12T17:53:53.887Z",
        "id": "RKVy2puwggBotitw",
        "name": "DAIN BENTLEY <dain.bentley@gmail.com>",
        "type": "personal",
        "icon": null,
        "description": null,
        "creatorId": "e292b776-c6b6-4eaa-a0cc-a6da0360053d"
      }
    }
  ],
  "tags": [],
  "activeVersion": {
    "updatedAt": "2026-04-28T01:31:48.784Z",
    "createdAt": "2026-04-28T01:31:48.784Z",
    "versionId": "0244a702-7c3f-4a02-a0d3-3420a487dfa4",
    "workflowId": "ixR2Cw9k5KU0eMzD",
    "nodes": [
      {
        "parameters": {
          "rule": {
            "interval": [
              {
                "field": "cronExpression",
                "expression": "0 8 * * *"
              }
            ]
          }
        },
        "name": "Schedule Trigger",
        "type": "n8n-nodes-base.scheduleTrigger",
        "typeVersion": 1.1,
        "position": [
          250,
          300
        ],
        "id": "4c76229f-305e-412f-bbb1-7d0c8bee994c"
      },
      {
        "parameters": {
          "url": "https://arstechnica.com/feed/",
          "options": {}
        },
        "name": "HTTP Request",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.1,
        "position": [
          470,
          300
        ],
        "id": "a10d4d82-9778-45f7-87e4-7d93e04a24cc"
      },
      {
        "parameters": {
          "method": "POST",
          "url": "https://discord.com/api/webhooks/1498496187261784065/U_GegrISA8NQUFeZQiYy5VaMvWsPeYpey2j2aKw4xKIhmqhKIag82XDFF16q5wBzY78I",
          "sendBody": true,
          "bodyParameters": {
            "parameters": [
              {
                "name": "content",
                "value": "={{ $json.content }}"
              }
            ]
          },
          "options": {}
        },
        "name": "Discord Webhook",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.1,
        "position": [
          690,
          300
        ],
        "id": "aa5c6eb1-c0b0-4b29-8612-ebc31be3b5bb"
      }
    ],
    "connections": {
      "Schedule Trigger": {
        "main": [
          [
            {
              "node": "HTTP Request",
              "type": "main",
              "index": 0
            }
          ]
        ]
      },
      "HTTP Request": {
        "main": [
          [
            {
              "node": "Discord Webhook",
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
        "createdAt": "2026-04-28T01:31:55.674Z",
        "id": 9,
        "workflowId": "ixR2Cw9k5KU0eMzD",
        "versionId": "0244a702-7c3f-4a02-a0d3-3420a487dfa4",
        "event": "activated",
        "userId": "e292b776-c6b6-4eaa-a0cc-a6da0360053d"
      }
    ]
  }
}
```

</details>

---

## WTOP News Digest

| Field | Value |
|---|---|
| **ID** | `RtPIlvD8CBMifOm8` |
| **Status** | 🔴 Inactive |
| **Backup file** | `wtop_news_digest.json` |

**Nodes (7):**
  - `n8n-nodes-base.scheduleTrigger` — **Schedule Trigger**
  - `n8n-nodes-base.httpRequest` — **Fetch WTOP RSS**
  - `@n8n/n8n-nodes-langchain.lmChatOpenAi` — **Local AI Model**
  - `@n8n/n8n-nodes-langchain.agent` — **Parse Headlines**
  - `n8n-nodes-base.discord` — **Send to Discord**
  - `n8n-nodes-base.stickyNote` — **Sticky Note**
  - `n8n-nodes-base.stickyNote` — **Sticky Note1**

<details>
<summary>Full JSON config</summary>

```json
{
  "updatedAt": "2026-04-28T12:47:11.702Z",
  "createdAt": "2026-04-28T12:47:11.702Z",
  "id": "RtPIlvD8CBMifOm8",
  "name": "WTOP News Digest",
  "description": null,
  "active": false,
  "isArchived": false,
  "nodes": [
    {
      "parameters": {
        "rule": {
          "interval": [
            {
              "field": "hours",
              "hoursInterval": 24
            }
          ]
        },
        "options": {
          "timeZone": "America/New_York",
          "startDateTime": "2026-04-29T06:00:00.000Z"
        }
      },
      "id": "schedule-trigger-01",
      "name": "Schedule Trigger",
      "type": "n8n-nodes-base.scheduleTrigger",
      "typeVersion": 1.2,
      "position": [
        -400,
        300
      ]
    },
    {
      "parameters": {
        "method": "GET",
        "url": "https://wtop.com/feed/",
        "options": {}
      },
      "id": "http-request-01",
      "name": "Fetch WTOP RSS",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.2,
      "position": [
        -200,
        300
      ]
    },
    {
      "parameters": {
        "model": "ollama/gemma4:26b",
        "options": {
          "maxTokens": 2048
        }
      },
      "id": "openai-chat-model-01",
      "name": "Local AI Model",
      "type": "@n8n/n8n-nodes-langchain.lmChatOpenAi",
      "typeVersion": 1,
      "position": [
        200,
        500
      ],
      "credentials": {
        "openAiApi": {
          "id": "local-ollama-cred",
          "name": "Ollama (Local)"
        }
      }
    },
    {
      "parameters": {
        "promptType": "define",
        "text": "=Extract the news items from this RSS feed XML. For each item, provide ONLY the Title and the Link.\n\nFormat the output as a clean Markdown list like this:\n- [Headline Title](Direct URL)\n\nDo NOT include:\n- Descriptions\n- Images\n- Dates\n- Authors\n- Any XML tags or metadata\n\nHere is the RSS content:\n{{ $json.data }}",
        "options": {
          "systemMessage": "You are a news summarizer. Your only job is to extract headlines and URLs from RSS XML and format them as a clean Markdown list of links. Be concise and accurate."
        }
      },
      "id": "agent-node-01",
      "name": "Parse Headlines",
      "type": "@n8n/n8n-nodes-langchain.agent",
      "typeVersion": 1.7,
      "position": [
        0,
        300
      ]
    },
    {
      "parameters": {
        "channelId": "1496187939552628826",
        "text": "={{ $json.output }}"
      },
      "id": "discord-node-01",
      "name": "Send to Discord",
      "type": "n8n-nodes-base.discord",
      "typeVersion": 1,
      "position": [
        200,
        300
      ],
      "credentials": {
        "discordBotApi": {
          "id": "discord-cred-01",
          "name": "Discord Bot"
        }
      }
    },
    {
      "parameters": {
        "content": "## WTOP News Workflow\n- **Trigger:** Daily at 6:00 AM EST\n- **Source:** WTOP RSS Feed\n- **Processing:** Local AI (gemma4:26b - DO NOT CHANGE)\n- **Output:** Discord Channel",
        "height": 500,
        "width": 400
      },
      "id": "sticky-note-01",
      "name": "Sticky Note",
      "type": "n8n-nodes-base.stickyNote",
      "typeVersion": 1,
      "position": [
        -500,
        100
      ]
    },
    {
      "parameters": {
        "content": "## Discord Setup\n- Add your Discord Bot credentials\n- Set Channel ID to: 1496187939552628826\n\n## Ollama Credential (IMPORTANT)\n- Base URL: http://192.168.200.242:11434/v1\n- Model: gemma4:26b (DO NOT CHANGE)",
        "height": 200,
        "width": 300
      },
      "id": "sticky-note-discord",
      "name": "Sticky Note1",
      "type": "n8n-nodes-base.stickyNote",
      "typeVersion": 1,
      "position": [
        500,
        100
      ]
    }
  ],
  "connections": {
    "Schedule Trigger": {
      "main": [
        [
          {
            "node": "Fetch WTOP RSS",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Fetch WTOP RSS": {
      "main": [
        [
          {
            "node": "Parse Headlines",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Local AI Model": {
      "ai_languageModel": [
        [
          {
            "node": "Parse Headlines",
            "type": "ai_languageModel",
            "index": 0
          }
        ]
      ]
    },
    "Parse Headlines": {
      "main": [
        [
          {
            "node": "Send to Discord",
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
  "pinData": {},
  "versionId": "62ffb13b-76e9-4179-83af-26db2461e124",
  "activeVersionId": null,
  "versionCounter": 1,
  "triggerCount": 0,
  "shared": [
    {
      "updatedAt": "2026-04-28T12:47:11.702Z",
      "createdAt": "2026-04-28T12:47:11.702Z",
      "role": "workflow:owner",
      "workflowId": "RtPIlvD8CBMifOm8",
      "projectId": "RKVy2puwggBotitw",
      "project": {
        "updatedAt": "2026-04-12T17:59:41.927Z",
        "createdAt": "2026-04-12T17:53:53.887Z",
        "id": "RKVy2puwggBotitw",
        "name": "DAIN BENTLEY <dain.bentley@gmail.com>",
        "type": "personal",
        "icon": null,
        "description": null,
        "creatorId": "e292b776-c6b6-4eaa-a0cc-a6da0360053d"
      }
    }
  ],
  "tags": [],
  "activeVersion": null
}
```

</details>

---

