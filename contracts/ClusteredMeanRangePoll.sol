// Author: Colby Anderson
pragma solidity ^0.6.0;
// This is the abstract contract that contains
// general functionality and state for range polls.
import "./RangePoll.sol";
// ** UNCOMMENT LINE BELOW when testing this contract
// with hardhat to use print statements in the form of
// console.log
import "hardhat/console.sol";

import "./MinHeap.sol";

/*
    This contract is
*/
contract ClusteredMeanRangePoll is RangePoll {
    struct Pair {
        uint256 a;
        uint256 b;
    }
    uint256[] ballots;
    mapping (uint256 => Pair[]) distances;
    MinHeap heap;

    // ***************************************************
    // --------------CONTRACT FUNCTIONALITY---------------
    // ***************************************************

    // No different than parent constructor.
    constructor(GovToken g, MinHeap h) RangePoll(g) public {
        console.log('aa');
        heap = h;
        console.log('bb');
    }

    // INSERT DOCS
    function voteOp(uint256 ballot, uint256 weight) override internal {
        for (uint i = 0; i < ballots.length; i++) {
            uint256 distance = ballots[i] < ballot ? (ballot - ballots[i]) : (ballots[i] - ballot);
            heap.insert(distance);
            distances[distance].push(Pair(ballots[i], ballot));
        }
        ballots.push(ballot);
    }

    mapping (uint256 => uint256[]) n2gn;
    mapping(uint256 => Pair) gn2v;

    function inn(uint256 val, uint256[] memory list) internal returns (bool){
        for (uint i = 0; i < list.length; i++) {
            if (val == list[i]) {
                return true;
            }
        }
        return false;
    }

    function mean(uint256 val1, uint w1, uint256 v2) internal returns (uint){
        return (val1.mul(w1).add(v2)).div(w1.add(1));
    }

    // INSERT DOCS
    function tally() override internal returns (uint256){
        uint256 majorityThreshold = (ballots.length).mod(2) > 0 ? (ballots.length).div(2) + 1 : (ballots.length).div(2);
        bool done = false;
        uint ngn = 1;
        while (!done) {
            uint next = heap.pop();
            for (uint i = 0; i < distances[next].length; i++) {
                Pair storage pr = distances[next][i];
                if (n2gn[pr.a].length == 0 && n2gn[pr.a].length == 0) {
                    n2gn[pr.a] = [ngn];
                    n2gn[pr.b] = [ngn];
                    console.log(n2gn[pr.b][0]);
                    gn2v[ngn] = Pair((pr.a.add(pr.b)).div(2), 2);
                    ngn++;
                } else {
                    for (uint j = 0; j < n2gn[pr.a].length; j++) {
                        if (!inn(n2gn[pr.a][j], n2gn[pr.b])) {
                            gn2v[n2gn[pr.a][j]] = Pair(mean(gn2v[n2gn[pr.a][j]].a, gn2v[n2gn[pr.a][j]].b, pr.b), gn2v[n2gn[pr.a][j]].b + 1);
                        }
                        if ( gn2v[n2gn[pr.a][j]].b >= majorityThreshold) {
                            return gn2v[n2gn[pr.a][j]].a;
                        }
                    }
                    for (uint j = 0; j < n2gn[pr.b].length; j++) {
                        if (!inn(n2gn[pr.b][j], n2gn[pr.a])) {
                            gn2v[n2gn[pr.b][j]] = Pair(mean(gn2v[n2gn[pr.b][j]].a, gn2v[n2gn[pr.b][j]].b, pr.a), gn2v[n2gn[pr.b][j]].b + 1);
                        }
                        if ( gn2v[n2gn[pr.b][j]].b >= majorityThreshold) {
                            return gn2v[n2gn[pr.b][j]].a;
                        }
                    }
                }
            }
        }
    }
}
