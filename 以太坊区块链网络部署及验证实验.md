# 以太坊区块链网络部署及验证实验

**姓　　名**：范红乐  
**班　　级**：计算机学院20250718班  
**学　　号**：2025E8007382043

## 0. 实验目标

通过部署一个包含至少4个节点的以太坊私有区块链网络，掌握以太坊私链的搭建、节点间通信、挖矿机制以及智能合约的部署与调用方法，从而深入理解区块链网络的基本原理和操作流程

## 1. 环境搭建

- 基础系统：WSL2 搭载 Ubuntu 20.04.6 LTS

- 编译环境：Golang 1.19，为 Geth 客户端提供编译与运行支持
- 以太坊客户端：Geth 1.10.25，用于搭建和管理私有区块链网络

### 1.1. Go 1.19安装

1. **下载 Go (v1.19)**

   ```bash
   wget https://dl.google.com/go/go1.19.linux-amd64.tar.gz
   ```

2. **解压文件**

   ```bash
   sudo tar -C /usr/local -xzf go1.19.linux-amd64.tar.gz
   ```

3. **设置环境变量**

   ```bash
   echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.profile
   ```

4. **使更改生效**

   ```bash
   source ~/.profile
   ```

   ![image-20251210110152084](E:\Typora\Typora\coding-study\image-20251210110152084.png)

### 1.2. Geth 1.10.25 安装

1. **下载 Geth (v1.10.25)**

   ```bash
   wget https://gethstore.blob.core.windows.net/builds/geth-linux-amd64-1.10.25-69568c55.tar.gz
   ```

2. **解压文件**

   ```bash
   tar -xvzf geth-linux-amd64-1.10.25-69568c55.tar.gz
   ```

3. **移动 Geth 到可执行目录**

   ```bash
   sudo mv geth-linux-amd64-1.10.25-69568c55/geth /usr/local/bin/
   ```

   ![image-20251210115158396](E:\Typora\Typora\coding-study\image-20251210115158396.png)

## 2. 网络部署

### 2.1. 创世区块配置

- **自定义文件目录结构说明**

  ```bash
  /home/fanhl/ethdata/	# 实验文件夹
  ├── genesis.json		# 创世区块信息文件
  ├── node1/ 				# 节点1数据目录
  ├── node2/ 				# 节点2数据目录
  ├── node3/ 				# 节点3数据目录
  ├── node4/ 				# 节点4数据目录
  └── logs/ 				# 节点运行日志
  ```

- **添加创世区块配置文件**  `genesis.json`

  ```json
  {
      "config": {					
            "chainId": 1001,
            "homesteadBlock": 0,
            "eip150Block": 0,
            "eip155Block": 0,
            "eip158Block": 0
        },
      "coinbase"   : "0x0000000000000000000000000000000000000000",
      "difficulty" : "0x1111111",
      "extraData"  : "",
      "gasLimit"   : "0x2fefd8",
      "nonce"      : "0x0000000000000042",
      "mixhash"    : "0x0000000000000000000000000000000000000000000000000000000000000000",
      "parentHash" : "0x0000000000000000000000000000000000000000000000000000000000000000",
      "timestamp"  : "0x00",
      "alloc"      : {}
   }
  ```

  **# 创世区块配置文件字段说明 **

  | 字段             | 取值范围                               | 说明                                                         |
  | :--------------- | -------------------------------------- | :----------------------------------------------------------- |
  | `config`         | 对象类型                               | 区块链的网络配置和硬分叉规则                                 |
  | `chainId`        | 整数：1-65535                          | 链ID，用于区分不同以太坊网络（1:主网, 3:Ropsten, 4:Rinkeby, 5:Goerli, 1337:常见开发链, 其他:私有链） |
  | `homesteadBlock` | 整数：0-∞                              | 从第0个区块启用该硬分叉（0:立即启用, >0:在指定区块高度启用, null:禁用该分叉） |
  | `eip150Block`    | 整数：0-∞                              | 0:立即启用, 与homesteadBlock类似                             |
  | `eip155Block`    | 整数：0-∞                              | 0:立即启用, 通常与eip150Block设置相同                        |
  | `eip158Block`    | 整数：0-∞                              | 0:立即启用, 必须≥eip155Block                                 |
  | `conibase`       | 20字节地址                             | 创世区块的矿工地址（以太坊中称`beneficiary`），此处为零地址，因为创世区块无实际矿工 |
  | `difficulty`     | 十六进制字符串：0x1-0xFFFFFFFFFFFFFFFF | 初始挖矿难度。值较低便于私有链/测试网快速生成区块            |
  | `extraData`      | 十六进制字符串：0-64字符(0-32字节)     | 附加信息，可为任意数据（最长32字节）。此处为空，常用于标识矿工或添加备注 |
  | `gasLimit`       | 十六进制字符串：0x15F90-0xFFFFFFFF     | 每个区块的Gas上限，限制区块内交易的总计算量。此值约为以太坊主网初始值（500万）的60% |
  | `nonce`          | 十六进制字符串：0x0-0xFFFFFFFFFFFFFFFF | 与mixhash配合用于工作量证明（PoW）的随机数。创世区块中该值通常固定 |
  | `mixhash`        | 32字节哈希值(64字符)                   | PoW算法中与nonce共同生成区块哈希的哈希值。创世区块固定为零哈希 |
  | `parentHash`     | 32字节哈希值(64字符)                   | 父区块哈希。创世区块无父区块，故为零哈希                     |
  | `timestamp`      | 十六进制字符串：0x0-0xFFFFFFFF         | 创世区块生成时间戳（Unix时间戳）。0表示1970年1月1日，实际运行时会更新 |
  | `alloc`          | 对象或空对象{}                         | 预分配初始账户和余额。此处为空对象，表示无预挖代币           |

  ![image-20251211110836003](E:\Typora\Typora\coding-study\image-20251211110836003.png)

### 2.2. 启动私链

- **初始化以太坊4个节点的Geth客户端**

  ```bash
  # 当前目录 /home/fanhl/ethdata
  
  # node1
  geth --datadir ./node1 init ./genesis.json
  
  # node2
  geth --datadir ./node2 init ./genesis.json
  
  # node3
  geth --datadir ./node3 init ./genesis.json
  
  # node4
  geth --datadir ./node4 init ./genesis.json
  ```

  **# 以太坊节点初始化命令说明 #**

  | 参数               | 说明                                       |
  | ------------------ | ------------------------------------------ |
  | `geth`             | 可执行文件，Go Ethereum客户端的主程序      |
  | `--datadir ./node` | 数据目录参数，指定节点数据的存储位置       |
  | `init`             | 初始化命名，创建新区块链的初始化操作       |
  | `./genesis.json`   | 创世文件路径，定义区块链初始状态的配置文件 |

  ![image-20251211111629136](E:\Typora\Typora\coding-study\image-20251211111629136.png)

- **启动私链**

  ```bash
  # 当前目录 /home/fanhl/ethdata
  
  # node1 
  geth --datadir ./node1 --networkid 1001 --identity "node1" --port 30303 --http --http.port 8545 --nodiscover --verbosity 4 console 2> node1.log
  
  # node2
  geth --datadir ./node2 --networkid 1001 --identity "node2" --port 30304 --http --http.port 8546 --nodiscover --verbosity 4 console 2> node2.log

  # node3 
  geth --datadir ./node3 --networkid 1001 --identity "node3" --port 30305 --http --http.port 8547 --nodiscover --verbosity 4 console 2> node3.log
  
  # node4 
  geth --datadir ./node4 --networkid 1001 --identity "node4" --port 30306 --http --http.port 8548 --nodiscover --verbosity 4 console 2> node4.log
  ```
  
  **# 启动私链命令说明**
  
  | 参数                 | 说明                                                         |
  | -------------------- | ------------------------------------------------------------ |
  | `--datadir ./node`   | 指定存储节点数据的目录                                       |
  | `--network 1001`     | 设置私有网络的网络ID为1001，与配置文件中chainId一致，同一网络需相同 |
  | `--identity "node1"` | 设置节点名称                                                 |
  | `--port 30303`       | 设置节点间通信端口，默认为以太坊P2P端口                      |
  | `--http`             | 开启HHTP-RPC接口，通过HTTP请求与节点交互                     |
  | `--nodiscover`       | 禁用自动发现节点，使节点不主动发现其他节点，适用于私有网络   |
  | `--verbosity 4`      | 设置日志详细级别为4，提供较详细的日志输出                    |
  | `console`            | 打开Geth的 JavaScript 控制台，允许节点交互                   |
  | `2 > node.log`       | 将错误日志输出到文件                                         |
  
  ![image-20251211152244400](E:\Typora\Typora\coding-study\image-20251211152244400.png)

- **另开终端监听 log**

  ```bash
  # 实时查看 node1.log 文件内容
  tail -f node1.log
  ```

  ![image-20251211153826652](E:\Typora\Typora\coding-study\image-20251211153826652.png)

### 2.3 多节点交互

- 链内创建账户
- 创建多个