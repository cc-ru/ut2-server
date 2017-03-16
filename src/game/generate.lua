local com = require("component")

local module = require("ut2-serv.modules")
local config = module.load("config")
local events = module.load("events")

local cb = com.command_block
local debug = com.debug

local field = config.world.field
local engine = events.engine

engine:subscribe("genmap", events.priority.normal, function(handler, evt)
  for k, v in pairs(config.world.blocks) do
    for i = 1, v[1], 1 do
      local x, y, z = math.random(field.x, field.x + field.w - 1),
                      math.random(field.y, field.y + field.h - 1),
                      math.random(field.z, field.z + field.l - 1)
      cb.setCommand("setblock " .. table.concat({x, y, z, v[2], v[3]}, " "))
      cb.executeCommand()
    end
  end
end)

engine:subscribe("clearmap", events.priority.normal, function(handler, evt)
  debug.getWorld().setBlocks(field.x, field.y, field.z,
                             field.x + field.w - 1,
                             field.y + field.h - 1,
                             field.z + field.l - 1,
                             "minecraft:air", 0)
end)
