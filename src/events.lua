-- The event module.
--
-- Registers events and listeners.

local aevent = require("aevent")

local events = {}

local EventEngine = aevent()
events.Init = EventEngine:event("init")
events.Stop = EventEngine:event("stop")
events.SendMsg = EventEngine:event("sendmsg")
events.GameStart = EventEngine:event("gamestart")
events.GameStop = EventEngine:event("gamestop")
events.RecvMsg = EventEngine:event("recvmsg")
events.Quit = EventEngine:event("quit")
events.SpawnBonus = EventEngine:event("spawnbonus")
events.RandomBonus = EventEngine:event("randombonus")
events.UpdateScore = EventEngine:event("updatescore")
events.WorldTick = EventEngine:event("worldtick")
events.DestroyLoot = EventEngine:event("destroyloot")
events.UIUpdate = EventEngine:event("uiupdate")
events.GenerateMap = EventEngine:event("genmap")
events.ClearMap = EventEngine:event("clearmap")
events.TunnelMessage = EventEngine:event("tunnelmsg")

EventEngine:stdEvent("modem_message", events.RecvMsg)

events.engine = EventEngine

events.priority = {
  top = 5,
  high = 10,
  normal = 50,
  low = 75,
  bottom = 100
}

return events
