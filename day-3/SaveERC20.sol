// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract SaveERC20 {

    string userToken;
    string userSymbol;
    uint256 userTokenTotalSupply;
    address user;


    constructor(string memory _token, string memory _symbol, uint256 _tokenTotalSupply) {
        userToken = _token;
        userSymbol = _symbol;
        userTokenTotalSupply = _tokenTotalSupply;
        user = msg.sender;

        balances[msg.sender] = _tokenTotalSupply;
        
    }

    function balanceOf(address _user) public view returns (uint256) {
        return balances[_user];     
    }


    mapping (address => uint256) balances;

    event DepositSuccessful(address indexed _to, uint256 _userToken);

    function deposit(address _to, uint256 _userToken) external payable {
        require(msg.sender != address(0), "Address zero detected"); // To check that a zero address doesn't intract with our contract

        require (_to != address(0), "Address zero detected");
        
        require(msg.value > 0, "Can't deposit zero value"); // To check that the address intracting with the function doesn't send any amount less than zero
        
        balances[msg.sender] = balances[msg.sender] - _userToken; 

        emit DepositSuccessful(msg.sender, _userToken);
    }

    event WithdrawSuccessful(address indexed reciever, uint indexed amount, bytes data);

    function withdraw(uint256 _userToken) external payable {
        require(msg.sender != address(0), "Address zero detected");
        
        require(msg.value > 0, "Can't withdraw zero value");

        uint256 userSavings_ = balances[msg.sender];

        require(userSavings_ > 0, "Insufficient funds");

        balances[msg.sender] = userSavings_ - _userToken;

        (bool result, bytes memory data) = payable(msg.sender).call{value: _userToken}("");

        require(result, "transfer failed");

        emit  WithdrawSuccessful(msg.sender, _userToken, data);
    }
}