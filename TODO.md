# Food Rush — 100% Upgrade Roadmap

## Step 0: Current state audit (done/observed)
- Cart (food): supports multi-restaurant lines already.
- Cart checkout (`CartScreen`) currently:
  - creates *multiple* `FoodOrder` (one per restaurant group)
  - but only **first order** is set as `OrderProvider.activeOrder` for tracking.
- Orders/Tracking UI:
  - `OrderProvider` supports only **single active order**.
  - `TrackingScreen` and `OrdersScreen` show only one active order.
- Payment UI: currently missing (Proceed button mocks delay + creates orders).
- Address: displayed from `LocationProvider.displayAddress`, but no explicit step for address/payment selection.

## Step 1 (MUST): Checkout UX + Payment method selection
- [ ] Add payment method selection UI (UPI/COD/Card mock) on `CartScreen`.
- [ ] Pass chosen `paymentMethod` into order model / persist in placed order.

## Step 2 (MUST): Delivery address selection step
- [ ] Add an “Address” chooser UI in checkout using `LocationProvider` (current + saved locations).
- [ ] Ensure chosen address is used when creating orders.

## Step 3 (MUST): Multi-order placement + multi-order tracking
- [ ] Extend `FoodOrder` to include `paymentMethod` and richer status fields if needed.
- [ ] Upgrade `OrderProvider` to track **List<FoodOrder> activeOrders** instead of a single `activeOrder`.
- [ ] Upgrade persistence (restore/save active orders list).
- [ ] Update `TrackingScreen` to show all active orders as cards/list.
- [ ] Update `OrdersScreen` active section accordingly (list + track buttons).

## Step 4: Partner assignment logic (same location => same partner)
- [ ] Add partnerId/partnerName + rules stub based on delivery address (mock).

## Step 5: RushMart end-to-end flow
- [ ] Verify `MartCartProvider` checkout creates orders and shows tracking.

## Step 6: Testing checklist
- [ ] Multi-restaurant: add items from 2 restaurants -> place order -> verify both orders created.
- [ ] Multi-order tracking: both appear in Tracking UI.
- [ ] Payment selection: chosen payment method persists and shows in invoice/active card.
- [ ] Address selection: selected address used in created orders.

