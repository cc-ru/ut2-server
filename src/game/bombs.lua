local com = require("component")

local module = require("ut2-serv.modules")
local events = module.load("events")
local gui = module.load("gui")

local cb = com.command_block

local EventEngine = events.engine

EventEngine:subscribe("tunnelmsg", events.priority.normal, function(handler, evt)
  local x, y, z = evt[6], evt[7], evt[8]
  local bombType = evt[9]
  local command = evt[10]
  cb.setCommand(command)
  cb.executeCommand()
  gui.log("Got command [" .. x .. ", " .. y .. ", " .. z .. ": " .. bombType .. "] " .. command)
end)
