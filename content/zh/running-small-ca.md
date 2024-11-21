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

[公开密钥基础设施](https://en.wikipedia.org/wiki/Public_key_infrastructure)（ Public Key Infrastructure, PKI ），是确保现今互联网传输安全的基础技术。我们日常上网使用的工具里，很多是基于自由／开源的软件工具，比如 [OpenSSL](https://www.openssl.org/) 、 [GnuTLS](http://gnutls.org/) 、 [Network Security Services](https://developer.mozilla.org/en-US/docs/NSS) ，以及嵌入式平台上的 [wolfSSL](https://github.com/wolfSSL/wolfssl) 等等[实现](https://en.wikipedia.org/wiki/Comparison_of_TLS_implementations)。因为有这些工具，不需要很大的花费，我们就可以运营一个小型的电子证书认证机构，作为给亲朋好友或一个小型公司内部用户验证的手段。本文以一个很常见的工具 OpenSSL 为例，展示运营一个小型证书认证机构的常见操作。

一开始我之所以会想自己运营一个[电子证书认证机构](https://zh.wikipedia.org/wiki/%E6%95%B0%E5%AD%97%E8%AF%81%E4%B9%A6%E8%AE%A4%E8%AF%81%E6%9C%BA%E6%9E%84)，是为了在自己配置的[虚拟专用网络（ VPN ）](https://zh.wikipedia.org/wiki/虚拟专用网)服务中用电子证书验证和加密传输的数据。

## 普通用户需要知道的概念

电子证书认证机构工作流程中的专用名词：
 - 电子证书颁发者（ issuer ），提供认证服务的（个人或机构）实体（ Entity ）。
 - 电子证书持有者（ subject ），使用证书验证和加密服务的用户，包括网络通信过程两端，典型的是我们经常接触的网站服务器和消费者。
 - 电子证书，最常见的是国际标准组织 ISO 的 [X.509](https://zh.wikipedia.org/wiki/X.509) 证书标准，描述证书里应该有什么数据。
 - 密钥对，包括由实体私有的数据，叫私钥，这部分应该只有持有者知道；还有一部分公开的数据，称为公钥，需要让其他通信参与方获取到。

为了方便普通的网友理解，这里拿中华人民共和国居民身份证做类比：
 - 电子证书颁发机构，这个相当于身份证上的「签发机关」，具体某一个颁发机构对应某一个公安局；
 - 电子证书持有者，相当于居民身份证的持有者，就是普通的中华人民共和国居民；
 - 电子证书，相当于居民身份证本身， X.509 标准相当于公安部制定的居民身份证标准，会描述上面应该有哪些信息；
 - 密钥对，这个是电子证书独有的，也是它的一个独特优势，有点像传统的公章、私章或手印，但在防止伪造方面比传统的签章强多了。

## 实际操作

本文中使用的 OpenSSL 版本为 `3.1.4` ，读者如果以本文作为参照的话，只要使用不太旧的 OpenSSL 版本，命令行接口选项应该和本文的差不多。在本文的示例中，我们有两个电子证书持有者：颁发机构和一个持有者。

### 在电子证书颁发机构端生成根证书

创建证书颁发机构的私钥，并把它利用 128 位[高级加密标准](https://zh.wikipedia.org/wiki/高级加密标准)算法加密，然后存储在[隐私增强邮件 Privacy-Enhanced Mail (PEM) 格式](https://en.wikipedia.org/wiki/Privacy-Enhanced_Mail)编码并加密的 `encrypted.ca.key.pem` 文件中， OpenSSL 会询问两次用于加密私钥数据的密码。这个密码最好复杂一些，并且一定要好好保管，后续给这个小型颁发机构添加其他持有者的时候，需要解密并使用根证书私钥的数据来签名，可以考虑使用离线的密码管理器比如跨平台的 KeePassXC 来保存。一些谨慎的用户，为了安全，会确保计算机在离线状态下生成颁发机构的根证书。
``` shell
$ openssl ecparam -genkey -name prime256v1 | openssl ec -aes128 -out encrypted.ca.key.pem
read EC key
writing EC key
Enter pass phrase for PEM:
Verifying - Enter pass phrase for PEM:
```
运行 `openssl ecparam -list_curves` 可以列出 OpenSSL 支持的[椭圆曲线密钥算法](https://zh.wikipedia.org/wiki/椭圆曲线密码学)。

接着用 OpenSSL 的 `req` 子命令从证书颁发者的私钥生成机构的根证书文件 ca.crt.pem ， OpenSSL 需要从私钥数据生成根证书，所以需要提供上面命令过程中输入的密码以解密私钥文件 encrypted.ca.key.pem 。
``` shell
$ openssl req -x509 -new -sha256 -days 1200 -key encrypted.ca.key.pem \
  -subj '/C=CN/O=Swan CA/CN=Swan Root Cert' -out ca.crt.pem
Enter pass phrase for encrypted.ca.key.pem:
```
这个示例命令中，根证书有效期 1200 天，组织名字由 `O=Swan CA` 指定，用于识别根证书的 common name 字段由 `CN=Swan Root Cert` 指定。

可以使用 OpenSSL 的 `x509` 子命令解码上述命令生成的证书文件 ca.crt.pem 的数据，查看里面的内容：

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
此处颁发和持有者为同一实体，所以这种证书也被称为「自签名」的电子证书。自签名的证书，是说这个机构的根证书归我控制，也就是表明「我是我」，其他实体会使用这个机构的服务，只是表明他们信任这个证书机构。通常更常见的做法是使用交叉签名，由第三方机构给这个颁发者做担保。

### 生成某一证书持有者的证书

证书持有者生成自己的私钥文件 `user1.key.pem` ，此处的文件不会被加密，因为实际情况中，这个私钥文件需要经常用到。它被用于给该实体（网络通讯中的服务器或客户端程序）发出的消息做签名，确保该消息是来自 Swan CA 里指定的持有者，如果每次使用私钥数据的时候都需要输入密码来解密数据，用户体验就不太好了。

``` shell
$ openssl ecparam -genkey -name prime256v1 | openssl ec -out user1.key.pem
```

生成证书签名请求（ Certificate Signing Request, CSR ）文件 `user1.csr.pem` ，然后把文件发送给证书颁发机构。
``` shell
$ openssl req -new -sha256 -key user1.key.pem -out user1.csr.pem \
  -subj "/C=CN/O=Swan CA/CN=user1@example.net"
```
此处 `/CN=...` 字段是必需的，但 `C=...` 和 `O=...` 不是。

### 颁发机构端生成持有者的电子证书

这里需要用到颁发者的私钥文件 `encrypted.ca.key.pem` 、颁发者的证书文件 `ca.crt.pem` 以及一个普通电子证书持有者的证书签名请求文件 `user1.csr.pem` ，然后生成持有者的电子证书文件 `user1.crt.pem` ，命令运行之后需要提供解密颁发者私钥数据文件 `encrypted.ca.key.pem` 的密码。
``` shell
$ openssl x509 -addtrust clientAuth -addtrust serverAuth \
  -req -days 360 -sha256 -CA ca.crt.pem -CAkey encrypted.ca.key.pem \
  -in user1.csr.pem -out user1.crt.pem
```
这个命令中，需要配置一些证书的属性，比如 `-addtrust clientAuth` ，表示持有此电子证书的实体可以作为网络服务客户端参与通信， `-addtrust serverAuth` 表示此实体可以作为网络服务的服务器端参与通信。实际应用中，各个证书软件工具对标准的证书属性的支持情况，需要查阅各个工具的文档确认。

颁发机构生成这一持有者（让我们把他称为「张三」）的证书文件 `user1.crt.pem` 后，需要把证书文件发回给张三，然后张三在进行网络通信的时候，就需要给通信的对端（这里我们称其为「李四」）提供自己的证书信息。为了验证证书确实是张三的，李四需要事先获取 Swan CA （签名）验证过的证书 ca.crt.pem ，在通信开始前配置好软件工具指向证书数据文件，用颁发机构的证书就可以验证通信过程中收到的某一证书确实是张三的。

重复此段的步骤以生成其他实体或用户的电子证书。

### 更新某一持有者的电子证书

电子证书颁发机构运营一段时间后，我们需要根据情况更新某一持有者的电子证书，本段展示更新证书的操作步骤。

从持有者私钥 user1.key.pem 重新生成新的证书签名请求文件 `user1.csr.pem` ，再重新发送给颁发机构。
``` shell
$ openssl req -new -key user1.key.pem -out user1.csr.pem -subj '/C=CN/O=Swan CA/CN=张三' -utf8
```
如果持有者的名字字段中含有[万国码](https://zh.wikipedia.org/wiki/Unicode)字符，需要在命令中加上 `-utf8` 选项。

查看持有者名字字段含有万国码字符的文件时，需要加上 `-nameopt utf8` 选项，才可以在终端正确显示名字中的字符。
``` shell
$ openssl req -in user1.csr.pem -nameopt utf8 -noout -text
.
Subject: C=CN, O=Swan CA, CN=张三
.
```

如果持有者希望更新自己的私钥，可以按[生成某一证书持有者的证书](#生成某一证书持有者的证书)段落步骤操作。

## 互联网上的证书机构

实际的互联网通讯中，对于一个实体的验证要复杂得多。在当前最常见的网络通讯流程中，服务端有电子证书，但用户端没有，用户端程序（比如浏览器）检查的是服务端的证书，但服务端验证用户是利用密码、[HTTP Cookie](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Cookies) 等其他手段。只有当用户使用一些特定设备，比如银行的 U 盾，来使用服务的时候，服务端才利用用户设备上的电子证书来做验证。

### 证书链／信任树
要让持有者都直接由证书认证机构认证，会费时费力，特别是组织规模比较大的情况下，所以除了根证书机构之外，还有中间（分支）证书颁发机构，边缘设备或用户的证书，可以称为叶子证书。从根到分支到叶子的证书系统，就是证书链，但好像说成「信任树」比较直观，信任树的根往往是交叉签名，所以可以称为信任林／信任网（ Web of Trust ）。

依次点击 Chrome 浏览器地址栏左侧的「查看网站信息 - 连接是安全的 - 证书有效」，可以查看一个网站的完整信任树。

比如 www.google.com 的信任树是这样的： GTS Root R1 -> WR2 -> www.google.com

当前本站的信任树是这样的： Baltimore CyberTrust Root -> Cloudflare Inc ECC CA-3 -> x080x.net

根据不同策略，在实际的网络通讯中，通讯参与方（比如浏览器）可以选择是验证完整的信任树的证书，还是只验证到某一个中间认证机构的。

## 后记

根据电子认证机构的用户数量和密钥更新频率，使用本文的命令行手动更新方式可能会不太现实。不过，运营这样一个小型认证机构，主要的挑战可能是在用户对这些技术、对工具不够熟悉。

之前我写了几个快速生成自签名电子证书的脚本，读者可以去 https://gist.github.com/HtwoO/9930212d0c70c4688db57cf3b6187a66 下载脚本来用，或者参考脚本里面的命令。

现今热门的「数字化转型」里很重要的一项基础技术就是数字签章或者叫数字签名技术。如果读者购物时向卖家索取过电子发票，一般下载到的电子发票是 pdf 格式的文件，这些文件通常就是带有数字签章的。在 Linux 或者 macOS 平台上，使用 LibreOffice 办公套件打开 pdf 格式的电子发票，可以查看嵌入在文件中的数字签章。 Adobe 公司的软件对 pdf 数字签章的支持应该不错，可以从他们网站的文档看到他们产品也在做数字签章方面的集成。 Windows 平台的其他 pdf 工具对电子发票数字签章的支持怎样，我还不清楚，现在也没有测试环境。

希望更多人熟悉和使用电子发票，因为它比传统的发票更容易保存和备份。不过因为 pdf 文件一般是二进制文件，里面的信息不是很方便转移到其他工具中，所以有一些新的在开发和推广中的文件格式，比如 [ofd](https://github.com/ofdrw/ofdrw) 格式。如果用更合适的文件格式，对促进更高效的网购等电子商务活动会更有帮助。

自由／开源软件社区已经使用数字签名技术几十年了，我写本篇文章的一个目的，是希望更多的行业和公司使用数字签名技术，推进无纸化工作流程。

## 参考资料
[Everything you should know about certificates and PKI but are too afraid to ask](https://smallstep.com/blog/everything-pki/)

