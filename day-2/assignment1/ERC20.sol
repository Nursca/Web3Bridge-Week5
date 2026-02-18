// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract ERC20 {
    string tokenName;
    string tokenSymbol;
    uint256 tokenTotalSupply;
    address owner;

    constructor(string memory _name, string memory _symbol, uint256 _tokenTotalSupply) {
        tokenName = _name;
        tokenSymbol = _symbol;
        tokenTotalSupply = _tokenTotalSupply;
        owner = msg.sender;

        balance[msg.sender] = _tokenTotalSupply;
        emit Transfer(address(0), msg.sender, _tokenTotalSupply);
    }

    mapping (address => uint256) balance;
    mapping (address => mapping(address => uint256)) tokenAllowance;

    function name() public view returns (string memory) {
        return tokenName;  
    }

    function symbol() public view returns (string memory) {
        return tokenSymbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view returns (uint256) {
        return tokenTotalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balance[_owner];     
    }

    event Transfer (address indexed to, address indexed onwer, uint256 value);

    function transfer(address _to, uint256 _value) public returns (bool) {
        require (balance [msg.sender] >= _value, "Insufficient Funds");

        require (_to != address(0), "Address zero detected");

        balance[msg.sender] = balance[msg.sender] - _value;
        balance[_to] = balance[_to] + _value;

        emit Transfer(_to, msg.sender, _value);

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(balance [_from] >= _value, "Insufficient Funds");

        require(_value <= tokenAllowance[_from][msg.sender], "Funds not approved");

        require(_from != address(0) && _to != address(0), "Address zero dectected");

        tokenAllowance[_from][msg.sender] =  tokenAllowance[_from][msg.sender] - _value;

        balance[_from] = balance[_from] - _value;
        balance[_to] = balance[_to] + _value;

        emit Transfer(_from, _to, _value);

        return true;
    }

    event Approval(address indexed owner, address indexed spender, uint256 value);


    function approve(address _spender, uint256 _value) public returns(bool) {
        require(_spender != address(0), "Address zero detected");

        require(_value == 0 || tokenAllowance[msg.sender][_spender] == 0, "tokenAllowance must reset to 0 first");

        tokenAllowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return tokenAllowance[_owner][_spender];
    }
}