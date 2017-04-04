-- original by Doob
-- fixed/modified by fingercomp

port, radius, t = 31415, 2, 'timer'
timer = math.random(3, 6)
sounds = {
  'entity.endermen.teleport',
  'entity.lightning.thunder',
  'entity.generic.explode',
  'entity.pig.ambient',
  'block.slime.step'
}
blocks = {
  'opencomputers:microcontroller',
  'opencomputers:robot'
}
function get(name)
  return component.proxy(component.list(name)())
end

modem, tunnel, deb = get('modem'), get('tunnel'), get('debug')
cmd = deb.runCommand

function cmd(c)
  x,y,z=math.floor(deb.getX()),math.floor(deb.getY()),math.floor(deb.getZ())
  tunnel.send(x,y,z,t,c)
end

function bang()
  x, y, z = math.floor(deb.getX()), math.floor(deb.getY()), math.floor(deb.getZ())
  cmd(('particle heart %d %d %d 1 1 1 0.1'):format(x,y,z))
  for _, i in pairs(sounds) do
    cmd(('playsound %s block @a %d %d %d 2 1'):format(i,x,y,z))
  end
  for _, i in pairs(blocks) do
    cmd(('fill %d %d %d %d %d minecraft:air 0 replace %s'):format(x-radius,y-radius,z-radius,x+radius,y+radius,z+radius, i))
  end
end

function signal(...)
  deb.changeBuffer(500)
  local s = {computer.pullSignal(...)}
  return table.unpack(s)
end

if timer then
  while computer.uptime() ~= timer do
    signal(1)
  end
  if math.random(1, 20) ~= 1 then
    bang()
  end
else
  modem.open(port)
  while true do
    signal(1)
  end
end
