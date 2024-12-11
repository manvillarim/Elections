// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

contract Election{

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Vote(address voter, address candidate);
    event AddCandidate(address candidate);

    /*//////////////////////////////////////////////////////////////
                             ERRORS
    //////////////////////////////////////////////////////////////*/

    error VoterAlreadyVoted(address voter);
    error CandidateDoesntExist(address candidate);
    error NoCandidates();
    error CandidateIsAddressZero();
    error SenderIsAddressZero();
    error SenderIsNotOwner();

    /*//////////////////////////////////////////////////////////////
                             STORAGE VARIABLES
    //////////////////////////////////////////////////////////////*/

    mapping(address => bool) private s_hasVoted;
    mapping(address => uint256) private s_candidateVotes;
    mapping(address => bool) private s_isCandidate;

    address[] public s_candidates;
    address private s_winner;
    address private s_owner;
    uint256 private s_maxVotes;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address[] memory candidates, address owner) {

        if (candidates.length <= 0) {
            revert NoCandidates();
        }

        if(owner == address(0)) {
            revert SenderIsAddressZero();
        }

        s_owner = owner;

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
                            MODIFIERS
    //////////////////////////////////////////////////////////////*/
    
    modifier safeCandidate(address candidate) {

        if (!s_isCandidate[candidate]) {
            revert CandidateDoesntExist(candidate);
        }

        if(candidate == address(0)) {
            revert CandidateIsAddressZero();
        }
        _;
    }

    modifier safeSender() {
        
        if(msg.sender == address(0)) {
            revert SenderIsAddressZero();
        }
        _;

    }

    modifier onlyOwner() {
        if(msg.sender != s_owner) {
            revert SenderIsNotOwner();
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                            ELECTION LOGIC
    //////////////////////////////////////////////////////////////*/

    function vote(address candidate) external safeCandidate(candidate) safeSender() {

        if (s_hasVoted[msg.sender]) {
            revert VoterAlreadyVoted(msg.sender);
        }

        s_hasVoted[msg.sender] = true;
        s_candidateVotes[candidate]++;

        emit Vote(msg.sender, candidate);

        updateWinner(candidate);
    }

    function addCandidate(address candidate) external safeCandidate(candidate) onlyOwner{
        s_isCandidate[candidate] = true;
        s_candidateVotes[candidate] = 0;
        s_candidates.push(candidate);

        emit AddCandidate(candidate);
    }

    /*//////////////////////////////////////////////////////////////
                            GETTERS
    //////////////////////////////////////////////////////////////*/

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

    /*//////////////////////////////////////////////////////////////
                            INTERNAL LOGIC
    //////////////////////////////////////////////////////////////*/

    function updateWinner(address candidate) internal {

        if (s_candidateVotes[candidate] > s_maxVotes) { 
            s_maxVotes = s_candidateVotes[candidate];
            s_winner = candidate; 
        } 

    }
}