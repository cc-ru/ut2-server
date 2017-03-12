-- The world interaction module.
--
-- Sets and unsets chests with coins.

local com = require("component")
local module = require("ut2-serv.modules")

local db = module.load("db")
local events = module.load("events")
local config = module.load("config")

local debug = com.debug

local EventEngine = events.engine

local field = config.world.field

EventEngine:subscribe("spawnbonus", events.priority.high, function(handler, evt)
  local result = debug.runCommand("summon item " ..
                                  evt.x .. " " ..
                                  evt.y .. " " ..
                                  evt.z .. " " ..
                                  "{" ..
                                    "NoGravity:1," ..
                                    "Invulnerable:1," ..
                                    "CustomName:\"Bonus\"," ..
                                    "CustomNameVisible:0," ..
                                    "Glowing:1," ..
                                    "Age:" .. 6000 - evt.lifetime .. "," ..
                                    "PickupDelay:32767," ..
                                    "Item:{" ..
                                      "Count:" .. evt.count .. "," ..
                                      "Damage:" .. evt.meta .. "," ..
                                      "id:" .. evt.id .. "," ..
                                      "tag:" .. evt.tag ..
                                    "}" ..
                                  "}")
  if not result then
    evt:cancel()
  end
end)

EventEngine:subscribe("destroyloot", events.priority.high, function(handler, evt)
  debug.runCommand("kill @e[type=item,name=Bonus]")
end)

EventEngine:subscribe("randombonus", events.priority.high, function(handler, evt)
  local x, y, z = math.random(field.x, field.x + field.w - 1),
                  math.random(field.y, field.y + field.h - 1),
                  math.random(field.z, field.z + field.l - 1)
  for _, bonus in pairs(config.bonuses) do
    if math.random(0, 99) / 100 < bonus[1] then
      EventEngine:push(events.SetBonus {
        x = x,
        y = y,
        z = z,
        lifetime = bonus[6],
        count = bonus[2],
        meta = data[4],
        id = data[3],
        tag = data[5]
      })
      EventEngine:push(events.SendMsg {"spawnedbonus", x, y, z})
      print("[" .. db.remaining .. "] Spawned a bonus at " .. x .. ", " .. y .. ", " .. z .. ": " .. bonus[2] .. " × " .. bonus[3] .. "/" .. bonus[4] .. " for " .. bonus[6] .. "s")
    end
  end
end)
