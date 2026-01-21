# 📜 Store Compliance Grimoire

> **Domain:** Legal Policies, Store Submissions, Data Safety Forms
> **Primary Agent:** Store Policy Expert (`/policy`)
> **Secondary:** CEO (`/ceo`)

---

## 📋 Master Policy Generation Protocol

### Role
Senior Mobile App Compliance Specialist.

### Required Inputs
```markdown
- **App Name:** [Insert]
- **Company/Developer Name:** [Insert]
- **Support Email:** [Insert]
- **Jurisdiction:** [Insert State/Country]
```

### Analysis Steps
1. Read `pubspec.yaml` → identify third-party libraries (AdMob, Firebase, Stripe)
2. Read `AndroidManifest.xml` and `Info.plist` → identify permissions
3. Determine sensitive data processing (Financial, Health, Auth)

### Output Files (in `docs/policies/`)

| File | Content |
|------|---------|
| `PRIVACY_POLICY.md` | Data collection, usage, third-party sharing |
| `TERMS_OF_SERVICE.md` | Usage terms, user conduct, liability. Include "Subscriptions" clause if IAP exists |
| `EULA.md` | Standard EULA. Include Apple's "Zero Tolerance" clause for UGC |
| `GDPR_CCPA_COMPLIANCE.md` | EU/California user rights statement |
| `PRIVACY_AND_TERMS_WEBSITE.md` | Combined version for website (Part 1 + Part 2) |

### Compliance Cheat Sheets

| File | Content |
|------|---------|
| `DATA_SAFETY_FORM.md` | Exact answers for Google Play Console questionnaire |
| `APP_STORE_PRIVACY_FORM.md` | Answers for Apple's App Privacy labels |
| `STORE_POLICIES_CHECKLIST.md` | Step-by-step store configuration guide |

---

## 📊 Data Safety Form Template (Google Play)

### Data Collection Questions

| Question | Common Answer | Notes |
|----------|---------------|-------|
| Does your app collect user data? | Yes | If AdMob, Firebase, or any analytics |
| Is all collected data encrypted in transit? | Yes | HTTPS is standard |
| Do you provide a way for users to request data deletion? | Yes | Required by GDPR |

### Data Types Collected

| Data Type | Collected? | Shared? | Purpose |
|-----------|------------|---------|---------|
| **Personal Info** | | | |
| - Name | Check if auth exists | No | Account |
| - Email | Check if auth exists | No | Account |
| **Financial Info** | | | |
| - Purchase history | Yes (if IAP) | No | In-app purchases |
| **Device Info** | | | |
| - Device ID | Yes (AdMob) | Yes (Advertising) | Ads |
| **App Activity** | | | |
| - App interactions | Yes (Analytics) | No | Analytics |

---

## 🍎 App Store Privacy Form Template (Apple)

### Data Linked to User

| Data Type | Collected? | Used for Tracking? |
|-----------|------------|-------------------|
| Contact Info | ❌ | ❌ |
| Health & Fitness | ❌ | ❌ |
| Financial Info | ✅ (if IAP) | ❌ |
| Location | Check permissions | ❌ |
| Usage Data | ✅ (Analytics) | ❌ |
| Identifiers | ✅ (if AdMob) | ✅ |

### Tracking Declaration
If using AdMob → "Yes, this app tracks users"
If using Firebase Analytics only → "No tracking" (if no IDFA)

---

## ✅ Store Configuration Checklist

### Google Play Console
- [ ] App category selected correctly
- [ ] Content rating questionnaire completed
- [ ] Data safety form filled
- [ ] Privacy policy URL added
- [ ] Target audience declared (if kids app)
- [ ] Ads declaration completed
- [ ] In-app purchases declared

### App Store Connect
- [ ] App Privacy labels completed
- [ ] Age rating questionnaire completed
- [ ] Privacy policy URL added
- [ ] IDFA usage declared (App Tracking Transparency)
- [ ] In-App Purchase products created
- [ ] Screenshots uploaded (all required sizes)

---

## 🚨 Common Rejection Reasons & Fixes

### Google Play
| Reason | Fix |
|--------|-----|
| "Deceptive behavior" | Ensure description matches functionality |
| "Insufficient permissions justification" | Add in-app permission rationale dialogs |
| "Data safety form incomplete" | Declare ALL data types including AdMob |
| "Subscription policy violation" | Show price before paywall, clear cancellation |

### Apple App Store
| Reason | Fix |
|--------|-----|
| "Guideline 2.1 - Crashes" | Test on real iOS device, not just simulator |
| "Guideline 3.1.1 - IAP" | All digital goods MUST use IAP, no external links |
| "Guideline 5.1.1 - Data Collection" | Add ATT prompt if using IDFA |
| "Guideline 4.2 - Minimum Functionality" | App must do something meaningful |

---

## 📝 Policy Document Templates

### Privacy Policy Core Sections
1. Introduction & Developer Info
2. Information We Collect
3. How We Use Information
4. Third-Party Services (list each: AdMob, Firebase, etc.)
5. Data Retention
6. User Rights (Access, Deletion, Portability)
7. Children's Privacy (COPPA if applicable)
8. Changes to This Policy
9. Contact Information

### Terms of Service Core Sections
1. Acceptance of Terms
2. License Grant
3. User Accounts (if applicable)
4. Subscriptions & Payments (if IAP)
5. User Conduct
6. Intellectual Property
7. Disclaimers & Limitations
8. Termination
9. Governing Law
10. Contact Information
