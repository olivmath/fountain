// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {StablecoinFactory} from "../src/StablecoinFactory.sol";
contract DeployStablecoinFactory is Script {
    function run() external returns (StablecoinFactory) {
        vm.startBroadcast();

        StablecoinFactory factory = new StablecoinFactory();

        vm.stopBroadcast();

        console.log("StablecoinFactory deployed at:", address(factory));
        console.log("Factory owner:", factory.owner());
        console.log("");
        console.log("=== Deployment Summary ===");
        console.log("Factory Address:", address(factory));
        console.log("Owner:", factory.owner());
        console.log("Stablecoin Count:", factory.getStablecoinCount());

        return factory;
    }
}
