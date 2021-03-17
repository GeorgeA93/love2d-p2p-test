enet = require 'enet'

host = enet.host_create('*:6789')

function processEvent(event)
  if event.type == 'connect' then
    print('Connection from: ', event.peer)
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
