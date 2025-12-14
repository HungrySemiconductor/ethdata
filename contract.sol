// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.4.25;

contract KeyValueStore {
    // 使用mapping实现键值存储
    mapping(string => uint256) private store;
    
    // 存储操作：set(key, value)
    function set(string memory key, uint256 value) public {
        store[key] = value;
    }
    
    // 查询操作：get(key) returns value
    function get(string memory key) public view returns (uint256) {
        return store[key];
    }
    
}