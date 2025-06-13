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