// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.3;

interface IREC20 {
    function transfer(address _to, uint256 _value) external returns (bool success);
    function balanceOf(address _onwer) external view returns (uint256);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    
}

contract NexusSchools {
    IREC20 public paymentToken;

    address owner;

    mapping (uint256 => uint256) public studentLevel;

    uint256 private constant SALARY = 10000e18;

    constructor(address _tokenAddress) {
        studentLevel[100] = 1000e18;
        studentLevel[200] = 2000e18;
        studentLevel[300] = 3000e18;
        studentLevel[400] = 4000e18;

        paymentToken = IREC20(_tokenAddress);

        owner = msg.sender;
    }

    struct Student {
        string name;
        uint256 id;
        uint256 level;
        bool hasPaid;
        uint256 paidAt;
    }
    struct Staff {
        string name;
        uint256 id;
        address account;
    }

    Student[] public students;
    Staff[] public staffs;
    
    uint256 studentId;
    uint256 staffId;

    function addStaff(string memory _name, address _account) external onlyOwner {
        staffId = staffId + 1;

        require(_account != address(0), "Address zero detected");
        Staff memory newStaff = Staff({id: staffId,  name: _name, account: _account});
        staffs.push(newStaff); 
        
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Not Owner");
        _;
    }

    function addStudent(string memory _name, uint256 _level) external {
        studentId = studentId + 1;
        require(_level == 100 || _level == 200 || _level == 300 || _level == 400, "Student level must be 100, 200, 300, or 400");

        uint256 fee = studentLevel[_level];
        require(fee > 0, "Incorect fee amount");

        bool success = paymentToken.transferFrom(msg.sender, address(this), fee);
        require (success, "Fee payment failed");

        Student memory newStudent = Student({id: studentId, name: _name, level: _level, hasPaid: true, paidAt: block.timestamp});
        students.push(newStudent);
    }

    function payStaff(uint256 _id) external onlyOwner{
        address staffAccount;
        for(uint256 i = 0; i < staffs.length; i++) {
            if(staffs[i].id == _id){
                require(staffs[i].account != address(0), "Invalid Staff");
                staffAccount = staffs[i].account;

            }
        }
        require(staffAccount != address(0), "Staff not found");
        require(paymentToken.balanceOf(address(this)) >= SALARY,"Insufficient Funds");

        paymentToken.transfer(staffAccount, SALARY);
    }

    function getAllStaff(uint256) external view returns(Staff[] memory) {
        return staffs;
        
    }

    function getStudent(uint256 _id) external view returns (Student memory) {
        for (uint256 i = 0; i < students.length; i++) {
            if (students[i].id == _id) {
                return students[i];
            }
        }
        revert("Student not found");
    }

    function getAllStudent() external view returns (Student[] memory) {
        return students;        
    }

}