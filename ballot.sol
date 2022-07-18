// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Ballat
{
    struct Voter
    {
        uint weight;
        bool voted;
        address delegate;
        uint vote;
        
    }

    struct Proposal
    {
        bytes32 name;
        uint voteCount;
    }

    address public chairperson;

    mapping(address => Voter) public voters;
    Proposal[] public proposals;

    constructor(bytes32[] memory proposalNames)
    {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        for(uint i = 0; 1 < proposalNames.length; i++)
        {
            proposals.push(Proposal(
                {
                name: proposalNames[i],
                voteCount: 0 
                }));

        }
        
    }

    function giveRightToVote(address voter) external
    {
        require(msg.sender==chairperson,"Only chairperson can give right");

        require(!voters[voter].voted, "The voter already voted");
        require(voters[voter].weight==0, "Condition failed");
        voters[voter].weight = 1;
    }

    function delegate(address to)external
    {
        Voter storage sender  = voters[msg.sender];
        require(sender.weight !=0,  "You have no right to vote");
        require(!sender.voted, "You already voted");

        require(to!=msg.sender, "Self-delegation is diasllowed");
        while (voters[to].delegate !=address(0))
        {
            to = voters[to].delegate;

            require(to !=msg.sender,"Found loop");
        }

        Voter storage _delegate = voters[to];

        require(_delegate.weight >= 1);

        sender.voted = true;
        sender.delegate = to;

        if (_delegate.voted)
        {
            proposals[_delegate.vote].voteCount += sender.weight;
        }
        else
        {
            _delegate.weight +=sender.weight;
        }
    }

        function vote(uint proposal) external
        {
            Voter storage sender = voters[msg.sender];
            require(sender.weight !=0, "Has no right to vote");
            require(!sender.voted,"Already voted");
            sender.voted = true;
            sender.vote = proposal;
            proposals[proposal].voteCount += sender.weight;
        }

        function winningProposal() public view returns(uint winningProposal_)
        {
            uint w=0;
            for(uint j=0;j<proposals.length;j++)
            {
                if (proposals[j].voteCount > w )
                {
                    w = proposals[j].voteCount;
                    winningProposal_ = j;
                }
            }
        }
    
    function winningName()external view returns(bytes32)
    {
        bytes32 Name = proposals[winningProposal()].name;
        return Name;
    }
}