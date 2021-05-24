//
//  AvxParser.swift
//  Teleport
//
//  Created by Adam Vician on 16/05/2021.
//

import Foundation
import Alamofire
import SceneKit
import ARKit
import Starscream

protocol ConnectionManagerDelegate {
    func didUpdateFrame(geometry: SCNGeometry) -> Void
}

class ConnectionManager: WebSocketDelegate{
    
    let socket: WebSocket

    var isConnected = false
    public var delegate: ConnectionManagerDelegate?
    
    init(url: URL) {
        let request = URLRequest(url: url)
        socket = WebSocket(request: request)
        socket.delegate = self
    }
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("Received text: \(string)")
        case .binary(let data):
            self.processBinary(data: data)
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            print(error.debugDescription)
        default:
            break
        }
        return
    }
    
    public func startSocket() {
        socket.connect()
    }
    
    public func stopSocket() {
        socket.disconnect()
    }
    
    var socStart = DispatchTime.now()
    func processBinary(data: Data){
        let socEnd = DispatchTime.now()
        let socDiff = Double(socEnd.uptimeNanoseconds - socStart.uptimeNanoseconds) / 1_000_000
        socStart = socEnd;
        var node: SCNGeometry?
        DispatchQueue.background{
            let start = DispatchTime.now()
            let binPoints = PointCloudVertex.decode(data: data)
            let dataProcessed = DispatchTime.now()
            node = Geometry.buildPointCloudGeometry(points: binPoints)
            let serialize = Double(dataProcessed.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000
            print("Time to deserialize: \(serialize)ms, Socket diff: \(socDiff)ms")
        } completion: { 
            if let node = node {
                self.delegate?.didUpdateFrame(geometry: node)
            }
        }
    }


}

extension DispatchQueue {

    static func background(background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .userInteractive).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }

}

