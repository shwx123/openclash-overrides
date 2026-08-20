#!/bin/sh
# ============================================================
# Prevent DNS Leak - OpenClash v0.47.156 custom-channel fix
# 维护: shwx123/openclash-overrides (2026-08-20)
# ------------------------------------------------------------
# 背景:
#   Aethersailor Prevent_DNS_Leak.conf 在 OpenClash v0.47.156 +
#   yaml 覆写模块(Custom_Clash_*)组合下, [Overwrite] 段 ruby 的
#   groups/rules 修改会被 [General] 段处理覆盖, 导致
#   COCR-DNS-Leak-Guard 组 / MATCH 重定向 / no-resolve 补全不落地。
# 修复:
#   将下方 ruby_edit 行追加到路由器:
#     /etc/openclash/custom/openclash_custom_overwrite.sh
#   必须放在文件中的 "exit 0" 之前 (custom 通道在模块覆写之后执行,
#   修改可落地; 追加在 exit 0 之后不会执行)。
# 验证:
#   运行配置出现 COCR-DNS-Leak-Guard 组 + MATCH,COCR-DNS-Leak-Guard
#   + respect-rules: true + proxy-server-nameserver。
# 注意:
#   Prevent_DNS_Leak 模块本身仍需启用 ([General] 段提供
#   respect-rules / proxy-server-nameserver 自动设置)。
# ============================================================

ruby_edit "$CONFIG_FILE" "['rules']" "begin; dns = Value['dns'].is_a?(Hash) ? Value['dns'] : {}; Value['dns'] = dns; dns['enable'] = true; dns['respect-rules'] = true; dns['prefer-h3'] = false; ['nameserver', 'fallback', 'default-nameserver', 'proxy-server-nameserver', 'direct-nameserver'].each { |key| if dns[key].is_a?(Array); dns[key] = dns[key].reject { |server| server.to_s.strip.match?(/^system($|:\/\/)/i) }; end }; custom_proxy_dns = ENV['EN_KEY2'].to_s.strip; if !custom_proxy_dns.empty?; dns['proxy-server-nameserver'] = custom_proxy_dns.split(';').map(&:strip).reject(&:empty?).uniq; elsif !dns['proxy-server-nameserver'].is_a?(Array) || dns['proxy-server-nameserver'].empty?; bootstrap_dns = dns['default-nameserver'].to_a.map { |server| server.to_s.strip }.reject { |server| server.empty? || server.match?(/^system($|:\/\/)/i) }; if bootstrap_dns.any?; dns['proxy-server-nameserver'] = bootstrap_dns.uniq; else; YAML.LOG_WARN('Prevent DNS Leak: proxy-server-nameserver is empty; configure EN_KEY2 or an IP-based default-nameserver'); end; end; add_no_resolve = lambda { |rule_list| next rule_list unless rule_list.is_a?(Array); rule_list.map { |rule| next rule unless rule.is_a?(String); parts = rule.split(',').map(&:strip); next rule if parts.length < 3; options = parts.drop(3).map { |part| part.downcase }; next rule if options.include?('no-resolve') || options.include?('src'); rule_type = parts[0].to_s.upcase; needs_no_resolve = ['IP-CIDR', 'IP-CIDR6', 'GEOIP'].include?(rule_type); if rule_type == 'RULE-SET'; provider = (Value['rule-providers'] || {})[parts[1].to_s]; needs_no_resolve = provider.is_a?(Hash) && provider['behavior'].to_s.strip.downcase == 'ipcidr'; end; if needs_no_resolve; parts.insert(3, 'no-resolve'); parts.join(','); else; rule; end } }; if Value['sub-rules'].is_a?(Hash); Value['sub-rules'].each { |name, rule_list| Value['sub-rules'][name] = add_no_resolve.call(rule_list) }; end; groups = Value['proxy-groups'].is_a?(Array) ? Value['proxy-groups'] : []; Value['proxy-groups'] = groups; guard_name = 'COCR-DNS-Leak-Guard'; requested_target = ENV['EN_KEY1'].to_s.strip; builtins = ['GLOBAL']; valid_targets = builtins + groups.map { |group| group['name'] if group.is_a?(Hash) }.compact + Value['proxies'].to_a.map { |proxy| proxy['name'] if proxy.is_a?(Hash) }.compact; unsafe_targets = ['DIRECT', 'REJECT', 'REJECT-DROP', 'PASS', 'COMPATIBLE']; use_custom_target = !requested_target.empty? && valid_targets.include?(requested_target) && !unsafe_targets.include?(requested_target.upcase); if use_custom_target; target = requested_target; else; if !requested_target.empty?; YAML.LOG_WARN('Prevent DNS Leak: invalid or non-proxy EN_KEY1, fallback to COCR-DNS-Leak-Guard'); end; groups.reject! { |group| group.is_a?(Hash) && group['name'].to_s == guard_name }; groups << {'name' => guard_name, 'type' => 'select', 'include-all' => true, 'exclude-type' => 'Direct', 'empty-fallback' => 'REJECT'}; target = guard_name; end; rules = add_no_resolve.call(Value['rules']); rules = [] unless rules.is_a?(Array); terminal_found = false; rules.map! { |rule| if rule.is_a?(String) && ['MATCH', 'FINAL'].include?(rule.split(',', 2)[0].to_s.strip.upcase); terminal_found = true; 'MATCH,' + target; else; rule; end }; rules << 'MATCH,' + target unless terminal_found; rules.uniq end"


