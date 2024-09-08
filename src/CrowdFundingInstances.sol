// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "forge-std/console.sol";

/*

Create a smart contract in which you can create new 'crowdfunding instances', 
raise funds, if target is met by deadline then do xyz. 
https://medium.com/@chigarbs1/creating-a-crowdfunding-smart-contract-with-solidity-ce2ea50750ee


Why the need for decentralised crowdfunding primitive?
https://www.theverge.com/2024/2/29/24085175/gofundme-gaza-palestine-fundraiser-under-review-esims

*/


/*
This contract could be reused and become a DeFi primitive - e.g. a ICO could use it to determine
how to distribute tokens in a verifiable manner, without having to deploy their own crowdfunding contract.

There would be no manager of this contract, it would be completely permissionless.
*/

contract CrowdFundingInstances { // create anonymous interaction for users

    struct Campaign {
        uint256 campaignId;
        address recipient;
        uint256 goal;
        uint256 deadline;
        STATUS status;
        uint256 totalContributions;
        mapping(address => uint256) contributions;
    }

    enum STATUS {
        ACTIVE,
        DELETED,
        SUCCESSFUL,
        UNSUCCEEDED
    }

    Campaign[] public campaigns;

    uint256 private idCounter = 0;

    event CampaignCreated(uint indexed campaignId, address campaignCreator, STATUS status);
    event CampaignDeleted(uint indexed campaignId, address campaignCreator, STATUS status);
    event ContributionMade(uint indexed campaignId, address contributor, uint amount);
    event RefundMade(uint indexed campaignId, address contributor, uint amount);

    function createCampaign(address recipient, uint256 goal, uint256 deadline) public {
        require(goal > 0, 'Goal must be greater than zero');
        require(deadline > block.number, 'Deadline time must be greater than the current time');
        campaigns.push();
        Campaign storage newCampaign = campaigns[campaigns.length - 1];
        newCampaign.campaignId = idCounter;
        newCampaign.recipient = recipient;
        newCampaign.goal = goal;
        newCampaign.deadline = deadline;
        newCampaign.status = STATUS.ACTIVE;
        newCampaign.totalContributions = 0;

        idCounter += 1;
        // Emit an event to log the creation of the campaign
        emit CampaignCreated(idCounter-1, msg.sender, STATUS.ACTIVE);
    }

    function contribute(uint256 campaignId) public payable {
        Campaign storage campaign = campaigns[campaignId];
        require(campaign.status == STATUS.ACTIVE || campaign.status == STATUS.SUCCESSFUL, "Campaign is no longer active");
        require(msg.value > 0, 'Contribution amount must be greater than zero');
        campaign.totalContributions += msg.value;
        if (campaign.totalContributions >= campaign.goal) {
            campaign.status = STATUS.SUCCESSFUL;
        }
        campaign.contributions[msg.sender] += msg.value;
        emit ContributionMade(campaignId, msg.sender, msg.value);
    }

    function deleteCampaign(uint256 campaignId) public {
        Campaign storage campaign = campaigns[campaignId];
        require(campaign.recipient == msg.sender, 'recipient must be msg sender');
        campaign.status = STATUS.DELETED;
        emit CampaignDeleted(campaignId, msg.sender, STATUS.DELETED);
    }

    function claimRefund(uint256 campaignId) public {
        Campaign storage campaign = campaigns[campaignId];
        require(campaign.status == STATUS.DELETED || campaign.status == STATUS.UNSUCCEEDED, 'Refunds not available');
        uint amount = campaign.contributions[msg.sender];
        require(amount > 0, 'No refund available');
        payable(msg.sender).transfer(amount);
        campaign.contributions[msg.sender] = 0;
        emit RefundMade(campaignId, msg.sender, amount);
    }

    function completeCampaign(uint256 campaignId) public {
        // anyone can complete the campaign (helps if the recipient doesnt know how to)
        Campaign storage campaign = campaigns[campaignId];
        //require(campaign.recipient == msg.sender, 'Only the recipient can complete the campaign');
        require(campaign.totalContributions >= campaign.goal, 'Cannot complete campaign, not enough funds raised');
        require(campaign.status == STATUS.SUCCESSFUL, 'Campaign must be successful to complete');

        campaign.status = STATUS.DELETED;
        uint contributions = campaign.totalContributions;
        //campaign.totalContributions = 0; // Exluding this because may want to look at contributions of past campaigns.
        (bool sent, ) = campaign.recipient.call{value: contributions}("");
        require(sent, "Failed to send Ether");
    }

    function getCampaignDetails(uint256 campaignId) public view returns (
        uint256 id,
        address recipient,
        uint256 goal,
        uint256 deadline,
        STATUS status,
        uint256 totalContributions
    ) {
        Campaign storage campaign = campaigns[campaignId];
        return(
            campaign.campaignId,
            campaign.recipient,
            campaign.goal,
            campaign.deadline,
            campaign.status,
            campaign.totalContributions
        );
    }

    function getRefundableAmount(uint campaignId, address contributor) public view returns (uint256) {
        Campaign storage campaign = campaigns[campaignId];
        return campaign.contributions[contributor];
    }

}
