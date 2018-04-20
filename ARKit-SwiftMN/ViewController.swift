//
//  ViewController.swift
//  SwiftMN-1
//
//  Created by Mark Dostal on 4/19/18.
//  Copyright © 2018 Mark Dostal. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self

        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // This bit will show the jet in front of the camera
        
//        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
//
//        // Set the scene to the view
//        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // add plane detection
        configuration.planeDetection = [.horizontal, .vertical]
        
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        configuration.detectionImages = referenceImages

        // Run the view's session
        sceneView.session.run(configuration)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tapGesture)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        
        // Create a plane to visualize the initial position of the detected image.
        let plane = SCNPlane(width: referenceImage.physicalSize.width,
                             height: referenceImage.physicalSize.height)
        let planeNode = SCNNode(geometry: plane)
        planeNode.opacity = 0.25
        
        /*
         `SCNPlane` is vertically oriented in its local coordinate space, but
         `ARImageAnchor` assumes the image is horizontal in its local space, so
         rotate the plane to match.
         */
        planeNode.eulerAngles.x = -.pi / 2
        
        /*
         Image anchors are not tracked after initial detection, so create an
         animation that limits the duration for which the plane visualization appears.
         */
        planeNode.runAction(self.imageHighlightAction) {
            // This is the code to take you to the IMDB page, provided
            // you set up the reference image names correctly...
            // Avengers: tt4154756
            // Isle Of Dogs: tt5104604
            //
//            guard let referenceImageName = imageAnchor.referenceImage.name else { return }
//            let urlString = "https://www.imdb.com/title/" + referenceImageName
//            guard let url = URL(string: urlString) else { return }
//            DispatchQueue.main.async {
//                UIApplication.shared.open(url, options: [:], completionHandler: nil)
//            }
            
            // This is the code to play a movie in the scene
            self.playLaptopMovie(planeNode)
        }
        
        // Add the plane visualization to the scene.
        node.addChildNode(planeNode)

//
//        // Place content only for anchors found by plane detection.
//        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
//
//        // Create a SceneKit plane to visualize the plane anchor using its position and extent.
//        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
//        let planeNode = SCNNode(geometry: plane)
//        planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
//
//        // `SCNPlane` is vertically oriented in its local coordinate space, so
//        // rotate the plane to match the horizontal orientation of `ARPlaneAnchor`.
//        planeNode.eulerAngles.x = -.pi / 2
//
//        // Make the plane visualization semitransparent to clearly show real-world placement.
//        planeNode.opacity = 0.25
//
//        // Add the plane visualization to the ARKit-managed node so that it tracks
//        // changes in the plane anchor as plane estimation continues.
//        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Update content only for plane anchors and nodes matching the setup created in `renderer(_:didAdd:for:)`.
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        // Plane estimation may shift the center of a plane relative to its anchor's transform.
        planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        // Plane estimation may also extend planes, or remove one plane to merge its extent into another.
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.height = CGFloat(planeAnchor.extent.z)
    }
    
    func blackDragon() -> SCNNode? {
        // load the scene
        let scene = SCNScene(named: "art.scnassets/Black Dragon/Dragon 2.5_dae.dae")!
        
        // Create and scale our node
        let dragonNode = SCNNode()
        scene.rootNode.scale = SCNVector3(0.005, 0.005, 0.005)
        dragonNode.addChildNode(scene.rootNode)
        
        return dragonNode
    }
    
    var imageHighlightAction: SCNAction {
        return .sequence([
            .wait(duration: 1.0),
            .fadeOpacity(to: 0.85, duration: 1.0),
            .fadeOpacity(to: 0.15, duration: 1.0),
            .fadeOpacity(to: 0.85, duration: 1.0),
            .fadeOut(duration: 2.0),
            ])
    }


    @objc func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let location = sender.location(in: sceneView)
            
            let results: [ARHitTestResult] = sceneView.hitTest(location, types: .existingPlaneUsingGeometry)
            guard let hitTestResult = results.first else { return }
            
            guard let node = blackDragon() else { return }
            node.transform = SCNMatrix4(hitTestResult.localTransform)
            
            guard let anchor = results.first?.anchor,
                let planeNode = sceneView.node(for: anchor)
                else { return }
            
            planeNode.addChildNode(node)
        }
    }

    func playLaptopMovie(_ node: SCNNode) {

        // create new video node with our movie
        let videoNode = SKVideoNode(fileNamed: "Laptop.mov")
        videoNode.zRotation = .pi
        videoNode.play()
        
        // create SKScene to hold video node
        let skScene = SKScene(size: CGSize(width: 640, height: 480))
        skScene.addChild(videoNode)
        
        // set node position and size
        videoNode.position = CGPoint(x: skScene.size.width/2, y: skScene.size.height/2)
        videoNode.size = skScene.size
        
        // get our plane geometry (essentially the detected image size) from the node
        // and set the SKScene as the diffuse.contents and make sure the opacity is 1.0
        guard let tvPlane = node.geometry else { return }
        tvPlane.firstMaterial?.diffuse.contents = skScene
        tvPlane.firstMaterial?.isDoubleSided = true

        node.opacity = 1.0
    }

    
    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
