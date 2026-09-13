# Seller application — phase 1

Implemented on 2026-09-08 against `E:/xampp/htdocs/ba`.

- Activation banner refreshes every 20 seconds. Approval closes the conversation in the app, removes the chat navigation history, opens the dashboard, and retains a dismissible green banner.
- Activation messages accept text and up to five images/PDF files (6 MB each), including attachment-only messages. Failed sends retain the draft. The API refuses further messages after approval and stops returning the completed conversation to the seller; the administrative archive remains intact.
- Registration supplies a session for the newly created seller. Existing server phone verification checks remain enforced. Login returns the registration reference, and logout clears activation state.
- Password recovery opens an in-app support conversation using the existing administrative contacts inbox and password-reset workflow. A random device capability is kept in secure storage, with only its hash stored by the backend. Knowing an email or ticket number does not grant access. Repeated creation reuses the device's conversation. Password replies are not written to HTTP logs.
- Arabic/English phase-one copy, themed fields and upload controls are included. Placeholder Firebase initialization was removed in favor of the native project configuration.

Validation:
- Backend: 6 tests / 44 assertions passed, including PDF upload, approval closure, contact isolation, idempotent creation, and administrator password delivery.
- Flutter: 5 tests passed, including the red-to-green banner transition and Arabic key coverage.
- Flutter static analysis: zero errors; existing warnings/style notices remain (136 total notices in the final recorded run).
- The single new migration for contact support capability hashes was applied locally. Support routes were verified with their throttles.

Limitations: Android SDK/device is not available in this environment. No APK was produced and no physical-device registration or document-picker journey was exercised. Native Firebase/OTP delivery requires valid project configuration. No real account was activated or password changed during verification.

Logs: `phase1-analysis.log`, `phase1-test.log`; backend `storage/logs/seller-phase1-tests.log`.
