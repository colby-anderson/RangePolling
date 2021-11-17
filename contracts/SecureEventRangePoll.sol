pragma solidity ^0.6.0;
// This is the abstract contract that contains
// general functionality and state for range polls.
import "./RangePoll.sol";

/*
    This contract is an event-driven range
    poll that is not susceptible to tactical voting.
    After voters lock their tokens, they can vote
    on any value in the selected range. The vote happens
    in a two step process (1. commit 2. reveal). The first
    phase features a commit where a hash is sent. The
    second phase features a reveal where a vote and a
    random string is sent. A centralized server would listen
    to these events and use whatever calculation method
    to reach a consensus.
*/
contract SecureEventRangePoll is RangePoll {

    // ***************************************************
    // --------------CONTRACT FUNCTIONALITY---------------
    // ***************************************************

    // No different than parent constructor.
    constructor(GovToken gT) RangePoll(gT) public {}

    // This function would usually be used to do some calculation per vote
    // that would help determine the winner. But it is not needed for this
    // particular range poll, as it is event driven.
    function voteOp(uint256 ballot, uint256 weight) override internal {}

    // This represents the commit phase. It is the hash(vote + random num)
    // represented as a string, and the weight for the particular vote.
    event Commit(bytes32[] hash, uint256 weight);

    // Sends a commit.
    // Note: Weight calculation can either be implemented within this function
    // or implemented off-chain.
    function commit(bytes32[] calldata hash, uint256 weight) external {
        require(_live);
        emit Commit(hash, weight);
    }

    // This represents the reveal phase. It is the hash(vote + random num)
    // represented as a string.
    event Reveal(uint256 vote, uint256 random);

    // Sends a reveal.
    // Note: Weight calculation can either be implemented within this function
    // or implemented off-chain.
    function reveal(uint256 vote, uint256 random) external {
        require(_live);
        emit Reveal(vote, random);
    }

    // This function is intended to calculate the winning number
    // in the range by tallying the votes. However, in this case,
    // it should be happening off-chain.
    function tally() override internal returns (uint256){
        return 0;
    }
}
