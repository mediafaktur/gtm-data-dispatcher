___INFO___

{
  "type": "TAG",
  "id": "mediafaktur-data-dispatcher-web",
  "version": 1,
  "securityGroups": [],
  "displayName": "Data Dispatcher (Web)",
  "brand": {
    "id": "mediafaktur",
    "displayName": "/ MEDIAFAKTUR",
    "thumbnail": "https://hosted.faktur.media/assets/mediafaktur_logo-icon.png"
  },
  "description": "Send custom event data from Web GTM to your server container using GET or POST. Supports optional metadata (URL, referrer, timestamp) and enables dataLayer feedback on server confirmation.",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "trackingDomain",
    "displayName": "Tracking Domain",
    "simpleValueType": true,
    "help": "The \u003cstrong\u003ebase URL\u003c/strong\u003e of your server container (e.g. https://sgtm.your-domain.tld).",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "trackingPath",
    "displayName": "Endpoint Name",
    "simpleValueType": true,
    "help": "The \u003cstrong\u003eendpoint path\u003c/strong\u003e used to send data to the server (e.g. \u003cem\u003e/dispatch\u003c/em\u003e). Must match the path in your server container’s custom client.",
    "defaultValue": "/dispatch"
  },
  {
    "type": "TEXT",
    "name": "eventName",
    "displayName": "Event Name",
    "simpleValueType": true,
    "help": "\u003cstrong\u003eName of the event\u003c/strong\u003e as received in your Server GTM container.",
    "defaultValue": "dispatch_event"
  },
  {
    "type": "GROUP",
    "name": "methodGroup",
    "displayName": "Method",
    "groupStyle": "ZIPPY_OPEN_ON_PARAM",
    "subParams": [
      {
        "type": "RADIO",
        "name": "method",
        "displayName": "",
        "radioItems": [
          {
            "value": "methodGet",
            "displayValue": "GET (no payload, no CORS restrictions)",
            "help": "\u003cstrong\u003eSends data via URL query parameters\u003c/strong\u003e. Recommended for simple use cases without any CORS limitations for small data payloads, where no complex objects are needed. No external fetch script is required."
          },
          {
            "value": "methodPost",
            "displayValue": "POST (with payload, requires fetch script)",
            "subParams": [
              {
                "type": "TEXT",
                "name": "postScriptUrl",
                "displayName": "Fetch script URL for POST requests.",
                "simpleValueType": true,
                "valueValidators": [
                  {
                    "type": "NON_EMPTY"
                  }
                ],
                "help": "URL of the \u003cstrong\u003efetch helper script\u003c/strong\u003e for POST requests. Must be \u003cem\u003ehosted on your own domain\u003c/em\u003e to avoid cross-site restrictions and preserve cookies (ensure that the \u003cem\u003einject_script\u003c/em\u003e permission allows this domain). A ready-to-use helper is included by default or available at \u003ca href\u003d\"https://github.com/mediafaktur/gtm-data-dispatcher\" target\u003d\"_blank\"\u003ehttps://github.com/mediafaktur/gtm-data-dispatcher\u003c/a\u003e.",
                "defaultValue": "https://hosted.faktur.media/gtm/dispatch-helper.js"
              },
              {
                "type": "CHECKBOX",
                "name": "postJson",
                "checkboxText": "Send nested objects (JSON format)",
                "simpleValueType": true,
                "help": "Enable this option if your payload contains nested data structures (e.g. objects or arrays). When checked, the payload will be sent as a JSON string using the Content-Type: text/plain header to avoid triggering a preflight request while still preserving full data structure."
              },
              {
                "type": "CHECKBOX",
                "name": "postEventGet",
                "checkboxText": "Add event name as GET parameter",
                "simpleValueType": true,
                "help": "Append event name to POST request URL (for easier debugging and visibility in server logs or inside stored data)."
              },
              {
                "type": "CHECKBOX",
                "name": "datalayerPushOnSuccess",
                "checkboxText": "Push \"dispatch_success\" event to Data Layer",
                "simpleValueType": true,
                "help": "When enabled, the external fetch helper script will push a \u003cem\u003edispatch_success\u003c/em\u003e event with status and payload information to the browser’s dataLayer. This allows triggering downstream tags or analytics logic inside Web GTM."
              }
            ],
            "help": "\u003cstrong\u003eTransmits structured payloads\u003c/strong\u003e using a browser-side fetch script. Required if you want to transmit structured or sensitive data. Separate fetch script needed to be hosted on your own domain to avoid cross-site restrictions and maintain cookie lifespan."
          }
        ],
        "simpleValueType": true
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "eventDataGroup",
    "displayName": "Event Data",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "SIMPLE_TABLE",
        "name": "eventParamsCustom",
        "displayName": "",
        "simpleTableColumns": [
          {
            "defaultValue": "",
            "displayName": "Key",
            "name": "key",
            "type": "TEXT"
          },
          {
            "defaultValue": "",
            "displayName": "Value",
            "name": "value",
            "type": "TEXT"
          }
        ]
      },
      {
        "type": "GROUP",
        "name": "eventParamsDocumentGroup",
        "displayName": "Document Context",
        "groupStyle": "NO_ZIPPY",
        "subParams": [
          {
            "type": "CHECKBOX",
            "name": "paramsPageUrl",
            "checkboxText": "Include Page URL",
            "simpleValueType": true
          },
          {
            "type": "CHECKBOX",
            "name": "paramsPageHost",
            "checkboxText": "Include Page Host",
            "simpleValueType": true
          },
          {
            "type": "CHECKBOX",
            "name": "paramsPagePath",
            "checkboxText": "Include Page Path",
            "simpleValueType": true
          },
          {
            "type": "CHECKBOX",
            "name": "paramsPageReferrer",
            "checkboxText": "Include Page Referrer",
            "simpleValueType": true
          }
        ],
        "help": ""
      },
      {
        "type": "GROUP",
        "name": "eventParamsEventGroup",
        "displayName": "Event Context",
        "groupStyle": "NO_ZIPPY",
        "subParams": [
          {
            "type": "CHECKBOX",
            "name": "paramsEventTimestamp",
            "checkboxText": "Include Event Timestamp",
            "simpleValueType": true
          },
          {
            "type": "CHECKBOX",
            "name": "paramsEventRandomId",
            "checkboxText": "Include Random Event ID",
            "simpleValueType": true
          }
        ]
      }
    ],
    "help": "Key-value pairs added to the tracking request as query string parameters"
  },
  {
    "type": "GROUP",
    "name": "debuggingGroup",
    "displayName": "Debugging",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "CHECKBOX",
        "name": "debugLogToGtmConsole",
        "checkboxText": "Log to GTM Debug Console",
        "simpleValueType": true,
        "help": "Outputs payloads, URLs, and responses to the GTM debug console. Only visible in GTM preview mode."
      },
      {
        "type": "GROUP",
        "name": "debugFlagGroup",
        "displayName": "Set Debug Flag (Optional)",
        "groupStyle": "NO_ZIPPY",
        "subParams": [
          {
            "type": "TEXT",
            "name": "dispatchDebugKeywords",
            "displayName": "Enable if URL contains (comma-separated keywords)",
            "simpleValueType": true,
            "help": "Add \u003cstrong\u003edispatch_debug\u003dtrue\u003c/strong\u003e to the payload if the URL contains any of the specified comma-separated keywords (e.g. debug, preview, test). Leave this field empty if not needed."
          },
          {
            "type": "TEXT",
            "name": "dispatchDebugMode",
            "displayName": "Enable if this field equals \"true\"",
            "simpleValueType": true,
            "help": "Add dispatch_debug\u003dtrue to the payload if the input equals \"true\" (case-insensitive). You can use: a literal string: \"true\", a custom GTM variable: e.g. {{Custom Debug Flag}}, the built-in variable: {{Debug Mode}}. Works independently of the keyword check."
          }
        ],
        "help": "Controls whether the event parameter \u003cstrong\u003edispatch_debug\u003dtrue\u003c/strong\u003e is added to the payload. The flag is included if either condition below is met – they are independent and case-insensitive. This helps with debugging and log filtering in your server container."
      }
    ]
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

/**
 * GTM Template: Data Dispatcher (Web)
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
 * FEATURES (Web GTM Template)
 * - Supports GET (pixel) or POST (fetch) dispatch methods
 * - Allows sending event name and arbitrary custom parameters
 * - Custom request path configuration (e.g., "/dispatch") 
 * - Automatically includes page-related info (URL, referrer, timestamp, etc.)
 * - Optional debug logging to GTM console
 * - Optional confirmation logic to trigger Data Layer events upon successful dispatch
 * - Optional "dispatch_debug=true" flag via keyword detection or dynamic control
 *
 * REQUIREMENTS
 * For POST requests, an external helper script must be available to execute the fetch call.
 * A reference implementation is available at:
 * https://github.com/mediafaktur/lightweight-dispatcher/blob/main/sendPostPing.js
 *
 * USE TOGETHER WITH:
 * - "Data Dispatcher (Server)" GTM Template
 *   → Receives incoming requests and runs containers in Server GTM.
 */



// === IMPORTS ===
var injectScript = require('injectScript');
var callInWindow = require('callInWindow');
var encode = require('encodeUriComponent');
var sendPixel = require('sendPixel');
var getUrl = require('getUrl');
var getReferrerUrl = require('getReferrerUrl');
var JSON = require('JSON');
var logToConsole = require('logToConsole');
var getTimestampMillis = require('getTimestampMillis');
var generateRandom = require('generateRandom');

// === Read configuration fields ===
var rawDomain = data.trackingDomain;
var tracking_path = data.trackingPath || '/dispatch';
var event_name = data.eventName || 'dispatch_event';
var method = data.method || 'GET';
var post_script_url = data.postScriptUrl;
var post_json = data.postJson;
var post_event_get = data.postEventGet === true;
var event_params_custom = data.eventParamsCustom || [];
var params_page_url = data.paramsPageUrl === true;
var params_page_host = data.paramsPageHost === true;
var params_page_path = data.paramsPagePath === true;
var params_page_referrer = data.paramsPageReferrer === true;
var params_event_timestamp = data.paramsEventTimestamp === true;
var params_event_random_id = data.paramsEventRandomId === true;
var debug_log_to_gtm_console = data.debugLogToGtmConsole === true;
var datalayer_push_on_success = data.datalayerPushOnSuccess === true;
var dispatch_debug_mode = data.dispatchDebugMode;
var dispatch_debug_keywords = data.dispatchDebugKeywords;

// === Wrapper for GTM debug console logging ===
function debugLogToGTMConsole(message) {
  if (debug_log_to_gtm_console) {
    logToConsole('DISPATCHER → ' + message);
  }
}

// Normalize domain (remove trailing slash if present)
var domain = rawDomain;
if (domain.slice(-1) === '/') {
  domain = domain.slice(0, -1);
}
debugLogToGTMConsole('Normalized Tracking Domain: ' + domain);

// === Helper: fail-safe logging and failure handling ===
function failIfMissing(value, message) {
  if (!value) {
    logToConsole('Error:', message);
    data.gtmOnFailure();
    return true;
  }
  return false;
}

// === Automatically append dynamic standard parameters based on checkboxes ===
function pushParam(shouldInclude, key, valueFn) {
  if (shouldInclude) {
    event_params_custom.push({ key: key, value: valueFn() });
  }
}

pushParam(params_page_url, 'page_location', () => getUrl());
pushParam(params_page_host, 'page_host', () => getUrl('host'));
pushParam(params_page_path, 'page_path', () => getUrl('path'));
pushParam(params_page_referrer, 'page_referrer', () => getReferrerUrl());
pushParam(params_event_timestamp, 'event_timestamp', () => getTimestampMillis());
pushParam(params_event_random_id, 'event_random_id', () => generateRandom(1000000000, 9999999999));

debugLogToGTMConsole('Final parameters passed to payload builder:' + JSON.stringify(event_params_custom));


// === Determine if dispatch_debug=true should be added ===
var shouldAddDebugFlag = false;

// debugLogToGTMConsole('dispatch_debug_mode raw value:', dispatch_debug_mode);
// debugLogToGTMConsole('dispatch_debug_keywords raw value:', dispatch_debug_keywords);

// Option 1: URL keywords (comma-separated, case-insensitive)
if (typeof dispatch_debug_keywords === 'string' && dispatch_debug_keywords.trim() !== '') {
  var debugWords = dispatch_debug_keywords.split(',').map(function(word) {
    return word.trim().toLowerCase();
  });

  var currentUrl = getUrl().toLowerCase();
  for (var i = 0; i < debugWords.length; i++) {
    if (currentUrl.indexOf(debugWords[i]) !== -1) {
      shouldAddDebugFlag = true;
      debugLogToGTMConsole('dispatch_debug enabled via URL keyword match:', debugWords[i]);
      break;
    }
  }
}

// Option 2: Input equals true (case-insensitive, supports boolean or string)
if (
  dispatch_debug_mode === true || 
  (typeof dispatch_debug_mode === 'string' && dispatch_debug_mode.trim().toLowerCase() === 'true')
) {
  shouldAddDebugFlag = true;
  debugLogToGTMConsole('dispatch_debug enabled via dispatchDebugMode input = true');
}

// Add to payload if either condition matches
if (shouldAddDebugFlag) {
  event_params_custom.push({
    key: 'dispatch_debug',
    value: 'true'
  });
  debugLogToGTMConsole('dispatch_debug=true parameter added to payload');
}



// === Helper: build payload object for JSON or key/value dispatch ===
function buildPayload(paramsArray, eventName) {
  var payload = { event_name: eventName };
  for (var i = 0; i < paramsArray.length; i++) {
    var param = paramsArray[i];
    var key = param.key;
    var value = param.value;
    if (typeof key === 'string' && key.trim() !== '' && key !== 'event_name') {
      payload[key] = value || '';
    }
  }
  return payload;
}

// === Helper: build URL-encoded query string for GET requests ===
function buildQueryString(paramsArray, eventName) {
  var query = 'event_name=' + encode(eventName);
  for (var i = 0; i < paramsArray.length; i++) {
    var param = paramsArray[i];
    var key = param.key;
    var value = param.value;
    if (typeof key === 'string' && key.trim() !== '' && key !== 'event_name') {
      query += '&' + encode(key) + '=' + encode(value || '');
    }
  }
  return query;
}

// === Send event via POST (uses external fetch script) ===
function sendPost() {
  if (failIfMissing(post_script_url, 'postScriptUrl missing')) return;
  
  var postUrl = domain + tracking_path;
  if (post_event_get) {
    postUrl += '?event_name=' + encode(event_name);
  }

  var formattedPayload;

  if (post_json) {
    // JSON mode: supports nested objects, triggers preflight
    var payload = buildPayload(event_params_custom, event_name);
    formattedPayload = JSON.stringify(payload);
    debugLogToGTMConsole('Dispatch payload (JSON): ' + formattedPayload);
  } else {
    // String mode: avoids preflight, flat structure only
    var parts = [];
    var paramMap = buildPayload(event_params_custom, event_name);
    for (var key in paramMap) {
      if (paramMap.hasOwnProperty(key)) {
        var encodedKey = encode(key);
        var encodedValue = encode(paramMap[key]);
        parts.push(encodedKey + '=' + encodedValue);
      }
    }
    formattedPayload = parts.join('&'); 
    debugLogToGTMConsole('Dispatch payload (String): ' + formattedPayload);
  }  

  debugLogToGTMConsole('POST URL: ' + postUrl);
  debugLogToGTMConsole('Injecting external script: ' + post_script_url); 
  
  // Inject external fetch helper and call it with payload
  injectScript(post_script_url, function() {
    debugLogToGTMConsole('POST script loaded and postDispatch() invoked');
    
    var result = callInWindow('postDispatch', formattedPayload, postUrl, event_name, datalayer_push_on_success);

    // Handle async result (Promise)
    if (result && typeof result.then === 'function') {
      result
        .then(function() {
          data.gtmOnSuccess();
        })
        .catch(function(err) {
          logToConsole('Fetch failed:', err);
          data.gtmOnFailure();
        });
    } else {
      data.gtmOnSuccess();
    }
  }, data.gtmOnFailure);
}

// === Send event via GET (image pixel) ===
function sendGet() {
  var queryString = buildQueryString(event_params_custom, event_name);
  var url = domain + tracking_path + '?' + queryString;
  
  debugLogToGTMConsole('GET Dispatch URL: ' + url);
  
  sendPixel(url, data.gtmOnSuccess, data.gtmOnFailure);
}

// === Dispatch flow: select method ===
debugLogToGTMConsole('Selected Method: ' + method);
if (method === 'methodPost') {
  debugLogToGTMConsole('Dispatching via POST');
  sendPost();
} else {
  debugLogToGTMConsole('Dispatching via GET');
  sendGet();
}


___WEB_PERMISSIONS___

[
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
        "publicId": "access_globals",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keys",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "postDispatch"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  }
                ]
              }
            ]
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
        "publicId": "inject_script",
        "versionId": "1"
      },
      "param": [
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://hosted.faktur.media/gtm/dispatch-helper.js"
              }
            ]
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
        "publicId": "send_pixel",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedUrls",
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
        "publicId": "get_referrer",
        "versionId": "1"
      },
      "param": [
        {
          "key": "urlParts",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "queriesAllowed",
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
        "publicId": "get_url",
        "versionId": "1"
      },
      "param": [
        {
          "key": "urlParts",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "queriesAllowed",
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
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 7.6.2025, 13:18:08


