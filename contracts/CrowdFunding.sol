// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract CrowdFunding {
    struct Campaign {
        address creator;
        string name;
        string description;
        uint goal;
        uint createdAt;
        uint deadline;
        uint amountCollected;
        string image;
        address[] pledgers;
        uint[] pledges;
    }

    mapping(uint => Campaign) public campaigns;

    // Number of campaigns
    uint public campaignCounts = 0;

    // Create campaign
    function createCampaign(
        address _creator,
        string memory _name,
        string memory _description,
        uint _goal,
        uint _created_at,
        uint _deadline,
        string memory _image
    ) public returns (uint256) {
        Campaign storage campaign = campaigns[campaignCounts];

        require(campaign.createdAt>= block.timestamp,"Created time is less than current Block Timestamp");
        require(campaign.deadline > campaign.createdAt,"Deadline is less than Start time");
        require(campaign.deadline <= block.timestamp, "Deadline time is invalid, should be time in the future.");

        campaign.creator = _creator;
        campaign.name = _name;
        campaign.description = _description;
        campaign.goal = _goal;
        campaign.createdAt = _created_at;
        campaign.deadline = _deadline;
        campaign.amountCollected = 0;
        campaign.image = _image;

        campaignCounts++;

        return campaignCounts - 1;
    }

    function pledge(uint256 _id) public payable {
        uint256 amount = msg.value;

        Campaign storage campaign = campaigns[_id];

        campaign.pledgers.push(msg.sender);
        campaign.pledges.push(amount);

        (bool sent,) = payable(campaign.creator).call{value: amount}("");

        if(sent) {
            campaign.amountCollected = campaign.amountCollected + amount;
        }
    }

    function getPledgers(uint256 _id) view public returns (address[] memory, uint256[] memory) {
        return (campaigns[_id].pledgers, campaigns[_id].pledges);
    }

    function getCampaigns() public view returns (Campaign[] memory) {
        Campaign[] memory Campaigns = new Campaign[](campaignCounts);
        for(uint i = 0; i < campaignCounts; i++) {
            Campaign storage item = campaigns[i];
            Campaigns[i] = item;
        }
        return Campaigns;
    }
}