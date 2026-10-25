# Clash Tun in Linux

此脚本为了解决Clash透明代理，也就是Tun模式在Linux端的配置，以达到全局代理的功能。

### 安装步骤
1. 安装依赖 **git**, **nftables**, **iproute2**
不同发行版安装方式不同，通过包管理非常容易安装，不再赘述。
检查是否安装成功
```bash
$ git --version
git version 2.36.1

$ ip -V                                                                                                                                            ✔ 
ip utility, iproute2-5.17.0, libbpf 0.7.0

$ nft --version                                                                                                                                    ✔ 
nftables v1.0.2 (Lester Gooch)
```

2. 克隆此项目
```bash
$ git clone https://github.com/blue7wings/clash-tun
$ cd clash-tun
```

3. 配置设置
```bash
$ sudo mkdir /srv/clash/
$ sudo mv config.yaml Country.mmdb /srv/clash/

```
~~$ sudo mv clash /usr/bin/~~
因为
```
/bin/clash
Failed to execute operation: No such file or directory
Install successfully
```
不需要下载clash，只需保证centos7 服务器能上百度就行~
最后用clash -v即可验证版本

4. 开始安装
```bash
$ sudo ./installer.sh install
```

5. 启动
安装完成之后，启动clash
```bash
$ sudo systemctl start clash
```
6. 查看clash服务状态
```bash
$ sudo systemctl status clash
```
如果状态是active，就说明我们就已经成功设置了Clash的Tun模式，所有流量都会经过Clash，从而达到了全局代理的功能。

### 系统 DNS 未被接管时

部分 Clash Premium 配置会先创建名为 `master` 的网卡，再将其改名为 `utun`。
此时 udev 收到的是 `master` 的 `add` 事件和 `utun` 的 `move` 事件。
如果仅匹配 `utun` 的 `add` 事件，`setup-tun.sh` 就不会执行，DNS 重定向规则也不会创建。
本项目的 udev 规则同时匹配 `add` 和 `move`，并在 `remove` 时清理规则。

已安装的机器可以只更新 udev 规则，无需重新运行安装器或修改 Clash 的 `config.yaml`。
在本项目目录下执行以下命令；重启期间代理连接会短暂中断：

```bash
sudo install -m 0644 scripts/99-clash.rules /etc/udev/rules.d/99-clash.rules
sudo udevadm control --reload-rules
sudo systemctl restart clash
```

如果系统使用 systemd-resolved，再清除旧 DNS 缓存：

```bash
sudo resolvectl flush-caches
```

检查规则是否生成，并验证实际访问：

```bash
sudo nft list table ip clash
curl -I --max-time 20 https://www.google.com.hk
```
