require "json"
require "resolv"
require "ipaddr"

cwd = File.dirname(__FILE__)
Dir.chdir(cwd)

servers = File.read("../template/servers.json")
json = JSON.parse(servers)

ca2048 = File.read("../certs/ca2048.pem")
ca4096 = File.read("../certs/ca4096.pem")

###

#info = json["info"]
#ports = info["vpn_ports"]

pools = []
json.each { |k, v|
    next if k == "info"

    hostname = v["dns"]

    addresses = nil
    if ARGV.length > 0 && ARGV[0] == "noresolv"
        addresses = []
        #addresses = ["1.2.3.4"]
    else
        addresses = Resolv.getaddresses(hostname)
    end
    addresses.map! { |a|
        IPAddr.new(a).to_i
    }

    id = hostname.split('.')[0]
    pool = {
        :id => id,
        :name => v["name"],
        :country => v["country"],
        :hostname => hostname,
        :addrs => addresses
    }
    pools << pool
}

recommended = {
    id: "recommended",
    name: "Recommended",
    comment: "128-bit encryption",
    cfg: {
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
        cipher: "AES-128-GCM",
        auth: "SHA1",
        ca: ca2048,
        frame: 1,
        ping: 10,
        reneg: 3600,
        pia: true
    }
}
strong = {
    id: "strong",
    name: "Strong",
    comment: "256-bit encryption (slower)",
    cfg: {
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
        cipher: "AES-256-GCM",
        auth: "SHA256",
        ca: ca4096,
        frame: 1,
        ping: 10,
        reneg: 3600,
        pia: true
    }
}
presets = [recommended, strong]

defaults = {
    :username => "p1234567",
    :pool => "us-east",
    :preset => "recommended"
}

###

infra = {
    :pools => pools,
    :presets => presets,
    :defaults => defaults
}

puts infra.to_json
puts
