// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint256 private seed;

    mapping(address => uint256) public addressToWaveTimes;
    mapping(address => uint256) public lastWavedAt;

    event NewWave(address indexed from, uint256 timestamp, string message);

    struct Wave {
        address waver; // The address of the user who waved.
        string message; // The message the user sent.
        uint256 timestamp; // The timestamp when the user waved.
    }

    Wave[] waves;
    constructor() payable {
        console.log("Yo yo, I am a contract and I am smart");
    }

    function wave(string memory _message) public {
        require(
            lastWavedAt[msg.sender] + 30 seconds < block.timestamp,
            "Wait 30 seconds"
        );
        lastWavedAt[msg.sender] = block.timestamp;

        addressToWaveTimes[msg.sender] += 1;
        console.log("%s has waved %d times", msg.sender, addressToWaveTimes[msg.sender]);

        waves.push(Wave(msg.sender, _message, block.timestamp));

        /*
         * Generate a Psuedo random number between 0 and 100
         */
        uint256 randomNumber = (block.difficulty + block.timestamp + seed) % 100;
        console.log("Random # generated: %s", randomNumber);

        /*
         * Set the generated, random number as the seed for the next wave
         */
        seed = randomNumber;

        /*
         * Give a 50% chance that the user wins the prize.
         */
        if (randomNumber < 50) {
            console.log("%s won!", msg.sender);
            emit NewWave(msg.sender, block.timestamp, _message);

            uint256 prizeAmount = 0.01 ether;
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        }

        emit NewWave(msg.sender, block.timestamp, _message);
    }

    /*
     * I added a function getAllWaves which will return the struct array, waves, to us.
     * This will make it easy to retrieve the waves from our website!
     */
    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getUserWaveTimes() public view returns (uint256) {
        console.log("We have %d wave times!", addressToWaveTimes[msg.sender]);

        return addressToWaveTimes[msg.sender];
    }

    function getFullInfo() public view returns (Wave[] memory, uint256) {
        return (
            getAllWaves(),
            getUserWaveTimes()
        );
    }
}

