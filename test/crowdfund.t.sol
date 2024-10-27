//SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;
import "forge-std/Test.sol";
import "src/CrowdFundingInstances.sol";
import "forge-std/console.sol";

contract CrowdFundingTest is Test {

    //MyToken mytoken;
    CrowdFundingInstances crowdfunding;
    
    address public myAddress = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    
    function setUp() public {
        crowdfunding = new CrowdFundingInstances();
        vm.deal(myAddress, 1000 ether);
        crowdfunding.createCampaign(myAddress, 10000, 10, 'test');
    }

    // A campaign is created.
    function test_createCampaign() public {
        crowdfunding.createCampaign(myAddress, 10000, 10, 'test');
        vm.deal(address(crowdfunding), 1 ether); // accepts ether only     
    }

    // Get the details of a campaign.
    function test_getCampaignDetails() public view {
        crowdfunding.getCampaignDetails(0);        
    }

    // Contribute funds to a campaign.
    function test_contribute(uint96 amount) public {
        vm.assume(amount > 0 ether);
        crowdfunding.contribute{value: amount}(0); 
    }

    // Get the refundable amount given to a campaign in case campaign is not successful
    function test_getRefundableAmount() public view {
        crowdfunding.getRefundableAmount(0, myAddress);
    }

    // Delete a campaign.
    function test_deleteCampaign() public {
        crowdfunding.getCampaignDetails(0);        
        vm.prank(myAddress);
        crowdfunding.deleteCampaign(0);
    }

    // Reclaim contributed amount in event of campaign deletion/non success
    function test_claimRefund() public {
        vm.prank(myAddress);
        crowdfunding.contribute{value: 100 wei}(0);

        vm.prank(myAddress);
        crowdfunding.deleteCampaign(0);

        vm.prank(myAddress);
        crowdfunding.claimRefund(0);
    }

    // Complete a campaign once the funds have been raised to execute a given task.
    function test_completeCampaign() public {
        vm.prank(myAddress);
        vm.expectRevert("Cannot complete campaign, not enough funds raised");
        crowdfunding.completeCampaign(0); // should fail, not reached goal
        
        vm.expectRevert("Only the recipient can complete the campaign");
        crowdfunding.completeCampaign(0); // should fail, not valid msg sender

        vm.prank(myAddress);
        crowdfunding.contribute{value: 10000 wei}(0); // should succeed
        vm.prank(myAddress);
        crowdfunding.contribute{value: 100 wei}(0); // should succeed, even though it exceeds the goal

        vm.expectRevert("Only the recipient can complete the campaign");
        crowdfunding.completeCampaign(0); // should fail, only recipient can complete

        crowdfunding.contribute{value: 10000 wei}(0); // should succeed, campaign has not been deleted


        console.log(myAddress.balance); // balance before completing
        vm.prank(myAddress);
        crowdfunding.completeCampaign(0); // should succeed, campaign achieved successful status

        vm.prank(myAddress);
        vm.expectRevert("Campaign must be successful to complete");
        crowdfunding.completeCampaign(0); // should fail, campaign achieved successful status
        console.log(myAddress.balance); // balance after completing

        vm.expectRevert("Campaign is no longer active");
        crowdfunding.contribute{value: 10000 wei}(0); // should fail, campaign has been completed/deleted
        crowdfunding.getCampaignDetails(0);        
    }

    function test_deadlineReached() public {
        
    }
    
}