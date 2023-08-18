fx_version 'adamant'

game 'gta5'

client_scripts {
    "@vrp/client/Tunnel.lua",
	"@vrp/client/Proxy.lua",
    "config.lua",
    'main/client.lua',
}

server_scripts{
    "@vrp/lib/utils.lua",
    "config.lua",
    'main/server.lua',
    'vehicles.lua',
}
