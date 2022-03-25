require "json"
require "resolv"
require "ipaddr"

cwd = File.dirname(__FILE__)
Dir.chdir(cwd)

###

template = File.read("../template/servers.json")
ca2048 = File.read("../static/ca2048.pem")
ca4096 = File.read("../static/ca4096.pem")

json = JSON.parse(template)

cfg = {
  compressionFraming: 2,
  keepAliveSeconds: 10,
  renegotiatesAfterSeconds: 0,
  usesPIAPatches: true,
  checksEKU: true
}

groups = json["groups"]
udp_ports = groups["ovpnudp"][0]["ports"]
tcp_ports = groups["ovpntcp"][0]["ports"]

ep = []
udp_ports.each { |p| ep << "UDP:#{p}" }
tcp_ports.each { |p| ep << "TCP:#{p}" }

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
  ovpn: {
    cfg: recommended_cfg,
    endpoints: ep
  }
}
strong = {
  id: "strong",
  name: "Strong",
  comment: "256-bit encryption",
  ovpn: {
    cfg: strong_cfg,
    endpoints: ep
  }
}
presets = [recommended, strong]

defaults = {
  :username => "p1234567",
  :country => "US"
}

###

#info = json["info"]
#ports = info["vpn_ports"]

servers = []

json["regions"].each { |v|
  hostname = v["dns"]
  #id = v["id"]
  id = hostname.split('.')[0]
  country = v["country"]

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

  server = {
    :id => id,
    :country => country,
    :hostname => hostname,
    :addrs => addresses
  }
  id_comps = id.split('-')
  server[:area] = id_comps[1] if id_comps.length > 1
  servers << server
}

###

infra = {
  :servers => servers,
  :presets => presets,
  :defaults => defaults
}

puts infra.to_json
puts
