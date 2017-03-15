local module = require("ut-serv.modules")
local events = module.load("events")
local gui = require("gui")

local EventEngine = events.engine

EventEngine:subscribe("tunnelmsg", events.priority.normal, function(handler, evt)
  local x, y, z = evt[6], evt[7], evt[8]
  local bombType = evt[9]
  gui.log("Set bomb '" .. bombType .. "' @ " .. x .. " " .. y .. " " .. z)
end)
