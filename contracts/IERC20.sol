// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function decimals() external view returns (uint256);

  function totalSupply() external view returns (uint64);

  function balanceOf(address account) external view returns (uint64);

  function transfer(address recipient, uint64 amount) external returns (bool);

  function allowance(address owner, address spender) external view returns (uint64);

  function approve(address spender, uint64 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint64 amount
  ) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint64 value);

  event Approval(address indexed owner, address indexed spender, uint64 value);
}
