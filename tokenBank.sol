// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev ERC20 接口定义，用于 TokenBank 与 Token 合约交互
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

/**
 * @title TokenBank 合约
 * @dev 实现 Token 的存入和提取功能
 */
contract TokenBank {
    // 指向要操作的 Token 合约地址
    IERC20 public immutable token;
    
    // 记录每个地址存入的 Token 数量
    mapping(address => uint256) public balances;

    // 构造函数，在部署时传入你要存取的那个 Token 的地址
    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
    }

    /**
     * @dev 存款函数
     * @param _amount 要存入的数量
     * 注意：调用此函数前，用户必须先在 Token 合约中调用 approve(TokenBank地址, _amount)
     */
    function deposit(uint256 _amount) public {
        require(_amount > 0, "Deposit amount must be greater than 0");

        // 使用 transferFrom 将 Token 从用户的钱包转移到本合约
        // 这一步需要用户预先授权（approve）
        bool success = token.transferFrom(msg.sender, address(this), _amount);
        require(success, "Token transfer failed");

        // 记录余额
        balances[msg.sender] += _amount;
    }

    /**
     * @dev 提款函数
     * @param _amount 要提取的数量
     */
    function withdraw(uint256 _amount) public {
        require(_amount > 0, "Withdraw amount must be greater than 0");
        require(balances[msg.sender] >= _amount, "Insufficient balance");

        // 先更新余额（遵循 Checks-Effects-Interactions 原则，防重入）
        balances[msg.sender] -= _amount;

        // 将 Token 从本合约转回用户钱包
        bool success = token.transfer(msg.sender, _amount);
        require(success, "Token transfer failed");
    }
}

/**
 * @dev 这是一个用来测试的简单 Token 合约
 */
contract BaseToken is IERC20 {
    string public name = "Test Token";
    string public symbol = "TTK";
    uint8 public decimals = 18;
    uint256 public override totalSupply;
    
    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    constructor(uint256 initialSupply) {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Balance insufficient");
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(balanceOf[sender] >= amount, "Balance insufficient");
        require(allowance[sender][msg.sender] >= amount, "Allowance insufficient");
        
        balanceOf[sender] -= amount;
        allowance[sender][msg.sender] -= amount;
        balanceOf[recipient] += amount;
        return true;
    }
}