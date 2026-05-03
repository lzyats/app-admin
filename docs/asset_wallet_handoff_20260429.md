# Asset Wallet Handoff 2026-04-29

This note captures the current state so the next chat/window can continue without losing context.

## Current rules
- `app.currency.investMode = 1`: single-currency mode, only RMB is shown/used in frontend flows.
- `app.currency.investMode = 2`: dual-currency mode, RMB + USDT wallets are both shown/used.
- `assetsRmb` is `???` in zh-CN and `RMB` in en-US.

## Assets page status
- Displays per-wallet values split by currency, not mixed.
- Loading now uses a compact skeleton layout instead of a bare spinner.
- Empty wallet states explain that assets will appear after deposit or wallet binding.
- Initial load failures now show an inline retry card, so error states are distinct from empty-wallet states.
- Current visible metrics:
  - total assets
  - frozen amount
  - available balance
  - pending amount
  - investable amount
  - profit amount
  - recharge total
  - withdraw total
- The page should stay visually compact; avoid adding more vertical sections unless necessary.
- Total assets currently display as `totalInvest + availableBalance + frozenAmount + pendingAmount + profitAmount`.
- Exchange entry on the assets page is shown in dual-currency mode:
  - when `app.currency.supportRmbToUsd` is true, RMB and USDT can swap freely
  - when it is false, USDT -> RMB increases `usd_exchange_quota` and RMB -> USDT consumes that quota
- The exchange quota is stored on the RMB wallet as `usd_exchange_quota` and grows when USDT is exchanged into RMB.

## Recharge / withdraw / bank card
- Recharge page no longer shows recharge history.
- Recharge / withdraw / bank card pages should use the image constants from `app/lib/config/app_images.dart`.
- RMB/USDT labels must stay localized and not drift into hard-coded Chinese/English mix.
- Withdraw uses per-currency wallet balance checks.
- RMB withdraw now requires real-name verification before submission, matching RMB bank-card binding rules.
- Bank card RMB binding still requires real-name verification.

## Docs already updated
- `docs/project_context.md`
- `docs/API_DOCUMENT.md`

## Important working files
- `app/lib/pages/mine/assets_page.dart`
- `app/lib/pages/mine/recharge_page.dart`
- `app/lib/pages/mine/withdraw_page.dart`
- `app/lib/pages/mine/bank_card_page.dart`
- `app/assets/i18n/zh-CN.json`
- `app/assets/i18n/en-US.json`
