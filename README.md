# OpenClash 自定义覆写模块

> 从 sdba-pve2-openwrt (V302) 和 qqhy-pve-openwrt (V104) 导出，GitHub 维护。
> 仅包含自定义规则，不包含订阅配置（订阅源见 [HenryChiao/MIHOMO_YAMLS](https://github.com/HenryChiao/MIHOMO_YAMLS)）。

## 目录结构

```
overwrite/          ← 覆写模块（上传到 /etc/openclash/overwrite/）
├── TailscaleDirect ← Tailscale 直连 + tailnet 域名 Fake-IP 排除
└── opencode-direct ← opencode.ai 直连规则

custom/             ← 自定义文件（上传到 /etc/openclash/custom/）
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
- **URL**: `https://raw.githubusercontent.com/<your-username>/openclash-overrides/main/overwrite/TailscaleDirect`
- **配置匹配**: `all`
- **启用**: ✅

## 注意事项

- `[YAML]` 段的 `+rules` 是追加操作，不会覆盖已有规则
- `fake-ip-filter+` 是追加操作，保留原有 Fake-IP 排除列表
- 修改后需重启 OpenClash 才能生效
