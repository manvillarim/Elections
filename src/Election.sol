// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

contract Election {

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Vote(address voter, address candidate);

    /*//////////////////////////////////////////////////////////////
                             ERRORS
    //////////////////////////////////////////////////////////////*/

    error VoterAlreadyVoted(address voter);
    error CandidateDoesntExist(address candidate);
    error NoCandidates();
    error CandidateIsAddressZero();
    error SenderIsAddressZero();

    /*//////////////////////////////////////////////////////////////
                             STORAGE VARIABLES
    //////////////////////////////////////////////////////////////*/

    mapping(address => bool) private s_hasVoted;
    mapping(address => uint256) private s_candidateVotes;
    mapping(address => bool) private s_isCandidate;

    address[] public s_candidates;
    address private s_winner;
    uint256 private s_maxVotes;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address[] memory candidates) {

        if (candidates.length <= 0) {
            revert NoCandidates();
        }

        for (uint256 i = 0; i < candidates.length; i++) {
            if(candidates[i] == address(0)) {
                revert CandidateIsAddressZero();
            }
            s_isCandidate[candidates[i]] = true;
            s_candidateVotes[candidates[i]] = 0;
        }

        s_candidates = candidates;
    }

    /*//////////////////////////////////////////////////////////////
                            ELECTION LOGIC
    //////////////////////////////////////////////////////////////*/

    function vote(address candidate) external {

        if(msg.sender == address(0)) {
            revert SenderIsAddressZero();
        }

        if (s_hasVoted[msg.sender]) {
            revert VoterAlreadyVoted(msg.sender);
        }

        if (!s_isCandidate[candidate]) {
            revert CandidateDoesntExist(candidate);
        }

        s_hasVoted[msg.sender] = true;
        s_candidateVotes[candidate]++;

        emit Vote(msg.sender, candidate);

        updateWinner(candidate);
    }

    function updateWinner(address candidate) internal {

        if (s_candidateVotes[candidate] > s_maxVotes) { 
            s_maxVotes = s_candidateVotes[candidate];
            s_winner = candidate; 
        } 

    }

    function getResults() external view returns(address[] memory, uint256[] memory) {
        
        uint256[] memory votes = new uint256[](s_candidates.length);
        for (uint256 i = 0; i < s_candidates.length; i++) {
            votes[i] = s_candidateVotes[s_candidates[i]];
        }

        return (s_candidates, votes);
    }
    function getWinner() external view returns(address) {
        return s_winner;
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