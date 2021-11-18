// Author: Colby Anderson
pragma solidity ^0.6.0;
// GovToken is a custom governance token that implements
// IERC20. However, unlike most governance tokens, it can
// be locked in multiple polls simultaneously.
import "./GovToken.sol";
// Used for basic math operations to prevent malicious use
// of contract.
import "@openzeppelin/contracts/math/SafeMath.sol";
// ** UNCOMMENT LINE BELOW when testing this contract
// with hardhat to use print statements in the form of
// console.log
//import "hardhat/console.sol";



/*
    This contract is a range poll that is susceptible to
    tactical voting. After voters lock their tokens, they
    can either choose to decrement or increment the current poll
    value (after a poll starts of course). Polls are started by
    whitelisted addresses (an example use case of the whitelisted
    addresses would be employees of a DAO). These whitelisted
    addresses can start the "starting point" of the poll and
    determine how much each increment/decrement is.
*/
contract IncrementPoll {
    using SafeMath for uint256;
    // ***************************************************
    // ------------------CONTRACT STATE-------------------
    // ***************************************************

    // Every poll will have a unique ID. The first poll has ID = 1
    uint256 _pollID;
    // This is the address of the particular governance token
    // used to count as voting power/weight in the polls.
    GovToken _govToken;
    // live is set to true when a poll is live (people are
    // voting), and false otherwise.
    bool _live;
    // Balances are a mapping from a voter to the amount of
    // governance tokens they have locked with this polling contract
    // (not necessarily the amount they are voting on a current poll
    // with).
    mapping(address => uint256) _balances;
    // used is a mapping from a voter to pollID to the weight they
    // have already used for that poll. In other words, it keeps
    // track of how much a voter has used of his total balance per
    // election.
    mapping(address => mapping (uint256 => uint256)) _used;
    // The interval is the amount that the current value can be incremented
    // or decremented by. It is meant to be fixed and set each poll.
    uint256 _interval;
    // The current value of the poll. The starting point is chosen when the
    // poll is first begun (by some whitelisted address).
    uint256 _currentValue;
    // Authorization levels for different addresses. Level 1 authorization
    // gives the users ability to start polls and give auth level 1 to
    // other addresses.
    mapping(address => uint8) _auth;


    // ***************************************************
    // --------------CONTRACT FUNCTIONALITY---------------
    // ***************************************************

    // Sets the pollID to 0. (It will be incremented to 1 in
    // startPoll, so technically the first poll will have ID 1.
    // Sets the governance token to a user supplied one. Also
    // gives authorization level of 1 to the caller.
    constructor(GovToken govToken) public {
        _govToken = govToken;
        _pollID = 0;
        _live = false;
        _auth[msg.sender] = 1;
    }

    // Gives authorization level of 1 to another address.
    // Requires that the calling address has authorization
    // level of 1.
    function giveAuth(address user) external {
        require(_auth[msg.sender] == 1);
        _auth[user] = 1;
    }

    // Emitted during a lock where users lock up their gov Tokens
    // in order to participate in polls. The user is the address
    // that locked the gov tokens and tokens is the amount of tokens
    // that were just locked.
    event Lock(address user, uint256 tokens);

    // Lets the governance token contract register this poll
    // as a place where tokens are locked (this could be the governance
    // contract keeping a record, or just transferring the tokens to this
    // contract)
    function lock(uint256 tokens) external {
        _govToken.lock(msg.sender, tokens);
        _balances[msg.sender] = _balances[msg.sender].add(tokens);
        emit Lock(msg.sender, tokens);
    }

    // This function is called when a voter wants to remove some
    // of their voting power (de-register it). Tokens represents
    // the amount of weight they want to decrease by.
    function unlock(uint256 tokens) external {
        unlock(msg.sender, tokens);
    }

    // Emitted during unlock where users unlock their gov Tokens
    // The user is the address
    // that locked the gov tokens and tokens is the amount of tokens
    // that were just locked.
    event Unlock(address user, uint256 tokens);

    // This function unlocks tokens from this contract, meaning
    // it removes the voting power of a voter. The governance token
    // contract or the voter himself can remove a voter's voting
    // power. Tokens represents the amount of weight they want
    // to decrease by. This can only be called when a poll is not
    // currently ongoing (_live is false).
    // Note: not really an incentive to unlock ever.
    // Note: should try and get GovToken to be able to unlock for
    // someone
    function unlock(address voter, uint256 tokens) public {
        require(!_live);
        require(msg.sender == voter);
        _govToken.unlock(msg.sender, tokens);
        _balances[msg.sender] = _balances[msg.sender].sub(tokens);
        emit Unlock(voter, tokens);
    }

    // startPoll starts a new range poll with the starting value
    // being start. The amount at which this value can incremented/decremented
    // by is the interval parameter. Only whitelisted addresses can
    // call this (think employees of a DAO).
    function startPoll(uint256 start, uint256 interval) external {
        require(_auth[msg.sender] == 1);
        _currentValue = start;
        _interval = interval;
        _live = true;
        _pollID =  _pollID.add(1);
    }

    // Represents a vote where increment is true if they incremented
    // the current value of poll and false if they decremented it.
    // Weight represents the amount of voting power associated with the vote.
    event Vote(bool increment, uint256 weight);

    // This function allows users to vote for a particular value
    // in a live poll. If increment is true, they want to increment
    // the current value for the poll. If false, they want to decrement
    // it.
    function vote(bool increment, uint256 weight) external {
        require(_live);
        require(_balances[msg.sender].sub(_used[msg.sender][_pollID]) >= weight);
        _used[msg.sender][_pollID] = _used[msg.sender][_pollID].add(weight);
        if (increment) {
            _currentValue = _currentValue.add(weight.mul(_interval));
        } else {
            _currentValue = _currentValue.sub(weight.mul(_interval));
        }
        emit Vote(increment, weight);
    }

    // The current value when the poll ends will be the result.
    function tally() internal returns (uint256) {
        return _currentValue;
    }

    // This event states what the result from the poll was after a whitelisted
    // address ends the poll.
    event PollResult(uint256 result);

    // Whitelisted user can end the current poll. This function will tally
    // the votes and do general housekeeping such as resetting some
    // parameters.
    function endPoll() external returns (uint256){
        require(_auth[msg.sender] == 1 && _live);
        _live = false;
        uint256 result = tally();
        emit PollResult(result);
        return result;
    }
}
