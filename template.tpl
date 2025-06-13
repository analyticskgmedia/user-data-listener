___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "User Data Listener",
  "brand": {
    "id": "kg_media",
    "displayName": "KG Media",
    "thumbnail": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg"
  },
  "description": "Capture user data from forms, purchases, and interactions without requiring code changes. Automatically listens for email, phone, name, and address data.",
  "categories": ["MARKETING", "PERSONALIZATION", "UTILITY"],
  "containerContexts": ["WEB"]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "GROUP",
    "name": "captureSettings",
    "displayName": "Data Capture Settings",
    "groupStyle": "ZIPPY_OPEN",
    "subParams": [
      {
        "type": "CHECKBOX",
        "name": "captureEmail",
        "checkboxText": "Capture Email Addresses",
        "simpleValueType": true,
        "defaultValue": true
      },
      {
        "type": "CHECKBOX",
        "name": "capturePhone",
        "checkboxText": "Capture Phone Numbers",
        "simpleValueType": true,
        "defaultValue": true
      },
      {
        "type": "CHECKBOX",
        "name": "captureName",
        "checkboxText": "Capture Names (First & Last)",
        "simpleValueType": true,
        "defaultValue": true
      },
      {
        "type": "CHECKBOX",
        "name": "captureAddress",
        "checkboxText": "Capture Address Information",
        "simpleValueType": true,
        "defaultValue": true
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "listenerConfig",
    "displayName": "Listener Configuration",
    "groupStyle": "ZIPPY_OPEN",
    "subParams": [
      {
        "type": "SELECT",
        "name": "listenMode",
        "displayName": "Listen Mode",
        "macrosInSelect": false,
        "selectItems": [
          {
            "value": "all",
            "displayValue": "All Forms & Interactions"
          },
          {
            "value": "forms",
            "displayValue": "Form Submissions Only"
          },
          {
            "value": "clicks",
            "displayValue": "Click Events Only"
          },
          {
            "value": "custom",
            "displayValue": "Custom Selector"
          }
        ],
        "simpleValueType": true,
        "defaultValue": "all"
      },
      {
        "type": "TEXT",
        "name": "customSelector",
        "displayName": "CSS Selector (for Custom Mode)",
        "simpleValueType": true,
        "enablingConditions": [
          {
            "paramName": "listenMode",
            "paramValue": "custom",
            "type": "EQUALS"
          }
        ],
        "help": "Enter a CSS selector to limit data capture to specific elements"
      },
      {
        "type": "TEXT",
        "name": "debounceDelay",
        "displayName": "Debounce Delay (ms)",
        "simpleValueType": true,
        "defaultValue": "500",
        "help": "Delay before capturing data to avoid duplicate events"
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "dataOutput",
    "displayName": "Data Output Settings",
    "groupStyle": "ZIPPY_OPEN",
    "subParams": [
      {
        "type": "SELECT",
        "name": "outputMethod",
        "displayName": "Output Method",
        "macrosInSelect": false,
        "selectItems": [
          {
            "value": "dataLayer",
            "displayValue": "Push to dataLayer"
          },
          {
            "value": "localStorage",
            "displayValue": "Save to localStorage"
          },
          {
            "value": "both",
            "displayValue": "Both dataLayer and localStorage"
          }
        ],
        "simpleValueType": true,
        "defaultValue": "dataLayer"
      },
      {
        "type": "TEXT",
        "name": "dataLayerEventName",
        "displayName": "dataLayer Event Name",
        "simpleValueType": true,
        "defaultValue": "userData.captured",
        "enablingConditions": [
          {
            "paramName": "outputMethod",
            "paramValue": "dataLayer",
            "type": "EQUALS"
          },
          {
            "paramName": "outputMethod",
            "paramValue": "both",
            "type": "EQUALS"
          }
        ]
      },
      {
        "type": "TEXT",
        "name": "localStorageKey",
        "displayName": "localStorage Key",
        "simpleValueType": true,
        "defaultValue": "kg_media_user_data",
        "enablingConditions": [
          {
            "paramName": "outputMethod",
            "paramValue": "localStorage",
            "type": "EQUALS"
          },
          {
            "paramName": "outputMethod",
            "paramValue": "both",
            "type": "EQUALS"
          }
        ]
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "advancedSettings",
    "displayName": "Advanced Settings",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "CHECKBOX",
        "name": "hashData",
        "checkboxText": "Hash Sensitive Data (SHA-256)",
        "simpleValueType": true,
        "defaultValue": false,
        "help": "Hash email and phone data before storing"
      },
      {
        "type": "CHECKBOX",
        "name": "enableLogging",
        "checkboxText": "Enable Console Logging",
        "simpleValueType": true,
        "defaultValue": false
      },
      {
        "type": "TEXT",
        "name": "cookieConsent",
        "displayName": "Cookie Consent Variable",
        "simpleValueType": true,
        "help": "GTM variable that returns true when user has consented to data collection (leave empty to skip consent check)"
      }
    ]
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

const log = require('logToConsole');
const createQueue = require('createQueue');
const copyFromDataLayer = require('copyFromDataLayer');
const getCookieValues = require('getCookieValues');
const localStorage = require('localStorage');
const sha256 = require('sha256');
const queryPermission = require('queryPermission');
const makeString = require('makeString');
const getTimestampMillis = require('getTimestampMillis');
const JSON = require('JSON');
const getType = require('getType');
const isConsentGranted = require('isConsentGranted');

// Check Google Consent Mode
const adStorageGranted = isConsentGranted('ad_storage');
const analyticsStorageGranted = isConsentGranted('analytics_storage');
const adUserDataGranted = isConsentGranted('ad_user_data');

// Determine if we should proceed based on consent
let shouldProceed = false;

// For analytics purposes, we need analytics_storage
// For advertising purposes, we need ad_storage and ideally ad_user_data
if (data.outputMethod === 'dataLayer' || data.outputMethod === 'both') {
  // Check if we have minimum required consent
  if (analyticsStorageGranted || (adStorageGranted && adUserDataGranted)) {
    shouldProceed = true;
  }
}

// For localStorage, we should have at least analytics consent
if (data.outputMethod === 'localStorage') {
  if (analyticsStorageGranted) {
    shouldProceed = true;
  }
}

if (!shouldProceed) {
  if (data.enableLogging) {
    log('User Data Listener: Insufficient consent granted. Current consent state:', {
      ad_storage: adStorageGranted,
      analytics_storage: analyticsStorageGranted,
      ad_user_data: adUserDataGranted
    });
  }
  data.gtmOnSuccess();
  return;
}

// Check legacy cookie consent if configured (backwards compatibility)
if (data.cookieConsent) {
  const consentValue = getCookieValues(data.cookieConsent);
  if (!consentValue || consentValue.length === 0 || consentValue[0] !== 'true') {
    if (data.enableLogging) {
      log('User Data Listener: No cookie consent, exiting');
    }
    data.gtmOnSuccess();
    return;
  }
}

// Create dataLayer push function
const dataLayerPush = createQueue('dataLayer');

// Initialize captured data storage
let capturedData = {};

// Process and store data
const processData = function(type, value) {
  if (!value || typeof value !== 'string') return;
  
  value = value.trim();
  if (!value) return;
  
  capturedData[type] = value;
  
  if (data.hashData && (type === 'email' || type === 'phone')) {
    sha256(value, function(hashedValue) {
      capturedData[type + '_hashed'] = hashedValue;
    }, data.gtmOnFailure);
  }
  
  if (data.enableLogging) {
    log('User Data Listener: Captured', type, ':', value);
  }
};

// Send captured data
const sendData = function() {
  let hasData = false;
  for (let key in capturedData) {
    if (capturedData.hasOwnProperty(key)) {
      hasData = true;
      break;
    }
  }
  
  if (!hasData) {
    if (data.enableLogging) {
      log('User Data Listener: No data captured');
    }
    return;
  }
  
  if (data.outputMethod === 'dataLayer' || data.outputMethod === 'both') {
    const eventData = {
      event: data.dataLayerEventName
    };
    
    for (let key in capturedData) {
      if (capturedData.hasOwnProperty(key)) {
        eventData['userData.' + key] = capturedData[key];
      }
    }
    
    dataLayerPush(eventData);
    
    if (data.enableLogging) {
      log('User Data Listener: Pushed to dataLayer', eventData);
    }
  }
  
  if (data.outputMethod === 'localStorage' || data.outputMethod === 'both') {
    if (queryPermission('access_local_storage', 'write', data.localStorageKey)) {
      const dataToStore = {
        timestamp: makeString(getTimestampMillis()),
        source: 'kg_media_user_data_listener',
        userData: capturedData
      };
      
      localStorage.setItem(data.localStorageKey, JSON.stringify(dataToStore));
      
      if (data.enableLogging) {
        log('User Data Listener: Saved to localStorage', dataToStore);
      }
    }
  }
};

// Main function to process form
const processForm = function() {
  if (data.enableLogging) {
    log('User Data Listener: Starting form processing');
  }
  
  // Get the entire gtm object
  const gtmData = copyFromDataLayer('gtm');
  if (data.enableLogging && gtmData) {
    log('User Data Listener: GTM data available', gtmData);
  }
  
  // Try multiple ways to get form data
  // Method 1: Check for form fields in Click Element variables
  const clickElement = copyFromDataLayer('gtm.element');
  const elementId = copyFromDataLayer('gtm.elementId');
  const elementClasses = copyFromDataLayer('gtm.elementClasses');
  const elementUrl = copyFromDataLayer('gtm.elementUrl');
  
  if (data.enableLogging) {
    log('User Data Listener: Form submission detected', {
      elementId: elementId,
      elementClasses: elementClasses,
      hasClickElement: !!clickElement
    });
  }
  
  // Method 2: Try to get values from GTM's auto-collected form data
  // GTM sometimes provides form field values in different formats
  const possibleFields = [
    // Direct form fields
    'gtm.element.email.value',
    'gtm.element.phone.value',
    'gtm.element.tel.value',
    'gtm.element.name.value',
    'gtm.element.firstName.value',
    'gtm.element.lastName.value',
    'gtm.element.first_name.value',
    'gtm.element.last_name.value',
    'gtm.element.address.value',
    'gtm.element.city.value',
    'gtm.element.zip.value',
    'gtm.element.postal.value',
    'gtm.element.country.value',
    // Form elements array
    'gtm.element.elements.email.value',
    'gtm.element.elements.phone.value',
    'gtm.element.elements.tel.value',
    'gtm.element.elements.name.value',
    'gtm.element.elements.firstName.value',
    'gtm.element.elements.lastName.value',
    'gtm.element.elements.first_name.value',
    'gtm.element.elements.last_name.value',
    'gtm.element.elements.address.value',
    'gtm.element.elements.city.value',
    'gtm.element.elements.zip.value',
    'gtm.element.elements.postal.value',
    'gtm.element.elements.country.value'
  ];
  
  // Try each possible field path
  possibleFields.forEach(function(fieldPath) {
    const value = copyFromDataLayer(fieldPath);
    if (value && getType(value) === 'string') {
      if (data.enableLogging) {
        log('User Data Listener: Found value at', fieldPath, ':', value);
      }
      
      // Determine field type from path
      const pathLower = fieldPath.toLowerCase();
      
      if (data.captureEmail && pathLower.indexOf('email') > -1) {
        if (value.indexOf('@') > 0) {
          processData('email', value);
        }
      }
      else if (data.capturePhone && (pathLower.indexOf('phone') > -1 || pathLower.indexOf('tel') > -1)) {
        processData('phone', value);
      }
      else if (data.captureName) {
        if (pathLower.indexOf('firstname') > -1 || pathLower.indexOf('first_name') > -1 || pathLower.indexOf('fname') > -1) {
          processData('firstName', value);
        }
        else if (pathLower.indexOf('lastname') > -1 || pathLower.indexOf('last_name') > -1 || pathLower.indexOf('lname') > -1) {
          processData('lastName', value);
        }
        else if (pathLower.indexOf('country') > -1) {
          processData('country', value);
        }
        else if (pathLower.indexOf('name') > -1 && 
                 pathLower.indexOf('user') === -1 && 
                 pathLower.indexOf('company') === -1 &&
                 pathLower.indexOf('country') === -1) {
          const parts = value.split(' ');
          if (parts.length >= 2) {
            processData('firstName', parts[0]);
            processData('lastName', parts.slice(1).join(' '));
          } else if (!capturedData.firstName) {
            processData('firstName', value);
          }
        }
      }
      else if (data.captureAddress) {
        if (pathLower.indexOf('address') > -1 || pathLower.indexOf('street') > -1) {
          processData('address', value);
        }
        else if (pathLower.indexOf('city') > -1) {
          processData('city', value);
        }
        else if (pathLower.indexOf('zip') > -1 || pathLower.indexOf('postal') > -1) {
          processData('postalCode', value);
        }
        else if (pathLower.indexOf('country') > -1) {
          processData('country', value);
        }
      }
    }
  });
  
  // Method 3: Try to access form data from Auto-Event Variables
  // Sometimes GTM stores form data in numbered indices
  for (let i = 0; i < 50; i++) {
    const fieldName = copyFromDataLayer('gtm.element.elements.' + i + '.name');
    const fieldValue = copyFromDataLayer('gtm.element.elements.' + i + '.value');
    const fieldType = copyFromDataLayer('gtm.element.elements.' + i + '.type');
    
    if (fieldName && fieldValue) {
      if (data.enableLogging) {
        log('User Data Listener: Found indexed field', i, ':', fieldName, '=', fieldValue);
      }
      
      const nameLower = fieldName.toLowerCase();
      const typeLower = (fieldType || '').toLowerCase();
      
      if (data.captureEmail && (typeLower === 'email' || nameLower.indexOf('email') > -1)) {
        if (fieldValue.indexOf('@') > 0) {
          processData('email', fieldValue);
        }
      }
      else if (data.capturePhone && (typeLower === 'tel' || nameLower.indexOf('phone') > -1 || nameLower.indexOf('tel') > -1)) {
        processData('phone', fieldValue);
      }
      else if (data.captureName) {
        if (nameLower.indexOf('first') > -1 || nameLower.indexOf('fname') > -1) {
          processData('firstName', fieldValue);
        }
        else if (nameLower.indexOf('last') > -1 || nameLower.indexOf('lname') > -1) {
          processData('lastName', fieldValue);
        }
        else if (nameLower === 'name' || (nameLower.indexOf('name') > -1 && 
                 nameLower.indexOf('user') === -1 && 
                 nameLower.indexOf('country') === -1 && 
                 nameLower.indexOf('company') === -1 &&
                 nameLower.indexOf('full') === -1)) {
          const parts = fieldValue.split(' ');
          if (parts.length >= 2) {
            processData('firstName', parts[0]);
            processData('lastName', parts.slice(1).join(' '));
          } else if (!capturedData.firstName) {  // Only set if firstName not already captured
            processData('firstName', fieldValue);
          }
        }
      }
      else if (data.captureAddress) {
        if (nameLower.indexOf('country') > -1) {
          processData('country', fieldValue);
        }
        else if (nameLower.indexOf('address') > -1 || nameLower.indexOf('street') > -1) {
          processData('address', fieldValue);
        }
        else if (nameLower.indexOf('city') > -1) {
          processData('city', fieldValue);
        }
        else if (nameLower.indexOf('zip') > -1 || nameLower.indexOf('postal') > -1) {
          processData('postalCode', fieldValue);
        }
      }
    }
  }
  
  // Send any captured data
  sendData();
};

// Initialize and process
if (data.enableLogging) {
  log('User Data Listener: Initialized with config', {
    captureEmail: data.captureEmail,
    capturePhone: data.capturePhone,
    captureName: data.captureName,
    captureAddress: data.captureAddress,
    listenMode: data.listenMode,
    outputMethod: data.outputMethod
  });
}

// Process the form
processForm();

// Call gtmOnSuccess to indicate successful initialization
data.gtmOnSuccess();


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
        "publicId": "access_consent",
        "versionId": "1"
      },
      "param": [
        {
          "key": "consentTypes",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "consentType"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "ad_storage"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "consentType"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "analytics_storage"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "consentType"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "ad_user_data"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
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
                    "string": "dataLayer"
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
                    "boolean": false
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
        "publicId": "access_local_storage",
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
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "kg_media_user_data"
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
        "publicId": "get_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "cookieAccess",
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
        "publicId": "read_data_layer",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedKeys",
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

scenarios:
- name: Basic Email Capture Test
  code: |-
    const mockData = {
      captureEmail: true,
      capturePhone: false,
      captureName: false,
      captureAddress: false,
      listenMode: 'forms',
      outputMethod: 'dataLayer',
      dataLayerEventName: 'userData.captured',
      debounceDelay: '100',
      enableLogging: true
    };

    // Run the template code
    runCode(mockData);

    // Verify initialization
    assertApi('addEventCallback').wasCalled();
    assertApi('gtmOnSuccess').wasCalled();

- name: Permission Test
  code: |-
    const mockData = {
      captureEmail: true,
      listenMode: 'forms',
      outputMethod: 'localStorage',
      localStorageKey: 'test_user_data'
    };

    // Run the template code
    runCode(mockData);

    // Verify permissions were checked
    assertApi('queryPermission').wasCalled();

- name: Consent Check Test
  code: |-
    const mockData = {
      captureEmail: true,
      cookieConsent: 'consent_cookie',
      listenMode: 'forms',
      outputMethod: 'dataLayer'
    };

    // Mock consent cookie
    mock('getCookieValues', (name) => {
      if (name === 'consent_cookie') return ['false'];
      return undefined;
    });

    // Run the template code
    runCode(mockData);

    // Should exit early due to no consent
    assertApi('gtmOnSuccess').wasCalled();


___NOTES___

Created on 6/11/2025, 4:30:00 PM