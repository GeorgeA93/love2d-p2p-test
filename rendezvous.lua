enet = require 'enet'
require 'libs.strong'

host = enet.host_create('*:34567')

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
      local ipPort = arg:split(':')
      local ip = ipPort[1]
      peers[ip] = { private = arg, public = tostring(event.peer) }
      print('Client Registered! private: ' .. peers[ip]['private'] .. ' public: ' .. peers[ip]['public'])
    elseif cmd == 'connect' then
      print('Connect request from ' .. tostring(event.peer) .. ' to ' .. arg)

      local ipPort = arg:split(':')
      local ip = ipPort[1]
      local peer = peers[ip]

      if not peer then
        print('Peer not registered!')
      end
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
