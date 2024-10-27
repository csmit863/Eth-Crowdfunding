// SPDX-License-Identifier: MIT
// deploy the contract and create a crowdfunding instance

pragma solidity ^0.8.13;
import "forge-std/console.sol";
import "forge-std/Script.sol";
import "../src/CrowdFundingInstances.sol";


contract EasySetup is Script {
    function run() external {
        vm.startBroadcast();
        CrowdFundingInstances crowdfund = new CrowdFundingInstances();
        crowdfund.createCampaign(address(1), 1000000, 50, "Blockchain Club");
        crowdfund.contribute{value: 2450 wei}(0);
        crowdfund.createCampaign(0x95222290DD7278Aa3Ddd389Cc1E1d165CC4BAfe5, 1 ether, 76, "Cambodian School");
        crowdfund.contribute{value:0.75 ether}(1);
        crowdfund.createCampaign(0x69c688b1886BF8c4A46A6BE210dA7F3eE66A3270, 35 ether, 20, "#FreeBoogooloo");
        crowdfund.contribute{value:38.213 ether}(2);
        vm.stopBroadcast();
    }
}

contract DeployMainContract is Script {
    function run() external {
        vm.startBroadcast();
        CrowdFundingInstances crowdfund = new CrowdFundingInstances();
        console.log(address(crowdfund));
        vm.stopBroadcast();
    }
}

contract CreateInstance is Script {
    function run() external {
        vm.startBroadcast();
        CrowdFundingInstances crowdfund = CrowdFundingInstances(0x5FbDB2315678afecb367f032d93F642f64180aa3); // replace address with deployed contract addr
        crowdfund.createCampaign(msg.sender, 1000, 10, "Test Campaign");
        vm.stopBroadcast();
    }
}

contract GetInstance is Script {
    function run() external {
        vm.startBroadcast();
        CrowdFundingInstances crowdfund = CrowdFundingInstances(0x5FbDB2315678afecb367f032d93F642f64180aa3);
        crowdfund.getCampaignDetails(0);
        vm.stopBroadcast();
    }
}

contract Donate is Script {
    function run() external {
        vm.startBroadcast();
        CrowdFundingInstances crowdfund = CrowdFundingInstances(0x5FbDB2315678afecb367f032d93F642f64180aa3);
        crowdfund.contribute{value: 1000 wei}(3);
        crowdfund.getCampaignDetails(0);
        vm.stopBroadcast();
    }
}

contract Refund is Script {
    function run() external {
        vm.startBroadcast();
        CrowdFundingInstances crowdfund = CrowdFundingInstances(0x5FbDB2315678afecb367f032d93F642f64180aa3);
        crowdfund.claimRefund(3);
        vm.stopBroadcast();
    }
}

contract Delete is Script {
    function run() external {
        vm.startBroadcast();
        CrowdFundingInstances crowdfund = CrowdFundingInstances(0x5FbDB2315678afecb367f032d93F642f64180aa3);
        crowdfund.deleteCampaign(3);
        vm.stopBroadcast();
    }
}

contract Complete is Script {
    function run() external {
        vm.startBroadcast();
        CrowdFundingInstances crowdfund = CrowdFundingInstances(0x5FbDB2315678afecb367f032d93F642f64180aa3);
        crowdfund.completeCampaign(3);
        vm.stopBroadcast();
    }
}

contract CheckBalance is Script {
    function run() external view {
        uint256 bal = address(1).balance;
        console.log(bal);
    }
}