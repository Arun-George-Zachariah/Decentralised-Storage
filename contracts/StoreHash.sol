// Defining solidity version.
pragma solidity ^0.5.3;

contract SimpleStorage {
    // Declaring a state variable called storedData of type uint (unsigned integer of 256 bits)
    string storedData;

    function set(string memory x) public {
        storedData = x;
    }

    function get() public view returns (string memory) {
        return storedData;
    }
}