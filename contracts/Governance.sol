//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "./ERC20.sol";
import "./IERC20.sol";

contract Governance {
  //Variables
  mapping(address => UserWhitelist) public votings;
  VotingDetails internal votingDetails;

  struct UserWhitelist {
    uint256 tokenTotalSupply;
    bool inWhitelist;
    bool executed;
    VoteStatus status;
  }

  struct VotingDetails {
    uint64 createdVote;
    uint64 endVote;
    uint32 minVotes;
    uint32 totalForVotes;
    uint32 totalAgainstVotes;
    uint32 totalAbstainVotes;
  }

  enum VoteStatus {
    None,
    For,
    Against,
    Abstain
  }

  address private immutable tokenAddress;
  address public governanceAddress;
  string public proposal;

  constructor(
    string memory _proposal,
    uint64 _createdVote,
    uint64 _endVote,
    uint8 _minVotes,
    address _tokenAddress,
    address[] memory addresses
  ) {
    proposal = _proposal;
    governanceAddress = msg.sender;
    votingDetails.createdVote = _createdVote;
    votingDetails.endVote = _endVote;
    votingDetails.minVotes = _minVotes;
    tokenAddress = _tokenAddress;
    setWhitelist(addresses);
  }

  //Modifire
  modifier onlyOwner() {
    require(msg.sender == governanceAddress, "Sender address must be onwer");
    _;
  }

  modifier isWhitelisted() {
    require(votings[msg.sender].inWhitelist == true, "You need to be whitelisted");
    _;
  }

  //Events
  event VotePlaced(address voter, VoteStatus status, uint256 voteWeight);

  //Function
  function getProposal() public view returns (string memory) {
    return proposal;
  }

  function getStartTimestamp() public view returns (uint256) {
    return votingDetails.createdVote;
  }

  function getEndTimestamp() public view returns (uint256) {
    return votingDetails.endVote;
  }

  function setWhitelist(address[] memory addresses) public onlyOwner {
    for (uint256 i = 0; i < addresses.length; i++) {
      if (votings[addresses[i]].inWhitelist == true) continue;
      votings[addresses[i]] = UserWhitelist(0, true, false, VoteStatus.None);
    }
  }

  function checkAddressWhitelist(address _address) external view returns (bool) {
    return votings[_address].inWhitelist;
  }

  function changeStartTimestamp(uint64 _createdVote) external onlyOwner {
    require(votingDetails.endVote > _createdVote, "Start timestamp must be less from the end");
    votingDetails.createdVote = _createdVote;
  }

  function changeEndTimestamp(uint64 _endVote) external onlyOwner {
    require(_endVote > votingDetails.createdVote, "End timestamp must be longer from the begin");
    votingDetails.endVote = _endVote;
  }

  function vote(VoteStatus status) external isWhitelisted {
    require(!votings[msg.sender].executed, "The voter already voted");
    require(votings[msg.sender].status == VoteStatus.None, "The voter not yet voted");
    require(ERC20(tokenAddress).balanceOf(msg.sender) > 0, "Not enought funds");
    uint256 accountWeight = ERC20(tokenAddress).balanceOf(msg.sender);
    votings[msg.sender] = UserWhitelist(accountWeight, true, true, status);

    if (status == VoteStatus.For) {
      votingDetails.totalForVotes++;
    } else if (status == VoteStatus.Against) {
      votingDetails.totalAgainstVotes++;
    } else votingDetails.totalAbstainVotes++;

    emit VotePlaced(msg.sender, status, accountWeight);
  }

  function getVoting() external view returns (VotingDetails memory) {
    return votingDetails;
  }
}
