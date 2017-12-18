#!/usr/bin/lua
local http = require("socket.http")

function parseargs(s)
  local arg = {}
  string.gsub(s, "([%-%w]+)=([\"'])(.-)%2", function (w, _, a)
    arg[w] = a
  end)
  return arg
end
    
function collect(s)
  local stack = {}
  local top = {}
  table.insert(stack, top)
  local ni,c,label,xarg, empty
  local i, j = 1, 1
  while true do
    ni,j,c,label,xarg, empty = string.find(s, "<(%/?)([%w:]+)(.-)(%/?)>", i)
    if not ni then break end
    local text = string.sub(s, i, ni-1)
    if not string.find(text, "^%s*$") then
      table.insert(top, text)
    end
    if empty == "/" then  -- empty element tag
      table.insert(top, {label=label, xarg=parseargs(xarg), empty=1})
    elseif c == "" then   -- start tag
      top = {label=label, xarg=parseargs(xarg)}
      table.insert(stack, top)   -- new level
    else  -- end tag
      local toclose = table.remove(stack)  -- remove top
      top = stack[#stack]
      if #stack < 1 then
        error("nothing to close with "..label)
      end
      if toclose.label ~= label then
        error("trying to close "..toclose.label.." with "..label)
      end
      table.insert(top, toclose)
    end
    i = j+1
  end
  local text = string.sub(s, i)
  if not string.find(text, "^%s*$") then
    table.insert(stack[#stack], text)
  end
  if #stack > 1 then
    error("unclosed "..stack[#stack].label)
  end
  return stack[1]
end

function getlocation()
    b, c, h = http.request("http://geoip.ubuntu.com/lookup")
    print(b, c, h)
    if b == nil then return end
    loc_page = collect(b)
    lat = loc_page[2][10][1]
    lon = loc_page[2][11][1]
    return lat, lon
end

function getweather()
    lat, lon = getlocation()
    if lat == nil then return end
    b, c, h = http.request("http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml?query="..lat..","..lon)
    w_page = collect(b)
    weather=w_page[1][14][1]
    temp=w_page[1][17][1]
    humidity=w_page[1][18][1]
    wind_direction=w_page[1][20][1]
    wind_speed_m=w_page [1][22][1]/2.2369362920544
    city=w_page[1][5][2][1]
    upd=os.date("*t", w_page[1][10][1])
    updated=string.format("%02.0f", upd.day).."."..string.format("%02.0f", upd.month).."."..upd.year.." "..string.format("%02.0f", upd.hour)..":"..string.format("%02.0f", upd.min)

    if string.match(string.lower(weather), "rain") then
        icon = "⛆"
    elseif string.match(string.lower(weather), "storm") then
        icon = "⛈"
    elseif string.match(string.lower(weather), "cloud") then
        icon = "⛅"
    elseif string.match(string.lower(weather), "clear") then
        icon = "☼"
    elseif string.match(string.lower(weather), "snow") then
        icon = "⛄"
    else
	icon = ""
    end

    return icon, weather, temp, humidity, wind_direction, string.format("%.2f", wind_speed_m), city, updated
end
