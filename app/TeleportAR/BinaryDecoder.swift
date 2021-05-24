//
//  BinDecoder.swift
//  TeleportAR
//
//  Created by Adam Vician on 21/05/2021.
//

import Foundation

struct PointCloudVertex {
    let x: Float, y: Float, z: Float
    let r: Float, g: Float, b: Float
    
    static func decode(data: Data) -> [PointCloudVertex] {
        
        let byteArray = [UInt8](data)
        var res: [PointCloudVertex] = []

        for i in stride(from: 0, to: byteArray.count, by: 9) {
            let x = Float(byteArray[i + 0]) + Float(byteArray[i + 1]) * 0.01 - 100
            let y = Float(byteArray[i + 2]) + Float(byteArray[i + 3]) * 0.01 - 100
            let z = Float(byteArray[i + 4]) + Float(byteArray[i + 5]) * 0.01 - 100
            let r = Float(byteArray[i + 6]) * 0.003921568627451 // Basicaly 255^-1.. Multiplication is faster then division
            let g = Float(byteArray[i + 7]) * 0.003921568627451
            let b = Float(byteArray[i + 8]) * 0.003921568627451
            res.append(PointCloudVertex(x: x, y: y, z: z, r: r, g:g, b: b))
        }
        return res
    }
    
}

