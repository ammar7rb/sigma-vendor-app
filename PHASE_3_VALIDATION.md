# Seller application — phase 3

Implemented and checked on 2026-09-08 against `E:/xampp/htdocs/ba`.

## Delivered

- Active orders list and insurance-gated order details use the platform workflow. Pending administrative review stays inaccessible. Opaque order references resolve correctly after access is released.
- Insurance credit, configured online methods and offline receipt submission share the backend payment state. Returning from payment refreshes the order; submitting an offline receipt does not grant access before approval.
- Assigned seller shipping shows entitlement, dates, instructions and acceptance/rejection controls when required.
- Seller can upload a delivery image, PDF or video directly, with an optional note, to complete the order. Intermediate proof uploads are not mandatory. Completed orders remove the submission form.
- Completion updates order, commerce and logistics states and records a logistics event. Proofs remain attached for administrative review and history.
- Mobile proof endpoints use the authenticated API seller, enforce ownership and order visibility, and download through an authenticated endpoint rather than a public storage URL.
- Refresh after actions updates order details, lists and wallet. Duplicate submissions and late responses after leaving the page are guarded.
- Arabic/English labels and theme-based delivery, insurance and offline-payment interfaces are included.

## Validation

- `flutter test --no-pub`: **17 tests passed**, including the phase 1/2 regression tests and phase 3 controller and Arabic narrow-screen widget checks in both themes.
- `flutter analyze --no-pub`: **zero errors; 143 warning/info findings remain**. This is not a warning-free analyzer run. Output: `phase3-analysis.log`.
- PHP unit suite filtered to `OrderShippingProofServiceTest|SellerRestrictedOrdersPhaseFourTest|SellerOrderInsuranceServiceTest|AdminOrderGatePhaseThreeTest`: **29 tests, 153 assertions passed**.
- Tests cover direct completion, rollback, duplicate submission, ownership, API authentication without a web login, private proof download, restricted orders and insurance access.
- Local controller check rejected an order still awaiting administration. A separate simulated release check inside a rolled-back database transaction returned HTTP 200 with one details row using the opaque reference. That check mocked the insurance service and is not a live payment test.

## Remaining environment validation

No Android SDK/device was available for APK build or physical-device verification. File picking, external file viewers, real payment gateway callbacks and a full device-to-server purchase/delivery journey still require device/staging validation. No real payment or customer notification was sent during validation. Widget tests validate layout and behavior, not production Arabic font rendering on a device.
