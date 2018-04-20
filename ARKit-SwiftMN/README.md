# ARKit-SwiftMN

This is the demo application created during the April 19, 2018 Swift MN Meetup.

## Overview

The application was designed as an introduction to some of the main ARKit features.  These features include:

- Creating an application using the new ARKit template in XCode
- Adding a simple 3d virtual object to an ARKit view
- Using plane detection to identify flat surfaces, both horizontal and vertical
- Placing a custom 3d model on a plane using results from a Hit Test operation
- Detecting reference images in the real world and taking action in response to the image detection


## Getting Started

ARKit image detection and this sample app require iOS 11.3 and a device with an A9 (or later) processor. ARKit isn't available in iOS Simulator.

## About the App
Since this app was built up from scratch over the course of the demonstration, some of the funcitonality has been commented out in order to better illustrate later concepts.

In the `viewDidLoad` method, uncommenting the following lines will display a jet plane in front of the camera when the app loads:

```
//        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
//
//        // Set the scene to the view
//        sceneView.scene = scene
```
In the `func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor)` method, in the `planeNode.runAction` closure block, the following lines were commented out, as the reference images used in the original demo were probably copyrighted.  You can uncomment them and add new reference images, with the appropriate title, to enable this funcitonality:

```
//            guard let referenceImageName = imageAnchor.referenceImage.name else { return }
//            let urlString = "https://www.imdb.com/title/" + referenceImageName
//            guard let url = URL(string: urlString) else { return }
//            DispatchQueue.main.async {
//                UIApplication.shared.open(url, options: [:], completionHandler: nil)
//            }
```

Also in the `func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor)` method, the following lines will create and visualize planes in for detected planes in the scene; these lines were commented out so as to not interfere with the image detection code:

```
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
```

Mark


