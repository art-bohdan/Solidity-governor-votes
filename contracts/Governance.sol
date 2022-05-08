//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "./ERC20.sol";

contract Governance {
  //Variables
  mapping(address => bool) whitelistAddress;
  mapping(uint256 => VotingDetails) public voterRegister;

  struct VotingDetails {
    uint256 myTokenTotalSupplySnapshot;
    uint256 createdAt;
    uint256 duration;
    uint256 totalForVotes;
    uint256 totalAgainstVotes;
    uint256 totalAbstainVotes;
    bool executed;
    mapping(address => VoteStatus) voteByAccount;
  }

  enum VoteStatus {
    For,
    Against,
    Abstain
  }

  enum VotingResult {
    NONE,
    ACCEPT,
    REJECT,
    NOT_APPLIED
  }

  uint256 public startTimestamp;
  uint256 public endTimestamp;

  uint256 public minVotes;
  address public governanceAddress;
  string public governanceName;
  string public proposal;

  constructor(
    string memory _governanceName,
    string memory _proposal,
    uint256 _startTimestamp,
    uint256 _endTimestamp,
    uint256 _minVotes,
    address[] memory addresses
  ) {
    governanceAddress = msg.sender;
    governanceName = _governanceName;
    proposal = _proposal;
    startTimestamp = _startTimestamp;
    endTimestamp = _endTimestamp;
    minVotes = _minVotes;
    setWhitelist(addresses);
  }

  //Modifire
  modifier onlyOwner() {
    require(msg.sender == governanceAddress);
    _;
  }

  modifier isWhitelisted(address _address) {
    require(whitelistAddress[_address], "You need to be whitelisted");
    _;
  }

  //Events
  event VotingStarted(uint256 indexed votingId);
  event VotePlaced(uint256 indexed votingId, address voter, VoteStatus status, uint256 voteWeight);
  event VotingExecuted(uint256 indexed votingId, VotingResult result);

  //Function
  receive() external payable {}

  function getGovernanceName() public view returns (string memory) {
    return governanceName;
  }

  function setWhitelist(address[] memory addresses) internal onlyOwner {
    for (uint256 i = 0; i < addresses.length; i++) {
      whitelistAddress[addresses[i]] = true;
    }
  }

  function checkAddressWhitelist(address _address) external view returns (bool) {
    return whitelistAddress[_address];
  }

  function changeStartTimestamp(uint256 _startTimestamp) external onlyOwner {
    startTimestamp = _startTimestamp;
  }

  function changeEndTimestamp(uint256 _endTimestamp) external onlyOwner {
    require(_endTimestamp > startTimestamp, "End timestamp must be longer from the begin");
    endTimestamp = _endTimestamp;
  }

  function vote(uint256 votingId, VoteStatus status) external isWhitelisted(msg.sender) {
    VotingDetails storage votingDetails = voterRegister[votingId];
    // checking inputs
    require(votingDetails.createdAt > 0, "The voting does not exist");
    require(status != VoteStatus.Abstain, "Invalid vote");
    require(votingDetails.createdAt != block.timestamp, "Unable to vote right after the voting's start");
    require(votingDetails.voteByAccount[msg.sender] == VoteStatus.Abstain, "The voter already voted");
    uint256 accountWeight = ERC20(governanceAddress).balanceOf(msg.sender);

    votingDetails.voteByAccount[msg.sender] = status;

    if (status == VoteStatus.For) {
      votingDetails.totalForVotes++;
    } else if (status == VoteStatus.Against) {
      votingDetails.totalAgainstVotes++;
    } else votingDetails.totalAbstainVotes++;

    emit VotePlaced(votingId, msg.sender, status, accountWeight);
  }

  function getVoteOf(uint256 votingId, address voter) external view returns (VoteStatus) {
    VotingDetails storage votingDetails = voterRegister[votingId];

    return votingDetails.voteByAccount[voter];
  }

  function getVoting(uint256 votingId)
    external
    view
    returns (
      uint256 createdAt,
      uint256 duration,
      uint256 totalForVotes,
      uint256 totalAgainstVotes,
      uint256 totalAbstainVotes,
      bool executed
    )
  {
    VotingDetails storage votingDetails = voterRegister[votingId];

    return (
      votingDetails.createdAt,
      votingDetails.duration,
      votingDetails.totalForVotes,
      votingDetails.totalAgainstVotes,
      votingDetails.totalAbstainVotes,
      votingDetails.executed
    );
  }
}
