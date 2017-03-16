local com = require("component")

local module = require("ut2-serv.modules")
local events = module.load("events")
local gui = module.load("gui")

local cb = com.command_block

local EventEngine = events.engine

EventEngine:subscribe("tunnelmsg", events.priority.normal, function(handler, evt)
  local x, y, z = evt[5], evt[6], evt[7]
  local bombType = evt[8]
  local command = evt[9]
  cb.setCommand(command)
  cb.executeCommand()
  gui.log("Got command [" .. x .. ", " .. y .. ", " .. z .. ": " .. bombType .. "] " .. command)
end)
