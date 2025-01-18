// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "lib/forge-std/src/Script.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {FundMe} from "../src/FundMe.sol";

contract DeployFundMe is Script {

    function run() external returns (FundMe){
            // Before startBroadcast -> Not a "real" tx
            HelperConfig helperConfig = new HelperConfig();
            address ethUsdPriceFeed = helperConfig.activeNetworkConfig();

            // After startBroadcast -> Real tx!
            vm.startBroadcast();
            // Mock
            FundMe fundMe = new FundMe(ethUsdPriceFeed);
            vm.stopBroadcast();
            return fundMe;
    }
}