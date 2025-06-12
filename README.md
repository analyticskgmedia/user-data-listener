# GTM User Data Listener - Automatic Form Data Capture

A lightweight Google Tag Manager template that automatically captures user-provided data from forms, purchases, and interactions. Perfect for enhancing conversion tracking, remarketing, and analytics without requiring code changes.

## Features

- ✅ **Automatic data capture** - Intelligently detects and captures user information
- ✅ **Google Consent Mode v2** - Built-in support for consent signals
- ✅ **No code required** - Works immediately after installation
- ✅ **Multiple capture modes** - Forms, clicks, or custom selectors
- ✅ **Privacy compliant** - Respects consent choices automatically
- ✅ **Lightweight** - Only ~8KB with zero dependencies
- ✅ **E-commerce ready** - Perfect for checkout and purchase events
- ✅ **Debug mode** - Console logging for easy troubleshooting
- ✅ **Flexible output** - Push to dataLayer or localStorage

## Installation

### 1. Import the Template

1. Download `template.tpl` from this repository
2. In Google Tag Manager, go to **Templates** → **Tag Templates** → **New**
3. Click the menu (⋮) → **Import**
4. Select the template file and save

### 2. Create a Tag

1. Go to **Tags** → **New**
2. Choose the "User Data Listener" template
3. Configure your settings (see Configuration below)
4. Add a trigger (typically Form Submission)
5. Save and publish

## Configuration

### Data Capture Settings

Choose what information to capture:

- **Email Addresses** - Detects email inputs and validates format
- **Phone Numbers** - Captures phone fields with basic validation
- **Names** - Intelligently splits full names or captures first/last separately
- **Address Information** - Street, city, postal code, and country

### Listen Modes

- **Form Submissions Only** - Captures when forms are submitted (recommended)
- **All Forms & Interactions** - Also captures on field changes
- **Click Events Only** - Captures on any click event
- **Custom Selector** - Target specific forms with CSS selectors

### Output Options

- **Push to dataLayer** - Creates `userData.captured` event
- **Save to localStorage** - Persists data locally
- **Both** - Maximum flexibility

### Advanced Settings

- **Hash Sensitive Data** - SHA-256 hash emails and phones
- **Enable Console Logging** - Debug mode for troubleshooting
- **Cookie Consent Variable** - Optional GTM variable for consent

## Usage Examples

### Basic Form Tracking

```javascript
// Captures all form submissions
Listen Mode: Form Submissions Only
Output: Push to dataLayer
Trigger: All Forms
```

### E-commerce Checkout

```javascript
// Captures during purchase
Listen Mode: Custom Selector
Selector: #checkout-form
Trigger: Purchase Event
```

### Lead Generation

```javascript
// Newsletter signups
Listen Mode: Custom Selector
Selector: .newsletter-form
Hash Data: Enabled
```

## Data Structure

Captured data is pushed to dataLayer as:

```javascript
{
  event: 'userData.captured',
  'userData.email': 'user@example.com',
  'userData.phone': '+1234567890',
  'userData.firstName': 'John',
  'userData.lastName': 'Doe',
  'userData.address': '123 Main St',
  'userData.city': 'New York',
  'userData.postalCode': '10001',
  'userData.country': 'US'
}
```

## Using Captured Data

### 1. Create Variables

Create Data Layer Variables for each field:
- Variable Name: `userData.email`
- Variable Type: Data Layer Variable

### 2. Enhanced Conversions

Use variables in Google Ads/GA4:
- Enable Enhanced Conversions
- Map variables to user data fields

### 3. Custom Events

Create triggers based on captured data:
```
Event: userData.captured
Condition: userData.email does not equal undefined
```

## Field Detection

The template automatically detects fields by:

1. **Input type** (`type="email"`, `type="tel"`)
2. **Field name** (`name="email"`, `name="phone"`)
3. **Field ID** (`id="customer-email"`)
4. **Common patterns** (first_name, lastName, etc.)

Supported patterns:
- Email: email, e-mail, mail
- Phone: phone, tel, mobile
- Names: name, first_name, last_name, fname, lname
- Address: address, street, city, zip, postal, country

## Performance

- **Size**: ~8KB uncompressed
- **Execution**: 1-5ms typical
- **Impact**: Negligible
- **No external requests**

## Troubleshooting

### No Data Captured

1. Enable Console Logging in Advanced Settings
2. Check browser console for "User Data Listener:" messages
3. Verify form fields match expected patterns
4. Ensure proper trigger configuration

### Testing

```javascript
// Check captured data in console
dataLayer.filter(x => x.event === 'userData.captured')
```

### Common Issues

- **Wrong trigger type** - Use Form Submission triggers
- **Fields not detected** - Check field names/IDs
- **Timing issues** - Use tag sequencing if needed

## Privacy & Compliance

### Google Consent Mode v2

The template automatically checks these consent types:
- **analytics_storage** - Required for analytics purposes
- **ad_storage** - Required for advertising features
- **ad_user_data** - Required for sending user data to Google
- **ad_personalization** - Checked but not required

The template will only capture data when appropriate consent is granted:
- For analytics: Requires `analytics_storage`
- For advertising: Requires `ad_storage` and `ad_user_data`

### Additional Privacy Features

- Only captures data from form submissions
- Respects consent settings automatically
- Optional data hashing for sensitive information
- No data sent to external servers
- Cookie consent variable for legacy support

## Browser Support

- Chrome/Edge 60+
- Firefox 55+
- Safari 11+
- Mobile browsers

## Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create your feature branch
3. Test thoroughly
4. Submit a pull request

## License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) file for details.

## Support

- **Issues**: [GitHub Issues](https://github.com/analyticskgmedia/user-data-listener/issues)
- **Email**: filip.aldic@kg-media.hr
- **Website**: [kg-media.eu](https://kg-media.eu)

## Credits

Created by [KG Media](https://kg-media.eu) for the GTM community.

---

Made with ❤️ for better data collection