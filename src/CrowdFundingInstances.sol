// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


contract CrowdFundingInstances { 

    struct Campaign { // Structure of a campaign
        uint256 campaignId;
        address recipient;
        uint256 goal;
        uint256 deadline;
        STATUS status;
        uint256 totalContributions;
        bytes32 campaignName;
        mapping(address => uint256) contributions;
    }

    enum STATUS { // Different status that a campaign can have.
        ACTIVE,
        DELETED,
        SUCCESSFUL,
        UNSUCCESSFUL
    }

    Campaign[] public campaigns; // All the campaigns.

    uint256 private idCounter = 0; // Count/index for each campaign.

    // Events
    event CampaignCreated(uint indexed campaignId, address campaignCreator, STATUS status, bytes32 campaignName);
    event CampaignStatusChanged(uint indexed campaignId, address campaignCreator, STATUS status, bytes32 campaignName);
    event ContributionMade(uint indexed campaignId, address contributor, uint amount, bytes32 campaignName);
    event RefundMade(uint indexed campaignId, address contributor, uint amount, bytes32 campaignName);

    // Create and start a campaign.
    function createCampaign(address recipient, uint256 goal, uint256 deadline, bytes32 _campaignName) public {
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
        newCampaign.campaignName = _campaignName;

        idCounter += 1;
        emit CampaignCreated(idCounter-1, msg.sender, STATUS.ACTIVE, _campaignName); 
    }

    // Contribute ether to a campaign.
    function contribute(uint256 campaignId) public payable {
        Campaign storage campaign = campaigns[campaignId];
        require(campaign.status == STATUS.ACTIVE || campaign.status == STATUS.SUCCESSFUL, "Campaign is no longer active");
        require(msg.value > 0, 'Contribution amount must be greater than zero');
        if (campaign.deadline < block.number && campaign.status != STATUS.SUCCESSFUL){
            campaign.status = STATUS.UNSUCCESSFUL;
            emit CampaignStatusChanged(campaignId, msg.sender, STATUS.DELETED, campaign.campaignName);
        } else {
            campaign.totalContributions += msg.value;
            if (campaign.totalContributions >= campaign.goal) {
                campaign.status = STATUS.SUCCESSFUL;
                emit CampaignStatusChanged(campaignId, msg.sender, STATUS.DELETED, campaign.campaignName);
            }
            campaign.contributions[msg.sender] += msg.value;
            emit ContributionMade(campaignId, msg.sender, msg.value, campaign.campaignName);
        }
    }

    // Delete a campaign.
    function deleteCampaign(uint256 campaignId) public {
        Campaign storage campaign = campaigns[campaignId];
        require(campaign.recipient == msg.sender, 'recipient must be msg sender');
        campaign.status = STATUS.DELETED;
        emit CampaignStatusChanged(campaignId, msg.sender, STATUS.DELETED, campaign.campaignName);
    }

    // Claim a refund from an unsuccessful or deleted campaign.
    function claimRefund(uint256 campaignId) public {
        Campaign storage campaign = campaigns[campaignId];
        require(campaign.status == STATUS.DELETED || campaign.status == STATUS.UNSUCCESSFUL, 'Refunds not available');
        uint amount = campaign.contributions[msg.sender];
        require(amount > 0, 'No refund available');
        payable(msg.sender).transfer(amount);
        campaign.contributions[msg.sender] = 0;        
        emit RefundMade(campaignId, msg.sender, amount, campaign.campaignName);
    }

    // Complete a campaign. Anyone can complete any campaign.
    function completeCampaign(uint256 campaignId) public {
        Campaign storage campaign = campaigns[campaignId];
        require(campaign.totalContributions >= campaign.goal, 'Cannot complete campaign, not enough funds raised');
        require(campaign.status == STATUS.SUCCESSFUL, 'Campaign must be successful to complete');

        campaign.status = STATUS.DELETED;
        uint contributions = campaign.totalContributions;
        (bool sent, ) = campaign.recipient.call{value: contributions}("");
        require(sent, "Failed to send Ether");
    }

    // Get the details of a particular campaign.
    function getCampaignDetails(uint256 campaignId) public view returns (
        uint256 id,
        address recipient,
        uint256 goal,
        uint256 deadline,
        STATUS status,
        uint256 totalContributions,
        bytes32 campaignName
    ) {
        Campaign storage campaign = campaigns[campaignId];
        return(
            campaign.campaignId,
            campaign.recipient,
            campaign.goal,
            campaign.deadline,
            campaign.status,
            campaign.totalContributions,
            campaign.campaignName
        );
    }

    // Get the refundable amount / contribution amount from a particular campaign for the caller.
    function getRefundableAmount(uint campaignId, address contributor) public view returns (uint256) {
        Campaign storage campaign = campaigns[campaignId];
        return campaign.contributions[contributor];
    }

}
