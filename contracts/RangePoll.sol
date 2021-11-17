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
    This contract implements general functionality
    for a range poll. It remains agnostic to how an
    actual number is voted on, and how the votes are
    tallied at the end. This abstract contract only deals
    with locking/unlocking governance tokens for a poll as
    well as initiating and ending polls. It also manages how
    much weight users have voted with per poll. It uses a
    specific governance token, but it can practically be swapped
    out with any ERC20 token with a few easy modifications.
*/
abstract contract RangePoll {
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
    // The floor is the minimum number that can be voted on in the
    // current range poll. This value is set by a whitelisted address
    // at the start of each poll.
    uint256 _floor;
    // The ceiling is the maximum number that can be voted on in the
    // current range poll. This value is set by a whitelisted address
    // at the start of each poll.
    uint256 _ceiling;
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
    // contract). Note, if the governance token was changed to a different
    // ERC20 gov token, then this function would need to be slightly modified.
    function lock(uint256 tokens) external {
        _govToken.lock(msg.sender, tokens);
        _balances[msg.sender] = _balances[msg.sender].add(tokens);
        emit Lock(msg.sender, tokens);
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
    // currently ongoing (_live is false). Note, if the governance
    // token was changed to a different ERC20 gov token, then this
    // function would need to be slightly modified.
    // Note: not really an incentive to unlock ever if gov-token that
    // supports ability to lock in multiple places concurrently.
    // TODO: should try and get GovToken to be able to unlock for
    // someone (necessary for this particular gov token to be non-exploitable)
    function unlock(address voter, uint256 tokens) public {
        require(!_live);
        require(msg.sender == voter);
        _govToken.unlock(msg.sender, tokens);
        _balances[msg.sender] = _balances[msg.sender].sub(tokens);
        emit Unlock(voter, tokens);
    }

    // This function is called when a voter wants to remove some
    // of their voting power (de-register it). Tokens represents
    // the amount of weight they want to decrease by.
    function unlock(uint256 tokens) external {
        unlock(msg.sender, tokens);
    }

    // startPoll starts a new range poll between the bounds of
    // floor and ceiling, meaning people can vote between these
    // two values. Only whitelisted addresses can call this (example
    // case of whitelisted addresses would be employees of a DAO).
    function startPoll(uint256 floor,uint256 ceiling) external {
        require(_auth[msg.sender] == 1);
        _floor = floor;
        _ceiling = ceiling;
        _live = true;
        _pollID =  _pollID.add(1);
    }

    // Represents a vote where ballot equals the number within
    // the range that a user voted on, and weight represents
    // the amount of voting power associated with the vote.
    event Vote(uint256 ballot, uint256 weight);

    // This function allows users to vote for a particular value
    // in a live poll. The ballot represents the number that the
    // address is voting on. It should be in between floor and ceiling
    // The user can specify how much weight he wants to use for the
    // particular vote. If the user does not have enough weight, as much
    // weight will be put down as he can use.
    function vote(uint256 ballot, uint256 weight) external {
        require(_live);
        require (ballot <= _ceiling && ballot >= _floor);
        require(_balances[msg.sender].sub(_used[msg.sender][_pollID]) >= weight);
        _used[msg.sender][_pollID] = _used[msg.sender][_pollID].add(weight);
        emit Vote(ballot, weight);
        voteOp(ballot, weight);
    }

    // Sometimes a particular calculation method might be doing
    // calculations as each vote comes in, instead of all at the
    // end. Some calculation methods may not need this functionality.
    function voteOp(uint256 ballot, uint256 weight) virtual internal;

    // This event states what the result from the poll was after a whitelisted
    // address ends the poll.
    event PollResult(uint256 result);

    // Whitelisted user can end the current poll. This function will tally
    // the votes and do general housekeeping such as resetting some
    // parameters. Only whitelisted addresses can call this (example
    // case of whitelisted addresses would be employees of a DAO).
    // Note: There is an option to instead put a time lock here, so that
    // polls last a certain set time. Then any "keeper" could end the poll,
    // not just a whitelisted address.
    function endPoll() external returns (uint256){
        require(_live && _auth[msg.sender] == 1);
        _live = false;
        uint256 result = tally();
        emit PollResult(result);
        return result;
    }

    // This function is responsible for calculating the winning number
    // in the range for a poll. Some calculation methods may be completely
    // off-chain and not really have a need for this method.
    function tally() virtual internal returns (uint256);
}
