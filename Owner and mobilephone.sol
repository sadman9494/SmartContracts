// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

contract CarOwner {
    // this contract is for storing car and owner information
    // an owner can have more than one car
    //uint carId;
    uint uId;

    struct Car {
        string brandName;
        string vehicleType;
        string color;
    }

    struct UserInfo {
        string name;
        uint age;
    }

    struct ownerInfo{
        UserInfo Owner;
        Car[] ownedCar;
    }
    mapping(uint => UserInfo) public users;
    mapping(uint => Car[]) public userCars;

    UserInfo[] public allUsers;
    Car[] public allCars;

    function addUser( string memory name, uint age) public {
       uId++;
       UserInfo memory newuser = UserInfo(name, age);
       users[uId] = newuser;
       allUsers.push(newuser);
        
    }
    function addCar (uint id, string memory brand , string memory vType , string memory color) public 
    {
        userCars[id].push(Car(brand , vType,color));
        allCars.push(Car(brand , vType,color));
    }

    function getAllUsers () public view  returns (ownerInfo[] memory)
    {
        ownerInfo[] memory ownerinformation = new ownerInfo[](allUsers.length);
        for (uint i = 0 ; i< allUsers.length ; i++)
        {
             ownerinformation[i] =ownerInfo(allUsers[i], userCars[i]);
        }
        return  ownerinformation;
    }

}
