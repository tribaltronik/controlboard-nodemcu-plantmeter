-- file : application.lua
local module = {}  
m = nil
config = require("config")
-- DHT sensor
dhtpin = 4 --  data pin, GPIO2

-- DHT22 sensor logic
function get_dht22() 
    DHT= require("dht22_min")
    DHT.read(dhtpin)
    temperature = DHT.getTemperature()
    humidity = DHT.getHumidity()
 
    if humidity == nil then
        print("Error reading from DHT22")
    else
        print("Temperature: "..(temperature / 10).."."..(temperature % 10).." deg C")
        print("Humidity: "..(humidity / 10).."."..(humidity % 10).."%")
        m:publish(config.ID .. "/temp",'{"value":"' ..(temperature / 10).."."..(temperature % 10)..'"}',0,1)
        m:publish(config.ID .. "/hum",'{"value":"' ..(humidity / 10).."."..(humidity % 10)..'"}',0,1)
    end
    DHT = nil
    package.loaded["dht22_min"]=nil  
end

function readPlant()
    plant = adc.read(0)
    print("sent plant value: ",plant)
    m:publish(config.ID .."/plant",'{"value":"' ..plant..'"}',0,1)
end


-- Sends a simple ping to the broker
local function send_ping()  
    if wifi.sta.status() == 5 then 
        m:publish(config.ID .. "/ping",'{"id":"' .. config.ID..'","ip":"' .. wifi.sta.getip()..'"}',0,0)
        get_dht22() 
        readPlant()
     else
        m:close()
        mqtt_start()
     end   
end

-- Sends my id to the broker for registration
local function register_myself()  
    m:subscribe(config.ID,0,function(conn)
        print("Successfully subscribed to data endpoint: "..config.ID)
    end)
end

local function mqtt_start()  
    print("start mqtt")
    m = mqtt.Client(config.ID, 120)
    -- register message callback beforehand
    m:on("message", function(conn, topic, data) 
      if data ~= nil then
        print(topic .. ": " .. data)
        if data == "alive" then
            m:publish(config.ID .. "/status",'{"id":"' .. config.ID..'","ip":"' .. wifi.sta.getip()..'"}',0,0)
        end
        -- do something, we have received a message
      end
    end)
    -- Connect to broker
    m:connect(config.HOST, config.PORT, 0, 1, function(con) 
        rgb.color("green") -- Green
        register_myself()
        -- And then pings each 1000 milliseconds
        tmr.stop(6)
        send_ping() 
        tmr.alarm(6, 60000, 1, send_ping)
    end) 

end

function module.start()  
  mqtt_start()
end

return module  
