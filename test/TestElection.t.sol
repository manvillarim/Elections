//SPDX-License-Identifier:MIT

pragma solidity >= 0.8.0;

import {Test} from "forge-std/Test.sol";
import {Election} from "../src/Election.sol";

contract TestVotation is Test{
    
    Election election;

    address candidate1 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address candidate2 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address candidate3 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
    address candidate4 = 0x90F79bf6EB2c4f870365E785982E1f101E93b906;
    address candidate5 = 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65;
    address candidate6 = 0x976EA74026E726554dB657fA54763abd0C3a0aa9;

    address[] candidates = [candidate1, candidate2, candidate3, candidate4, candidate5, candidate6];

    address owner = 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720;

    function setUp() public {
        election = new Election(candidates, owner);
    }

    // Proves Vote
    function proveVote(address candidate, address voter) public {
        bool isCandidate = election.getIsCandidate(candidate);
        bool hasVoted = election.getHasVoted(voter);
        require(isCandidate);
        require(!hasVoted);
        require(voter != address(0));
        uint256 oldVotes = election.getVotes(candidate);
        vm.prank(voter);
        election.vote(candidate);
        assertEq(oldVotes + 1, election.getVotes(candidate));
    }

    function proveWinner(address candidate, address voter) public {
        bool isCandidate = election.getIsCandidate(candidate);
        bool hasVoted = election.getHasVoted(voter);
        require(isCandidate);
        require(!hasVoted);
        require(voter != address(0));
        vm.prank(voter);
        election.vote(candidate);
        assertEq(candidate, election.getWinner());
    }

    function testAdd(address candidate) public{
        vm.assume(candidate != address(0));
        vm.prank(0xa0Ee7A142d267C1f36714E4a8F75612F20a79720);
        election.addCandidate(candidate);
        election.vote(candidate);
        assertEq(candidate, election.getWinner());
    }

}