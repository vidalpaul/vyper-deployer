// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/// @title VyperDeployer.s.sol
/// @author vidalpaul
/// @notice VyperDeployerScript is a script that deploys Vyper contracts

import {Script, console2} from "forge-std/Script.sol";

contract VyperDeployerScript is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();
    }
}
