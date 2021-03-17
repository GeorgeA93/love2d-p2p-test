enet = require 'enet'
inspect = require 'libs.inspect'

serverThread = love.thread.newThread('server.lua')
serverThread:start()

local host = enet.host_create()
local server = host:connect('localhost:6789')

function love.load()
end

function love.update(dt)
  processRecievedPackets(host:service())
end

function processRecievedPackets(event)
  while event do
    processEvent(event)
    event = host:service()
  end
end

function processEvent(event)
  if event.type == 'connect' then
    print('Client Connected')
    server:send('hi')
  elseif event.type == 'receive' then
    print(event.data)
  end
end

function love.draw()
end

function love.resize(w, h)
  sx, sy = w/gw, h/gh
end

function resize(x, y, fs)
  local w, h = love.window.getDesktopDimensions()
  if w / h == 16 / 10 then
    gw = 480
    gh = 300 
  end

  local y = y or x
  fullscreen = fs
  love.window.setMode(x*gw, y*gh, {display = display, fullscreen = fs, borderless = fs})
  sx, sy = x, y
end

function resizeFullScreen()
  fullscreen = true
  local w, h = love.window.getDesktopDimensions()
  if w / h == 16 / 10 then
    gw = 480
    gh = 300 
  end

  love.window.setMode(w, h, {display = display, fullscreen = true, borderless = true})
  sx, sy = w/gw, h/gh
end

function love.quit()
  server:disconnect()
  host:flush()
end

function love.run()
  if love.math then love.math.setRandomSeed(os.time()) end
  if love.load then love.load(arg) end
  if love.timer then love.timer.step() end

  local dt = 0
  local fixed_dt = 1/60
  local accumulator = 0

  while true do
    if love.event then
      love.event.pump()
      for name, a, b, c, d, e, f in love.event.poll() do
        if name == 'quit' then
          if not love.quit or not love.quit() then
            return a
          end
        end
        love.handlers[name](a, b, c, d, e, f)
      end
    end

    if love.timer then
      love.timer.step()
      dt = love.timer.getDelta()
    end

    accumulator = accumulator + dt
    while accumulator >= fixed_dt do
      if love.update then love.update(fixed_dt) end
      accumulator = accumulator - fixed_dt
    end

    if love.graphics and love.graphics.isActive() then
      love.graphics.clear(love.graphics.getBackgroundColor())
      love.graphics.origin()
      if love.draw then love.draw() end
      love.graphics.present()
    end

    if love.timer then love.timer.sleep(0.001) end
  end
end

