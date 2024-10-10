## OrderBook

An **OrderBook** is a fundamental component in financial markets, including decentralized exchanges (DEXs) on Ethereum.
It is a real-time, continuously updated list of buy and sell orders for a particular asset.
The OrderBook helps match buyers with sellers, facilitating trades at the best available prices.

## Functions

#### **placeOrder**: This function allows users to place a new buy or sell order in the OrderBook.
It will match an opposite order if it exist and will execute it directly then.

It requires 4 parameters:
   - **bool _orderTokenA**: Indicates if the order is for tokenA or tokenB.
   - **uint256 _amount**: The quantity of the asset to be traded.
   - **uint256 _price**: The price at which the asset is to be traded.
   - **bool _isBuy**: Specifies whether the order is a buy or sell order. parameters such as the asset, order type (buy/sell), quantity, and price.

Thus there is only 4 possibilities :
- Order on tokenA:
  -   **buyOrder**: This function allows users to place a new buy order in the OrderBook.
  -   **sellOrder**: This function allows users to place a new sell order in the OrderBook.
- Order on tokenB:
  -   **buyOrder**: This function allows users to place a new buy order in the OrderBook.
  -   **sellOrder**: This function allows users to place a new sell order in the OrderBook.

#### **cancelOrder**: This function enables users to cancel an existing order that has not yet been matched.
Users need to provide the order ID to identify which order to cancel.

#### **_matchOrder**: This function automatically match buy and sell order based on price.
It ensures that trades are executed at the best possible prices for both parties.
