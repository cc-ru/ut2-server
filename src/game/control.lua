local com = require("component")
local module = require("ut2-serv.modules")

local db = module.load("db")
local events = module.load("events")
local gui = module.load("gui")
local config = module.load("config")

local EventEngine = events.engine

local cb = com.command_block
local debug = com.debug

local bonusSpawnInterval = config.game.bonusSpawnInterval
local scoreUpdateInterval = config.game.scoreUpdateInterval
local syncMsgInterval = config.game.syncMsgInterval

local function title(subtitle, title, fin, stay, fout)
  if fin then
    cb.setCommand([[title @a times ]] .. fin .. [[ ]] .. stay .. [[ ]] .. fout)
    cb.executeCommand()
  end
  cb.setCommand([[title @a subtitle {"text":]] .. ("%q"):format(subtitle) .. [[, "color": "dark_gray", "italic": true}]])
  cb.executeCommand()
  cb.setCommand([[title @a title {"text":]] .. ("%q"):format(title) .. [[, "color": "dark_red", "bold": true}]])
  cb.executeCommand()
  cb.setCommand([[playsound entity.experience_orb.pickup block @a 0 64 0 4 1 1]])
  cb.executeCommand()
end

EventEngine:subscribe("setplayerlist", events.priority.high, function(handler, evt)
  for team, name in pairs(evt.players) do
    db.teams[team].name = name
  end
end)

EventEngine:subscribe("updatescore", events.priority.high, function(handler, evt)
  db.updatingScore = true
  local world = debug.getWorld()
  EventEngine:push(events.SendMsg {"whoalive"})
  local alive = {blue = 0, green = 0, red = 0, yellow = 0}
  local recdResponse = {}
  local subscriber = EventEngine:subscribe("recvmsg", events.priority.high, function(handler, evt)
    local team, x, y, z = evt[6], evt[7], evt[8], evt[9]
    if evt[5] == "i'm alive" then
      if not recdResponse[evt[2]] then
        if type(team) == "string" and alive[team] then
          if type(x) == "number" and type(y) == "number" and type(z) == "number" then
            if debug.getWorld().getBlockId(x, y, z) == config.world.robotid then
              alive[team] = alive[team] + 1
              recdResponse[evt[2]] = true
            end
          end
        end
      end
    end
  end)
  os.sleep(config.game.alivePollTime)
  subscriber:destroy()
  for k, v in pairs(alive) do
    db.teams[k].alive = v
  end
  db.updatingScore = false
end)

EventEngine:subscribe("worldtick", events.priority.high, function(handler, evt)
  db.remaining = math.max(0, db.remaining - 1)
  db.scoreUpdate = math.max(0, db.scoreUpdate - 1)
  db.syncMsg = math.max(0, db.syncMsg - 1)
  if not db.updatingScore then
    if db.remaining <= 0 then
      gui.log("Time is out")
      EventEngine:push(events.GameStop())
    end
    if db.scoreUpdate <= 0 then
      gui.log("Updating score...")
      EventEngine:push(events.UpdateScore())
      db.scoreUpdate = scoreUpdateInterval
    end
    if db.syncMsg <= 0 then
      gui.log("Sending sync msg")
      EventEngine:push(events.SendMsg {"time", db.remaining, db.time})
      db.syncMsg = syncMsgInterval
    end
  end
end)

EventEngine:subscribe("gamestart", events.priority.high, function(handler, evt)
  if not db.started then
    db.started = true
    gui.log("Starting the game...")
    title("Clearing map...", "Starting soon", 10, 1200, 0)
    gui.log(" * Clearing map...")
    EventEngine:push(events.ClearMap())
    title("Generating map...", "Starting soon", 0, 1200, 0)
    gui.log(" * Generating map...")
    EventEngine:push(events.GenerateMap())
    title("Refreshing score...", "Starting soon", 0, 1200, 0)
    gui.log(" * Refreshing score...")
    EventEngine:push(events.UpdateScore())

    local oldTime = db.time
    db.time = 10
    for i = 10, 0, -1 do
      db.remaining = 10 - i
      if i > 5 then
        title(("00:%02d"):format(i), "Starting in", 0, 40, 10)
      else
        title("", i, 8, 10, 5)
      end
      os.sleep(1)
    end
    db.time = oldTime

    title("Setting up...", "", 0, 1200, 100)

    gui.log(" * Setting up...")
    db.remaining = db.time
    db.timers.worldTick = EventEngine:timer(
      1, events.WorldTick, math.huge)
    db.timers.randomLoot = EventEngine:timer(
      bonusSpawnInterval, events.RandomBonus, math.huge)
    EventEngine:push(events.SendMsg {"gamestart"})
    title("The game started!", "", 20, 80, 10)
    cb.setCommand([[playsound entity.enderdragon.death block @a 0 64 0 4 1 1]])
    cb.executeCommand()
    gui.log("Game started!")
  end
end)

EventEngine:subscribe("gamestop", events.priority.high, function(handler, evt)
  db.started = false
  db.timers.worldTick:destroy()
  db.timers.randomLoot:destroy()
  gui.log("Stopping the game...")
  EventEngine:push(events.SendMsg {"gamestop"})
  title("Refreshing the score...", "Stopping", 0, 1200, 100)
  gui.log(" * Refreshing the score...")
  EventEngine:push(events.UpdateScore())
  title("Clearing the map...", "Stopping", 10, 1200, 100)
  gui.log(" * Clearing the map...")
  EventEngine:push(events.ClearMap())
  title("Destroying loot...", "Stopping", 0, 1200, 100)
  gui.log(" * Destroying loot...")
  EventEngine:push(events.DestroyLoot())
  gui.log("Game stopped!")
  title("The game stopped!", "", 20, 80, 10)
end)

EventEngine:subscribe("stop", events.priority.high, function(handler, evt)
  EventEngine:push(events.ClearMap())
end)
