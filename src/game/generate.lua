local com = require("component")

local module = require("ut2-serv.modules")
local config = module.load("config")
local events = module.load("events")

local debug = com.debug

local field = config.world.field
local engine = events.engine

engine:subscribe("genmap", events.priority.normal, function(handler, evt)
  for x = field.x, field.x + field.w - 1, 1 do
    for y = field.y, field.y + field.h - 1, 1 do
      for z = field.z, field.z + field.l - 1, 1 do
        local random = math.random(0, 1000) / 1000
        local index = 1
        for i = 1, #config.world.blocks, 1 do
          local block = config.world.blocks[i]
          if random < block[1] then
            break
          end
          index = i + 1
        end
        local block = config.world.blocks[index]
        debug.getWorld().setBlock(x, y, z, block[2], block[3])
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
