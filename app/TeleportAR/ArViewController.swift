//
//  ViewController.swift
//  TeleportAR
//
//  Created by Adam Vician on 20/05/2021.
//

import UIKit
import SceneKit
import ARKit

class ArViewController: UIViewController {
    
    var manager: ConnectionManager?
    var displayedNode: SCNNode = SCNNode()
    var selectedNode: SCNNode?
    var url: URL?
    
    let sceneView: ARSCNView = {
        let view = ARSCNView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        view.addSubview(sceneView)
        sceneView.topAnchor.constraint(equalTo: view.topAnchor).activate()
        sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor).activate()
        sceneView.leftAnchor.constraint(equalTo: view.leftAnchor).activate()
        sceneView.rightAnchor.constraint(equalTo: view.rightAnchor).activate()
        sceneView.delegate = self
//        sceneView.showsStatistics = true
        displayedNode.scale = SCNVector3(0.02, 0.02, 0.02)
        displayedNode.rotation = SCNVector4(0, 1, 0, Double.pi)
//        sceneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
        sceneView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:))))
        sceneView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleMove(_:))))
        manager = ConnectionManager(url: url!)
        manager?.delegate = self
        
        sceneView.scene.rootNode.addChildNode(displayedNode)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
//        self.sceneView.debugOptions = [.showFeaturePoints]
        sceneView.session.run(configuration)
        sceneView.session.delegate = self
        sceneView.session.run(configuration)
        manager?.startSocket()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        manager?.stopSocket()
        sceneView.session.pause()
    }
    

    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        guard let recognizerView = sender.view as? ARSCNView else { return }
        let location = sender.location(in: recognizerView)
        guard let hitTest = sceneView.hitTest(location, types: .existingPlane).first else {
            return
        }
        let column = hitTest.worldTransform.columns.3
        displayedNode.position = SCNVector3(column.x, column.y, column.z)
    }

    @objc func handlePinch(_ sender: UIPinchGestureRecognizer) {
        guard let recognizerView = sender.view as? ARSCNView else { return }
        let location = sender.location(in: recognizerView)
        guard let hitResults = sceneView.hitTest(location).first, hitResults.node == displayedNode else {
            return
        }
        
        if sender.state == .changed {
            
            let pinchScaleX: CGFloat = sender.scale * CGFloat((displayedNode.scale.x))
            let pinchScaleY: CGFloat = sender.scale * CGFloat((displayedNode.scale.y))
            let pinchScaleZ: CGFloat = sender.scale * CGFloat((displayedNode.scale.z))
            displayedNode.scale = SCNVector3Make(Float(pinchScaleX), Float(pinchScaleY), Float(pinchScaleZ))
            print(displayedNode.scale)
            sender.scale = 1
            
        }
    }
    
    @objc func handleMove(_ sender: UILongPressGestureRecognizer) {
        
        guard let recognizerView = sender.view as? ARSCNView else { return }
        let location = sender.location(in: recognizerView)

        guard let hitResults = sceneView.hitTest(location).first, hitResults.node == displayedNode else {
            return
        }

        
        if sender.state == .began {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
        
        if sender.state == .changed {
            
            guard let hitTest = self.sceneView.hitTest(location, types: .existingPlane).first else { return }
            let worldTransform = hitTest.worldTransform
            let newPosition = SCNVector3(worldTransform.columns.3.x, worldTransform.columns.3.y, worldTransform.columns.3.z)
            displayedNode.worldPosition = newPosition
            
            
            
        }
        if sender.state == .ended {
            
        }
        
    }

}

extension ArViewController: ConnectionManagerDelegate {
    func didUpdateFrame(geometry: SCNGeometry) {
        displayedNode.geometry = geometry
    }
}

extension ArViewController : ARSessionDelegate {
        
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
//        let cameraRotation = frame.camera.transform.columns.2
//        let cameraPosition = frame.camera.transform.columns.3
//        displayedNode.position = SCNVector3(cameraPosition.x, cameraPosition.y, cameraPosition.z)
//        displayedNode.rotation = SCNVector4(0 ,1, 0, Double.pi + Double(cameraRotation.x))
    }
}

extension ArViewController : ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        

    }
}


