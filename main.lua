enet = require 'enet'
inspect = require 'libs.inspect'

serverThread = love.thread.newThread('server.lua')
serverThread:start()

function love.load()
  host = enet.host_create()
  -- server = host:connect('192.168.1.95:3456')
  server = host:connect('vast-shelf-39527.herokuapp.com:34567')
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
    -- server:send('register#' .. tostring(event.peer))
    server:send('register#foo,192.168.1.95:5678')
    -- server:send('connect#192.168.1.95:3456')
  elseif event.type == 'receive' then
    -- once we get info back we connect to right thing
    -- server = host:connect('192.168.1.95:3456')
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

