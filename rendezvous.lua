enet = require 'enet'
require 'libs.strong'

print('hi')
host = enet.host_create('0.0.0.0:' .. os.getenv('PORT'))

peers = {}

function getCmd(data)
  local split = data:split('#')
  return split[1], split[2]
end

function processEvent(event)
  if event.type == 'connect' then
    print('Peer connect ', event.peer)
  elseif event.type == 'receive' then
    local cmd, arg = getCmd(event.data)
    if cmd == 'register' then
      local nameAddress = arg:split(',')
      local name = nameAddress[1]
      peers[name] = { private = nameAddress[2], public = tostring(event.peer) }
      print('Client Registered ' .. name .. '! private: ' .. peers[name]['private'] .. ' public: ' .. peers[name]['public'])
    elseif cmd == 'connect' then
      print('Connect request from ' .. tostring(event.peer) .. ' to ' .. arg)

      local peer = peers[arg]

      if not peer then
        print('Peer not registered!')
        return
      end

      event.peer:send('connection#' .. peer['public'])
    end
  end
end

function processAllEvents()
  event = host:service()
  while event do
    processEvent(event)
    event = host:service()
  end
end

running = true
while running do
  processAllEvents()
end
