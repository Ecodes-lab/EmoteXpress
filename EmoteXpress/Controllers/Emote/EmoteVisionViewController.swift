//
//  ZARVisionViewController.swift
//  EmoteXpress
//
//  Created by Eco Dev System on 08/12/2022.
//

import Foundation
import UIKit
import AVFoundation
import Vision
import CoreML

protocol EmoteVisionViewControllerDelegate: AnyObject {
    func emoteVisionController(_ controller: EmoteVisionViewController, request: VNCoreMLRequest, regionOfInterest: CGRect, didCapture buffer: CVImageBuffer)
    func emoteTextRecognitionHandler(_ controller: EmoteVisionViewController, request: VNRequest, error: Error?)
}

class EmoteVisionViewController: EmoteViewController {
    
    weak var delegate: EmoteVisionViewControllerDelegate?

    var model: VNCoreMLModel!
    
    var request: VNCoreMLRequest!
    
    var edSmileModelFile = Bundle.main.url(forResource: "EDSmileDetector", withExtension: "mlmodelc")!
    
    // Temporal string tracker
    let emoteTracker = EmoteTracker()
    
    override func viewDidLoad() {
        
        let bundle = Bundle(for: type(of: self))
        bundle.loadNibNamed("EmoteViewController", owner: self)
        
        // Set up vision request before letting ViewController set up the camera
        // so that it exists when the first buffer is received.
        loadModel()
        request = VNCoreMLRequest(model: model, completionHandler: recognizeFaceHandler)

        super.viewDidLoad()
    }
    
    private func loadModel() {
        let edSmileModel = try! MLModel(contentsOf: edSmileModelFile)
        model = try? VNCoreMLModel(for: edSmileModel)
    }
    
    // MARK: - Text recognition
    
    // Vision recognition handler.
    func recognizeFaceHandler(request: VNRequest, error: Error?) {
        delegate?.emoteTextRecognitionHandler(self, request: request, error: error)
    }
    
    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            delegate?.emoteVisionController(self, request: request, regionOfInterest: regionOfInterest, didCapture: pixelBuffer)
        }
    }
    
    // MARK: - Bounding box drawing
    
    // Draw a box on screen. Must be called from main queue.
    var boxLayer = [CAShapeLayer]()
    func draw(rect: CGRect, color: CGColor) {
        let layer = CAShapeLayer()
        layer.opacity = 0.5
        layer.borderColor = color
        layer.borderWidth = 2
        
        layer.frame = rect
//        layer.frame.size.width += 10
        boxLayer.append(layer)
        previewView.videoPreviewLayer.insertSublayer(layer, at: 1)
    }
    
    // Remove all drawn boxes. Must be called on main queue.
    func removeBoxes() {
        for layer in boxLayer {
            layer.removeFromSuperlayer()
        }
        boxLayer.removeAll()
    }
    
    typealias ColoredBoxGroup = (color: CGColor, boxes: [CGRect])
    
    // Draws groups of colored boxes.
    func show(boxGroups: [ColoredBoxGroup]) {
        DispatchQueue.main.async {
            let layer = self.previewView.videoPreviewLayer
            self.removeBoxes()
            for boxGroup in boxGroups {
                let color = boxGroup.color
                for box in boxGroup.boxes {
//                    let rect = layer.layerRectConverted(fromMetadataOutputRect: box.applying(self.visionToAVFTransform))
//                    let rect = layer.layerRectConverted(fromMetadataOutputRect: self.regionOfInterest.applying(self.bottomToTopTransform.concatenating(self.uiRotationTransform)))
//                    self.draw(rect: rect, color: color)
                }
            }
        }
    }
}
