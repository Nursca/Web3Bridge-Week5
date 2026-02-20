// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value) external returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    function approve(address _spender, uint256 _value) external returns (bool success);

    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
}

contract Vault {
    IERC20 public token_address;

    constructor(address _tokenAddress) {
        token_address = IERC20(_tokenAddress);
    }

    mapping(address => uint256) public balances;

    mapping (address => uint256) erc20SavingsBalance;

    event DepositSuccessful(address indexed sender, uint indexed amount);

    event WithdrawSuccessful(address indexed reciever, uint indexed amount, bytes data);

    function deposit() external payable {
        require(msg.sender != address(0), "Address zero detected"); // To check that a zero address doesn't intract with our contract
        
        require(msg.value > 0, "Can't deposit zero value"); // To check that the address intracting with the function doesn't send any amount less than zero
        
        balances[msg.sender] = balances[msg.sender] + msg.value; 

        emit DepositSuccessful(msg.sender, msg.value);
    }

    function depositERC20 (uint256 _amount) external {

        require(_amount > 0, "can't send zero value");

        require(IERC20(token_address).balanceOf(msg.sender) >= _amount, "Insufficient funds");

        erc20SavingsBalance[msg.sender] = erc20SavingsBalance[msg.sender] + _amount;

        require(IERC20(token_address).transferFrom(msg.sender, address(this), _amount), "transfer failed");

        emit DepositSuccessful(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) external payable {
        require(msg.sender != address(0), "Address zero detected");
        
        require(msg.value > 0, "Can't withdraw zero value");

        uint256 userSavings_ = balances[msg.sender];

        require(userSavings_ > 0, "Insufficient funds");

        balances[msg.sender] = userSavings_ - _amount;

        (bool result, bytes memory data) = payable(msg.sender).call{value: _amount}("");

        require(result, "transfer failed");

        emit  WithdrawSuccessful(msg.sender, _amount, data);
    }

    function withdrawERC20(uint256 _amount) external {
        require (_amount > 0, "Can't send zero value");

        require(erc20SavingsBalance[msg.sender] >= _amount, "Not enough savings");

        erc20SavingsBalance[msg.sender] = erc20SavingsBalance[msg.sender] - _amount;

        require (IERC20(token_address).transfer(msg.sender, _amount), "transfer failed");

        emit WithdrawSuccessful(msg.sender, _amount, "");
        
    }

    function getUserSavings() external view returns (uint256) {
        return balances[msg.sender];
    }

    function getERC20SavingsBalance() external view returns (uint256) {
        return erc20SavingsBalance[msg.sender];
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}