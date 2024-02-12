// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

contract CarOwner {
    // this contract is for storing car and owner information
    // an owner can have more than one car
    mapping(uint => UserInfo) public users;
    mapping(uint => Car[]) public userCars;

    struct Car {
        string brandName;
        string vehicleType;
        string color;
    }

    struct UserInfo {
        string name;
        uint age;
    }

    function addUser(uint id, string memory name, uint age) public {
        UserInfo storage existingUser = users[id];

        // Check if the user already exists
        require(bytes(existingUser.name).length == 0, "User already exists");

        UserInfo memory newUser = UserInfo(name, age);
        users[id] = newUser;
    }

    function addCar(string memory brand, string memory vType, string memory color, uint id) public {
        Car memory newCar = Car(brand, vType, color);
        userCars[id].push(newCar);
    }

    function getAllUserInfo(uint id) public view returns (UserInfo memory) {
        // Return the UserInfo for a specific user id
        return users[id];
    }
}
