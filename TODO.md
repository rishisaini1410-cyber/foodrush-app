# Food Rush — 100% Upgrade Roadmap

## Step 0: Current state audit (done/observed)
- Modes: `food` + `rushmart` already exist via `AppProvider.serviceMode`.
- Cart:
  - `CartProvider` (food) currently **prevents mixing restaurants**.
  - `MartCartProvider` exists but full rushmart checkout flow not verified yet.
- Orders/Tracking:
  - `OrderProvider` supports **only one active order** (`activeOrder`).
  - `TrackingScreen` + `OrdersScreen` are single-order UIs.

## Step 1: Multi-restaurant cart + partner assignment logic (must)
- [x] Remove/replace restaurant-mixing restriction in `CartProvider`.
- [x] Place multi-restaurant cart checkout creates one `FoodOrder` per restaurant group (UI/fees distribution MVP).
- [ ] Define “same location => same partner” rule at checkout.


## Step 2: Multi-order placement (must)
- [ ] Upgrade order model to support multiple concurrent orders in a single checkout.
- [ ] Upgrade `OrderProvider` to manage multiple active orders (or per-restaurant order list).
- [ ] Update checkout to create one order per restaurant group.

## Step 3: Multi-order tracking UI (must)
- [ ] Update `TrackingScreen` to show list/cards of active orders.
- [ ] Update `OrdersScreen` active section accordingly.

## Step 4: RushMart end-to-end flow
- [ ] Build RushMart cart + checkout + order success + tracking integration.

## Step 5: Help + Chat support
- [ ] Add `SupportScreen` + `ChatScreen`.

## Step 6: Settings + About App
- [ ] Add `SettingsScreen` with About App, Terms/Privacy placeholders, Support shortcuts.

## Step 7: UI/animations polish
- [ ] Cart add animation, checkout success animation, tracking stage animation.

## Step 8: Testing checklist
- [ ] Multi-restaurant cart: add items from 2 restaurants; ensure no crash; correct grouping.
- [ ] Multi-order: place order; verify both orders created and shown in tracking.
- [ ] RushMart: add items; checkout; verify order history.
- [ ] Support: open chat; send messages (mock locally if backend not ready).

