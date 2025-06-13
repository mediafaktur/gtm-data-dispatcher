# Data Dispatcher for Google Tag Manager

Lightweight, privacy-aware event dispatcher for Web and Server GTM.

## Overview

**Data Dispatcher** allows you to send custom tracking events from Web GTM to Server GTM with flexible parameter mapping, optional debug handling, and optional server confirmation logic - without Third-Party dependencies or setting cookies.

## Components

| File                                     | Description                                                                 |
|:----------------------------------------|:----------------------------------------------------------------------------|
| **templates/data-dispatcher-web.tpl**    | Custom template for the Web GTM container                                  |
| **templates/data-dispatcher-server.tpl** | Matching receiver template for the Server GTM container                    |
| **code/data-dispatcher-web.js**          | Core logic for the Web dispatcher (used inside the **tpl**)                |
| **code/data-dispatcher-server.js**       | Core logic for the Server receiver (used inside the **tpl**)              |
| **helper/data-dispatch-helper.js**       | Optional fetch helper (e.g. for POST requests using `postDispatch()`)      |


## Features

- Supports both `GET` (pixel) and `POST` (fetch) dispatch modes
- Fully customizable parameters and event names
- Built-in auto-inclusion of:
  - page URL, page referrer, page host, page path
  - event timestamp, random event ID, etc..
- Optional debug logging (via URL keywords or GTM variables)
- Optional `dispatch_debug=true` flag in payload
- Optional server confirmation and dataLayer push


## Installation

1. Import the `.tpl` file in the GTM Template Editor.
2. Optionally adapt `data-dispatch-helper.js` and host it on your domain.
3. Configure your tags using the custom templates.

## Privacy & Security

All data is dispatched in a controlled, transparent format.
No third-party dependencies or cookies are required.

## License

MIT – see [LICENSE](./LICENSE)

## Author

/ MEDIAFAKTUR – Marketing Performance Precision, [https://mediafaktur.marketing](https://mediafaktur.marketing)  
Florian Pankarter, [fp@mediafaktur.marketing](mailto:fp@mediafaktur.marketing)
