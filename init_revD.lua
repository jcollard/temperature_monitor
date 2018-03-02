oled_sda = 4
oled_scl = 3
dht22_1_pin = 2

function showStatusPage ()
    disp:setFont (u8g.font_6x10)
    disp:setFontPosTop()

    disp:firstPage()
    repeat
        disp:drawStr(0,0,  "WiFi status : " .. wifi.sta.status())      
        ipaddr = wifi.sta.getip()
        if (ipaddr == nil) then
          ipaddr_human = "(none)"
        else
          ipaddr_human = ipaddr:match("([^\s]+).*")
        end
        disp:drawStr(0,20, "IP : " .. ipaddr_human)
        disp:drawStr(0,30, "ID : " .. node.chipid())
    until disp:nextPage() == false
end

function init_OLED(sda,scl) --Set up the u8glib lib
     sla = 0x3c
     i2c.setup(0, sda, scl, i2c.SLOW)
     disp = u8g.ssd1306_128x64_i2c(sla)
     disp:setFont (u8g.font_fub25)
     disp:setFontRefHeightExtendedText()
     disp:setDefaultForegroundColor()
     disp:setFontPosTop()
     disp:begin()
end

function init_DHT22 ()
    dht22 = require("dht")
end

function showInfo (temp1, humi1)
    disp:setFont (u8g.font_fub25)
    disp:setFontPosTop()
    disp:firstPage()
    repeat
        disp:drawStr(0,0, temp1 .. "\176C")
        disp:drawStr(10,32, humi1 .. "%")
    until disp:nextPage() == false
end

intervalCounter = 0
intervalMax = 12
host = "http://45.55.217.238:8881/senddata"

function convert_str (value_int, value_dec)
    value = 1000*value_int + value_dec;
    if value < 0 then
        value = -value
        result = "-"
    else
        result = ""
    end
    value = value + 5
    result = result .. string.format("%d.%01d", value / 1000, (value % 1000) / 100)
    return result
end

function readDHT22 (datapin)
    status, temp_int, humi_int, temp_dec, humi_dec = dht22.read(datapin)

    if status == dht.OK then
        temp_str = convert_str (temp_int, temp_dec)
        humi_str = convert_str (humi_int, humi_dec)
    else
        temp_str = "n/a"
        humi_str = "n/a"
    end
    return temp_str, humi_str
end

function timerFunction()
    temp1_str, humi1_str = readDHT22 (dht22_1_pin)
        
    if (intervalCounter == 1) or (intervalCounter == 7) then
      showStatusPage()
    else
      showInfo (temp1_str, humi1_str)
    end

    if (intervalCounter == 0) or (intervalCounter == 6) then
        url = string.format("%s?id=%d&temp1=%s&humi1=%s", host, node.chipid(), temp1_str, humi1_str)
        http.get(url)
    end

    if intervalCounter == 0 then
        intervalCounter = intervalMax - 1
    else
        intervalCounter = intervalCounter - 1
    end
end

init_OLED (oled_sda, oled_scl)
init_DHT22 ()

tmr.alarm(0, 5000, tmr.ALARM_AUTO, timerFunction)
