-- In-memory DB
-- actually, just a Lua table

local module = require("ut2-serv.modules")
local config = module.load("config")

local totalGameTime = config.game.totalGameTime

return {
  -- whether the game has been started or not
  started = false,
  -- team info (player names and robots alive)
  teams = {
    blue = {name = "", alive = 0},
    green = {name = "", alive = 0},
    red = {name = "", alive = 0},
    yellow = {name = "", alive = 0}
  },
  -- time until the end of game
  remaining = 0,
  -- time until next score update
  scoreUpdate = 0,
  -- time until next sync message
  syncMsg = 0,
  -- the total game time
  time = totalGameTime,
  -- timers
  timers = {},
  -- to prevent worldtick handler from looping
  updatingScore = false
}
