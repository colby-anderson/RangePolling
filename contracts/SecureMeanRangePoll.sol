pragma solidity ^0.6.0;
// This is the abstract contract that contains
// general functionality and state for range polls.
import "./RangePoll.sol";

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

    // The current denominator of the formula for mean.
    uint256 _denominator;
    // The current numerator of the formula for mean.
    uint256 _numerator;
    // represents the hashes sent by each user during the commit
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
    // represented as a string, and the weight for the particular vote.
    event Commit(bytes32 hash, uint256 weight);

    // Sends a commit.
    function commit(bytes32 hash, uint256 weight) external {
        require(_live);
        require(_balances[msg.sender].sub(_used[msg.sender][_pollID]) >= weight);
        _used[msg.sender][_pollID] = _used[msg.sender][_pollID].add(weight);
        _hashed[msg.sender][_pollID] = hash;
        emit Commit(hash, weight);
    }

    // This represents the reveal phase. It is the hash(vote + random num)
    // represented as a string.
    event Reveal(uint256 ballot, uint256 random);

    // Reveals the vote of a user from the commit phase.
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
