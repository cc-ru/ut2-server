-- The world interaction module.
--
-- Sets and unsets chests with coins.

local com = require("component")
local module = require("ut2-serv.modules")

local db = module.load("db")
local events = module.load("events")
local config = module.load("config")
local gui = module.load("gui")

local cb = com.command_block
local debug = com.debug

local EventEngine = events.engine

local field = config.world.field

EventEngine:subscribe("spawnbonus", events.priority.high, function(handler, evt)
  cb.setCommand("summon Item " ..
                evt.x .. " " ..
                evt.y .. " " ..
                evt.z .. " " ..
                "{" ..
                  "NoGravity:1b," ..
                  "Invulnerable:1b," ..
                  "CustomName:\"Bonus\"," ..
                  "CustomNameVisible:0b," ..
                  "Glowing:1b," ..
                  "Age:" .. 6000 - (evt.lifetime * 20) .. "s," ..
                  "PickupDelay:32767s," ..
                  "Item:{" ..
                    "Count:" .. evt.count .. "b," ..
                    "Damage:" .. evt.meta .. "s," ..
                    "id:" .. ("%q"):format(evt.id) .. "," ..
                    "tag:" .. evt.tag ..
                  "}" ..
                "}")
  cb.executeCommand()
end)

EventEngine:subscribe("destroyloot", events.priority.high, function(handler, evt)
  cb.setCommand("minecraft:kill @e[type=Item,name=Bonus]")
  cb.executeCommand()
end)

EventEngine:subscribe("randombonus", events.priority.high, function(handler, evt)
  local x, y, z = math.random(field.x, field.x + field.w - 1),
                  math.random(field.y, field.y + field.h - 1),
                  math.random(field.z, field.z + field.l - 1)
  for _, bonus in pairs(config.world.bonuses) do
    if math.random(0, 99) / 100 < bonus[1] then
      EventEngine:push(events.SpawnBonus {
        x = x,
        y = y,
        z = z,
        lifetime = bonus[6],
        count = bonus[2],
        meta = bonus[4],
        id = bonus[3],
        tag = bonus[5]
      })
      EventEngine:push(events.SendMsg {"spawnedbonus", x, y, z})
      gui.log("Spawned a bonus at " .. x .. ", " .. y .. ", " .. z .. ": " .. bonus[2] .. " × " .. bonus[3] .. "/" .. bonus[4] .. " for " .. bonus[6] .. "s")
    end
  end
end)
