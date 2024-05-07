//SPDX-License-Identifier:MIT
pragma solidity 0.8.25;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "test/Mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepolia = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepolia;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // All configurations here..
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(8, 2000e8);
        vm.stopBroadcast();

        NetworkConfig memory anvilEth = NetworkConfig({priceFeed: address(mockPriceFeed)});
        return anvilEth;
    }
}
