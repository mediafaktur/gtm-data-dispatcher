/**
 * GTM Data Dispatcher – Helper Script
 * Sends POST requests from Web GTM to a server endpoint with optional dataLayer feedback.
 * 
 * Used to trigger server-side tracking or custom logic via a lightweight, CORS-friendly POST call.
 * See README for usage and deployment.
 *
 * © Florian Pankarter, / MEDIAFAKTUR – Marketing Performance Precision  
 * https://mediafaktur.marketing · fp@mediafaktur.marketing  
 * GitHub: https://github.com/mediafaktur/gtm-data-dispatcher  
 * License: MIT
 */

(function () {
  /**
   * Push a structured dispatch event to the GTM dataLayer.
   * @param {string} eventName - The original event name.
   * @param {string} status - Either 'ok' or 'error'.
   * @param {string|object} [data] - Optional payload or error details.
   */
  function pushDispatchEvent(eventName, status, data) {
    const finalEventName = (eventName || 'dispatch') + '_' + (status === 'ok' ? 'success' : 'error');

    const eventData = {
      event: finalEventName,
      dispatch_event_name: eventName || 'unknown_event',
      dispatch_status: status
    };

    if (status === 'ok' && data !== undefined) {
      eventData.dispatch_echo = data;
    }

    if (status === 'error' && data) {
      eventData.error_message = data;
    }

    window.dataLayer = window.dataLayer || [];
    window.dataLayer.push(eventData);
  }

  /**
   * Sends a POST request with the given payload to a server endpoint,
   * and optionally pushes a result to the dataLayer.
   *
   * @param {string} payload - The request body (typically a JSON string).
   * @param {string} url - The server endpoint to which the event should be dispatched.
   * @param {string} eventName - The logical event name (e.g. 'form_submission').
   * @param {boolean} pushToDataLayer - Whether to push a result event to the GTM dataLayer.
   */
  window.postDispatch = function (payload, url, eventName, pushToDataLayer) {
    const options = {
      method: 'POST',
      headers: {
        'Content-Type': 'text/plain' // Avoids triggering CORS preflight
      },
      body: payload,
      credentials: 'include' // Include cookies for same-site session attribution
    };

    fetch(url, options)
      .then(function (response) {
        if (!response.ok) {
          console.error('POST failed with status:', response.status);
          if (pushToDataLayer) {
            pushDispatchEvent(eventName, 'error', 'http_' + response.status);
          }
          return;
        }

        // Try to parse the JSON response returned by the server (optional)
        return response.json()
          .then(function (json) {
            if (!pushToDataLayer) return;

            if (json && json.received === true) {
              // Server confirmed receipt – optionally echo back data
              pushDispatchEvent(eventName, 'ok', json.echo);
            } else {
              // Server responded but did not confirm
              pushDispatchEvent(eventName, 'ok');
            }
          })
          .catch(function (err) {
            console.warn('Response is not valid JSON:', err);
            if (pushToDataLayer) {
              pushDispatchEvent(eventName, 'ok'); // Still considered success, just no JSON parsing
            }
          });
      })
      .catch(function (error) {
        console.error('POST request failed:', error);
        if (pushToDataLayer) {
          pushDispatchEvent(eventName, 'error', error.message || 'unknown');
        }
      });
  };
})();
