pragma solidity ^0.6.0;
// This is the abstract contract that contains
// general functionality and state for range polls.
import "./RangePoll.sol";

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

    uint256[] _sortedBallots;
    uint256 _totalWeight;
    mapping(uint256 => mapping(uint256 => uint256)) _ballots;

    // ***************************************************
    // --------------CONTRACT FUNCTIONALITY---------------
    // ***************************************************

    // No different than parent constructor.
    constructor(GovToken g) RangePoll(g) public {}

    function voteOp(uint256 ballot, uint256 weight) override internal {
        _totalWeight = _totalWeight.add(weight);
        _ballots[_pollID][ballot] = _ballots[_pollID][ballot].add(weight);
        insertionSort(ballot);
    }

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

