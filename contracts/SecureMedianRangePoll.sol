// Author: Colby Anderson
pragma solidity ^0.6.0;
// This is the abstract contract that contains
// general functionality and state for range polls,
// specifically about starting/ending polls and
// locking/unlocking governance tokens.
import "./RangePoll.sol";
// ** UNCOMMENT LINE BELOW when testing this contract
// with hardhat to use print statements in the form of
// console.log
//import "hardhat/console.sol";



/*
    This contract is a range poll that is not susceptible to
    tactical voting. After voters lock their tokens, they
    can vote on any value in the selected range. The vote happens
    in a two step process (1. commit 2. reveal). The first
    phase features a commit where a hash is sent. The
    second phase features a reveal where a vote and a
    random string is sent.To determine the winner, the median
    is calculated.
*/
contract SecureMedianRangePoll is RangePoll {
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
    // Represents the hashes sent by each user during the commit
    // phase
    mapping(address => mapping(uint256 => bytes32)) _hashed;


    // ***************************************************
    // --------------CONTRACT FUNCTIONALITY---------------
    // ***************************************************

    // No different than parent constructor.
    constructor(GovToken g) RangePoll(g) public {}

    // Every vote has to add to the numerator and denominator
    function voteOp(uint256 ballot, uint256 weight) override internal {}

    // This represents the commit phase. It is the hash(vote + random num)
    // represented as a string, and the weight for the particular vote. Sha3
    // is the specific hash function that should be used.
    event Commit(bytes32 hash, uint256 weight);

    // Sends a commit. The hash of the vote is stored for later. The weight
    // the voter used to vote with is also recorded.
    function commit(bytes32 hash, uint256 weight) external {
        require(_live);
        require(_balances[msg.sender].sub(_used[msg.sender][_pollID]) >= weight);
        _used[msg.sender][_pollID] = _used[msg.sender][_pollID].add(weight);
        _hashed[msg.sender][_pollID] = hash;
        emit Commit(hash, weight);
    }

    // This represents the reveal phase. It is the vote and random num used
    // in the commit phase.
    event Reveal(uint256 ballot, uint256 random);

    // Reveals the vote of a user from the commit phase. First, the reveal
    // is checked to be a valid reveal by hashing the input and matching it
    // with the earlier hash the user submitted. Then, the vote is inserted
    // into the sorted votes (_sortedBallots).
    function reveal(uint256 ballot, uint256 random) external {
        require (ballot <= _ceiling && ballot >= _floor);
        require (_hashed[msg.sender][_pollID] == keccak256(abi.encode(ballot.add(random))));
        _totalWeight = _totalWeight.add(_used[msg.sender][_pollID]);
        _ballots[_pollID][ballot] = _ballots[_pollID][ballot].add(_used[msg.sender][_pollID]);
        if (_sortedBallots.length != 0) {
            insertionSort(ballot);
        } else {
            _sortedBallots.push(ballot);
        }
        emit Reveal(ballot, random);
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
