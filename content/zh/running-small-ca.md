---
title: 运营一个小型电子证书认证机构
date: 2023-11-13
slug: running-small-ca
author: HtwoO
categories:
    - 技术
tags:
    - 技术普及
    - 数字签名
    - 信息安全
---

[公开密钥基础设施](https://en.wikipedia.org/wiki/Public_key_infrastructure)（ Public Key Infrastructure, PKI ），是确保现今互联网传输安全的基础技术。我们日常上网使用的工具里，很多是基于自由／开源的软件工具，比如 [OpenSSL](https://www.openssl.org/) 、 [GnuTLS](http://gnutls.org/) 、 [Network Security Services, NSS](https://developer.mozilla.org/en-US/docs/NSS) ，以及嵌入式平台上的 [wolfSSL](https://github.com/wolfSSL/wolfssl) 等等[实现](https://en.wikipedia.org/wiki/Comparison_of_TLS_implementations)。因为有这些工具，不需要很大的花费，我们就可以运营一个小型的电子证书认证机构，作为给亲朋好友或一个小型公司内部用户验证的手段。本文以一个很常见的工具 OpenSSL 为例，展示运营一个小型证书认证机构的常见操作。

一开始我之所以会想自己运营一个[电子证书认证机构](https://zh.wikipedia.org/wiki/%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%E8%AE%A4%E8%AF%81%E6%9C%BA%E6%9E%84)，是为了在自己配置的[虚拟专用网络（ VPN ）](https://zh.wikipedia.org/wiki/虚拟专用网)服务中用电子证书验证和加密传输的数据。

## 普通用户需要知道的概念

电子证书认证机构工作流程中的专用名词：
 - 电子证书颁发者（ issuer ），提供认证服务的（个人或机构）实体。
 - 电子证书持有者（ subject ），使用证书验证和加密服务的用户，包括网络通信过程两端，典型的是我们经常接触的网站服务器和消费者。
 - 电子证书，最常见的是国际标准组织 ISO 的 [X.509](https://zh.wikipedia.org/wiki/X.509) 证书标准，描述证书里应该有什么数据。
 - 密钥对，包括由一个实体私有的部分，叫私钥，这部分应该只有持有者知道；还有一个公开的部分，称为公钥，需要让其他通信参与方获取。

为了方便普通的网友理解，这里拿中华人民共和国居民身份证做类比：
 - 电子证书颁发机构，这个相当于身份证上的「签发机关」，具体某一个颁发机构对应某一个公安局；
 - 电子证书持有者，相当于居民身份证的持有者，就是普通的中华人民共和国居民；
 - 电子证书，相当于居民身份证本身， X.509 标准相当于公安部制定的居民身份证标准，会描述上面应该有哪些信息；
 - 密钥对，这个是电子证书独有的，也是它的一个独特优势，有点像传统的公章或私章，但在防止伪造方面比传统的签章强多了。

## 实际操作

本文中使用的 OpenSSL 版本为 `3.1.4` ，读者如果以本文作为参照的话，只要使用不太旧的 OpenSSL 版本，命令行接口选项应该差不多。在本文的示例中，我们有两个电子证书持有者：颁发者和一个持有者。

### 在电子证书颁发机构端生成根证书

创建证书颁发机构的私钥，并把它利用 128 位[高级加密标准](https://zh.wikipedia.org/wiki/高级加密标准)算法加密，然后存储在 `encrypted.ca.key.pem` 文件中， OpenSSL 会询问两次用于加密私钥数据的密码。
``` shell
$ openssl ecparam -genkey -name prime256v1 | openssl ec -aes128 -out encrypted.ca.key.pem
read EC key
writing EC key
Enter pass phrase for PEM:
Verifying - Enter pass phrase for PEM:
```
运行 `openssl ecparam -list_curves` 可以列出 OpenSSL 支持的[椭圆曲线密钥算法](https://zh.wikipedia.org/wiki/椭圆曲线密码学)。

接着用 OpenSSL 的 `req` 子命令从证书颁发者的私钥生成机构的根证书， OpenSSL 需要从私钥数据生成根证书，所以需要提供上面命令过程中输入的密码以解密私钥文件。
``` shell
$ openssl req -x509 -new -sha256 -days 1200 -key encrypted.ca.key.pem \
  -subj '/C=CN/O=Swan CA/CN=Swan Root Cert' -out ca.crt.pem
Enter pass phrase for encrypted.ca.key.pem:
```
这个示例命令中，根证书有效期 1200 天，组织名字由 `O=Swan CA` 指定，用于识别根证书的 common name 字段由 `CN=Swan Root Cert` 指定。

可以使用 OpenSSL 的 `x509` 子命令解码证书数据，查看里面的内容：

``` shell
$ openssl x509 -in ca.crt.pem -noout -text
.
Signature Algorithm: ecdsa-with-SHA256
Issuer: C = CN, O = Swan CA, CN = Swan Root Cert
Validity
    Not Before: Nov 13 09:26:38 2023 GMT
    Not After : Feb 25 09:26:38 2027 GMT
Subject: C = CN, O = Swan CA, CN = Swan Root Cert
.
```
电子证书中一些重要字段：
 - `Issuer` 部分表示颁发者信息
 - `Validity` 部分表示根证书有效期
 - `Subject` 部分表示证书持有者
此处颁发和持有者为同一实体，所以这种证书也被称为「自签名」的电子证书。通常更常见的做法是使用交叉签名，由第三方给这个颁发者做担保。

### 生成某一证书持有者的证书

证书持有者生成自己的私钥文件 `user1.key.pem` ，此处的文件不会被加密。

``` shell
$ openssl ecparam -genkey -name prime256v1 | openssl ec -out user1.key.pem
```

生成证书签名请求（ Certificate Signing Request ）文件 `user1.csr.pem` ，然后把文件发送给证书颁发机构。
``` shell
$ openssl req -new -sha256 -key user1.key.pem -out user1.csr.pem \
  -subj "/C=CN/O=Swan CA/CN=user1@example.net"
```
此处的 `O=Swan CA` 不一定是必需的。

### 颁发机构端生成持有者的电子证书

这里需要用到颁发者的私钥文件 `encrypted.ca.key.pem` 、颁发者的证书文件 `ca.crt.pem` 以及一个普通电子证书持有者的证书签名请求文件 `user1.csr.pem` ，然后生成持有者的电子证书文件 `user1.crt.pem` ，命令中需要提供解密颁发者私钥数据文件 `encrypted.ca.key.pem` 的密码，。
``` shell
$ openssl x509 -addtrust clientAuth -addtrust serverAuth \
  -req -days 360 -sha256 -CA ca.crt.pem -CAkey encrypted.ca.key.pem \
  -in user1.csr.pem -out user1.crt.pem
```
这个命令中，需要配置一些证书的属性，比如 `-addtrust clientAuth` ，表示持有此电子证书的实体可以作为网络服务客户端参与通信， `-addtrust serverAuth` 表示此实体可以作为网络服务的服务器端参与通信。实际应用中，各个证书软件工具对标准的证书属性的支持情况，需要查阅各个工具的文档确认。

重复此段的步骤以生成其他实体或用户的电子证书。

### 更新某一持有者的电子证书

电子证书颁发机构运营一段时间后，我们需要根据情况更新某一持有者的电子证书，本段更新证书的操作步骤。

从持有者私钥重新生成证书签名请求文件 `user1.csr.pem` ，再重新发给颁发机构。
``` shell
$ openssl req -new -key user1.key.pem -out user1.csr.pem -subj '/C=CN/O=Swan CA/CN=喵呜' -utf8
```
如果持有者的名字字段中含有[万国码](https://zh.wikipedia.org/wiki/Unicode)字符，需要在命令中加上 `-utf8` 选项。

查看持有者名字字段含有万国码字符的文件时，需要加上 `-nameopt utf8` 选项，才可以在终端正确显示名字中的字符。
``` shell
$ openssl req -in user1.csr.pem -nameopt utf8 -noout -text
.
Subject: C=CN, O=Swan CA, CN=喵呜
.
```

如果持有者希望更新自己的私钥，可以按[生成某一证书持有者的证书](#生成某一证书持有者的证书)段落步骤操作。

## 后记

现今热门的「数字化转型」里很重要的一项基础技术就是数字签章，或者叫数字签名。如果读者购物时要求卖家提供过电子发票，一般下载到的电子发票是 pdf 格式的文件，这些文件一般就是带有数字签章的。在 Linux 或者 macOS 平台上，使用 LibreOffice 打开 pdf 格式的电子发票，可以查看嵌入在文件中的数字签章。实际上，我写本篇文章的一个目的，是希望更多人熟悉和使用电子发票。因为它比传统的发票更容易保存和备份，不过因为 pdf 文件一般是二进制文件，里面的信息不是很方便转移到其他工具中，所以有一些新的在开发和推广中的文件格式，比如 [odf](https://github.com/ofdrw/ofdrw) 格式。如果用更合适的文件格式，对促进更高效的网购等电子商务活动会更有帮助。

根据电子认证机构的用户数量和密钥更新频率，使用本文的命令行手动更新方式可能会不太现实。不过，运营这样一个小型认证机构，主要的挑战可能是在用户对这些技术、对工具不够熟练。

之前我写了几个快速生成自签名电子证书的脚本，读者可以去 https://gist.github.com/HtwoO/9930212d0c70c4688db57cf3b6187a66 下载脚本来用，或者参考脚本里面的命令。

## 参考资料
[Everything you should know about certificates and PKI but are too afraid to ask](https://smallstep.com/blog/everything-pki/)