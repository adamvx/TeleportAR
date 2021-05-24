import express from 'express'
import * as fs from 'fs'
import * as path from 'path'
import http from 'http'
import { Server } from 'socket.io'


const app = express()
const server = http.createServer(app)
const io = new Server(server, { allowEIO3: true })
const port = 3000

let connectedUsers = 0

app.get('/', async (req, res) => {
  res.send("I'm up and running.")
})

io.on('connection', async (socket) => {
  console.log('a user connected');
  connectedUsers++;

  socket.on('disconnect', () => {
    connectedUsers--;
  })


  let i = 0;
  setInterval(() => {
    if (connectedUsers <= 0) return;
    const file = fs.readFileSync(path.resolve(`./bin/bin${i % 10}.bin`), null)
    console.log("sending file " + i % 10)
    socket.emit(`frame`, file);
    i++;
  }, 100)

});


server.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`)
})