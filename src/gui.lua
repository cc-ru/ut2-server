local com = require("component")
local term = require("term")

local module = require("ut2-serv.modules")
local db = module.load("db")
local events = module.load("events")

local debug = com.debug
local gpu = com.gpu

local EventEngine = events.engine

local oldw, oldh = gpu.getResolution()
gpu.setResolution(80, 25)
os.sleep(0)

local forms = require("forms")

local function str2time(s)
  local minutes, seconds = s:match("^(%d%d):(%d%d)$")
  if not minutes then
    return false
  end
  return minutes * 60 + seconds
end

local function time2str(time)
  local minutes = math.floor(time / 60)
  local seconds = time - minutes * 60
  return ("%02d:%02d"):format(minutes, seconds)
end

local root = forms.addForm()
root.color = 0x2D2D2D
root.fontColor = 0xFFFFFF

root:addEvent("interrupted", function()
  forms.stop()
end)

local frameTime = root:addFrame(3, 2, 0)
frameTime.W = 24
frameTime.H = 12
frameTime.color = 0x4B4B4B
frameTime.fontColor = 0xFFFFFF

local labelPassed = frameTime:addLabel(2, 2, "Time passed")
labelPassed.color = frameTime.color
labelPassed.fontColor = 0xC3C3C3

local labelPassedTime = frameTime:addLabel(19, 2, "00:00")
labelPassedTime.color = frameTime.color
labelPassedTime.fontColor = frameTime.fontColor

local labelRemaining = frameTime:addLabel(2, 3, "Time remaining")
labelRemaining.color = frameTime.color
labelRemaining.fontColor = 0xC3C3C3

local labelRemainingTime = frameTime:addLabel(19, 3, "00:00")
labelRemainingTime.color = frameTime.color
labelRemainingTime.fontColor = frameTime.fontColor

local labelTotal = frameTime:addLabel(2, 4, "Total time")
labelTotal.color = frameTime.color
labelTotal.fontColor = 0xC3C3C3

local editTotalTime = frameTime:addEdit(2, 5, function(self)
  if not db.started then
    local time = str2time(self.text)
    if time then
      db.time = time
      EventEngine:push(events.UIUpdate())
    end
  end
end)
editTotalTime.W = frameTime.W - 2
editTotalTime.H = 3
editTotalTime.text = "10:00"
editTotalTime.color = frameTime.color
editTotalTime.fontColor = frameTime.fontColor

local prbarTime = frameTime:addFrame(2, 8, 0)
prbarTime.W = frameTime.W - 2
prbarTime.H = 1
prbarTime.color = 0x696969
prbarTime.fontColor = 0x990000
prbarTime.value = 0
function prbarTime:paint()
  local w = self.W * 2 * self.value
  w = math.floor(w)
  if w > 1 then
    gpu.set(self.X, self.Y, ("█"):rep(math.floor(w / 2)))
  end
  if w % 2 ~= 0 then
    gpu.set(self.X + math.floor(w / 2), self.Y, "▌")
  end
end

local frameTimeAction = frameTime:addFrame(2, 9, 0)
frameTimeAction.W = frameTime.W - 2
frameTimeAction.H = 3
frameTimeAction.color = 0x636363
frameTimeAction.fontColor = frameTime.fontColor

local customActionTop = frameTimeAction:addFrame(1, 1, 0)
customActionTop.W = frameTimeAction.W
customActionTop.H = 1
customActionTop.color = frameTime.color
customActionTop.fontColor = frameTimeAction.color
function customActionTop:paint()
  local x = self.W * 2 * prbarTime.value
  x = math.floor(x)
  if x == 0 then
    x = 1
  end
  local realX = math.floor((x - 1) / 2)
  gpu.fill(self.X, self.Y, self.W, self.H, "▄")
  gpu.set(self.X + realX, self.Y, x % 2 == 1 and "▙" or "▟")
end

local buttonTimeAction = frameTimeAction:addButton(
  math.floor(frameTimeAction.W / 6),
  2,
  "Start",
  function()
    if db.started then
      EventEngine:push(events.GameStop())
    else
      EventEngine:push(events.GameStart())
    end
  end)
buttonTimeAction.W = frameTimeAction.W - buttonTimeAction.left - 1
buttonTimeAction.H = frameTimeAction.H - 2
buttonTimeAction.color = 0x660000
buttonTimeAction.fontColor = 0xFFFFFF

local frameContestants = root:addFrame(29, 2, 0)
frameContestants.W = 24
frameContestants.H = 12
frameContestants.color = 0x4B4B4B
frameContestants.fontColor = root.fontColor

local contestants = {
  blue = {color = 0x0092FF, y = 1},
  green = {color = 0x00B600, y = 4},
  red = {color = 0xFF2400, y = 7},
  yellow = {color = 0xFFDB00, y = 10}
}

for k, v in pairs(contestants) do
  local frame = frameContestants:addFrame(2, v.y, 0)
  frame.W = frameContestants.W - 2
  frame.H = 3
  frame.color = frameContestants.color
  frame.fontColor = frameContestants.fontColor

  local score = frame:addLabel(1, 2, "00")
  score.W = 4
  score.H = 1
  score.autoSize = false
  score.centered = true
  score.color = v.color
  score.fontColor = 0x000000

  local field = frame:addEdit(6, 1, function(self)
    db.teams[k].name = self.text
    EventEngine:push(events.UIUpdate())
  end)
  field.W = frame.W - 4 - 1
  field.H = 3
  field.color = frame.color
  field.fontColor = frame.fontColor

  v.field = field
  v.score = score
end

local frameUsers = root:addFrame(55, 2, 0)
frameUsers.W = 24
frameUsers.H = 23
frameUsers.color = 0x4B4B4B
frameUsers.fontColor = root.fontColor

local listUsers = frameUsers:addList(1, 1, function() end)
listUsers.W = frameUsers.W
listUsers.H = frameUsers.H - 7
listUsers.border = 0
listUsers.color = frameUsers.color
listUsers.fontColor = frameUsers.fontColor
listUsers.selColor = 0x696969
listUsers.sfColor = 0xFFFFFF

local buttonBan = frameUsers:addButton(2, frameUsers.H - 5, "Ban", function() end)
buttonBan.W = 6
buttonBan.H = 2
buttonBan.color = 0x660000
buttonBan.fontColor = frameUsers.fontColor

local buttonKick = frameUsers:addButton(2, frameUsers.H - 2, "Kick", function() end)
buttonKick.W = 6
buttonKick.H = 2
buttonKick.color = 0x660000
buttonKick.fontColor = frameUsers.fontColor

local buttonTp2p = frameUsers:addButton(10, frameUsers.H - 5, "Tp2p", function() end)
buttonTp2p.W = 6
buttonTp2p.H = 2
buttonTp2p.color = 0x660000
buttonTp2p.fontColor = frameUsers.fontColor

local buttonTphere = frameUsers:addButton(10, frameUsers.H - 2, "Tphere", function() end)
buttonTphere.W = 6
buttonTphere.H = 2
buttonTphere.color = 0x660000
buttonTphere.fontColor = frameUsers.fontColor

local buttonTpLobby = frameUsers:addButton(17, frameUsers.H - 5, "Lobby", function() end)
buttonTpLobby.W = 6
buttonTpLobby.H = 1
buttonTpLobby.color = 0x660000
buttonTpLobby.fontColor = frameUsers.fontColor

local buttonTpScene = frameUsers:addButton(17, frameUsers.H - 3, "Scene", function() end)
buttonTpScene.W = 6
buttonTpScene.H = 1
buttonTpScene.color = 0x660000
buttonTpScene.fontColor = frameUsers.fontColor

local buttonTpArena = frameUsers:addButton(17, frameUsers.H - 1, "Arena", function() end)
buttonTpArena.W = 6
buttonTpArena.H = 1
buttonTpArena.color = 0x660000
buttonTpArena.fontColor = frameUsers.fontColor

local frameLog = root:addFrame(3, 15, 0)
frameLog.W = 50
frameLog.H = 10
frameLog.color = 0x4B4B4B
frameLog.fontColor = root.fontColor

local editLog = frameLog:addEdit(1, 1, function() end)
editLog.W = frameLog.W
editLog.H = frameLog.H
editLog.color = frameLog.color
editLog.fontColor = frameLog.fontColor
editLog.text = {}

EventEngine:subscribe("uiupdate", events.priority.normal, function(handler, evt)
  labelPassedTime.caption = time2str(db.time - db.remaining)
  labelPassedTime:redraw()
  labelRemainingTime.caption = time2str(db.remaining)
  labelRemainingTime:redraw()
  prbarTime.value = (db.time - db.remaining) / db.time
  if prbarTime.value == math.huge then
    prbarTime.value = 0
  end
  prbarTime:redraw()
  customActionTop:redraw()
  buttonTimeAction.caption = db.started and "Stop" or "Start"
  buttonTimeAction:redraw()
  for k, v in pairs(contestants) do
    v.score.caption = ("%02d"):format(db.teams[k].alive)
    v.score:redraw()
  end
  do
    local selected
    if listUsers.index ~= 0 then
      selected = listUsers.items[listUsers.index]
    end
    listUsers:clear()
    local index = 0
    for k, v in pairs(debug.getPlayers()) do
      if k ~= "n" then
        table.insert(listUsers.items, v)
        table.insert(listUsers.lines, v)
        if v == selected then
          index = #listUsers.lines
        end
      end
    end
    listUsers.index = index
    listUsers:redraw()
  end
end)

local function run()
  forms.run(root)
  os.sleep(0)
  term.clear()
  gpu.setResolution(oldw, oldh)
end

return {
  run = run
}
