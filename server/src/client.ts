import WebSocket from 'ws'
import * as fs from 'fs'
import * as path from 'path'

const ws = new WebSocket('http://localhost:3000/kinect')

ws.on('open', () => {
  let i = 0;
  setInterval(() => {
    const file = fs.readFileSync(path.resolve(`./bin2/bin${i % 120}.bin`), null)
    console.log("sending file " + i % 120)
    ws.send(file);
    i++;
  }, 100)
})