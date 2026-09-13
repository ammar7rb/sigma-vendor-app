# Seller application — phase 2

Implemented on 2026-09-08 against `E:/xampp/htdocs/ba`.

## Delivered

- `WalletScreen` opens one themed, responsive wallet with available, pending, operating and separate insurance credit. Held and under-review insurance and the next reuse date appear separately.
- Order entitlements list is paginated and exposes sales, seller shipping, insurance, maturity/reuse dates and status. Missing dates are explicitly shown as unset. Customer delivery estimates are not treated as settlement dates. Company shipping is not counted as a seller entitlement.
- Financial history has server-side pagination and insurance/shipping filters. Deposits have a separate paginated history with administrative review/rejection notes. Withdrawal requests/history and the existing withdrawal form remain reachable.
- Dashboard financial balances use the same ledger source as the wallet. Metrics wrap into two columns, money uses the app currency formatter, and actions link to the unified wallet and deposits.
- Deposit form scrolls with the keyboard, uses the platform's enabled payment methods and default funding currency, supports required transfer fields and a receipt up to 5 MB, and refreshes after returning from an external payment page. Administrative approval/payment callbacks remain authoritative; opening a payment page never credits a wallet.
- Zero maximum funding amount means unlimited, matching the platform. Non-finite, negative and out-of-range amounts are rejected. Concurrent submission is blocked, with lock cleanup on failure. Failed loads provide retry controls.
- Arabic and English labels are included; surfaces use theme colors and outlined Material icons.
- Fixed the balance API's call to a nonexistent seller deposit relationship and removed the dashboard's dependency on a web-session currency code.

## Verification

- PHP: 8 tests / 33 assertions passed for ledger/deposits/funding settings, seller isolation, record filtering/pagination, insurance reuse dates and shipping entitlements. Log: backend `storage/logs/seller-phase2-tests.log`.
- Flutter: 9 tests passed, including phase-one regressions, balance-model compatibility, funding bounds, duplicate-submission prevention and lock recovery. Log: `phase2-test.log`.
- Full Flutter analysis: zero errors in the recorded run; existing unrelated warnings/notices remain. Final focused check covers wallet, dashboard overview and phase-two tests (`phase2-focused-analysis.log`).
- Local MySQL integration smoke check invoked the balance controller and dashboard with an existing seller: HTTP 200, insurance summary present, paginated data present, matching available balances. The check ran inside a transaction and rolled back; no real deposit or balance change was retained.

## Validation limits

Android SDK/device is unavailable. No APK or physical-device picker/keyboard/gateway journey was tested. A real gateway transaction requires the platform's configured payment provider. Default `BASE_URL` is Android emulator host `http://10.0.2.2/ba/public`; a physical device needs a reachable server URL.

Order execution, insurance payment gating and delivery-proof synchronization remain phase three. This phase presents the platform's existing financial decisions and dates; it does not invent settlement dates or release funds itself.
