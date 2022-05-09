//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "./ERC20.sol";
import "./IERC20.sol";

contract Governance {
  //Variables
  mapping(address => bool) whitelistAddress;
  mapping(uint256 => VotingDetails) public votings;
  uint256 votingIdsCounter;

  struct VotingDetails {
    uint256 myTokenTotalSupply;
    uint256 createdVote;
    uint256 endVote;
    uint minVotes;
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
    setWhitelist(addresses);
  }

  //Modifire
  modifier onlyOwner() {
    require(msg.sender == governanceAddress, "must be address onwer");
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
  function getProposal() public view returns (string memory) {
    return proposal;
  }
  
  function getStartTimestamp(uint votingId) public view returns (uint256) {
    return votings[votingId].createdVote;
  }

  function getEndTimestamp(uint votingId) public view returns (uint256) {
    return votings[votingId].endVote;
  }

  function setWhitelist(address[] memory addresses) public onlyOwner {
    for (uint256 i = 0; i < addresses.length; i++) {
      whitelistAddress[addresses[i]] = true;
    }
  }

  function checkAddressWhitelist(address _address) external view returns (bool) {
    return whitelistAddress[_address];
  }

  function changeStartTimestamp(uint256 _createdVote, uint votingId) external onlyOwner {
     votings[votingId].createdVote = _createdVote;
  }

  function changeEndTimestamp(uint256 _endVote, uint votingId) external onlyOwner {
    require(_endVote > votings[votingId].createdVote, "End timestamp must be longer from the begin");
    votings[votingId].endVote = _endVote;
  }

  function startVoting(uint256 createdVote, uint256 endVote, uint minVotes) external {
        // checking inputs
        require(IERC20(governanceAddress).balanceOf(msg.sender) > 0, "You should possess at least some tokens to be able to start a voting");

        // creating new voting
        uint256 votingId = votingIdsCounter++;
        uint256 myTokenTotalSupply =IERC20(governanceAddress).totalSupply();
        // votings[votingId] = VotingDetails(
        //     myTokenTotalSupply,
        //     createdVote,
        //     endVote,
        //     minVotes,
        //     0,
        //     0,
        //     0,
        //     false
        // );

        emit VotingStarted(votingId);
    }

  function vote(uint256 votingId, VoteStatus status) external isWhitelisted(msg.sender) {
    VotingDetails storage votingDetails = votings[votingId];
    // checking inputs
    require(votingDetails.createdVote > 0, "The voting does not exist");
    require(status != VoteStatus.Abstain, "Invalid vote");
    require(votingDetails.createdVote != block.timestamp, "Unable to vote right after the voting's start");
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
    VotingDetails storage votingDetails = votings[votingId];

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
    VotingDetails storage votingDetails = votings[votingId];

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
