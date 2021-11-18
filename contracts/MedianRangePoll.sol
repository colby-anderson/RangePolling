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
    This contract is a range poll that is susceptible to
    tactical voting. After voters lock their tokens, they
    can vote on any value in the selected range. To determine
    the winner, the median is calculated.
*/
contract MedianRangePoll is RangePoll {
    // ***************************************************
    // ------------------CONTRACT STATE-------------------
    // ***************************************************

    // This is a sorted list of votes from the current poll.
    uint256[] _sortedBallots;
    // The total weight is the summed weight of all the weight
    // the voters used when voting.
    uint256 _totalWeight;
    // The ballots keep track of how much weight there is for
    // each vote in each poll. It maps pollID to the vote to
    // the amount of weight for that vote.
    mapping(uint256 => mapping(uint256 => uint256)) _ballots;

    // ***************************************************
    // --------------CONTRACT FUNCTIONALITY---------------
    // ***************************************************

    // No different than parent constructor.
    constructor(GovToken g) RangePoll(g) public {}

    // The weight the voter used to vote with is added to the total weight
    // for the current poll and is added to the total amount of weight for
    // the particular value he voted for. Then, the particular vote (ballot)
    // is added to the rest of the sorted votes using insertion sort.
    function voteOp(uint256 ballot, uint256 weight) override internal {
        _totalWeight = _totalWeight.add(weight);
        _ballots[_pollID][ballot] = _ballots[_pollID][ballot].add(weight);
        if (_sortedBallots.length != 0) {
            insertionSort(ballot);
        } else {
            _sortedBallots.push(ballot);
        }
    }

    // Tally does general housekeeping for the end of the poll and
    // calculates the median. The median is calculated by dividing
    // the sum of all weights the voters voted with, by 2. This is
    // the midpoint. Then, the sorted votes must be traversed into
    // the midpoint (according to weight) is found. The corresponding
    // vote is the result of the poll.
    function tally() override internal returns (uint256){
        uint256 midpoint = _totalWeight.div(2);
        uint256 runningTotal = 0;
        for (uint256 i = 0; i < _sortedBallots.length; i++) {
            if (runningTotal.add(_ballots[_pollID][_sortedBallots[i]]) >= midpoint) {
                uint256 result = _sortedBallots[i];
                delete _sortedBallots;
                return result;
            }
            runningTotal = runningTotal.add(_sortedBallots[i]);
        }
    }

    // This is a basic insertion sort algorithm where the ballot
    // is inserted into a sorted list (_sortedBallots) in the correct
    // position.
    function insertionSort(uint256 ballot) internal {
        uint length = _sortedBallots.length;
        for (uint256 i = 0; i < length; i++) {
            if (ballot <= _sortedBallots[i]) {
                uint256 save = _sortedBallots[i];
                uint256 replacement = ballot;
                for (uint256 j = i; j < length.add(1); j++) {
                    if (j == length) {
                        _sortedBallots.push(replacement);
                    }
                    else {
                        save = _sortedBallots[j];
                        _sortedBallots[j] = replacement;
                        replacement = save;
                    }
                }
                break;
            } else if (length == i.add(1)) {
                _sortedBallots.push(ballot);
            }
        }
    }
}

