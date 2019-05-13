require "json"
require "resolv"
require "ipaddr"

cwd = File.dirname(__FILE__)
Dir.chdir(cwd)

###

servers = File.read("../template/servers.json")
ca2048 = File.read("../static/ca2048.pem")
ca4096 = File.read("../static/ca4096.pem")

cfg = {
    ep: [
        "UDP:1194",
        "UDP:8080",
        "UDP:9201",
        "UDP:53",
        "UDP:1198",
        "UDP:1197",
        "TCP:443",
        "TCP:110",
        "TCP:80",
        "TCP:502",
        "TCP:501"
    ],
    frame: 1,
    ping: 10,
    reneg: 3600,
    pia: true,
    eku: true
}

external = {
    "hostname": "${id}.privateinternetaccess.com"
}

recommended_cfg = cfg.dup
recommended_cfg["ca"] = ca2048
recommended_cfg["cipher"] = "AES-128-GCM"

strong_cfg = cfg.dup
strong_cfg["ca"] = ca4096
strong_cfg["cipher"] = "AES-256-GCM"

recommended = {
    id: "recommended",
    name: "Recommended",
    comment: "128-bit encryption",
    cfg: recommended_cfg,
    external: external
}
strong = {
    id: "strong",
    name: "Strong",
    comment: "256-bit encryption",
    cfg: strong_cfg,
    external: external
}
presets = [recommended, strong]

defaults = {
    :username => "p1234567",
    :pool => "us-east",
    :preset => "recommended"
}

###

#info = json["info"]
#ports = info["vpn_ports"]

pools = []

json = JSON.parse(servers)
json.each { |k, v|
    next if k == "info"

    hostname = v["dns"]

    addresses = nil
    if ARGV.include? "noresolv"
        addresses = []
        #addresses = ["1.2.3.4"]
    else
        addresses = Resolv.getaddresses(hostname)
    end
    addresses.map! { |a|
        IPAddr.new(a).to_i
    }

    id = hostname.split('.')[0]
    id_comps = id.split('-')
    pool = {
        :id => id,
        :country => v["country"],
        :hostname => hostname,
        :addrs => addresses
    }
    pool[:area] = id_comps[1] if id_comps.length > 1
    pools << pool
}

###

infra = {
    :pools => pools,
    :presets => presets,
    :defaults => defaults
}

puts infra.to_json
puts
