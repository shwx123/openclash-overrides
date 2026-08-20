# OpenClash 自定义覆写模块

> 从 sdba-pve2-openwrt (V302) 和 qqhy-pve-openwrt (V104) 导出，GitHub 维护。
> 仅包含自定义规则，不包含订阅配置（订阅源见 [HenryChiao/MIHOMO_YAMLS](https://github.com/HenryChiao/MIHOMO_YAMLS)）。

## 目录结构

```
overwrite/                ← 覆写模块（上传到 /etc/openclash/overwrite/）
├── TailscaleDirect.conf  ← Tailscale 直连 + tailnet 域名 Fake-IP 排除
└── opencode-direct.conf  ← opencode.ai 直连规则

custom/                   ← 自定义文件（上传到 /etc/openclash/custom/）
├── openclash_custom_rules.list      ← Tailscale 直连规则（规则注入）
└── openclash_custom_fake_filter.list ← Fake-IP 排除列表
```

## 各模块说明

### TailscaleDirect
- **用途**: 让 Tailscale 流量直连，防止被 OpenClash 代理
- **规则**:
  - `DOMAIN-SUFFIX,tailscale.com,DIRECT`
  - `SRC-PORT,41641,DIRECT`（Tailscale 打洞端口）
  - `IP-CIDR,100.64.0.0/10,DIRECT`（CGNAT 网段）
  - `IP-CIDR,100.100.100.100/32,DIRECT`（MagicDNS）
- **Fake-IP 排除**: `*.qqhy.suhuilinqing.dpdns.org`、`*.sdba.suhuilinqing.dpdns.org`
- **部署位置**: V302 + V104

### opencode-direct
- **用途**: opencode.ai 直连（不走代理）
- **规则**: `DOMAIN-SUFFIX,opencode.ai,DIRECT`
- **部署位置**: V302 only

## 部署方法

### 从 GitHub 同步（推荐）

在 OpenWrt 上执行：

```bash
# 安装 git（如未安装）
opkg update && opkg install git

# 克隆仓库
cd /tmp
git clone https://github.com/<your-username>/openclash-overrides.git

# 复制覆写模块
cp overwrite/* /etc/openclash/overwrite/
chmod 644 /etc/openclash/overwrite/*

# 复制自定义文件
cp custom/* /etc/openclash/custom/

# 重启 OpenClash 使生效
/etc/init.d/openclash restart
```

### 使用 OpenClash 远程覆写（自动更新）

在 LuCI → 服务 → OpenClash → 覆写模块 → 新建：

- **名称**: `TailscaleDirect`
- **类型**: `http`
- **URL**: `https://raw.githubusercontent.com/shwx123/openclash-overrides/main/overwrite/TailscaleDirect.conf`
- **配置匹配**: `all`
- **启用**: ✅

## 注意事项

- `[YAML]` 段的 `+rules` 是追加操作，不会覆盖已有规则
- `fake-ip-filter+` 是追加操作，保留原有 Fake-IP 排除列表
- 修改后需重启 OpenClash 才能生效

## Prevent_DNS_Leak 修复（v0.47.156 custom 通道）

Aethersailor 的 [Prevent_DNS_Leak](https://github.com/Aethersailor/Custom_OpenClash_Rules/tree/main/overwrite) 模块在 **OpenClash v0.47.156 + yaml 覆写方案**（Custom_Clash_8in1 / Custom_Clash_*）下，`[Overwrite]` 段 ruby 的 groups/rules 修改会被 `[General]` 段处理**覆盖**——表现为 COCR-DNS-Leak-Guard 组、MATCH 重定向、no-resolve 补全不落地（核心 respect-rules 仍生效）。

**修复**：将 [`fix/prevent_dns_leak_custom.sh`](fix/prevent_dns_leak_custom.sh) 中的 `ruby_edit` 行追加到路由器 `/etc/openclash/custom/openclash_custom_overwrite.sh` 的 **`exit 0` 之前**（custom 通道在模块覆写之后执行，修改可落地；放在 `exit 0` 之后不会执行）。

- 前置：仍须启用 Prevent_DNS_Leak 覆写模块（`[General]` 段提供 respect-rules / proxy-server-nameserver 自动设置）
- 验证：运行配置出现 `COCR-DNS-Leak-Guard` 组 + `MATCH,COCR-DNS-Leak-Guard` + `respect-rules: true` + `proxy-server-nameserver`
- 实测：2026-08-20，V202 + Custom_Clash_Fallback + v0.47.156（google/tailnet 正常）

## Prevent_DNS_Leak_Fix 自安装模块（v0.47.156，推荐用法）

把「Prevent DNS Leak 修复」做成**纯订阅格式**：模块通过 `[General] DOWNLOAD_FILE` 自动把仓库版完整 custom 脚本（`custom/openclash_custom_overwrite.sh`）下载到路由器 `/etc/openclash/custom/`。custom 通道（init.d 3644 行，模块覆写之后执行）让 ruby 修改落地——**无需手工改任何文件**。

**部署**（任意机器，1 分钟）：
1. 添加覆写模块条目：`type=http`，`url=https://raw.githubusercontent.com/shwx123/openclash-overrides/main/overwrite/Prevent_DNS_Leak_Fix.conf`，`config=all`，`enable=1`，`order=25`（须在 Prevent_DNS_Leak 之后）
2. 重启 OpenClash（首次启动自动下载 custom 脚本并生效；已实测「删除脚本→重启→自动恢复」）

**前置**：仍须启用 Aethersailor Prevent_DNS_Leak 模块（`[General]` 段提供 respect-rules / proxy-server-nameserver 设置）。

**验证**：运行配置出现 `COCR-DNS-Leak-Guard` 组 + `MATCH,COCR-DNS-Leak-Guard` + `respect-rules: true` + `proxy-server-nameserver`。

**踩坑实录（2026-08-20）**：
- **别用 jsdelivr 分支 URL 作 DOWNLOAD_FILE 源**：jsdelivr 对 `@main` 分支缓存约 12h 且**忽略 query 参数**（`?v=2` 无效），会拉取到旧版。用 raw.githubusercontent.com（Fastly 缓存仅分钟级）。
- **CRLF 陷阱**：经 Windows 本地 `cat` 提取的脚本会变 CRLF，shebang `#!/bin/sh\r` 导致 execve 失败（busybox 报 `not found`、无日志）。仓库文件必须为 LF。
- cron=`0 4 * * *` 每天 4 点自动同步 custom 脚本（CDN 缓存过期后内容自然最新）。
