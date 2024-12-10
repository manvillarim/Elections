// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

contract Election {

    error Have__Voted(address voter);
    error Candidate__Doesnt__Exist(address candidate);
    error No__Candidates();
    error None__Address();

    mapping(address => bool) private s_hasVoted;
    mapping(address => uint256) private s_candidateVotes;
    mapping(address => bool) private s_isCandidate;

    event Vote(address voter, address candidate);

    address[] public s_candidates;

    constructor(address[] memory candidates) {

        if (candidates.length <= 0) {
            revert No__Candidates();
        }

        for (uint256 i = 0; i < candidates.length; i++) {
            if(candidates[i] == address(0)) {
                revert None__Address();
            }
            s_isCandidate[candidates[i]] = true;
            s_candidateVotes[candidates[i]] = 0;
        }

        s_candidates = candidates;
    }

    function vote(address candidate) external {

        if(msg.sender == address(0)) {
            revert None__Address();
        }

        if (s_hasVoted[msg.sender]) {
            revert Have__Voted(msg.sender);
        }

        if (!s_isCandidate[candidate]) {
            revert Candidate__Doesnt__Exist(candidate);
        }

        s_hasVoted[msg.sender] = true;
        s_candidateVotes[candidate]++;

        emit Vote(msg.sender, candidate);
    }

    function checkWinner() external view returns(address) {

        address winner;
        uint256 maxVotes = 0;
        for (uint256 i = 0; i < s_candidates.length; i++) {
            uint256 currentVotes = s_candidateVotes[s_candidates[i]];
            if (currentVotes > maxVotes) {
                maxVotes = currentVotes;
                winner = s_candidates[i];
            }
        }

        return winner;
    }

    function getIsCandidate(address candidate) external view returns(bool) {
        return s_isCandidate[candidate];
    }

    function getHasVoted(address voter) external view returns(bool) {
        return s_hasVoted[voter];
    }

    function getVotes(address candidate) external view returns(uint256) {
        return s_candidateVotes[candidate];
    }
}