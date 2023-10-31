---
title: 逐渐停用 apt-key
date: 2023-10-29
slug: phasing-out-apt-key
author: HtwoO
categories:
    - 技术
tags:
    - Debian
    - 数字签名
---

## Debian 官方建议逐渐停用 `apt-key`
为确保软件仓库（软件源）分发内容的完整性， Debian 系统的开发者会使用[数字签名](https://zh.wikipedia.org/wiki/%E6%95%B8%E4%BD%8D%E7%B0%BD%E7%AB%A0)技术给仓库里的一些数据做签名。 Debian 9.x 和更早的版本，一般会用 `apt-key` 处理下载的验证公钥，不过好像是从 Debian 10.x 开始，运行 `apt-key` 时，时不时会看到下面这一行警告信息：
```
Warning: apt-key is deprecated. Manage keyring files in trusted.gpg.d instead (see apt-key(8)).
```
上面这句大概意识是「 apt-key 即将要被停用，请使用 trustred.gpg.d 管理密钥」。查了一下， Debian 官方缺陷跟踪系统里关于停用 `apt-key` 的讨论发布于 2017 年，但是很多教程仍然写的还是旧的使用 `apt-key` 的方法。

## 替代方法
有些教程以及我自己以前曾经直接把验证用的公钥直接放在 `/etc/apt/trusted.gpg.d/` ，后来意识到那样不太好，后来我就创建了一个 `/etc/apt/keyring/` 目录，用来放第三方软件源的验证公钥。

### 下载验证用公钥
下载第三方软件源的验证公钥，可以使用 `wget` 或者 `curl` ，两个命令行下载工具，在各个 Linux 发行版都很容易安装。要注意的是，如果分发者提供的公钥是纯文本编码的格式，保存的文件后缀名应该使用 `.asc` ，如果分发者提供的是二进制文件格式，需要使用 [GnuPG](https://www.gnupg.org/) 二进制文件惯用的 `.gpg` 后缀名，放到指定的目录。

``` shell
$ sudo mkdir /etc/apt/keyring
$ sudo wget --output-document=/etc/apt/keyring/file.gpg https://x.y.z/file.gpg
```

### 配置软件源
验证用公钥下载回来后，在软件仓库的 `.list` 文件里配成类似下面这样，就是添加 `[signed-by=/etc/apt/keyring/file.gpg]` 段，这里的文件路径要和上文下载的路径一样：
```
deb [signed-by=/etc/apt/keyring/file.gpg] https://deb...
deb-src [signed-by=/etc/apt/keyring/file.gpg] https://deb...
```

## Google Linux 软件仓库示例
Google 的 Linux 软件源配置指南在 https://www.google.com/linuxrepositories/ ，可以用下面命令下载公钥的内容到终端输出查看仓库的验证公钥内容：
``` shell
$ curl --location --show-error --silent https://dl.google.com/linux/linux_signing_key.pub
-----BEGIN PGP PUBLIC KEY BLOCK-----
.
-----END PGP PUBLIC KEY BLOCK-----
```

上面的数据是典型的[隐私增强邮件 Privacy-Enhanced Mail (PEM)](https://en.wikipedia.org/wiki/Privacy-Enhanced_Mail) 格式的数据，是编码成[纯文本](https://zh.wikipedia.org/wiki/%E6%96%87%E6%9C%AC%E6%96%87%E4%BB%B6)的数据，所以我们可以像下面一样把数据下载并原样保存成 `.asc` 文件：

``` shell
$ sudo mkdir /etc/apt/keyring
$ sudo curl --location --output /etc/apt/keyring/google.asc --show-error --silent https://dl.google.com/linux/linux_signing_key.pub
```

然后配置软件源配置文件指向下载的文件路径，以下是我一个 Debian 系统上 `/etc/apt/sources.list.d/google.list` 文件的内容，某个包的路径是从其他来源看到的，不知道 Google 的软件源里都还有哪些软件支持直接用 Linux 包管理器安装：
```
deb [signed-by=/etc/apt/keyring/google.asc] https://dl.google.com/linux/chrome/deb/ stable main
deb [signed-by=/etc/apt/keyring/google.asc] https://dl.google.com/linux/earth/deb/ stable main
```
可以用下面命令验证如果签名文件没生效的话， `apt update` 时会报什么警告或错误。
``` shell
$ sudo mv /etc/apt/keyring/google.asc{,.unused}
$ sudo apt update
.
Err:1 https://dl.google.com/linux/chrome/deb stable InRelease
  The following signatures couldn't be verified because the public key is not available: NO_PUBKEY 4EB27DB2A3B88B8B
Err:2 https://dl.google.com/linux/earth/deb stable InRelease
  The following signatures couldn't be verified because the public key is not available: NO_PUBKEY 4EB27DB2A3B88B8B
.
```

## 扩展实验
如果想知道验证用的公钥里具体存了什么数据，比如公钥什么时候生成、有效期到什么时候，用了什么算法等等，可以使用 GnuPG 的 `--list-packets` 子命令查看：
``` shell
$ cat /etc/apt/keyring/google.asc | gpg --list-packets
# off=0 ctb=99 tag=6 hlen=3 plen=418
:public key packet:
        version 4, algo 17, created 1173385030, expires 0
        pkey[0]: [1024 bits]
        pkey[1]: [160 bits]
        pkey[2]: [1024 bits]
        pkey[3]: [1021 bits]
        keyid: A040830F7FAC5991
.
# off=9522 ctb=89 tag=2 hlen=3 plen=1115
:signature packet: algo 1, keyid 7721F63BD38B4796
        version 4, created 1676474712, md5len 0, sigclass 0x18
        digest algo 8, begin of digest cf 19
        hashed subpkt 27 len 1 (key flags: 02)
        hashed subpkt 33 len 21 (issuer fpr v4 EB4C1BFD4F042F6DDDCCEC917721F63BD38B4796)
        hashed subpkt 2 len 4 (sig created 2023-02-15)
        hashed subpkt 9 len 4 (key expires after 3y0d0h0m)
        subpkt 32 len 540 (signature: v4, class 0x19, algo 1, digest algo 8)
        subpkt 16 len 8 (issuer key ID 7721F63BD38B4796)
        data: [4096 bits]
```
如果要理解更具体的各个数据项目的细节，可以去查看由[互联网工程任务组 Internet Engineering Task Force (IETF)](https://zh.wikipedia.org/wiki/%E4%BA%92%E8%81%94%E7%BD%91%E5%B7%A5%E7%A8%8B%E4%BB%BB%E5%8A%A1%E7%BB%84) 在 [RFC](https://zh.wikipedia.org/wiki/RFC) 4880 里标准化的 [OpenPGP 消息编码规范](https://datatracker.ietf.org/doc/html/rfc4880)，OpenPGP 里的 PGP 指[相当不错的隐私 Pretty Good Privacy (PGP)](https://en.wikipedia.org/wiki/Pretty_Good_Privacy) 。

## 参考资料

https://wiki.debian.org/SecureApt

[Debian 缺陷跟踪系统上关于停用 apt-key 的讨论](https://bugs.debian.org/851774)