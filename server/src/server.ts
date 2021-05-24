import http from 'http'
import WebSocket from 'ws'
import url from 'url'

const port = 3000

const server = http.createServer();
const kinectSocket = new WebSocket.Server({ noServer: true });
const appSocket = new WebSocket.Server({ noServer: true });


kinectSocket.on('connection', function connection(ws) {
  // ...
  ws.on('message', (data) => {
    appSocket.clients.forEach(c => {
      if (c.readyState === WebSocket.OPEN) {
        c.send(data)
      }
    })
  })
});

appSocket.on('connection', function connection(ws) {
  // ...
});


server.on('upgrade', function upgrade(request, socket, head) {
  const pathname = url.parse(request.url).pathname;

  if (pathname === '/kinect') {
    kinectSocket.handleUpgrade(request, socket, head, function done(ws) {
      kinectSocket.emit('connection', ws, request);
    });
  } else if (pathname === '/app') {
    appSocket.handleUpgrade(request, socket, head, function done(ws) {
      appSocket.emit('connection', ws, request);
    });
  } else {
    socket.destroy();
  }
});

server.listen(port, () => {
  console.log('Server listening on port ' + port)
});