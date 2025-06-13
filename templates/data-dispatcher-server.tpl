___INFO___

{
  "type": "CLIENT",
  "id": "mediafaktur-data-dispatcher-server",
  "version": 1,
  "securityGroups": [],
  "displayName": "Data Dispatcher (Server)",
  "brand": {
    "id": "mediafaktur",
    "displayName": "/ MEDIAFAKTUR",
    "thumbnail": "https://hosted.faktur.media/assets/mediafaktur_logo-icon.png"
  },
  "description": "Parses GET or POST requests at a specified endpoint in your server container and converts incoming data (JSON or key-value pairs) into events for further processing.",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "requestPath",
    "displayName": "Request Path",
    "simpleValueType": true,
    "help": "The \u003cstrong\u003epath used to receive requests\u003c/strong\u003e from the Web GTM container. Must match the path configured in the corresponding client-side tag. Must start with a forward slash (/).",
    "defaultValue": "/dispatch"
  },
  {
    "type": "CHECKBOX",
    "name": "debug",
    "checkboxText": "Enable Debug Logging",
    "simpleValueType": true,
    "help": "If enabled, logs the request body and origin to the Server GTM log for debugging purposes."
  },
  {
    "type": "GROUP",
    "name": "corsConfigGroup",
    "displayName": "CORS Configuration",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "TEXT",
        "name": "allowedOrigin",
        "displayName": "Allowed Origin",
        "simpleValueType": true,
        "defaultValue": "auto",
        "help": "Origin to allow in the CORS response. Use \"auto\" to reflect the incoming request’s origin dynamically."
      },
      {
        "type": "TEXT",
        "name": "allowedMethods",
        "displayName": "Allowed Methods",
        "simpleValueType": true,
        "defaultValue": "POST, OPTIONS",
        "help": "HTTP methods to include in the Access-Control-Allow-Methods response header (e.g., POST, OPTIONS)."
      },
      {
        "type": "TEXT",
        "name": "allowedHeaders",
        "displayName": "Allowed Headers",
        "simpleValueType": true,
        "defaultValue": "Content-Type",
        "help": "Headers to allow in the Access-Control-Allow-Headers response (e.g., Content-Type)."
      }
    ]
  }
]


___SANDBOXED_JS_FOR_SERVER___

/**
 * GTM Template: Data Dispatcher (Server)
 * Lightweight client-to-server bridge for clean and privacy-aware event dispatching.
 * Designed for customizable, streamlined delivery and optional server feedback.
 *
 * © COPYRIGHT
 * Florian Pankarter, / MEDIAFAKTUR - Marketing Performance Precision
 * https://mediafaktur.marketing
 * Contact: fp@mediafaktur.marketing
 * License: MIT
 * GitHub: https://github.com/mediafaktur/gtm-data-dispatcher
 *
 * DESCRIPTION
 * This template is part of a two-part system for data exchange between Web GTM and Server GTM.
 * It enables the sending of custom tracking events via GET or POST to a Server GTM endpoint,
 * with various optional parameters, privacy-friendly behavior, and CORS-safe communication.
 *
 * FEATURES (Server GTM Template)
 * - Custom request path configuration (e.g., "/dispatch")
 * - Supports both JSON and form-encoded POST bodies
 * - Handles CORS pre-flight OPTIONS requests (optional)
 * - Accepts GET requests with query parameters (pixel-style)
 * - Optional debug mode with logging to Server GTM console
 * - Returns JSON confirmation or tracking pixel response
 * - Compatible with external systems or Web GTM setups
 *
 * REQUIREMENTS
 * For POST requests, an external helper script must be available to execute the fetch call.
 * A reference implementation is available at:
 * https://github.com/mediafaktur/lightweight-dispatcher/blob/main/sendPostPing.js
 *
 * USE TOGETHER WITH:
 * - "Data Dispatcher (Web)" GTM Template
 *   → Sends lightweight tracking events to this server endpoint
 */


// === IMPORTS ===
// Built-in SGTM APIs zur Verarbeitung von HTTP-Anfragen
const claimRequest = require('claimRequest');
const runContainer = require('runContainer');
const getRequestPath = require('getRequestPath');
const getRequestMethod = require('getRequestMethod');
const getRequestHeader = require('getRequestHeader');
const getRequestQueryParameters = require('getRequestQueryParameters');
const getRequestBody = require('getRequestBody');
const setResponseHeader = require('setResponseHeader');
const setResponseBody = require('setResponseBody');
const returnResponse = require('returnResponse');
const setPixelResponse = require('setPixelResponse');
const JSON = require('JSON');
const Object = require('Object');
const decodeUriComponent = require('decodeUriComponent');
const logToConsole = require('logToConsole');

// === TEMPLATE CONFIGURATION (populated via UI fields) ===
const requestPath = data.requestPath || '/dispatch';
const allowedOrigin = data.allowedOrigin || 'auto';
const allowedMethods = data.allowedMethods || 'POST, OPTIONS';
const allowedHeaders = data.allowedHeaders || 'Content-Type, X-Gtm-Server-Preview';
const debug = data.debug === true;

// === SAFE JSON PARSE ===
// Only attempts parsing if input looks like JSON
function safeJsonParse(input) {
  if (!input || typeof input !== 'string') return {};
  if (input[0] !== '{' && input[0] !== '[') return {};
  if (input.slice(-1) !== '}' && input.slice(-1) !== ']') return {};
  return JSON.parse(input);
}

// === FORM-ENCODED PARSE FALLBACK ===
// Parses key=value&key2=value2 into an object
function parseKeyValueBody(bodyString) {
  const obj = {};
  const parts = bodyString.split('&');
  for (let i = 0; i < parts.length; i++) {
    const pair = parts[i].split('=');
    if (pair.length === 2) {
      const key = decodeUriComponent(pair[0] || '');
      const value = decodeUriComponent(pair[1] || '');
      obj[key] = value;
    }
  }
  return obj;
}

// === OPTIONS REQUEST HANDLING (CORS Preflight) ===
// Handles CORS preflight requests when enabled
const handleOptions = false; // Can be enabled later via template UI
if (handleOptions && getRequestPath() === requestPath && getRequestMethod() === 'OPTIONS') {
  claimRequest();

  const originHeader = getRequestHeader('origin');
  const originValue = allowedOrigin === 'auto' ? originHeader : allowedOrigin;

  setResponseHeader('Access-Control-Allow-Origin', originValue);
  setResponseHeader('Access-Control-Allow-Methods', allowedMethods);
  setResponseHeader('Access-Control-Allow-Headers', allowedHeaders);
  setResponseHeader('Access-Control-Allow-Credentials', 'true');

  returnResponse(); // Empty 200 OK response for preflight
}


// === POST REQUEST HANDLING ===
if (getRequestPath() === requestPath && getRequestMethod() === 'POST') {
  claimRequest();

  const contentType = getRequestHeader('content-type') || '';
  const rawBody = getRequestBody();

  // Try to parse as JSON
  let parsedBody = safeJsonParse(rawBody);

  // Fallback: Parse as key=value string
  if (!parsedBody || Object.keys(parsedBody).length === 0) {
    parsedBody = parseKeyValueBody(rawBody);
  }

  // Ensure event_name is always defined
  const eventName = parsedBody.event_name || 'dispatch_event_fallback';

  // Set correct CORS headers
  const originHeader = getRequestHeader('origin');
  const originValue = allowedOrigin === 'auto' ? originHeader : allowedOrigin;
  
  
  // Debug output
  if (debug) {
    logToConsole(JSON.stringify({
      message: 'Body received and passed to runContainer()',
      raw_body: rawBody,
      parsed_body: parsedBody,
      event_name: eventName
    }));
  }
  
  // Pass full event data to container
  const eventData = parsedBody;
  eventData.event_name = eventName;

  // Run container and respond with JSON echo
  runContainer(eventData, () => {
    setResponseHeader('Access-Control-Allow-Origin', originValue);
    setResponseHeader('Access-Control-Allow-Credentials', 'true');
    setResponseHeader('Content-Type', 'application/json');

    const responseBody = JSON.stringify({
      status: 'ok',
      received: true,
      echo: parsedBody
    });

    setResponseBody(responseBody);
    returnResponse();
  });  
 
}


// === GET REQUEST HANDLING ===
if (getRequestPath() === requestPath && getRequestMethod() === 'GET') {
  claimRequest();

  const queryParams = getRequestQueryParameters();
  const eventName = queryParams.event_name || 'dispatch_event_fallback';

  // Build event data from query parameters
  const eventData = {};
  for (let key in queryParams) {
    if (queryParams.hasOwnProperty(key)) {
      eventData[key] = queryParams[key];
    }
  }

  // Ensure event_name is included
  eventData.event_name = eventName;

  if (debug) {
    logToConsole('Event data (GET):', eventData);
  }

  // Run container and return 1x1 tracking pixel
  runContainer(eventData, () => {
    setPixelResponse(); // 1x1 GIF
    returnResponse();
  });
}


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "read_request",
        "versionId": "1"
      },
      "param": [
        {
          "key": "requestAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "headerAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "queryParameterAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "return_response",
        "versionId": "1"
      },
      "param": []
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_response",
        "versionId": "1"
      },
      "param": [
        {
          "key": "writeResponseAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "writeHeaderAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "run_container",
        "versionId": "1"
      },
      "param": []
    },
    "isRequired": true
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 7.6.2025, 13:18:15