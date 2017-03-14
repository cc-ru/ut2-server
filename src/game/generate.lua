local com = require("component")

local module = require("ut2-serv.modules")
local config = module.load("config")
local events = module.load("events")

local cb = com.command_block
local debug = com.debug

local field = config.world.field
local engine = events.engine

local blocks = config.world.blocks

engine:subscribe("genmap", events.priority.normal, function(handler, evt)
  for y = field.y, field.y + field.h - 1, 1 do
    for x = field.x, field.x + field.w - 1, 1 do
      for z = field.z, field.z + field.l - 1, 1 do
        local random = math.random(0, 1000)
        if random <= blocks[1][1] then
          cb.setCommand("setblock " .. table.concat({x, y, z, blocks[1][2], blocks[1][3]}, " "))
          cb.executeCommand()
          break
        elseif random <= blocks[2][1] then
          cb.setCommand("setblock " .. table.concat({x, y, z, blocks[2][2], blocks[2][3]}, " "))
          cb.executeCommand()
          break
        elseif random <= blocks[3][1] then
          cb.setCommand("setblock " .. table.concat({x, y, z, blocks[3][2], blocks[3][3]}, " "))
          cb.executeCommand()
          break
        end
      end
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
