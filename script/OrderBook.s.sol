// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {OrderBook} from "../src/OrderBook.sol";

contract CounterScript is Script {
    OrderBook public orderBook;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        orderBook = new OrderBook(address(0), address(0));

        vm.stopBroadcast();
    }
}
