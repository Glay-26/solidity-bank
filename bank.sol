// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// IBank 接口定义
interface IBank {
    function deposit() external payable;
    function withdraw() external;
}

// Bank 合约实现 IBank 接口
contract Bank is IBank {
    address public admin; // 管理员地址
    mapping(address => uint256) public balances; // 记录每个地址的存款金额
    address[3] public top3Users; // 记录存款金额前 3 名的地址

    // 构造函数：部署合约的人自动成为管理员
    constructor() {
        admin = msg.sender;
    }

    // 存款函数：外部账户通过 MetaMask 调用并发送 ETH
    function deposit() public payable virtual override {
        require(msg.value > 0, "Deposit amount must be greater than 0");

        // 1. 增加当前用户的余额记录
        balances[msg.sender] += msg.value;

        // 2. 更新前 3 名排名
        _updateTop3(msg.sender);
    }

    // 内部函数：维护前 3 名排名逻辑
    function _updateTop3(address _user) internal {
        // 如果用户已经在前 3 名中，先不处理，等统一排序
        // 这里采用简单的冒泡插入排序思想
        for (uint i = 0; i < 3; i++) {
            // 如果当前用户已经在榜上，或者比榜上某人钱多
            if (_user == top3Users[i]) {
                _sortTop3();
                return;
            }
        }

        // 如果用户不在榜上，但余额比第 3 名（数组末尾）多
        if (balances[_user] > balances[top3Users[2]]) {
            top3Users[2] = _user; // 先替换第 3 名
            _sortTop3(); // 重新排序
        }
    }

    // 简单的排序逻辑
    function _sortTop3() internal {
        for (uint i = 0; i < 2; i++) {
            for (uint j = 0; j < 2 - i; j++) {
                if (balances[top3Users[j]] < balances[top3Users[j + 1]]) {
                    address temp = top3Users[j];
                    top3Users[j] = top3Users[j + 1];
                    top3Users[j + 1] = temp;
                }
            }
        }
    }

    // 提款函数：仅限管理员提取所有 ETH
    function withdraw() public virtual override {
        require(msg.sender == admin, "Only admin can withdraw");

        uint256 amount = address(this).balance;
        require(amount > 0, "No ETH to withdraw");

        // 使用 call 代替 transfer
        (bool success, ) = payable(admin).call{value: amount}("");

        // 如果转账不成功，直接报错回滚
        require(success, "ETH Transfer Failed");
    }
}

// BigBank 合约继承 Bank
contract BigBank is Bank {
    // modifier：限制最小存款金额必须大于 0.001 ether
    modifier minDeposit() {
        require(msg.value > 0.001 ether, "Deposit must be greater than 0.001 ether");
        _;
    }

    // 重写 deposit 函数，添加 minDeposit modifier
    function deposit() public payable override minDeposit {
        balances[msg.sender] += msg.value;
        _updateTop3(msg.sender);
    }

    // 转移管理员功能
    function transferAdmin(address newAdmin) public {
        require(msg.sender == admin, "Only current admin can transfer");
        require(newAdmin != address(0), "Invalid new admin address");
        admin = newAdmin;
    }
}

// Admin 合约
contract Admin {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // 只有 owner 可以调用的 modifier
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // 提取 bank 合约的资金到 Admin 合约地址
    function adminWithdraw(IBank bank) public onlyOwner {
        bank.withdraw();
    }

    // Admin 合约需要能接收 ETH
    receive() external payable {}

    // 查询 Admin 合约余额
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
