enet = require 'enet'
inspect = require 'libs.inspect'

host = enet.host_create('*:3456')
players = {}

function sendMessageToAllPeers(sender, msg)
  for i, p in pairs(peers) do
    if not (sender == p) then
      p:send(msg)
    end
  end
end

function processEvent(event)
  if event.type == 'connect' then
    print('Connection from: ', event.peer)
    peers[event.peer:index()] = event.peer
    sendMessageToAllPeers(event.peer, 'joined')
  elseif event.type == 'receive' then
    print(event.data)
    event.peer:send('alright mate')
  end
end

function processAllEvents(ms)
  event = host:service(ms)
  while event do
    processEvent(event)
    event = host:service()
  end
end

print(host:get_socket_address())

running = true
while running do
  processAllEvents(50)
end
