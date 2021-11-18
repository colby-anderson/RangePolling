// Author: Colby Anderson
pragma solidity ^0.6.0;
// This is the abstract contract that contains
// general functionality and state for range polls.
import "./RangePoll.sol";
// ** UNCOMMENT LINE BELOW when testing this contract
// with hardhat to use print statements in the form of
// console.log
//import "hardhat/console.sol";



/*
    This contract is an event-driven range
    poll that is susceptible to tactical voting.
    After voters lock their tokens, they can vote
    on any value in the selected range. An event
    will be emitted. A centralized server would listen
    to these events and use whatever calculation method
    to reach a consensus.
*/
contract EventRangePoll is RangePoll {

    // ***************************************************
    // --------------CONTRACT FUNCTIONALITY---------------
    // ***************************************************

    // No different than parent constructor.
    constructor(GovToken g) RangePoll(g) public {}

    // Represents a vote where ballot equals the number within
    // the range that a user voted on, and weight represents
    // the amount of voting power associated with the vote.
    event Vote(uint256 ballot, uint256 weight);

    // Does nothing since the event is already emitted.
    // Note: To make this method more gas efficient, this method should
    // do nothing, and a separate voting method should be made. This would
    // mean the weight checks and updating would not be done in smart contracts
    // but rather done off-chain.
    function voteOp(uint256 ballot, uint256 weight) override internal {}

    // This function is intended to calculate the winning number
    // in the range by tallying the votes. However, in this case,
    // it should be happening off-chain so a dummy value is returned.
    function tally() override internal returns (uint256){
        return 0;
    }
}
