-- file : config.lua
local module = {}

module.HOST = "mqtt.controlboard.net"  
module.PORT = 1883  
module.ID = node.chipid().."mcu"

return module  
