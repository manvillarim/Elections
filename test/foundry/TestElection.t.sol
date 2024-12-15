// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/Election.sol";

contract ElectionTest is Test {

    Election private election;
    address[] private candidates;

    address private owner = address(0xABCD);
    address private voter1 = address(0x1111);
    address private voter2 = address(0x2222);
    address private invalidAddress = address(0);
    address private candidate1 = address(0x1234);
    address private candidate2 = address(0x5678);

    function setUp() public {
        vm.startPrank(owner);

        candidates.push(candidate1);
        candidates.push(candidate2);

        election = new Election(candidates, 3600);
        vm.stopPrank();
    }

    function testStartElection() public {
        vm.prank(owner);
        election.startElection();

        (address[] memory candidatesList, uint256[] memory votes) = election.getResults();
        assertEq(candidatesList.length, 2);
        assertEq(votes[0], 0);
    }

    function testVoteWithValidCandidate(address voter, uint8 candidateIndex) public {
        vm.assume(voter != invalidAddress);
        vm.assume(candidateIndex < candidates.length);

        vm.prank(owner);
        election.startElection();

        vm.prank(voter);
        election.vote(candidates[candidateIndex]);

        uint256 votes = election.getVotes(candidates[candidateIndex]);
        assertEq(votes, 1);
    }

    function testCannotVoteTwice() public {
        vm.prank(owner);
        election.startElection();

        vm.prank(voter1);
        election.vote(candidate1);

        vm.expectRevert(abi.encodeWithSelector(Election.VoterAlreadyVoted.selector, voter1));
        vm.prank(voter1);
        election.vote(candidate1);
    }

    function testCannotVoteForInvalidCandidate() public {
        vm.prank(owner);
        election.startElection();

        vm.expectRevert(abi.encodeWithSelector(Election.CandidateDoesntExist.selector, invalidAddress));
        vm.prank(voter1);
        election.vote(invalidAddress);
    }

    function testOnlyOwnerCanStartElection() public {
        vm.expectRevert(abi.encodeWithSelector(Election.SenderIsNotOwner.selector));
        vm.prank(voter1);
        election.startElection();
    }

    function testMultipleVotes(address voterone, address votertwo, uint8 candidateIndex) public {
        vm.assume(voterone != invalidAddress && votertwo != invalidAddress);
        vm.assume(voterone != votertwo);
        vm.assume(candidateIndex < candidates.length);

        vm.prank(owner);
        election.startElection();

        vm.prank(voterone);
        election.vote(candidates[candidateIndex]);

        vm.prank(votertwo);
        election.vote(candidates[candidateIndex]);

        uint256 votes = election.getVotes(candidates[candidateIndex]);
        assertEq(votes, 2);
    }

    function testEndElection() public {
        vm.prank(owner);
        election.startElection();

        vm.prank(owner);
        election.endElection();

        vm.expectRevert(abi.encodeWithSelector(Election.ElectionHasNotStarted.selector));
        vm.prank(voter1);
        election.vote(candidate1);
    }
}
