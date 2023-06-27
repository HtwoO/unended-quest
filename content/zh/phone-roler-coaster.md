---
title: 手机过山车
date: 2023-06-20
slug: oneplus7t-lineageos
author: HtwoO
categories:
    - 生活
tags:
    - Android
    - LineageOS
    - 一加
---

几个月前，一加 7T 官方推送了 ColorOS 后，升级后，出现的一个很不爽的问题是不能从 Google Drive 下载文件。这个问题，搜索一加的英文论坛，能轻松找到十几个遇到一样问题的用户反馈帖子。忍了一阵子，通过手机自带、论坛和邮件等几个渠道给他们提反馈后，没收到过有意义的回应。从论坛的状态看，一加似乎快倒闭了，中文和英文论坛都蛮久没新帖子了。后来我自己找到了绕过的办法，就是直接在浏览器打开 Google Drive 下载。把机器里之前下载的播客基本听完后，就尝试恢复出厂设置，看是否有帮助，结果从日常使用的系统里没法恢复出厂设置，报了个什么 Token 3040 错误，后来同时按「电源 + 减小音量 」键开机，进入恢复模式，选择格式化数据分区。再开机后，机器上的数据是清干净了，重新装了 Google Drive ，再尝试下载文件，问题还在，考虑到用原厂系统时不时会遇到推广，虽然比我主要用的一个小米手机默认的少多了，但系统使用中的一些小问题，感觉比小米的多多了，我就决定刷机成 LineageOS 看看。

## 安装刷机用到的工具和下载 LineageOS 系统映像
本本上事先有 Homebrew ，直接安装里面人家打好的 Android 平台工具包。
```
$ brew install android-platform-tools
```

前往 LineageOS 的[一加 7T 设备页面](https://wiki.lineageos.org/devices/hotdogb/)，下载了系统映像，下载后还检查了文件校验码，没有发现问题。当时还以为必须要有 twrp 恢复映像才可以刷机，就顺便下载了最后更新于 2021 年、已经不再维护的、针对相近手机型号的 twrp 恢复映像。这成了本篇的坑点之一，刷了个不完整的恢复映像（ Recovery Image ），导致手机变「砖」。

## 激活开发者模式

进入 **设置 -> 关于本机 -> 版本信息 -> 版本号** 菜单，连续点击「版本号」字段多次之后，屏幕上会弹出提醒「现在只需再执行 X 步操作即可进入开发者模式」，继续点击直到出现「您现在处于开发者模式！」，表示成功激活开发者模式。再次点击，屏幕上的提醒会变成「您已处于开发者模式，无需进行此操作。」

## 启用 USB 调试功能

进入 **设置 -> 系统设置 -> 开发者选项 -> USB 调试** 菜单，启用选项。手机屏幕上会出现如下提醒：
```
允许 USB 调试吗？
这台计算机的 RSA 密钥指纹如下：xx:yy:...:zz
一律允许使用这台计算机进行调试
取消 允许
```

点击 **允许** ，即可启用 USB 调试功能，启用成功后，在命令行运行
```
$ adb devices
```
如果找不到设备，则在接上 USB 线后，从屏幕顶端下滑菜单的系统通知选项里，在以下几个 USB 选项中，选择「传输文件」。
 - 仅充电
 - 传输文件 / Android Auto
 - 传输照片
 - ...

再运行 `adb` ，应该能识别出设备。
```
$ adb devices
List of devices attached
ec123456        device

# 重启进入引导程序，含有 ** 的选项为界面中选中状态的选项
$ adb reboot bootloader
** FastBoot Mode
PRODUCT_NAME - msmnile
VARIANT - SDM UFS
BOOTLOADER VERSION -
BASEBAND VERSION
SERIAL NUMBER - ec123456
SECURE BOOT - yes
** DEVICE STATE - locked
```

## 解锁引导程序
在上面引导程序界面，会发现设备属于 `locked` （已锁定）状态，直接尝试用 `fastboot` 解锁失败。

```
$ fastboot oem unlock
FAILED (remote: 'Flashing Unlock is not allowed
')
fastboot: error: Command failed
```

需要重启手机到 Android 系统中，进入 **设置 -> 系统设置 -> 开发者选项 -> OEM 解锁（允许解锁引导加载程序）** ，启用选项，再重启进入引导程序界面。（注： `oem unlock` 似乎是比较旧的命令，新的 `flash unlock` 我没试过，也许这个能解锁。）

```
$ adb devices   # 看起来似乎没认出手机
List of devices attached

$ fastboot oem unlock
OKAY [  0.032s]
Finished. Total time: 0.032s
```
解锁时会有个界面，上面有个红色感叹号和一段提醒文字。
```
By unlocking the bootloader, you will be ...
```

解锁引导程序后再开机进入的系统，在重新启用开发者模式后， **设置 -> 系统设置 -> 开发者选项** 菜单下面不再有 **OEM 解锁** 选项。再次重启进入引导程序界面，

```
$ adb reboot bootloader
** FastBoot Mode
.
** DEVICE STATE - unlocked
```

可以看到设备状态变成了 `unlocked` （已解锁）。当时，在 LineageOS 的一加 7T 设备页面，我看得不够仔细，那么大的 Guides 和下面的 Installation 链接我都没注意到没点进去看 p_q

## 误刷恢复映像，变「砖」了
我跑了下面的命令，手机就进入了无限重启进恢复模式状态，并且插上线时它会自己开机，恢复模式里选择关机它还是会重启，再次进入恢复模式，直到拔线再选关机选项，才能关机。
```
$ fastboot flash recovery twrp-3.7.0_11-hotdog.img
Sending 'recovery' (78360 KB)                      OKAY [  0.214s]
Writing 'recovery'                                 OKAY [  0.375s]
Finished. Total time: 0.767s
$ fastboot reboot recovery
Rebooting into recovery                            OKAY [  0.004s]
Finished. Total time: 0.004s
```

无论是在有错误的恢复模式，还是仍然可以进入的引导程序界面，本本上的 `adb devices` 和 `fastboot devices` 都识别不到设备， macOS 「系统信息」应用的 **硬件 -> USB** 页面里也看不到设备。当时有些心惊胆战，心想可能需要去售后才能刷机恢复了。不过还是去找了一个有 Windows 系统的朋友，考虑到 Windows 上的工具比较多，想要自己再尝试一下看能否自己刷机恢复。

在朋友的 Windows 本本上装了一加的 USB 驱动后，插上 USB 线，手机有时会显示为存储设备，但没被识别成 U 盘，去网上一番搜索之后，了解到有个 USB 线刷「救砖包」工具，名字叫 MsmDownloadTool ，使用高通基带芯片的手机（一加和小米的手机很多使用的是高通的基带芯片），有个 Emergency DownLoad (EDL) （紧急下载）模式。人家网上所说的救砖，看起来是在 EDL 模式上刷进一加原厂的系统。在手机处于引导程序界面时，用 USB 线接入桌机，然后同时按住 **电源** 和 **增加音量** 按键大概 30 秒，可以进入该模式。我按照这个指示操作后， Windows 系统会检测到一个新的硬件设备，但让它自动去搜索驱动的话，并不能找到能用的驱动。当天时间有限，没有去尝试更多次，就放弃了，然后那个手机就关机呆了几天。

## 死马当活马医

之后几天，多方搜索了解之后，在 www.thecustomdroid.com 的[这篇](https://www.thecustomdroid.com/qpst-flash-tool-download-usage-guide/)文章中，我了解到需要让 Windows 系统识别出处于 EDL 模式的手机，需要安装[高通的 HS-USB QDLoader 9008 驱动](http://download.windowsupdate.com/c/msdownload/update/driver/drvs/2017/03/fe241eb3-d71f-4f86-9143-c6935c203e12_fba473728483260906ba044af3c063e309e6259d.cab) ，后来因为意外发现 macOS 上的 `fastboot` 又能识别到手机，我没有下载和用到这个驱动。

### 折腾 Windows 虚拟机
当时，我以为要救回手机，需要使用工具更为丰富的 Windows 系统，所以我在 macOS 上用 VirtualBox 装了个 Windows 虚拟客户机，然后想方设法，既在宿主机上安装 extension pack ，又在虚拟客机上安装 guest additions ，然后还需要 sudo 运行 VirtualBox ，以绕过 VirtualBox 7.x 上使用 USB 设备的问题，并经过多次重启宿主和客户机尝试，才在 Windows 客机上识别出了宿主机 USB 线接着的手机。在这个过程中，我注意到宿主和客户机有时识别不出设备，可以识别的时候， macOS System Profiler （系统信息） 11.0 (915) ，识别到的设备信息如下：
```
USB 3.0 总线：

  主控制器驱动器：	AppleUSBXHCILPT
  PCI设备ID：	0x9c31 
  PCI修订版ID：	0x0004 
  PCI供应商ID：	0x8086 

Android：

  产品ID：	0xd00d
  厂商ID：	0x18d1  (Google Inc.)
  版本：	1.00
  序列号：	ec123456
  生产企业：	Google
  位置ID：	0x14600000
```

但是 Windows 虚拟机只是识别到一个新设备，Windows 的自动查找没找到合适的驱动。

## 柳暗花明

后来我注意到宿主机重启后第一次插入手机时，宿主和客户机都能识别出 USB 线上接的手机，然后某一次在宿主机识别了手机的状态下，手机启动到引导程序界面（ `FastBoot Mode` ）时， `fastboot` 能识别到手机，
```
$ fastboot devices
ec123456    fastboot
```
这时我感觉到应该可以自己「救砖」。也是在这段尝试期间，我才仔细去看了 LineageOS 的 Installation 页面，然后意识到自己尝试刷入恢复映像时，没有刷入以下两个映像的步骤，猜测手机是因此变「砖」的。

```
$ fastboot flash vbmeta <vbmeta>.img
$ fastboot flash dtbo <dtbo>.img
```

## 刷入 LineageOS 20

我还注意到 LineageOS 的几个系统映像里，有一个就是叫 `recovery.img` ，当时我就猜测到刷 `twrp` 可能是没有必要的。这时，我就按照安装指南页面依次刷入以下几个映像：
```
$ fastboot flash dtbo dtbo.img
Sending 'dtbo' (24576 KB)                          OKAY [  0.194s]
Writing 'dtbo'                                     OKAY [  0.120s]
Finished. Total time: 0.337s

$ fastboot flash vbmeta vbmeta.img
Sending 'vbmeta' (8 KB)                            OKAY [  0.008s]
Writing 'vbmeta'                                   OKAY [  0.003s]
Finished. Total time: 0.034s
```

然后重启到引导程序界面
```
$ adb reboot bootloader
```

刷入 LineageOS recovery （恢复）映像
```
$ fastboot flash recovery recovery.img
Sending 'recovery' (98304 KB)                      OKAY [  0.691s]
Writing 'recovery'                                 OKAY [  0.462s]
Finished. Total time: 1.178s
```

重启进 LineageOS 恢复模式，然后进入 **LineageOS recovery -> Advanced -> Enable ADB** 启用 ADB ，之后 `adb` 就可以识别出设备。当时我又没仔细看步骤，就光去跑安装指导页面的命令了，可能上面连续几个命令顺利执行让自己又大意了，结果发现 `adb sideload` 无法把 LineageOS 主系统映像上传到手机。
```
$ adb devices
List of devices attached
ec123456        unauthorized

$ adb sideload lineage-20.0-20230528-nightly-hotdogb-signed.zip
adb: sideload connection failed: device unauthorized.
This adb server's $ADB_VENDOR_KEYS is not set
Try 'adb kill-server' if that seems wrong.
Otherwise check for a confirmation dialog on your device.
adb: trying pre-KitKat sideload method...
adb: pre-KitKat sideload connection failed: device unauthorized.
This adb server's $ADB_VENDOR_KEYS is not set
Try 'adb kill-server' if that seems wrong.
Otherwise check for a confirmation dialog on your device.

$ adb devices
List of devices attached
ec123456        recovery

$ adb sideload lineage-20.0-20230528-nightly-hotdogb-signed.zip
adb: sideload connection failed: closed
adb: trying pre-KitKat sideload method...
adb: pre-KitKat sideload connection failed: closed

$ adb shell
OnePlus7T:/ # adb push lineage-20.0-20230528-nightly-hotdogb-signed.zip /sdcard
/system/bin/sh: adb: inaccessible or not found

127|OnePlus7T:/ # pwd
/

OnePlus7T:/ # ls
acct         debug_ramdisk  odm_dlkm                product                    second_stage_resources    system_ext_property_contexts
apex         default.prop   odm_file_contexts       product_file_contexts      sepolicy                  system_ext_service_contexts
bin          dev            odm_property_contexts   product_property_contexts  sideload                  tmp
bugreports   etc            oem                     product_service_contexts   storage                   vendor
cache        init           plat_file_contexts      prop.default               sys                       vendor_dlkm
config       linkerconfig   plat_property_contexts  res                        system                    vendor_file_contexts
d            metadata       plat_service_contexts   root                       system_dlkm               vendor_property_contexts
data         mnt            postinstall             sbin                       system_ext                vendor_service_contexts
data_mirror  odm            proc                    sdcard                     system_ext_file_contexts

OnePlus7T:/ # df -h
Filesystem      Size Used Avail Use% Mounted on
rootfs          3.4G  30M  3.4G   1% /
tmpfs           3.6G 1.6M  3.6G   1% /dev
tmpfs           3.6G    0  3.6G   0% /mnt
tmpfs           3.6G    0  3.6G   0% /apex
tmpfs           3.6G 4.0K  3.6G   1% /linkerconfig
tmpfs           3.6G  36K  3.6G   1% /tmp
tmpfs           3.6G    0  3.6G   0% /storage
```

上面可以看到我尝试了各种奇怪的命令，顺便查看了一下 LineageOS 恢复模式的根目录。然后我仔细阅读了安装指南页面，才发现要使用 sideload ，需要进入 **Apply update -> Apply from ADB** 菜单启用 sideload 功能，然后总算把 LineageOS 上传到手机存储里去了。

```
$ adb devices
List of devices attached
ec123456        sideload

$ adb sideload lineage-20.0-20230528-nightly-hotdogb-signed.zip
serving: 'lineage-20.0-20230528-nightly-hotdogb-signed.zip'  (~47%)
.
Total xfer: 1.00x
```
上传结束后它好像会自动解包 LineageOS 系统到手机的存储里去（现在记不太清了）。

然后根据安装指南，从恢复模式又重启了一下再次进入恢复模式 **Advanced -> Reboot to Recovery** ，然后可以根据自己喜好刷入一些工具包，比如 Google 应用框架。

## 刷入 Google 应用框架

再次进入 LineageOS 恢复模式 **Apply update -> Apply from ADB** 启用设备的 sideload 功能，上传 Google 应用框架。

```
$ adb sideload MindTheGapps-13.0.0-arm64-20230408_162909.zip
serving: 'lineage-20.0-20230528-nightly-hotdogb-signed.zip'  (~47%)
.
Total xfer: 1.00x
```

传完后简单看了一下 `adb` 检测到的设备状态，在 `adb` 可识别到手机的时候，我瞄了一眼 macOS 的系统信息显示的 USB 设备状态。

```
USB 3.0总线：

  主控制器驱动器：	AppleUSBXHCILPT
  PCI设备ID：	0x9c31 
  PCI修订版ID：	0x0004 
  PCI供应商ID：	0x8086 

HD1901：

  产品ID：	0xd001
  厂商ID：	0x18d1  (Google Inc.)
  版本：	4.14
  序列号：	ec123456
  速度：	最高可达5 Gb/秒
  生产企业：	OnePlus
  位置ID：	0x14600000 / 15
  可用电流(mA)：	900
  所需电流(mA)：	896
  额外的操作电流(mA)：	0
```

```
$ adb devices
List of devices attached
ec123456        unauthorized
```

## 重启进入常规系统查看刷机是否成功

经过以上步骤后，重启手机，顺利进入了基于 Android 13 的 LineageOS 20 。

## 后记

之前的氧 OS 和几个月前升级的 ColorOS ，指纹传感器的解锁成功率都很低，升级到 LineageOS 后，指纹解锁成功率高多了，基本不再遇到失败次数过多需要冷却时间的情况，可能 LineageOS 也没有这个机制。现在充电似乎没有之前一加系统时候快，也许是一加用了什么私有的充电协议，也可能是我的感觉不准。

LineageOS 系统比较简洁干净，原始系统只有 AudioFX 、拨打电话、短信、计算器、浏览器、录音机、日历、设置、时钟、通讯录、图库、文件、相机、音乐这些有图标的应用。刷入的 Google 应用框架应该就只有 Google 、 Play 商店和语音搜索（这个也可能是后面装 Gboard 后出现的）三个应用。（我开始以为只有 Play 商店，其他的应该都能在商店安装。） Android 13 系统自带的相机应用 Aperture 带了扫描二维码功能，扫描识别速率很快，不过好像不支持扫描传统的一维条形码，所以我还是装了传统的 ZXing 那个扫描器，那个应用在 Play 商店显示最后更新时间 2018 年 9 月，不过在 Android 13 上还能用，虽然遇到过显示错误。看到过 LineageOS 不支持双卡双待的说法，我还没试过放两张卡，不过在 **设置 -> 关于手机** 菜单里，能看到两个 SIM 卡槽的界面字段。数字人民币应用装上后用不了，提示「您的设备运行环境存在风险，系统可能被修改或存在威胁您资金安全的因素，为了您的资金安全，...」，后面的文字看不到。

现代 Android 系统，从上层往下，似乎有四种主要工作模式，上面层的系统坏了，理论上都可以用更底层的系统恢复工具来救「砖」：
 - 标准日常使用的系统，用户日常使用的模式
 - Recovery 恢复模式，可以清理用户数据，刷入定制 ROM （只读存储？）等，现在甚至支持触摸屏操作了
 - Fastboot 模式，可以用 `fastboot` 工具刷入定制的恢复映像
 - 使用高通基带的手机，有 EDL 紧急下载模式，可以利用串口 communication port (COM) 通信模式刷入映像，不知道其他基带厂的有没有相似模式

在手机引导程序界面状态， USB 线着 macOS 时，系统识别不出手机， `adb devices` 和 `fastboot devices` 都没见设备，之前没有怀疑过 macOS ，后来能识别到是在宿主操作系统重启过之后，所以在折腾硬件时，还是不应过于信任操作系统，还是有必要重启（ reset ）看看是否有帮助。

不需要经过一加公司方面的流程，用户就可以自己解锁手机引导程序，我只能感恩。

刷完系统到现在， LineageOS 有三个新的更新包了。一加作为商业公司，为什么系统的细节打磨上甚至不如开源的 LineageOS 呢？公司的钱都花到哪儿去了呢？是不是去[做芯片](https://ee.ofweek.com/2023-05/ART-8440-2800-30596990.html)了？

## 参考资料

https://wiki.lineageos.org/adb_fastboot_guide

https://en.wikipedia.org/wiki/Qualcomm_EDL_mode