// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Test, console} from "forge-std/Test.sol";

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
        // Check for opposite orders and match if found
        for (uint256 i = 0; i < orders.length; i++) {
            Order memory existingOrder = orders[i];
            if (
                existingOrder.orderTokenA == _orderTokenA &&
                existingOrder.isBuy != _isBuy &&
                existingOrder.price == _price &&
                existingOrder.amount == _amount
            ) {
                _matchOrder(i);
                return;
            }
            if (
                existingOrder.orderTokenA != _orderTokenA &&
                existingOrder.isBuy == _isBuy &&
                existingOrder.price == _amount &&
                existingOrder.amount == _price
            ) {
                _matchOrder(i);
                return;
            }
        }

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

    function _matchOrder(uint256 _orderIndex) internal {
        Order memory order = orders[_orderIndex];
        require(order.user != msg.sender, "Cannot match your own order");

        // firstly, the user pay to see if he has enough token and only then get his token
        // that we already know the contract has already blocked
        if (order.orderTokenA) {
            if (order.isBuy) {
                tokenA.transferFrom(msg.sender, order.user, order.amount);
                tokenB.approve(address(this), order.price);
                tokenB.transferFrom(address(this), msg.sender, order.price);
            } else {
                tokenB.transferFrom(order.user, order.user, order.amount);
                tokenA.approve(address(this), order.price);
                tokenA.transferFrom(address(this), msg.sender, order.price);
            }
        } else {
            if (order.isBuy) {
                tokenB.transferFrom(msg.sender, order.user, order.amount);
                tokenA.approve(address(this), order.price);
                tokenA.transferFrom(address(this), msg.sender, order.price);
            } else {
                tokenA.transferFrom(order.user, order.user, order.amount);
                tokenB.approve(address(this), order.price);
                tokenB.transferFrom(address(this), msg.sender, order.price);
            }
        }

        emit OrderMatched(msg.sender, order.user, order.amount, order.price);
        delete orders[_orderIndex];
    }

    function cancelOrder(uint256 _orderIndex) external {
        Order memory order = orders[_orderIndex];
        require(
            order.user == msg.sender,
            "Only the order creator can cancel the order"
        );

        if (order.orderTokenA) {
            if (order.isBuy) {
                tokenB.transfer(msg.sender, order.price);
            } else {
                tokenA.transfer(msg.sender, order.amount);
            }
        } else {
            if (order.isBuy) {
                tokenA.transfer(msg.sender, order.price);
            } else {
                tokenB.transfer(msg.sender, order.amount);
            }
        }

        delete orders[_orderIndex];
    }
}
