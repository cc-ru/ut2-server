local bit32 = require("bit32")
local com = require("component")

local module = require("ut-serv.modules")
local config = module.load("config")
local db = module.load("db")
local events = module.load("events")
local drawUI = module.load("glasses.ui")

local glasses = com.glasses

local EventEngine = events.engine

local function convColor(color)
  local b = bit32.band(color, 0xff)
  local g = bit32.band(bit32.rshift(color, 8), 0xff)
  local r = bit32.band(bit32.rshift(color, 16), 0xff)
  return r / 0xff, g / 0xff, b / 0xff
end

local function addObject(...)
  local args = {...}
  if args[2] == "addBox" then
    local rect = glasses.addRect()
    rect.setPosition(args[3], args[4])
    rect.setSize(args[5], args[6])
    rect.setColor(convColor(args[7]))
    if args[8] then
      rect.setAlpha(args[8])
    end
    return rect
  elseif args[2] == "addText" then
    local text = glasses.addText()
    text.setPosition(args[3], args[4])
    text.setText(args[5])
    text.setText(args[6])
    text.setScale(1)
    return text
  elseif args[2] == "addLine" then
    local quad = glasses.addQuad()
    quad.setVertex(1, args[3].x, args[3].y)
    quad.setVertex(2, args[4].x, args[4].y)
    quad.setColor(convColor(args[5]))
    return quad
  elseif args[2] == "addPolygon" then
    local quad = glasses.addQuad()
    quad.setColor(convColor(args[3]))
    quad.setAlpha(args[4])
    for i = 1, #args - 4, 1 do
      quad.setVertex(i, args[i].x, args[i].y)
    end
    for i = #args - 4 + 1, 4, 1 do
      quad.setVertex(i, args[#args - 4].x, args[#args - 4].y)
    end
    if #args > 8 then
      local quad2 = glasses.addQuad()
      quad.setVertex(1, args[5].x, args[5].y)
      quad.setVertex(2, args[8].x, args[8].y)
      quad.setVertex(3, args[9].x, args[9].y)
      if args[10] then
        quad.setVertex(4, args[10].x, args[10].y)
      else
        quad.setVertex(4, args[9].x, args[9].y)
      end
      return {quad, quad2}
    end
    return {quad}
  end
end

local function drawUI()
  -- SCORE
  addObject("score.blue.box", "addBox", 5, 5, 50, 50, 0x20afff, .33)
  local score1 = addObject("score.blue.text", "addText", 13, 20, "00", 0xffffff)
  score1.setScale(3)

  addObject("score.green.box", "addBox", 55, 5, 50, 50, 0x20ff20, .33)
  local score2 = addObject("score.green.text", "addText", 63, 20, "09", 0xffffff)
  score2.setScale(3)

  addObject("score.red.box", "addBox", 105, 5, 50, 50, 0xff2020, .33)
  local score3 = addObject("score.red.text", "addText", 113, 20, "18", 0xffffff)
  score3.setScale(3)

  addObject("score.yellow.box", "addBox", 155, 5, 50, 50, 0xffff20, .33)
  local score4 = addObject("score.yellow.text", "addText", 163, 20, "27", 0xffffff)
  score4.setScale(3)

  -- SCORE PRBAR
  addObject("score.yellow.bar", "addBox", 5, 57, 200, 1, 0xffff20)
  addObject("score.red.bar", "addBox", 5, 57, 150, 1, 0xff2020)
  addObject("score.green.bar", "addBox", 5, 57, 100, 1, 0x20ff20)
  addObject("score.blue.bar", "addBox", 5, 57, 50, 1, 0x20afff)

  -- TIME BOX
  addObject("time.box", "addBox", 5, 60, 200, 50, 0xffffff, .5)

  addObject("time.separator", "addLine", {x=105, y=63}, {x=105, y=107}, 0x606060)

  local passed = addObject("time.passed.time", "addText", 18, 75, "01:23", 0x000000)
  passed.setScale(3)
  addObject("time.passed.label", "addText", 18, 65, "Time passed", 0x000000)

  local total = addObject("time.total.time", "addText", 118, 70, "05:00", 0x000000)
  total.setScale(1.75)
  local totalLabel = addObject("time.total.label", "addText", 118, 63, "Total", 0x000000)
  totalLabel.setScale(0.8)

  local remaining = addObject("time.remaining.time", "addText", 118, 95, "03:37", 0x000000)
  remaining.setScale(1.75)
  local remainingLabel = addObject("time.remaining.label", "addText", 118, 88, "Remaining", 0x000000)
  remainingLabel.setScale(0.8)

  -- TIME PRBAR
  addObject("time.bar.total", "addBox", 5, 112, 200, 1, 0xffffff)
  addObject("time.bar.passed", "addBox", 5, 112, 55, 1, 0x20afff)

  -- NICKS
  addObject("nicks.blue.box.small", "addBox", 210, 5, 5, 11, 0x20afff)
  addObject("nicks.blue.box", "addBox", 215, 5, 150, 11, 0x20afff, .5)
  addObject("nicks.blue.text", "addText", 217, 7, "Fingercomp", 0xffffff)

  addObject("nicks.green.box.small", "addBox", 210, 18, 5, 11, 0x20ff20)
  addObject("nicks.green.box", "addBox", 215, 18, 150, 11, 0x20ff20, .5)
  addObject("nicks.green.text", "addText", 217, 20, "Fingercomp", 0xffffff)

  addObject("nicks.red.box.small", "addBox", 210, 31, 5, 11, 0xff2020)
  addObject("nicks.red.box", "addBox", 215, 31, 150, 11, 0xff2020, .5)
  addObject("nicks.red.text", "addText", 217, 33, "Fingercomp", 0xffffff)

  addObject("nicks.yellow.box.small", "addBox", 210, 44, 5, 11, 0xffff20)
  addObject("nicks.yellow.box", "addBox", 215, 44, 150, 11, 0xffff20, .5)
  addObject("nicks.yellow.text", "addText", 217, 46, "Fingercomp", 0xffffff)

  -- LOGO
  local rs = 5
  local rx = 20
  local ry = -22.5
  local robotTop1 = addObject("logo.robot.top.1", "addPolygon", 0x000000, .5,
    {x = 0 * rs + rx, y = -5 * rs + ry},
    {x = 2 * rs + rx, y = -6 * rs + ry},
    {x = 2 * rs + rx, y = -5 * rs + ry})
  local robotTop2 = addObject("logo.robot.top.2", "addPolygon", 0x000000, .5,
    {x = 3 * rs + rx, y = -9 * rs + ry},
    {x = 3.5 * rs + rx, y = -7 * rs + ry},
    {x = 3 * rs + rx, y = -6 * rs + ry},
    {x = 2 * rs + rx, y = -5 * rs + ry},
    {x = 2 * rs + rx, y = -6 * rs + ry})
  local robotTop3 = addObject("logo.robot.top.3", "addPolygon", 0x000000, .5,
    {x = 2 * rs + rx, y = -5 * rs + ry},
    {x = 3 * rs + rx, y = -6 * rs + ry},
    {x = 5 * rs + rx, y = -6 * rs + ry},
    {x = 6 * rs + rx, y = -5 * rs + ry})
  local robotTop4 = addObject("logo.robot.top.4", "addPolygon", 0x000000, .5,
    {x = 5 * rs + rx, y = -9 * rs + ry},
    {x = 4.5 * rs + rx, y = -7 * rs + ry},
    {x = 5 * rs + rx, y = -6 * rs + ry},
    {x = 6 * rs + rx, y = -5 * rs + ry},
    {x = 6 * rs + rx, y = -6 * rs + ry})
  local robotTop5 = addObject("logo.robot.top.5", "addPolygon", 0x000000, .5,
    {x = 8 * rs + rx, y = -5 * rs + ry},
    {x = 6 * rs + rx, y = -6 * rs + ry},
    {x = 6 * rs + rx, y = -5 * rs + ry})

  local robotBot1 = addObject("logo.robot.bottom.1", "addPolygon", 0x000000, .5,
    {x = 0 * rs + rx, y = -4 * rs + ry},
    {x = 2 * rs + rx, y = -2 * rs + ry},
    {x = 2 * rs + rx, y = -3.5 * rs + ry},
    {x = 1.5 * rs + rx, y = -4 * rs + ry})
  local robotBot2 = addObject("logo.robot.bottom.2", "addPolygon", 0x000000, .5,
    {x = 2 * rs + rx, y = -2 * rs + ry},
    {x = 2 * rs + rx, y = -3.5 * rs + ry},
    {x = 2.5 * rs + rx, y = -4 * rs + ry},
    {x = 5.5 * rs + rx, y = -4 * rs + ry},
    {x = 6 * rs + rx, y = -3.5 * rs + ry},
    {x = 6 * rs + rx, y = -2 * rs + ry},
    {x = 4 * rs + rx, y = 0 * rs + ry})
  local robotBot3 = addObject("logo.robot.bottom.3", "addPolygon", 0x000000, .5,
    {x = 8 * rs + rx, y = -4 * rs + ry},
    {x = 6 * rs + rx, y = -2 * rs + ry},
    {x = 6 * rs + rx, y = -3.5 * rs + ry},
    {x = 6.5 * rs + rx, y = -4 * rs + ry})

  local robotMid1 = addObject("logo.robot.middle.1", "addPolygon", 0xffffff, .5,
    {x = 1.5 * rs + rx, y = -5 * rs + ry},
    {x = 1.5 * rs + rx, y = -4 * rs + ry},
    {x = 2 * rs + rx, y = -3.5 * rs + ry},
    {x = 2.5 * rs + rx, y = -4 * rs + ry},
    {x = 2.5 * rs + rx, y = -5 * rs + ry})
  local robotMid2 = addObject("logo.robot.middle.2", "addPolygon", 0xff2020, .5,
    {x = 2.5 * rs + rx, y = -5 * rs + ry},
    {x = 2.5 * rs + rx, y = -4 * rs + ry},
    {x = 5.5 * rs + rx, y = -4 * rs + ry},
    {x = 5.5 * rs + rx, y = -5 * rs + ry})
  local robotMid3 = addObject("logo.robot.middle.3", "addPolygon", 0xffffff, .5,
    {x = 5.5 * rs + rx, y = -5 * rs + ry},
    {x = 5.5 * rs + rx, y = -4 * rs + ry},
    {x = 6 * rs + rx, y = -3.5 * rs + ry},
    {x = 6.5 * rs + rx, y = -4 * rs + ry},
    {x = 6.5 * rs + rx, y = -5 * rs + ry})

  local logoRed1 = addObject("logo.logo.red.1", "addPolygon", 0xff2020, .5,
    {x = 3 * rs + rx, y = -9 * rs + ry},
    {x = 3 * rs + rx, y = -12.5 * rs + ry},
    {x = 5 * rs + rx, y = -12.5 * rs + ry},
    {x = 5 * rs + rx, y = -9 * rs + ry},
    {x = 4.5 * rs + rx, y = -7 * rs + ry},
    {x = 3.5 * rs + rx, y = -7 * rs + ry})
  local logoRed2 = addObject("logo.logo.red.2", "addPolygon", 0xff2020, .5,
    {x = 2.5 * rs + rx, y = -7.5 * rs + ry},
    {x = 2.5 * rs + rx, y = -12.5 * rs + ry},
    {x = 3 * rs + rx, y = -12.5 * rs + ry},
    {x = 3 * rs + rx, y = -9 * rs + ry})
  local logoRed3 = addObject("logo.logo.red.3", "addPolygon", 0xff2020, .5,
    {x = 5.5 * rs + rx, y = -7.5 * rs + ry},
    {x = 5.5 * rs + rx, y = -12.5 * rs + ry},
    {x = 5 * rs + rx, y = -12.5 * rs + ry},
    {x = 5 * rs + rx, y = -9 * rs + ry})
  local logoRed4 = addObject("logo.logo.red.4", "addPolygon", 0xff2020, .5,
    {x = 6.5 * rs + rx, y = -12 * rs + ry},
    {x = 6.5 * rs + rx, y = -5.75 * rs + ry},
    {x = 8 * rs + rx, y = -5 * rs + ry},
    {x = 11 * rs + rx, y = -5 * rs + ry},
    {x = 11 * rs + rx, y = -12 * rs + ry})
  local logoRed5 = addObject("logo.logo.red.5", "addPolygon", 0xff2020, .5,
    {x = 6.5 * rs + rx, y = -4 * rs + ry},
    {x = 6.5 * rs + rx, y = -5 * rs + ry},
    {x = 11 * rs + rx, y = -5 * rs + ry},
    {x = 11 * rs + rx, y = -4 * rs + ry})
  local logoRed6 = addObject("logo.logo.red.6", "addPolygon", 0xff2020, .5,
    {x = 6.5 * rs + rx, y = 3 * rs + ry},
    {x = 6.5 * rs + rx, y = -2.5 * rs + ry},
    {x = 8 * rs + rx, y = -4 * rs + ry},
    {x = 11 * rs + rx, y = -4 * rs + ry},
    {x = 11 * rs + rx, y = 3 * rs + ry})
  local logoRed7 = addObject("logo.logo.red.7", "addPolygon", 0xff2020, .5,
    {x = 4 * rs + rx, y = 3.5 * rs + ry},
    {x = 4 * rs + rx, y = 0 * rs + ry},
    {x = 5.5 * rs + rx, y = -1.5 * rs + ry},
    {x = 5.5 * rs + rx, y = 3.5 * rs + ry})
  local logoRed8 = addObject("logo.logo.red.8", "addPolygon", 0xff2020, .5,
    {x = 4 * rs + rx, y = 3.5 * rs + ry},
    {x = 4 * rs + rx, y = 0 * rs + ry},
    {x = 2.5 * rs + rx, y = -1.5 * rs + ry},
    {x = 2.5 * rs + rx, y = 3.5 * rs + ry})
  local logoRed9 = addObject("logo.logo.red.9", "addPolygon", 0xff2020, .5,
    {x = 1.5 * rs + rx, y = 3 * rs + ry},
    {x = 1.5 * rs + rx, y = -2.5 * rs + ry},
    {x = 0 * rs + rx, y = -4 * rs + ry},
    {x = -3 * rs + rx, y = -4 * rs + ry},
    {x = -3 * rs + rx, y = 3 * rs + ry})
  local logoRed10 = addObject("logo.logo.red.10", "addPolygon", 0xff2020, .5,
    {x = 1.5 * rs + rx, y = -4 * rs + ry},
    {x = 1.5 * rs + rx, y = -5 * rs + ry},
    {x = -3 * rs + rx, y = -5 * rs + ry},
    {x = -3 * rs + rx, y = -4 * rs + ry})
  local logoRed11 = addObject("logo.logo.red.11", "addPolygon", 0xff2020, .5,
    {x = 1.5 * rs + rx, y = -12 * rs + ry},
    {x = 1.5 * rs + rx, y = -5.75 * rs + ry},
    {x = 0 * rs + rx, y = -5 * rs + ry},
    {x = -3 * rs + rx, y = -5 * rs + ry},
    {x = -3 * rs + rx, y = -12 * rs + ry})
  local logoRed12 = addObject("logo.logo.red.12", "addPolygon", 0xff2020, .5,
    {x = 3 * rs + rx, y = -6 * rs + ry},
    {x = 3.5 * rs + rx, y = -7 * rs + ry},
    {x = 4.5 * rs + rx, y = -7 * rs + ry},
    {x = 5 * rs + rx, y = -6 * rs + ry})
end

EventEngine:subscribe("init", events.priority.normal, function(handler, evt)
  drawUI()
end)
