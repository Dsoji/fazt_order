July Update Corrections & Improvements1. Discount Meals & Featured Restaurants Section
​There is too much unnecessary white space below the Discount Meals and Featured Restaurants category boxes. Please reduce this spacing as it negatively affects the overall aesthetics of the app.
​In the Discount Meals section, use the available empty space to add an "Add" button for each meal.
​After a user taps Add, selects all required options for that meal, and taps Add to Cart, the app should automatically navigate the user to the Order Checkout screen.
​This will improve usability because many users may not realise the item has already been added to their cart.
2. Order Checkout Flow
​When a user taps Add Another Package from the checkout screen, they should be taken directly back to the same restaurant they are currently ordering from.
​This should happen every time they choose to add another package, creating a much smoother ordering experience.
3. User Ongoing Order Details
​The current design of the User > Ongoing Order Details page is not visually appealing.
​Replace this layout with the same design used in the Vendor Order Details page, as it presents the order information much better.
​Once a rider accepts the order:
​ Rider Information to call  should pop up on the order details for the user as the customer details is showing for the vendor too
​Display all order details using the same clean structure available on the vendor side.
4. Pack & Item Grouping LogicA. Items Without Option Groups
If a menu item does not have any option groups:
​Every item added should automatically be grouped into a single pack.
​Example:
​Rice Dish (no options)
​Fish (no options)
These should appear together in one pack instead of being separated.
If the user duplicates an item using the duplicate button:
​Keep all duplicated quantities within the same pack.
​Display quantities clearly, e.g. 2× Rice, 3× Fish, rather than creating separate packs.
B. Items With Option Groups
For items that have option groups (e.g. Semo):
​If a user selects all options and then duplicates the order, the current display is confusing.
​At the moment it simply shows something like:
4× Semo
This can easily be misunderstood as four individual semo rather than four complete customised packs.
Instead, display it like:
4 Packs of:
​ Semo 2x
​Egusi  1x
​Beef   2x
​Fish  1x
This clearly communicates that:
​There are 4 identical customised packs.
​Each pack contains the listed items.
​If each pack contains two semo, it should display 2× Semo inside each pack.
Apply this improved display format in:
​User Checkout Summary
​Vendor Order Details
This will greatly reduce mistakes during food preparation and order verification.
5. Vendor Order Status
On the Vendor App, the order summary header section currently displays:
​Date
​Status
​Pack
However, the Pack value always remains 1 Pack, regardless of the actual order.
Please make this dynamic so it reflects the total number of packs ordered.
Example:
​1 Pack
​2 Packs
​4 Packs
​7 Packs
The displayed value should always match the actual order.
6. Vendor Availability (Accepting Orders)
There is a bug with the Accepting Orders toggle.
Current behaviour:
​When a vendor switches Accepting Orders to Off, customers are still able to view the restaurant as available and place orders.
Expected behaviour:
​Once Accepting Orders is turned off:
​The restaurant should immediately stop accepting new orders.
​Customers should not be able to place new orders until the vendor turns the feature back on.
​The restaurant should clearly display that it is Not Accepting Orders.
This should update in real time across both the Vendor App and User App.

7. Vendor Order total
Do not show the service charge and delivery amount to vendor on the order summary