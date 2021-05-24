import * as fs from 'fs'
import * as path from 'path'
import protobuf from 'protobufjs'

function hexToRgb(hex: string) {
  var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  return result ? {
    r: parseInt(result[1], 16),
    g: parseInt(result[2], 16),
    b: parseInt(result[3], 16)
  } : null;
}

function write(index: number) {

  let buff = fs.readFileSync(path.resolve(`./data/res${index}.avx`), 'ascii')
  let res = {
    pointcloud: [{}]
  }
  let lines = buff.split('\n');
  for (const line of lines) {
    if (line.length === 0) continue;
    let words = line.split(' ');
    let str = words[3];
    let rgb = hexToRgb("#" + str)

    res.pointcloud.push({
      x: parseFloat(words[0]),
      y: parseFloat(words[1]),
      z: parseFloat(words[2]),
      r: rgb!.r,
      g: rgb!.g,
      b: rgb!.b,
    })
  }
  res.pointcloud.shift()

  // fs.writeFileSync("res.test", res)

  let root = protobuf.loadSync(path.resolve('src/pc.proto'))
  let pointCloud = root.lookupType('PointCloud')

  var message = pointCloud.fromObject(res);

  var buffer = pointCloud.encode(message).finish();
  let p = path.resolve(`out/res${index}.avb`)
  console.log(p)

  fs.writeFileSync(p, buffer)
}

for (let i = 0; i < 10; i++) {
  write(i)
}

