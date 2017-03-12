local module = require("ut2-serv.modules")
local db = module.load("db")
local events = module.load("events")
local surface = module.load("glasses.surface")

local EventEngine = events.engine

EventEngine:subscribe("uiupdate", events.priority.normal, function(handler, evt)
  -- 1. Update score

  do
    -- calculate advantages
    local scoreB = db.teams.blue.alive
    local scoreG = db.teams.green.alive
    local scoreR = db.teams.red.alive
    local scoreY = db.teams.yellow.alive
    local scoreSum = scoreB + scoreG + scoreR + scoreY

    local adB = scoreB / scoreSum
    local adG = scoreG / scoreSum
    local adR = scoreR / scoreSum
    local adY = scoreY / scoreSum

    if scoreSum == 0 then
      adB = 0.25
      adG = 0.25
      adR = 0.25
      adY = 0.25
    end

    -- set score labels
    surface.objects["score.blue.text"].setText(("%02d"):format(scoreB))
    surface.objects["score.green.text"].setText(("%02d"):format(scoreG))
    surface.objects["score.red.text"].setText(("%02d"):format(scoreR))
    surface.objects["score.yellow.text"].setText(("%02d"):format(scoreY))

    -- set opacity
    local oB = 0.8 * adB + 0.2
    local oG = 0.8 * adG + 0.2
    local oR = 0.8 * adR + 0.2
    local oY = 0.8 * adY + 0.2

    surface.objects["score.blue.box"].setAlpha(oB)
    surface.objects["score.green.box"].setAlpha(oG)
    surface.objects["score.red.box"].setAlpha(oR)
    surface.objects["score.yellow.box"].setAlpha(oY)

    -- update progress bars
    surface.objects["score.red.bar"].setSize(1, (1 - adY) * 200)
    surface.objects["score.green.bar"].setSize(1, (1 - adY - adR) * 200)
    surface.objects["score.blue.bar"].setSize(1, adB * 200)
  end


  -- 2. Update time
  do
    local passed = db.time - db.remaining
    local pMin = math.floor(passed / 60)
    local pSec = passed - pMin * 60
    pMin = ("%02d"):format(pMin)
    pSec = ("%02d"):format(pSec)
    surface.objects["time.passed.time"].setText(pMin .. ":" .. pSec)

    local total = db.time
    local tMin = math.floor(total / 60)
    local tSec = total - tMin * 60
    tMin = ("%02d"):format(tMin)
    tSec = ("%02d"):format(tSec)
    surface.objects["time.total.time"].setText(tMin .. ":" .. tSec)

    local remain = db.remaining
    local rMin = math.floor(remain / 60)
    local rSec = remain - rMin * 60
    rMin = ("%02d"):format(rMin)
    rSec = ("%02d"):format(rSec)
    surface.objects["time.remaining.time"].setText(rMin .. ":" .. rSec)

    surface.objects["time.bar.passed"].setSize(1, passed / total * 200)
  end

  -- 3. Update nicks
  do
    surface.objects["nicks.blue.text"].setText(db.teams.blue.name)
    surface.objects["nicks.green.text"].setText(db.teams.green.name)
    surface.objects["nicks.red.text"].setText(db.teams.red.name)
    surface.objects["nicks.yellow.text"].setText(db.teams.yellow.name)
  end
end)
