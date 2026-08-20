#!/bin/sh
. /usr/share/openclash/ruby.sh
. /usr/share/openclash/log.sh
. /lib/functions.sh

# This script is called by /etc/init.d/openclash
# Add your custom overwrite scripts here, they will be take effict after the OpenClash own srcipts

LOG_TIP "Start Running Custom Overwrite Scripts..."
LOGTIME=$(echo $(date "+%Y-%m-%d %H:%M:%S"))
LOG_FILE="/tmp/openclash.log"
#Config Path
CONFIG_FILE="$1"

    #Simple Demo:
    #Key Overwrite Demo
    #1--config path
    #2--key name
    #3--value
    #ruby_edit "$CONFIG_FILE" "['redir-port']" "7892"
    #ruby_edit "$CONFIG_FILE" "['secret']" "123456"
    #ruby_edit "$CONFIG_FILE" "['dns']['enable']" "true"
    #ruby_edit "$CONFIG_FILE" "['dns']['proxy-server-nameserver']" "['https://doh.pub/dns-query','https://223.5.5.5:443/dns-query']"

    #Hash Overwrite Demo
    #1--config path
    #2--key name
    #3--hash type value
    #ruby_edit "$CONFIG_FILE" "['dns']['nameserver-policy']" "{'+.msftconnecttest.com'=>'114.114.114.114', '+.msftncsi.com'=>'114.114.114.114', 'geosite:gfw'=>['https://dns.cloudflare.com/dns-query', 'https://dns.google/dns-query#ecs=1.1.1.1/24&ecs-override=true'], 'geosite:cn'=>['114.114.114.114'], 'geosite:geolocation-!cn'=>['https://dns.cloudflare.com/dns-query', 'https://dns.google/dns-query#ecs=1.1.1.1/24&ecs-override=true']}"
    #ruby_edit "$CONFIG_FILE" "['sniffer']" "{'enable'=>true, 'parse-pure-ip'=>true, 'force-domain'=>['+.netflix.com', '+.nflxvideo.net', '+.amazonaws.com', '+.media.dssott.com'], 'skip-domain'=>['+.apple.com', 'Mijia Cloud', 'dlg.io.mi.com', '+.oray.com', '+.sunlogin.net'], 'sniff'=>{'TLS'=>nil, 'HTTP'=>{'ports'=>[80, '8080-8880'], 'override-destination'=>true}}}"

    #Map Edit Demo
    #1--config path
    #2--map name
    #3--key name
    #4--sub key name
    #5--value
    #ruby_map_edit "$CONFIG_FILE" "['proxy-providers']" "HK" "['url']" "http://test.com"

    #Hash Merge Demo
    #1--config path
    #2--key name
    #3--hash
    #ruby_merge_hash "$CONFIG_FILE" "['proxy-providers']" "'TW'=>{'type'=>'http', 'path'=>'./proxy_provider/TW.yaml', 'url'=>'https://gist.githubusercontent.com/raw/tw_clash', 'interval'=>3600, 'health-check'=>{'enable'=>true, 'url'=>'http://cp.cloudflare.com/generate_204', 'interval'=>300}}"
    #ruby_merge_hash "$CONFIG_FILE" "['rule-providers']" "'Reject'=>{'type'=>'http', 'behavior'=>'classical', 'url'=>'https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/refs/heads/master/Clash/Apple.list', 'path'=>'./rule_provider/Apple.list', 'interval'=>86400}"

    #Array Edit Demo
    #1--config path
    #2--key name
    #3--match key name
    #4--match key value
    #5--target key name
    #6--target key value
    #ruby_arr_edit "$CONFIG_FILE" "['proxy-groups']" "['name']" "Proxy" "['type']" "smart"
    #ruby_arr_edit "$CONFIG_FILE" "['dns']['nameserver']" "" "114.114.114.114" "" "119.29.29.29"

    #Array Insert Value Demo:
    #1--config path
    #2--key name
    #3--position(start from 0, end with -1)
    #4--value
    #ruby_arr_insert "$CONFIG_FILE" "['dns']['nameserver']" "0" "114.114.114.114"

    #Array Insert Hash Demo:
    #1--config path
    #2--key name
    #3--position(start from 0, end with -1)
    #4--hash
    #ruby_arr_insert_hash "$CONFIG_FILE" "['proxy-groups']" "0" "{'name'=>'Disney', 'type'=>'select', 'disable-udp'=>false, 'use'=>['TW', 'SG', 'HK']}"
    #ruby_arr_insert_hash "$CONFIG_FILE" "['proxies']" "0" "{'name'=>'HKG 01', 'type'=>'ss', 'server'=>'cc.hd.abc', 'port'=>'12345', 'cipher'=>'aes-128-gcm', 'password'=>'123456', 'udp'=>true, 'plugin'=>'obfs', 'plugin-opts'=>{'mode'=>'http', 'host'=>'microsoft.com'}}"
    #ruby_arr_insert_hash "$CONFIG_FILE" "['listeners']" "0" "{'name'=>'name', 'type'=>'shadowsocks', 'port'=>'12345', 'listen'=>'0.0.0.0', 'rule'=>'sub-rule-1', 'proxy'=>'proxy'}"

    #Array Insert Other Array Demo:
    #1--config path
    #2--key name
    #3--position(start from 0, end with -1)
    #4--array
    #ruby_arr_insert_arr "$CONFIG_FILE" "['dns']['proxy-server-nameserver']" "0" "['https://doh.pub/dns-query','https://223.5.5.5:443/dns-query']"

    #Array Insert From Yaml File Demo:
    #1--config path
    #2--key name
    #3--position(start from 0, end with -1)
    #4--value file path
    #5--value key name in #4 file
    #ruby_arr_add_file "$CONFIG_FILE" "['dns']['fallback-filter']['ipcidr']" "0" "/etc/openclash/custom/openclash_custom_fallback_filter.yaml" "['fallback-filter']['ipcidr']"

    #Delete Array Value Demo:
    #1--config path
    #2--key name
    #3--value
    #ruby_delete "$CONFIG_FILE" "['dns']['nameserver']" "114.114.114.114"

    #Delete Key Demo:
    #1--config path
    #2--key name
    #3--key name
    #ruby_delete "$CONFIG_FILE" "['dns']" "nameserver"
    #ruby_delete "$CONFIG_FILE" "" "dns"

    #Ruby Script Demo:
    #ruby -ryaml -rYAML -I "/usr/share/openclash" -E UTF-8 -e "
    #   begin
    #      Value = YAML.load_file('$CONFIG_FILE');
    #   rescue Exception => e
    #      puts '${LOGTIME} [error] Load File Failed,【' + e.message + '】';
    #   end;

        #General
    #   begin
    #   Thread.new{
    #      Value['redir-port']=7892;
    #      Value['tproxy-port']=7895;
    #      Value['port']=7890;
    #      Value['socks-port']=7891;
    #      Value['mixed-port']=7893;
    #   }.join;

    #   rescue Exception => e
    #      puts '${LOGTIME} [error] Set General Failed,【' + e.message + '】';
    #   ensure
    #      YAML.dump(Value, '$CONFIG_FILE');
    #   end" 2>/dev/null >> $LOG_FILE


# === Prevent DNS Leak (custom channel fix 2026-08-20) ===
ruby_edit "$CONFIG_FILE" "['rules']" "begin; dns = Value['dns'].is_a?(Hash) ? Value['dns'] : {}; Value['dns'] = dns; dns['enable'] = true; dns['respect-rules'] = true; dns['prefer-h3'] = false; ['nameserver', 'fallback', 'default-nameserver', 'proxy-server-nameserver', 'direct-nameserver'].each { |key| if dns[key].is_a?(Array); dns[key] = dns[key].reject { |server| server.to_s.strip.match?(/^system($|:\/\/)/i) }; end }; custom_proxy_dns = ENV['EN_KEY2'].to_s.strip; if !custom_proxy_dns.empty?; dns['proxy-server-nameserver'] = custom_proxy_dns.split(';').map(&:strip).reject(&:empty?).uniq; elsif !dns['proxy-server-nameserver'].is_a?(Array) || dns['proxy-server-nameserver'].empty?; bootstrap_dns = dns['default-nameserver'].to_a.map { |server| server.to_s.strip }.reject { |server| server.empty? || server.match?(/^system($|:\/\/)/i) }; if bootstrap_dns.any?; dns['proxy-server-nameserver'] = bootstrap_dns.uniq; else; YAML.LOG_WARN('Prevent DNS Leak: proxy-server-nameserver is empty; configure EN_KEY2 or an IP-based default-nameserver'); end; end; add_no_resolve = lambda { |rule_list| next rule_list unless rule_list.is_a?(Array); rule_list.map { |rule| next rule unless rule.is_a?(String); parts = rule.split(',').map(&:strip); next rule if parts.length < 3; options = parts.drop(3).map { |part| part.downcase }; next rule if options.include?('no-resolve') || options.include?('src'); rule_type = parts[0].to_s.upcase; needs_no_resolve = ['IP-CIDR', 'IP-CIDR6', 'GEOIP'].include?(rule_type); if rule_type == 'RULE-SET'; provider = (Value['rule-providers'] || {})[parts[1].to_s]; needs_no_resolve = provider.is_a?(Hash) && provider['behavior'].to_s.strip.downcase == 'ipcidr'; end; if needs_no_resolve; parts.insert(3, 'no-resolve'); parts.join(','); else; rule; end } }; if Value['sub-rules'].is_a?(Hash); Value['sub-rules'].each { |name, rule_list| Value['sub-rules'][name] = add_no_resolve.call(rule_list) }; end; groups = Value['proxy-groups'].is_a?(Array) ? Value['proxy-groups'] : []; Value['proxy-groups'] = groups; guard_name = 'COCR-DNS-Leak-Guard'; requested_target = ENV['EN_KEY1'].to_s.strip; builtins = ['GLOBAL']; valid_targets = builtins + groups.map { |group| group['name'] if group.is_a?(Hash) }.compact + Value['proxies'].to_a.map { |proxy| proxy['name'] if proxy.is_a?(Hash) }.compact; unsafe_targets = ['DIRECT', 'REJECT', 'REJECT-DROP', 'PASS', 'COMPATIBLE']; use_custom_target = !requested_target.empty? && valid_targets.include?(requested_target) && !unsafe_targets.include?(requested_target.upcase); if use_custom_target; target = requested_target; else; if !requested_target.empty?; YAML.LOG_WARN('Prevent DNS Leak: invalid or non-proxy EN_KEY1, fallback to COCR-DNS-Leak-Guard'); end; groups.reject! { |group| group.is_a?(Hash) && group['name'].to_s == guard_name }; groups << {'name' => guard_name, 'type' => 'select', 'include-all' => true, 'exclude-type' => 'Direct', 'empty-fallback' => 'REJECT'}; target = guard_name; end; rules = add_no_resolve.call(Value['rules']); rules = [] unless rules.is_a?(Array); terminal_found = false; rules.map! { |rule| if rule.is_a?(String) && ['MATCH', 'FINAL'].include?(rule.split(',', 2)[0].to_s.strip.upcase); terminal_found = true; 'MATCH,' + target; else; rule; end }; rules << 'MATCH,' + target unless terminal_found; rules.uniq end"
exit 0

