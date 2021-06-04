import * as fs from 'fs'
import * as path from 'path'

type Point = { x: number, y: number, z: number, r: number, g: number, b: number }

function hexToRgb(hex: string) {
  var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  let res = {
    r: parseInt(result![1], 16),
    g: parseInt(result![2], 16),
    b: parseInt(result![3], 16)
  }
  return res;
}

export const fileToHexBuffer = () => {
  let buff = fs.readFileSync(path.resolve(`./test.avx`), 'ascii')
  let pc: Point[] = []
  let res: Buffer[] = []
  let lines = buff.split('\n');
  for (const line of lines) {
    if (line.length === 0) continue;
    let words = line.split(' ');
    let r = parseInt(words[3]);
    let g = parseInt(words[4]);
    let b = parseInt(words[5]);
    let p = {
      x: parseFloat(words[0]) + 100,
      y: parseFloat(words[1]) + 100,
      z: parseFloat(words[2]) + 100,
      r: r,
      g: g,
      b: b,
    }
    pc.push(p)

    res.push(pointToBuffer(p))
  }

  const send = Buffer.concat(res)
  console.log(send)
  fs.writeFileSync(path.resolve(`./test.avb`), send)
}

const pointToBuffer = (p: Point) => {
  const xb = Buffer.from(getFullAndRest(p.x))
  const yb = Buffer.from(getFullAndRest(p.y))
  const zb = Buffer.from(getFullAndRest(p.z))
  const rgbBuffer = Buffer.from([p.r, p.g, p.b])
  const arr = [xb, yb, zb, rgbBuffer]
  return Buffer.concat(arr);
}

const getFullAndRest = (n: number) => {
  let full = Math.floor(n)
  var decimal = Math.round((n - full) * 100)
  return [full, decimal]
}
fileToHexBuffer()