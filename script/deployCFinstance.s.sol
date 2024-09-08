// SPDX-License-Identifier: MIT
// deploy the contract and create a crowdfunding instance

pragma solidity ^0.8.13;
import "forge-std/console.sol";
import "forge-std/Script.sol";
import "../src/CrowdFundingInstances.sol";


contract DeployMainContractScript is Script {
    function run() external {
        vm.startBroadcast();
        CrowdFundingInstances crowdfund = new CrowdFundingInstances();
        console.log(address(crowdfund));
        vm.stopBroadcast();
    }
}

contract CreateInstanceScript is Script {
    function run() external {
        vm.startBroadcast();
        CrowdFundingInstances crowdfund = CrowdFundingInstances(0x5FbDB2315678afecb367f032d93F642f64180aa3); // replace address with deployed contract addr
        crowdfund.createCampaign(address(1), 1000, 10);
        vm.stopBroadcast();
    }
}

contract GetInstanceScript is Script {
    function run() external {
        vm.startBroadcast();
        CrowdFundingInstances crowdfund = CrowdFundingInstances(0x5FbDB2315678afecb367f032d93F642f64180aa3);
        crowdfund.getCampaignDetails(0);
        vm.stopBroadcast();
    }
}

contract DonateScript is Script {
    function run() external {
        vm.startBroadcast();
        CrowdFundingInstances crowdfund = CrowdFundingInstances(0x5FbDB2315678afecb367f032d93F642f64180aa3);
        crowdfund.contribute{value: 1000 wei}(0);
        crowdfund.getCampaignDetails(0);
        vm.stopBroadcast();
    }
}

contract RefundScript is Script {
    function run() external {
        vm.startBroadcast();
        CrowdFundingInstances crowdfund = CrowdFundingInstances(0x5FbDB2315678afecb367f032d93F642f64180aa3);
        crowdfund.claimRefund(0);
        vm.stopBroadcast();
    }
}

contract DeleteScript is Script {
    function run() external {
        vm.startBroadcast();
        CrowdFundingInstances crowdfund = CrowdFundingInstances(0x5FbDB2315678afecb367f032d93F642f64180aa3);
        crowdfund.deleteCampaign(0);
        vm.stopBroadcast();
    }
}

contract CompleteScript is Script {
    function run() external {
        vm.startBroadcast();
        CrowdFundingInstances crowdfund = CrowdFundingInstances(0x5FbDB2315678afecb367f032d93F642f64180aa3);
        crowdfund.completeCampaign(0);
        vm.stopBroadcast();
    }
}

contract CheckBalance is Script {
    function run() external {
        uint256 bal = address(1).balance;
        console.log(bal);
    }
}