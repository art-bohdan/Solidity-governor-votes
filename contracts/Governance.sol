//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Governance {
  //Variables
  mapping(uint256 => vote) private votes;
  mapping(address => bool) whitelist;
  mapping(address => voter) public voterRegister;
  mapping(address => uint256) public blocked;

  struct vote {
    address voterAddress;
    VoteType choice;
  }

  struct voter {
    address voterAddress;
    bool voted;
  }

  enum VoteType {
    Against,
    For,
    Abstain
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
    uint256 _minVotes
  ) {
    governanceAddress = msg.sender;
    governanceName = _governanceName;
    proposal = _proposal;
    startTimestamp = _startTimestamp;
    endTimestamp = _endTimestamp;
    minVotes = _minVotes;
  }

  //Modifire
  modifier onlyOwner() {
    require(msg.sender == governanceAddress);
    _;
  }

  //Events

  //Function
  function changeStartTimestamp(uint256 _startTimestamp) public onlyOwner {
    startTimestamp = _startTimestamp;
  }

  function changeEndTimestamp(uint256 _endTimestamp) public onlyOwner {
    require(
      _endTimestamp > startTimestamp,
      "End timestamp must be longer from the begin"
    );
    endTimestamp = _endTimestamp;
  }
}
