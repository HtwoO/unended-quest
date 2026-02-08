---
title: 环境状态污染导致家（目录）莫名其妙被搬了
date: 2026-02-08
slug: env-var-poluted-home
author: HtwoO
categories:
    - 技术
tags:
    - 问题
---

大约是 2025 年八月份左右，我部署在亚马逊网络服务 (Amazon Web Services, AWS) Lightsail 上的一个服务器实例出现奇怪的问题，一开始发现该问题是在我用 rsync 同步该服务器和自己本地的文本笔记的时候，会出现下面的错误：

``` shell
CLI> rsync admin@...net:~/note/ ~/bak/note/
.
rsync: [sender] change_dir "//note" failed: No such file or directory (2)
.
```

出现问题后的几天，我没有去排查问题的根源，只是把远程路径里的 `~` 自己换成了完整的路径 `/home/admin` 继续用。

该服务器运行的是 Debian Unstable ，在另一家云服务商上，我还运行了另一个 Debian Unstable 实例，这两个实例平时我都是偶尔连上去的时候升级系统。直到之后比较闲的某一天，我以为是某一次 Debian 升级时导致的问题，然后就去某 Debian 中文技术群里问了一下，里面群友给出了一些建议，我去查了一下，才**发现 `$HOME` 不知道被什么莫名其妙的改成了 `/`** ， ssh 远程登录到服务器后 `PS1` 配置里的 `\W` 也没有显示成 `~` ，颜色也不是我 `.bashrc` 里配置的 `ANSI` 颜色。但我在另一家云服务商上相近的几天内升级的服务器，没有出现类似的问题，所以我怀疑可能和 AWS Lightsail 外部服务商配置实例的 cloud-init 有关系，但这个还没有时间去验证。

发现家目录环境变量不对的时候，就粗略的去检查了 `/etc/bash.bashrc` `/etc/profile` `/home/admin/.bashrc` 等可能影响 `HOME` 环境变量的配置文件，没发现什么异常。

## 排查环境状态污染的来源

### 排查系统和用户层级 shell 以及 ssh 配置文件

``` shell
CLI> ls -hl /home/admin/.bash* /home/admin/.profile* /etc/bash* /etc/profile*
-rw-r--r-- 1 root  root  2.5K Sep  3 16:39 /etc/bash.bashrc
-rw-r--r-- 1 root  root  2.5K Sep  3 16:39 /etc/bash.bashrc.orig
-rw-r--r-- 1 root  root    45 Feb 12  2019 /etc/bash_completion
-rw-r--r-- 1 root  root   828 May  4  2024 /etc/profile
-rw------- 1 admin admin 335K Feb  8 19:03 /home/admin/.bash_history
-rw-r--r-- 1 admin admin  220 Apr 18  2019 /home/admin/.bash_logout
-rw-r--r-- 1 admin admin 1.7K Jan  7 10:45 /home/admin/.bashrc
-rw-r--r-- 1 admin admin 3.5K Apr 18  2019 /home/admin/.bashrc.orig
-rw-r--r-- 1 admin admin  807 Apr 18  2019 /home/admin/.profile.unused

/etc/bash_completion.d:
total 24K
-rw-r--r-- 1 root root 18K May  3  2024 000_bash_completion_compat.bash
-rw-r--r-- 1 root root 439 Mar 10  2021 git-prompt

/etc/profile.d:
total 8.0K
lrwxrwxrwx 1 root root   52 Sep  5 18:37 70-systemd-shell-extra.sh -> /usr/lib/systemd/profile.d/70-systemd-shell-extra.sh
lrwxrwxrwx 1 root root   52 Sep  5 18:37 80-systemd-osc-context.sh -> /usr/lib/systemd/profile.d/80-systemd-osc-context.sh
-rw-r--r-- 1 root root 2.7K Mar 12  2024 Z99-cloud-locale-test.sh
-rw-r--r-- 1 root root  747 May  3  2024 bash_completion.sh

CLI> grep --ignore-case 'home=' /home/admin/.bash* /home/admin/.profile*
/home/admin/.bashrc:export HOME="/home/admin"
/home/admin/.bashrc:export XDG_CACHE_HOME="$HOME/.cache"
/home/admin/.bashrc:export XDG_CONFIG_HOME="$HOME/.config"
/home/admin/.bashrc:export XDG_DATA_HOME="$HOME/.local/share"
/home/admin/.bashrc:export XDG_STATE_HOME="$HOME/.local/state"
/home/admin/.bashrc:export PM2_HOME="$HOME/.local/state/pm2"

CLI> grep --ignore-case 'home=' -r /etc/bash_completion.d /etc/profile.d
无输出

CLI> grep --ignore-case '^\.' /home/admin/.bash* /home/admin/.profile*
输出只有一些 /home/admin/.bash_history 里的结果

CLI> grep --ignore-case '^source' /home/admin/.bash* /home/admin/.profile*
/home/admin/.bash_history:source .venv/bin/activate
/home/admin/.bash_history:source .venv/bin/activate
/home/admin/.bash_history:source .venv/bin/activate
/home/admin/.bash_history:source ~/app/mycli/mycli-git/.venv/bin/activate

CLI> grep --ignore-case '^\.' -r /etc/bash_completion.d /etc/profile.d
CLI> grep --ignore-case '^source' -r /etc/bash_completion.d /etc/profile.d
以上两个命令均无输出

CLI> sudo grep --ignore-case 'env' /etc/sudoers
Defaults        env_reset
# This preserves proxy settings from user environments of root
#Defaults:%sudo env_keep += "http_proxy https_proxy ftp_proxy all_proxy no_proxy"
#Defaults:%sudo env_keep += "EDITOR"
#Defaults:%sudo env_keep += "GREP_COLOR"
#Defaults:%sudo env_keep += "GIT_AUTHOR_* GIT_COMMITTER_*"
#Defaults:%sudo env_keep += "EMAIL DEBEMAIL DEBFULLNAME"
#Defaults:%sudo env_keep += "SSH_AGENT_PID SSH_AUTH_SOCK"
#Defaults:%sudo env_keep += "GPG_AGENT_INFO"

CLI> sudo grep --ignore-case 'env' --recursive /etc/sudoers.d
无输出

CLI> grep --ignore-case 'env' --recursive /etc/ssh
/etc/ssh/sshd_config:#PermitUserEnvironment no
/etc/ssh/sshd_config:# Allow client to pass locale and color environment variables
/etc/ssh/sshd_config:AcceptEnv LANG LC_* COLORTERM NO_COLOR
/etc/ssh/ssh_config:    SendEnv LANG LC_* COLORTERM NO_COLOR
/etc/ssh/sshd_config.orig:#PermitUserEnvironment no
/etc/ssh/sshd_config.orig:# Allow client to pass locale and color environment variables
/etc/ssh/sshd_config.orig:AcceptEnv LANG LC_* COLORTERM NO_COLOR
grep: /etc/ssh/ssh_host_ecdsa_key: Permission denied
grep: /etc/ssh/ssh_host_ed25519_key: Permission denied
grep: /etc/ssh/ssh_host_rsa_key: Permission denied
```

``` shell
CLI> cat /etc/ssh/sshd_config.d/aws.cnf
ClientAliveInterval 120
TrustedUserCAKeys /etc/ssh/lightsail_instance_ca.pub
CLI> cat /etc/ssh/sshd_config.d/alt.port.cnf
Port 233
```

### 排查 PAM 相关的配置
Linux Pluggable Authentication Modules (PAM) 也可能会在登录的某个阶段注入环境变量，不过这一块我不是很熟悉，根据 AI 的一些提醒，我查了可能会改动环境变量的一些配置，并尝试在 `/etc/pam.d/sshd` 里的 `session    required     pam_env.so` 行加入 `debug` 选项，并登录新的 ssh 远程会话，再去查看 `/var/log/auth.log` 里的信息，也没见到和环境变量相关的信息。

``` shell
CLI> grep --ignore-case 'pam_env' --recursive /etc/pam.d
/etc/pam.d/remote:# file /etc/security/pam_env.conf.
/etc/pam.d/remote:session       required   pam_env.so readenv=1
/etc/pam.d/remote:session       required   pam_env.so readenv=1 envfile=/etc/default/locale
/etc/pam.d/login:# file /etc/security/pam_env.conf.
/etc/pam.d/login:session       required   pam_env.so readenv=1
/etc/pam.d/login:session       required   pam_env.so readenv=1 envfile=/etc/default/locale
/etc/pam.d/su:# file /etc/security/pam_env.conf.
/etc/pam.d/su:session       required   pam_env.so readenv=1
/etc/pam.d/su:session       required   pam_env.so readenv=1 envfile=/etc/default/locale
/etc/pam.d/cron:# Read environment variables from pam_env's default files, /etc/environment
/etc/pam.d/cron:# and /etc/security/pam_env.conf.
/etc/pam.d/cron:session       required   pam_env.so
/etc/pam.d/cron:session       required   pam_env.so envfile=/etc/default/locale
/etc/pam.d/sshd:# /etc/security/pam_env.conf.
/etc/pam.d/sshd:session    required     pam_env.so # [1]
/etc/pam.d/sshd:session    required     pam_env.so envfile=/etc/default/locale

CLI> cat /etc/default/locale
LANG=C.UTF-8
```

`/etc/security/pam_env.conf` 的所有行都是注释掉的

``` shell
CLI> ls -hl /etc/environment
-rw-r--r-- 1 root root 0 Feb  8  2021 /etc/environment
CLI> ls -hl /home/admin/.pam_environment
ls: cannot access '/home/admin/.pam_environment': No such file or directory
```

`/etc/environment` 是零字节， `/home/admin/.pam_environment` 不存在，所以和它们也无关。

各种排查尝试修改配置文件之后，登录上去检查 `HOME` 环境变量，依然还是不对。远程登录后看到 `HOME` 还是 `/` 。

``` shell
CLI> env | rg --ignore-case 'home'
PWD=/home/admin
HOME=/
```

甚至 `strace` 都用上了，还是没发现 `HOME` 是被什么，怎么被改的。

``` shell
CLI> echo exit | strace bash -il |& grep --ignore-case '^open' > /tmp/"$(date +%F)".bash.trace.log
CLI> strace bash -il --verbose -x -c 'env' 2>&1 | tee --append /tmp/"$(date +%F)".bash.trace.log
```
以上两个命令输出的完整 [2026-02-08.bash.trace.log](/2026-02-08.bash.trace.log)

加上 `bash` 的 `--debug` 参数获取更为详细的 bash 启动信息，还是没有找到问题的根源。

``` shell
CLI> bash --debug -il -x -c 'env' 2>&1 | tee --append /tmp/"$(date +%F)".bash.env.debug.log
```
以上命令输出的完整日志 [2026-02-08.bash.env.debug.log](/2026-02-08.bash.env.debug.log)

## 临时绕过问题的办法

之后我只得在家目录下创建了个文件 `x` ，里面内容如下：
``` text
export HOME=/home/admin
. "$HOME/.bashrc"
```

然后每次登录上去后的目录确实是预期中的 `/home/admin` ，但需要手动 `. x` 一下，用来引入我常用的 `$PS1` 以及一些命令别名。但因为没有权限把 bash 命令历史记录写入 `/.bash_history` 路径会报下面的错误：
``` shell
CLI> . x
-bash: history: //.bash_history: cannot create: Permission denied
```

令我疑惑的是， `/home/admin/.bashrc` 里有 `export HOME=/home/admin` ，里面修改 `PS1` 变量和引入的命令别名也没生效，似乎 ssh 远程登录以及在 tmux 里开新 panel 的时候也没有 `source /home/admin/.bashrc` ，但我登录完成手动运行 `. x` 后，对 `HOME` 和 PS1 的修改就都生效了。

## 后记
这过程有点像盲人摸象，查了很多持久配置，仍难以定位到导致异常状态的配置。当前的工具里，也没有一个可以完全列出影响 `HOME` 这个环境变量的所有层级的配置，也没有办法列出各个层级的有效 (effective) 或持久 (persistent) 配置到底是什么值。

现代操作系统如此复杂，出现异常状态的时候，难以找出是到底是哪个组件 (context) 引入的状态变更。作为用户，我特别希望 http://0pointer.net/blog/projects/stateless.html 这个 systemd 远景规划、兼具「无状态、可重现、可验证」特性的系统，有更多系统或发行版实现，这样可以更容易追踪到出问题的状态变更。我曾经在 macOS 上尝试使用 nix 作为包管理器，也想做到把系统状态完全声明式定义在系统配置文件里，但发现它在 macOS 上仍有很多不成熟之处，并且要学习和完全依赖一个新的包管理工具我一下子又不太情愿。

