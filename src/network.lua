-- The network module.
--
-- Initializes the networking.
-- Sends modem messages on event.

local component = require("component")
local srl = require("serialization")

local module = require("ut2-serv.modules")
local events = module.load("events")
local config = module.load("config")
local db = module.load("db")

local EventEngine = events.engine

local modem = component.modem
local tunnel = component.tunnel

if not modem.isWireless() then
  error("welp, that's a problem: you forgot to give me some wirelessness")
end
modem.setStrength(config.network.modem.strength)

local port = config.network.modem.port
modem.open(port)

EventEngine:subscribe("sendmsg", events.priority.low, function(handler, evt)
  if evt.addressee then
    modem.send(evt.addressee, port, table.unpack(evt:get()))
  else
    modem.broadcast(port, table.unpack(evt:get()))
  end
end)

EventEngine:subscribe("recvmsg", events.priority.low, function(handler, evt)
  local data = evt:get()
  if data[5] == "getInfo" then
    EventEngine:push(events.SendMsg {
      addressee = data[2],
      db.remaining,
      db.time,
      srl.serialize(db.teams)})
  end
end)

EventEngine:subscribe("recvmsg", events.priority.high, function(handler, evt)
  if data[1] == tunnel.address then
    EventEngine:push(events.TunnelMessage(table.unpack(data:get())))
  end
end)
