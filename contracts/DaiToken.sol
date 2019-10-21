pragma solidity ^0.5.0;
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol";

contract DaiToken is ERC20Mintable {
  string public NAME = "Dai Simulated";
  string public SYMBOL = "DAI";
  uint public DECIMALS = 18;
}
