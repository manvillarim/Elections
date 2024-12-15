// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

contract Election{

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event StartElection(uint256 time, address owner);
    event Vote(address voter, address candidate);
    event AddCandidate(address candidate);
    event CloseElection(uint256 time);

    /*//////////////////////////////////////////////////////////////
                             ERRORS
    //////////////////////////////////////////////////////////////*/

    error VoterAlreadyVoted(address voter);
    error CandidateDoesntExist(address candidate);
    error NoCandidates();
    error CandidateIsAddressZero();
    error SenderIsAddressZero();
    error SenderIsNotOwner();
    error ElectionHasNotStarted();
    error ElectionAlreadyStarted();

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
    bool s_startElection;
    uint256 s_durationTime;
    uint256 s_endTime;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address[] memory candidates, uint256 time) {

        if (candidates.length <= 0) {
            revert NoCandidates();
        }

        if(msg.sender == address(0)) {
            revert SenderIsAddressZero();
        }

        s_owner = msg.sender;

        for (uint256 i = 0; i < candidates.length; i++) {
            if(candidates[i] == address(0)) {
                revert CandidateIsAddressZero();
            }
            s_isCandidate[candidates[i]] = true;
            s_candidateVotes[candidates[i]] = 0;
        }

        s_candidates = candidates;
        s_startElection = false;
        s_durationTime = time;
    }


    /*//////////////////////////////////////////////////////////////
                            MODIFIERS
    //////////////////////////////////////////////////////////////*/
    
    modifier safeCandidate(address candidate) {

        if (!s_isCandidate[candidate])
            revert CandidateDoesntExist(candidate);

        if(candidate == address(0))
            revert CandidateIsAddressZero();
        _;
    }

    modifier safeSender() {
        
        if(msg.sender == address(0))
            revert SenderIsAddressZero();
        _;

    }

    modifier onlyOwner() {
        if(msg.sender != s_owner)
            revert SenderIsNotOwner();
        _;
    }

    modifier onlyDuringElection() {

        if(block.timestamp >= s_endTime) {
            emit CloseElection(s_endTime);
            s_startElection = false;
        }

        if(!s_startElection) {
            revert ElectionHasNotStarted();
        }
        _;
    }

    modifier onlyBeforeElection() {
        if(s_startElection) {
            revert ElectionAlreadyStarted();
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                            ELECTION LOGIC
    //////////////////////////////////////////////////////////////*/

    function startElection() external onlyOwner onlyBeforeElection{

        s_endTime = block.timestamp + s_durationTime;
        s_startElection = true;

        emit StartElection(block.timestamp, s_owner);

    }

    function endElection() external onlyOwner {

        s_startElection = false;

        emit CloseElection(block.timestamp);
    }

    function vote(address candidate) external safeCandidate(candidate) safeSender onlyDuringElection {

        if (s_hasVoted[msg.sender]) {
            revert VoterAlreadyVoted(msg.sender);
        }

        s_hasVoted[msg.sender] = true;
        s_candidateVotes[candidate]++;

        emit Vote(msg.sender, candidate);

        updateWinner(candidate);
    }

    function addCandidate(address candidate) external onlyOwner onlyBeforeElection(){
        
        if(candidate == address(0)) {
            revert CandidateIsAddressZero();
        }
        
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

    function getTime() external view returns(uint256) {
        return block.timestamp;
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