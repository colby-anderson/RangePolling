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
    random string is sent.To determine the winner, the mean
    is calculated.
*/
contract SecureMeanRangePoll is RangePoll {
    // ***************************************************
    // ------------------CONTRACT STATE-------------------
    // ***************************************************

    // The current denominator of the formula for mean. Namely,
    // the sum of all weights.
    uint256 _denominator;
    // The current numerator of the formula for mean. Namely,
    // (weight for voter A * vote of voter A) + (..B * ...B) ... for
    // all voters.
    uint256 _numerator;
    // Represents the hashes sent by each user during the commit
    // phase. These are later checked during the reveal phase.
    mapping(address => mapping(uint256 => bytes32)) _hashed;


    // ***************************************************
    // --------------CONTRACT FUNCTIONALITY---------------
    // ***************************************************

    // No different than parent constructor.
    constructor(GovToken g) RangePoll(g) public {}

    // Every vote has to add to the numerator and denominator
    function voteOp(uint256 ballot, uint256 weight) override internal {}

    // This represents the commit phase. It is the hash(vote + random num)
    // represented as a string, and the weight for the particular vote.  Sha3
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
    // with the earlier hash the user submitted. Then, the numerator and denominator
    // are updated.
    function reveal(uint256 ballot, uint256 random) external {
        require (ballot <= _ceiling && ballot >= _floor);
        require (_hashed[msg.sender][_pollID] == keccak256(abi.encode(ballot.add(random))));
        _denominator = _denominator.add(_used[msg.sender][_pollID]);
        _numerator = _numerator.add(_used[msg.sender][_pollID].mul(ballot));
        emit Reveal(ballot, random);
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
