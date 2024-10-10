// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract OrderBook {
    IERC20 public tokenA; // token to buy
    IERC20 public tokenB; // token to sell

    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    struct Order {
        address user;
        bool orderTokenA; // true if it's an order for tokenA, false for tokenB
        uint256 amount;
        uint256 price;
        bool isBuy; // true if it's a buy order, false for sell order
    }
    Order[] public orders;

    event OrderPlaced(
        address indexed user,
        bool orderTokenA,
        uint256 amount,
        uint256 price,
        bool isBuy
    );
    event OrderMatched(
        address indexed buyer,
        address indexed seller,
        uint256 amount,
        uint256 price
    );

    function placeOrder(
        bool _orderTokenA, // is it an order for the tokenA or tokenB
        uint256 _amount,
        uint256 _price,
        bool _isBuy
    ) external {
        if (_orderTokenA) {
            if (_isBuy) {
                tokenB.transferFrom(msg.sender, address(this), _price);
            } else {
                tokenA.transferFrom(msg.sender, address(this), _amount);
            }
        } else {
            if (_isBuy) {
                tokenA.transferFrom(msg.sender, address(this), _price);
            } else {
                tokenB.transferFrom(msg.sender, address(this), _amount);
            }
        }
        orders.push(Order(msg.sender, _orderTokenA, _amount, _price, _isBuy));
        emit OrderPlaced(msg.sender, _orderTokenA, _amount, _price, _isBuy);
    }

    function getOrder(
        uint256 _orderIndex
    ) external view returns (Order memory) {
        return orders[_orderIndex];
    }

    function matchOrder(uint256 _orderIndex) external {
        Order memory order = orders[_orderIndex];
        require(order.user != msg.sender, "Cannot match your own order");

        // in first the user pay to see if he has enough token and only then get his token
        // that we already know the contract has enought token
        if (order.isBuy) {
            tokenA.transferFrom(msg.sender, order.user, order.price);
            tokenB.approve(address(this), order.amount);
            tokenB.transferFrom(address(this), msg.sender, order.amount);
        } else {
            tokenB.transferFrom(order.user, order.user, order.price);
            tokenA.approve(address(this), order.amount);
            tokenA.transferFrom(address(this), msg.sender, order.amount);
        }

        emit OrderMatched(msg.sender, order.user, order.amount, order.price);
        delete orders[_orderIndex];
    }
}
