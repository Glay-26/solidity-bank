Bank 合约实现了以下功能
• 通过 Metamask 向 Bank 合约存款（转账ETH）
• 在 Bank 合约记录每个地址存款金额
• 用数组记录存款金额前 3 名
• 编写 Bank 合约 withdraw(), 实现只有管理员提取出所有的 ETH
部署在测试网上，合约地址为：0x6Fce66C08Ec63dF5bA2a8B152EA28439923c777A

在remix进行合约部署和函数调用的测试过程：
部署：
1.先选择bigbank合约并部署
2.选择admin合约并部署
测试：
1.deposit先转入0.1eth
2.查看存款金额（应该是0.1eth）
3.查看admin是部署合约的钱包地址
4.复制admin合约地址，调用bigbank合约的transferAdmin函数并填入admin合约地址
5.在bigbank合约中调用admin函数，call之后显示的应该就是admin合约的地址
6.在admin合约中调用adminWithdraw函数，并填入bigbank的合约地址，点击Transact
7.点击admin合约的getBalance函数，可以查看余额应该是0.1th
8.点击admin合约中的withdrawToOwner函数，点击Transact之后就看到部署合约的地址的余额增加了
