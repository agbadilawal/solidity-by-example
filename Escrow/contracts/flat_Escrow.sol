
/** 
 *  SourceUnit: c:\Users\memunat\Documents\GitHub\solidity-by-example\Escrow\contracts\Escrow.sol
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity ^0.8.0;

/// @title Escrow
/// @author agbadilawal
/// @notice an amount of ether is sent to the contract by a payer and once its at a stated amount it can be disbursed by the arbiter to the payee

contract Escrow{
  address public payer;//Address of the party making the payment
  address payable public payee;//Address of the reciever of the payment
  address public arbiter;//Address of the trusted intermidiary who can disburse payment
  uint public amount;//Amount of ether to be payed by payer
  
  constructor(
    address _payer, 
    address payable _payee, 
    uint _amount
    ) public {
    payer = _payer;
    payee = _payee;
    arbiter = msg.sender;//arbiter is the address that deploys the smart contract
    amount = _amount;
  }

  function deposit() payable public onlyPayer {
    require(address(this).balance <= amount, 'Cant send more than escrow amount');//only the stated payer address is allowed to deposit into the pool
  }

  function release() public onlyArbiter {
    require(address(this).balance == amount, 'cannot release funds before full amount is sent');//only the arbiter is allowed to release the funds to the payee
    payee.transfer(amount);
  }
  
  function balanceOf() view public returns(uint) {
    return address(this).balance;//returns the current balance of the pool 
  }

  modifier onlyArbiter() {
    require(msg.sender == arbiter, 'only arbiter can release funds');
    _;
  }
  modifier onlyPayer() {
    require(msg.sender == payer, 'Sender must be payer');
    _;
  }

}

