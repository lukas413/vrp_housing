description "vrp_housing v0.10"

dependency "vrp"

client_scripts{ 
  "lib/Tunnel.lua",
  "lib/Proxy.lua",
  "shared/config.lua",
  "client/main.lua"
}

server_scripts{ 
  '@mysql-async/lib/MySQL.lua',
  "@vrp/lib/utils.lua",
  "server/main.lua"
}

