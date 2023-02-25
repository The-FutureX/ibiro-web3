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
        address[] donators;
        uint[] donations;
    }

    mapping(uint => Campaign) public campaigns;

    uint256 public campaignCounts = 0;

    function createCampaign(
        address _creator,
        string memory _name,
        string memory _description,
        uint _goal,
        uint _created_at,
        uint _deadline,
        string memory _image
    ) public returns (uint256) {
        Campaign storage campaign = campaigns[numberOfCampaigns];

        require(
            campaign.deadline < block.timestamp,
            "The deadline should be a date in the future."
        );

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

        campaign.donators.push(msg.sender);
        campaign.donations.push(amount);

        (bool sent,) = payable(campaign.creator).call{value: amount}("");

        if(sent) {
            campaign.amountCollected = campaign.amountCollected + amount;
        }
    }

    function getDonators(uint256 _id) view public returns (address[] memory, uint256[] memory) {
        return (campaigns[_id].donators, campaigns[_id].donations);
    }

    function getCampaigns() public view returns (Campaign[] memory) {
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);

        for(uint i = 0; i < numberOfCampaigns; i++) {
            Campaign storage item = campaigns[i];

            allCampaigns[i] = item;
        }

        return allCampaigns;
    }
}