//
//  PointCloud.swift
//  Teleport
//
//  Created by Adam Vician on 16/05/2021.
//

import Foundation
import SceneKit

class Geometry {
    
    public static func buildPointCloudGeometry(points: [PointCloudVertex]) -> SCNGeometry{
        let vertexData = NSData(
            bytes: points,
            length: MemoryLayout<PointCloudVertex>.size * points.count
        )
        let positionSource = SCNGeometrySource(
            data: vertexData as Data,
            semantic: SCNGeometrySource.Semantic.vertex,
            vectorCount: points.count,
            usesFloatComponents: true,
            componentsPerVector: 3,
            bytesPerComponent: MemoryLayout<Float>.size,
            dataOffset: 0,
            dataStride: MemoryLayout<PointCloudVertex>.size
        )
        let colorSource = SCNGeometrySource(
            data: vertexData as Data,
            semantic: SCNGeometrySource.Semantic.color,
            vectorCount: points.count,
            usesFloatComponents: true,
            componentsPerVector: 3,
            bytesPerComponent: MemoryLayout<Float>.size,
            dataOffset: MemoryLayout<Float>.size * 3,
            dataStride: MemoryLayout<PointCloudVertex>.size
        )
        let elements = SCNGeometryElement(
            data: nil,
            primitiveType: .point,
            primitiveCount: points.count,
            bytesPerIndex: MemoryLayout<Int>.size
        )
        elements.pointSize = 10
        elements.minimumPointScreenSpaceRadius = 10
        elements.maximumPointScreenSpaceRadius = 10
        let pointsGeometry = SCNGeometry(sources: [colorSource, positionSource], elements: [elements])
        
        return pointsGeometry
    }
}
