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

export const fileToHexBuffer = (id: number) => {
  let buff = fs.readFileSync(path.resolve(`./data/res${id}.avx`), 'ascii')
  let pc: Point[] = []
  let res: Buffer[] = []
  let lines = buff.split('\n');
  for (const line of lines) {
    if (line.length === 0) continue;
    let words = line.split(' ');
    let str = words[3];
    let rgb = hexToRgb("#" + str)
    let p = {
      x: parseFloat(words[0]) + 100,
      y: parseFloat(words[1]) + 100,
      z: parseFloat(words[2]) + 100,
      r: rgb.r,
      g: rgb.g,
      b: rgb.b,
    }
    pc.push(p)

    res.push(pointToBuffer(p))
  }

  const send = Buffer.concat(res)
  console.log(send)
  fs.writeFileSync(path.resolve(`./lz4/bin${id}.lz4`), send)
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
// fileToHexBuffer(1)
// for (let i = 0; i < 10; i++) {
//   fileToHexBuffer(i)
// }
// hexToRgb('#ffccaa')
// console.log(Buffer.from('22ff22'))
console.log(pointToBuffer({ x: 2.12 + 100, y: 3.1 + 100, z: 22.3 + 100, r: 255, g: 44, b: 252 }))