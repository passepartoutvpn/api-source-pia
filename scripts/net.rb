require "json"
require "resolv"
require "ipaddr"

cwd = File.dirname(__FILE__)
Dir.chdir(cwd)

###

template = File.read("../template/servers.json")
ca = File.read("../static/ca.pem")

json = JSON.parse(template)

cfg = {
  ca: ca,
  cipher: "AES-256-CBC",
  digest: "SHA256",
  compressionFraming: 2,
  keepAliveSeconds: 10,
  renegotiatesAfterSeconds: 0,
  checksEKU: true
}

groups = json["groups"]
udp_ports = groups["ovpnudp"][0]["ports"]
tcp_ports = groups["ovpntcp"][0]["ports"]

ep = []
udp_ports.each { |p| ep << "UDP:#{p}" }
tcp_ports.each { |p| ep << "TCP:#{p}" }

recommended = {
  id: "default",
  name: "Default",
  comment: "256-bit encryption",
  ovpn: {
    cfg: cfg,
    endpoints: ep
  }
}
presets = [recommended]

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
