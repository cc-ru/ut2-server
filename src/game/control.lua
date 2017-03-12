local com = require("component")
local module = require("ut2-serv.modules")

local db = module.load("db")
local events = module.load("events")
local config = module.load("config")

local EventEngine = events.engine

local debug = com.debug

local chestSpawnInterval = config.game.bonusSpawnInterval
local scoreUpdateInterval = config.game.scoreUpdateInterval
local syncMsgInterval = config.game.syncMsgInterval

EventEngine:subscribe("setplayerlist", events.priority.high, function(handler, evt)
  for team, name in pairs(evt.players) do
    db.teams[team].name = name
  end
end)

EventEngine:subscribe("updatescore", events.priority.high, function(handler, evt)
  print("[" .. db.remaining .. "] Updating score")
  local world = debug.getWorld()
  for team, coords in pairs(inv) do
    db.teams[team].score = getCoins(world, table.unpack(coords))
  end
end)

EventEngine:subscribe("worldtick", events.priority.high, function(handler, evt)
  db.remaining = db.remaining - 1
  db.scoreUpdate = db.scoreUpdate - 1
  db.syncMsg = db.syncMsg - 1
  if db.remaining <= 0 then
    EventEngine:push(events.GameStop())
  end
  if db.scoreUpdate <= 0 then
    EventEngine:push(events.UpdateScore())
    db.scoreUpdate = scoreUpdateInterval
  end
  if db.syncMsg <= 0 then
    EventEngine:push(events.SendMsg {"time", db.remaining, db.time})
    db.syncMsg = syncMsgInterval
  end
end)

EventEngine:subscribe("gamestart", events.priority.high, function(handler, evt)
  if not db.started then
    db.started = true
    EventEngine:push(events.GenerateMap())
    EventEngine:push(events.UpdateScore())
    db.remaining = db.time
    db.timers.worldTick = EventEngine:timer(
      1, events.WorldTick, math.huge)
    db.timers.randomLoot = EventEngine:timer(
      bonusSpawnInterval, events.RandomBonus, math.huge)
    EventEngine:push(events.SendMsg {"gamestart"})
    print("[" .. db.remaining .. "] THE GAME STARTED")
  end
end)

EventEngine:subscribe("gamestop", events.priority.high, function(handler, evt)
  db.started = false
  EventEngine:push(events.SendMsg {"gamestop"})
  EventEngine:push(events.ClearMap())
  EventEngine:push(events.UpdateScore())
  EventEngine:push(events.DestroyLoot())
  db.timers.worldTick:destroy()
  db.timers.randomLoot:destroy()
  print("[" .. db.remaining .. "] THE GAME STOPPED")
end)
