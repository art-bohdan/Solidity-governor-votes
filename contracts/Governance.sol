//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "./ERC20.sol";
import "./IERC20.sol";

contract Governance {
  //Variables
  mapping(address => UserWhitelist) whitelistAddress;
  mapping(address => VoteStatus) public votings;
  VotingDetails votingDetails;

  struct UserWhitelist {
    bool inWhitelist;
    bool executed;
  }

  struct VotingDetails {
    uint64 myTokenTotalSupply;
    uint64 createdVote;
    uint64 endVote;
    uint8 minVotes;
    uint8 totalForVotes;
    uint8 totalAgainstVotes;
    uint8 totalAbstainVotes;
  }

  enum VoteStatus {
    For,
    Against,
    Abstain
  }

  address public governanceAddress;
  string public governanceName;
  string public proposal;

  constructor(
    string memory _governanceName,
    string memory _proposal,
    uint64 _startTimestamp,
    uint64 _endTimestamp,
    uint8 _minVotes,
    address[] memory addresses
  ) {
    governanceAddress = msg.sender;
    governanceName = _governanceName;
    proposal = _proposal;
    setWhitelist(addresses);
  }

  //Modifire
  modifier onlyOwner() {
    require(msg.sender == governanceAddress, "must be address onwer");
    _;
  }

  modifier isWhitelisted() {
    require(whitelistAddress[msg.sender].inWhitelist == true, "You need to be whitelisted");
    _;
  }

  //Events
  event VotePlaced(address voter, VoteStatus status, uint256 voteWeight);

  // event VotingExecuted(uint256 indexed votingId, VotingResult result);

  //Function

  function getGovernanceName() public view returns (string memory) {
    return governanceName;
  }

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
      whitelistAddress[addresses[i]].inWhitelist = true;
    }
  }

  function checkAddressWhitelist(address _address) external view returns (bool) {
    return whitelistAddress[_address].inWhitelist;
  }

  function changeStartTimestamp(uint64 _createdVote) external onlyOwner {
    require(votingDetails.endVote < _createdVote, "Start timestamp must be less from the end");
    votingDetails.createdVote = _createdVote;
  }

  function changeEndTimestamp(uint64 _endVote) external onlyOwner {
    require(_endVote > votingDetails.createdVote, "End timestamp must be longer from the begin");
    votingDetails.endVote = _endVote;
  }

  function vote(VoteStatus status) external isWhitelisted {
    require(whitelistAddress[msg.sender].executed == true, "The voter already voted");
    uint256 accountWeight = ERC20(governanceAddress).balanceOf(msg.sender);
    votings[msg.sender] = status;

    if (status == VoteStatus.For) {
      votingDetails.totalForVotes++;
    } else if (status == VoteStatus.Against) {
      votingDetails.totalAgainstVotes++;
    } else votingDetails.totalAbstainVotes++;

    emit VotePlaced(msg.sender, status, accountWeight);
  }

  function getVoteOf(address voter) external view returns (VoteStatus) {
    return votings[voter];
  }

  function getVoting() external view returns (VotingDetails memory) {
    return votingDetails;
  }
}
