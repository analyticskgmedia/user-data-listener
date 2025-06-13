# GTM User Data Listener - Smart Form Data Capture

A comprehensive Google Tag Manager template that automatically captures user data from forms, purchases, and interactions without requiring code changes. Features intelligent data merging, GDPR compliance, and cross-page persistence.

## Features

- ✅ **Automatic Data Capture** - No code changes required, works with any form
- ✅ **Smart Data Merging** - Preserves existing data while adding new information
- ✅ **GDPR Compliance** - Hash-only mode for EU clients with full consent integration
- ✅ **Multiple Output Methods** - dataLayer, localStorage, or both
- ✅ **SHA-256 Hashing** - Secure hashing for sensitive data (email, phone)
- ✅ **Google Consent Mode v2** - Full integration with all consent types
- ✅ **Comprehensive Logging** - Detailed debugging information
- ✅ **Cross-page Persistence** - Works with User Data Restorer template

## Installation

### 1. Upload the Template to GTM

1. Download the template file: `template.tpl`
2. In GTM, go to **Templates** → **Tag Templates** → **New**
3. Click the three dots menu → **Import**
4. Select the template file and import it

### 2. Create a New Tag

1. Go to **Tags** → **New**
2. Choose your imported "User Data Listener" template
3. Configure the settings (see below)
4. Set trigger to "Form Submission" or "All Elements - Clicks"
5. Save and publish

## Configuration

### Data Capture Settings

- **Capture Email Addresses**: Automatically detect and capture email fields
- **Capture Phone Numbers**: Automatically detect and capture phone/tel fields
- **Capture Names (First & Last)**: Extract first and last names from forms
- **Capture Address Information**: Capture address, city, postal code, country

### Listener Configuration

- **Listen Mode**: Choose what events to monitor
  - `All Forms & Interactions`: Monitor all form and click events
  - `Form Submissions Only`: Only capture on form submissions
  - `Click Events Only`: Only capture on click events
  - `Custom Selector`: Use custom CSS selector
- **CSS Selector**: Custom selector for targeted data capture
- **Debounce Delay**: Delay in milliseconds to prevent duplicate captures

### Data Output Settings

- **Output Method**: Choose how to store captured data
  - `Push to dataLayer`: Send data to GTM dataLayer only
  - `Save to localStorage`: Store data in browser localStorage only
  - `Both dataLayer and localStorage`: Use both methods (recommended)
- **dataLayer Event Name**: Custom event name for dataLayer pushes
- **localStorage Key**: Custom key for localStorage storage

### Advanced Settings

- **Hash Sensitive Data (SHA-256)**: Enable secure hashing for email and phone
- **GDPR Mode**: Store ONLY hashed data for EU compliance (requires hashing enabled)
- **Enable Console Logging**: Detailed debugging information

## Setting Up Variables in GTM

### Required Data Layer Variables

After installing the template, create these **Data Layer Variables** in GTM:

| Variable Name | Data Layer Variable Name | Description |
|---------------|--------------------------|-------------|
| `userData - Email` | `userData.email` | Original email address |
| `userData - Email Hashed` | `userData.email_hashed` | SHA-256 hashed email (GDPR compliant) |
| `userData - Phone` | `userData.phone` | Original phone number |
| `userData - Phone Hashed` | `userData.phone_hashed` | SHA-256 hashed phone (GDPR compliant) |
| `userData - First Name` | `userData.firstName` | User's first name |
| `userData - Last Name` | `userData.lastName` | User's last name |
| `userData - Country` | `userData.country` | User's country |
| `userData - City` | `userData.city` | User's city |
| `userData - Address` | `userData.address` | User's address |
| `userData - Postal Code` | `userData.postalCode` | User's postal/zip code |

### User-Provided Data Variable (Essential for Advertising)

Create a **User-Provided Data variable** for enhanced conversions and advertising platforms:

1. **Go to Variables** → **New** → **User-Defined Variables**
2. **Choose Variable Type:** `User-Provided Data`
3. **Configure fields:**

#### For GDPR Mode (EU Clients - Recommended):
```
Variable Name: "User Data - Enhanced Conversions"

Configuration:
├── Email Address: {{userData - Email Hashed}}
├── Phone Number: {{userData - Phone Hashed}}
├── Address - First Name: {{userData - First Name}}
├── Address - Last Name: {{userData - Last Name}}
├── Address - Street: {{userData - Address}}
├── Address - City: {{userData - City}}
├── Address - Postal Code: {{userData - Postal Code}}
└── Address - Country: {{userData - Country}}
```

#### For Non-GDPR Mode:
```
Variable Name: "User Data - Enhanced Conversions"

Configuration:
├── Email Address: {{userData - Email}}
├── Phone Number: {{userData - Phone}}
├── Address - First Name: {{userData - First Name}}
├── Address - Last Name: {{userData - Last Name}}
├── Address - Street: {{userData - Address}}
├── Address - City: {{userData - City}}
├── Address - Postal Code: {{userData - Postal Code}}
└── Address - Country: {{userData - Country}}
```

### Using with Conversion Tags

#### Google Ads Enhanced Conversions:
1. **Open your Google Ads Conversion tag**
2. **Enhanced Conversions** → **User-provided data from your website**
3. **Select:** `{{User Data - Enhanced Conversions}}`

#### Facebook Conversions API:
```javascript
// Use individual hashed variables
'user_data': {
  'em': [{{userData - Email Hashed}}],      // Hashed email
  'ph': [{{userData - Phone Hashed}}],      // Hashed phone
  'fn': [{{userData - First Name}}],        // First name
  'ln': [{{userData - Last Name}}],         // Last name
  'ct': [{{userData - City}}],              // City
  'country': [{{userData - Country}}]       // Country
}
```

#### GA4 Enhanced Ecommerce:
```javascript
gtag('event', 'purchase', {
  'transaction_id': '12345',
  'value': 25.42,
  'currency': 'USD',
  'user_data': {
    'email_address': {{userData - Email Hashed}},
    'phone_number': {{userData - Phone Hashed}},
    'address': {
      'first_name': {{userData - First Name}},
      'last_name': {{userData - Last Name}},
      'country': {{userData - Country}}
    }
  }
});
```

## Data Structure

### Standard Output (dataLayer)
```javascript
{
  event: 'userData.captured',
  'userData.firstName': 'John',
  'userData.lastName': 'Doe',
  'userData.email': 'john.doe@example.com',
  'userData.phone': '+1234567890',
  'userData.country': 'US'
}
```

### With Hashing Enabled
```javascript
{
  event: 'userData.captured',
  'userData.firstName': 'John',
  'userData.lastName': 'Doe',
  'userData.email': 'john.doe@example.com',
  'userData.email_hashed': 'UQoDd1hKDBlxKKg5YZb+Q3HUp6AlXTKq2Z3B5coDxus=',
  'userData.phone': '+1234567890',
  'userData.phone_hashed': 'abc123def456...'
}
```

### GDPR Mode (EU Compliant)
```javascript
{
  event: 'userData.captured',
  'userData.firstName': 'John',
  'userData.lastName': 'Doe',
  'userData.email_hashed': 'UQoDd1hKDBlxKKg5YZb+Q3HUp6AlXTKq2Z3B5coDxus=',
  'userData.phone_hashed': 'abc123def456...'
}
```

### localStorage Structure
```json
{
  "timestamp": "1749811721514",
  "source": "kg_media_user_data_listener",
  "lastUpdated": "1749811721514",
  "updateCount": 3,
  "userData": {
    "firstName": "John",
    "lastName": "Doe",
    "email": "john.doe@example.com",
    "email_hashed": "UQoDd1hKDBlxKKg5YZb+Q3HUp6AlXTKq2Z3B5coDxus=",
    "phone": "+1234567890",
    "phone_hashed": "abc123def456...",
    "country": "US"
  }
}
```

## Smart Data Merging

The template intelligently merges new data with existing data:

### Scenario 1: Newsletter Signup → Contact Form
```
Initial: { email: "user@example.com" }
After:   { email: "user@example.com", firstName: "John", lastName: "Doe", phone: "+1234567890" }
```

### Scenario 2: Email Change
```
Before: { email: "old@example.com", email_hashed: "oldHash123", firstName: "John" }
After:  { email: "new@example.com", firstName: "John" }
```
*Note: Old hash automatically removed when email changes*

## GDPR Compliance

### For EU Clients
Enable **GDPR Mode** to ensure compliance:
- ✅ Only hashed versions of sensitive data stored
- ✅ Original email/phone discarded after hashing
- ✅ Names preserved for personalization
- ✅ Meets data minimization requirements
- ✅ Reduces data breach impact

### Consent Integration
The template respects Google Consent Mode:
- `analytics_storage`: Required for localStorage
- `ad_storage` + `ad_user_data`: Required for advertising use
- Automatically stops processing if consent denied

## Field Detection

The template automatically detects these field types:

### Email Fields
- `type="email"`
- `name` contains: email, e-mail, e_mail
- Field validation patterns

### Phone Fields
- `type="tel"`
- `name` contains: phone, tel, mobile, cellular

### Name Fields
- `name` contains: firstname, first_name, fname
- `name` contains: lastname, last_name, lname
- Single `name` field (automatically splits)

### Address Fields
- `name` contains: address, street, city, zip, postal, country

## Events

The template pushes these events to dataLayer:

- `userData.captured`: Fired when new user data is captured and processed

## Common Use Cases

### E-commerce Tracking
```javascript
// Capture checkout form data for enhanced conversions
{
  'userData.email_hashed': 'abc123...',
  'userData.phone_hashed': 'def456...',
  'userData.firstName': 'John',
  'userData.lastName': 'Doe'
}
```

### Lead Generation
```javascript
// Progressive data collection across multiple forms
Newsletter: { email: "user@example.com" }
Contact:    { email: "user@example.com", firstName: "John", phone: "+1234567890" }
```

### Cross-page Personalization
Use with [User Data Restorer](https://github.com/analyticskgmedia/user-data-restorer) for persistent user data across page navigation.

## Browser Support

- Chrome/Edge: Latest 2 versions
- Firefox: Latest 2 versions  
- Safari: Latest 2 versions
- Mobile browsers: iOS Safari, Chrome for Android

## Security

- ✅ SHA-256 hashing for sensitive data
- ✅ Google Consent Mode integration
- ✅ GDPR-compliant data handling
- ✅ No external dependencies
- ✅ Secure localStorage usage

## License

This template is provided under the Apache License version 2.0. See LICENSE file for details.

## Support

For issues or questions:
- GitHub Issues: [https://github.com/analyticskgmedia/user-data-listener/issues](https://github.com/analyticskgmedia/user-data-listener/issues)
- Email: filip.aldic@kg-media.hr

## Related Templates

- **[User Data Restorer](https://github.com/analyticskgmedia/user-data-restorer)**: Companion template for cross-page data persistence
- **[GTM Consent Banner](https://github.com/analyticskgmedia/gtm-consent-banner)**: Advanced Consent Mode v2 implementation

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting PRs.

## Credits

Developed by [KG Media](https://kg-media.eu)

---

Made with ❤️ for the GTM community