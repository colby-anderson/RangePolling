pragma solidity ^0.6.0;
// This is the abstract contract that contains
// general functionality and state for range polls.
import "./RangePoll.sol";

/*
    This contract is a range poll that is susceptible to
    tactical voting. After voters lock their tokens, they
    can vote on any value in the selected range. To determine
    the winner, the mean is calculated.
*/
contract MeanRangePoll is RangePoll {
    // ***************************************************
    // ------------------CONTRACT STATE-------------------
    // ***************************************************

    // The current denominator of the formula for mean.
    uint256 _denominator;
    // The current numerator of the formula for mean.
    uint256 _numerator;


    // ***************************************************
    // --------------CONTRACT FUNCTIONALITY---------------
    // ***************************************************

    // No different than parent constructor.
    constructor(GovToken g) RangePoll(g) public {}

    // Every vote has to add to the numerator and denominator
    function voteOp(uint256 ballot, uint256 weight) override internal {
        _denominator = _denominator.add(weight);
        _numerator = _numerator.add(weight.mul(ballot));
    }

    // Tally does general housekeeping for the end of the poll and
    // calculates the mean.
    function tally() override internal returns (uint256){
        uint256 mean = _numerator.div(_denominator);
        _numerator = 0;
        _denominator = 0;
        return mean;
    }
}
