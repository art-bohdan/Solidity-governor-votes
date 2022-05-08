//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ERC20 is IERC20 {
  //Variables
  uint256 public _totalSupply;

  mapping(address => uint256) public _balanceOf;
  mapping(address => mapping(address => uint256)) public override allowance;

  string public _name;
  string public _symbol;
  uint8 public _decimals;

  constructor(
    string memory name_,
    string memory symbol_,
    uint8 dec,
    uint256 totalSupply_
  ) {
    _name = name_;
    _symbol = symbol_;
    _decimals = dec;
    _mint(totalSupply_);
  }

//Function
  function name() public view returns (string memory) {
    return _name;
  }

  // returns Symbol token
  function symbol() public view returns (string memory) {
    return _symbol;
  }

  // returns decimals
  function decimals() public view returns (uint8) {
    return _decimals;
  }

  // returns balances from account address
  function balanceOf(address account) public view override returns (uint256) {
    return _balanceOf[account];
  }

  function increaseAllowance(address spender, uint256 addedValue)
    public
    payable
    returns (bool)
  {
    require(
      spender != address(0),
      "ERC20: spender should be not a zero address"
    );
    allowance[msg.sender][spender] += addedValue;
    emit Approval(msg.sender, spender, addedValue);
    return true;
  }

  function decreaseAllowance(address spender, uint256 addedValue)
    public
    payable
    returns (bool)
  {
    require(
      spender != address(0),
      "ERC20: spender should be not a zero address"
    );
    allowance[msg.sender][spender] -= addedValue;
    emit Approval(msg.sender, spender, addedValue);
    return true;
  }

//   function _beforeTokenTransfer(
//     address operator, 
//     address from, 
//     address to, 
//     uint256 amount
// ) 
//     internal 
//     override 
//     virtual 
// {
//     if (from != Utils.EMPTY_ADDRESS) {
//         updateAccountHistory(from, balanceOf(from).sub(amount));
//     }
//     if (to != Utils.EMPTY_ADDRESS) {
//         updateAccountHistory(to, balanceOf(to).add(amount));
//     }
//     super._beforeTokenTransfer(operator, from, to, amount);
// }

  function totalSupply() public view override returns (uint256) {
    return _totalSupply;
  }

  function _allowance(address owner, address spender)
    external
    view
    returns (uint256)
  {
    return allowance[owner][spender];
  }

  function transfer(address to, uint256 amount)
    external
    override
    returns (bool)
  {
    require(
      _balanceOf[msg.sender] >= amount,
      "ERC20: transfer amount exceeds balance"
    );
    _balanceOf[msg.sender] -= amount;
    _balanceOf[to] += amount;
    emit Transfer(msg.sender, to, amount);
    return true;
  }

  function approve(address spender, uint256 amount)
    external
    override
    returns (bool)
  {
    require(spender != address(0), "ERC20: approve to the zero address");
    allowance[msg.sender][spender] = amount;
    emit Approval(msg.sender, spender, amount);
    return true;
  }

  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) external override returns (bool) {
    require(_balanceOf[from] >= amount, "ERC20: not enough funds on account");
    require(
      allowance[from][msg.sender] >= amount,
      "ERC20: not enough allowance funds on account"
    );
    allowance[from][msg.sender] -= amount;
    _balanceOf[from] -= amount;
    _balanceOf[to] += amount;
    emit Transfer(from, msg.sender, amount);
    return true;
  }

  function burnFrom(address from, uint256 amount) external returns (bool) {
    require(_balanceOf[from] >= amount, "ERC20: not enough funds on account");
    require(
      allowance[from][msg.sender] >= amount,
      "ERC20: not enough allowance funds"
    );
    allowance[from][msg.sender] -= amount;
    _balanceOf[from] -= amount;
    _totalSupply -= amount;
    emit Transfer(from, address(0), amount);
    return true;
  }

  function _mint(uint256 amount) internal {
    _balanceOf[msg.sender] += amount;
    _totalSupply += amount;
    emit Transfer(address(0), msg.sender, amount);
  }

  function _burn(uint256 amount) external {
    require(msg.sender != address(0), "ERC20: burn to the zero address");
    require(_balanceOf[msg.sender] >= amount, "ERC20 not enough funds");
    _balanceOf[msg.sender] -= amount;
    _totalSupply -= amount;
    emit Transfer(msg.sender, address(0), amount);
  }
}
