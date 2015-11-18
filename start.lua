
timeout    = 20000000 -- 20s

-- Load files
app = require("application")  
rgb = require("rgbled")
rgb.color("red") 

-- Load wifi credencials
dofile('wificonfig.lua')



if ssid ~= nil and password ~= nil then
    local time = tmr.now()
    print("ESP8266 SSID is: " .. ssid .. " and PASSWORD is: " .. password)
     --Station mode
     wifi.setmode(wifi.STATION)
     wifi.sta.config(ssid,password)
     wifi.sta.connect()
     tmr.alarm(1, 1000, 1, function()
        if wifi.sta.status() == 5 then 
               tmr.stop(1)
                  print("Station: connected! IP: " .. wifi.sta.getip())
                 rgb.color("white") 
                 -- dofile(MAIN)
                 print('Start app')
                 app.start()
         else
                     if tmr.now() - time > timeout then
                        tmr.stop(1)
                        print("Timeout!")

                       rgb.color("blue") 
                       dofile ("configap.lua")
                  end
         end 
     end)
else
    rgb.color("blue") 
    dofile ("configap.lua")
end
