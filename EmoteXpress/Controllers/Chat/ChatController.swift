//
//  ChatController.swift
//  EmoteXpress
//
//  Created by Eco Dev System on 02/01/2023.
//

import UIKit
import Vision
import CoreImage

private let reuseIdentifier = "MessageCell"

class ChatController: UICollectionViewController {

    // MARK: - Properties
    
    private let user: User
    private var messages = [Message]()
    var fromCurrentUser = false
    
    private lazy var edInputView: EDInputAccessoryView = {
        let iv = EDInputAccessoryView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        iv.backgroundColor = UIColor(named: "BackgroundColor")
        iv.delegate = self
        return iv
    }()
    
//    var emoteVisionViewController: EmoteVisionViewController!
    
    // MARK: - Lifecycle
    
    init(user: User) {
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchMessages()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        emoteVisionViewController.stopCaptureSession()
    }
    
    override var inputAccessoryView: UIView? {
        get { return edInputView }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: - API
    
    func fetchMessages() {
        Service.fetchMessages(forUser: user) { messages in
            self.messages = messages
            self.collectionView.reloadData()
            self.collectionView.scrollToItem(at: [0, self.messages.count - 1], at: .bottom, animated: true)
        }
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        collectionView.backgroundColor = UIColor(named: "BackgroundColor")
        configureNavigationBar(withTitle: user.username, prefersLargeTitles: false)
        
        let emoteView = UIView()
        emoteView.setDimensions(height: 30, width: 30)
        emoteView.layer.cornerRadius = 30 / 2
        emoteView.clipsToBounds = true
        
//        let emoteController = EmoteVisionViewController()
//        emoteController.delegate = self
//        emoteVisionViewController = emoteController
//        emoteController.view.frame = CGRect(x: emoteView.frame.origin.x, y: emoteView.frame.origin.y, width: emoteView.frame.width, height: emoteView.frame.height)
//        emoteView.addSubview(emoteController.view)
//        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: emoteView)
        
        collectionView.register(MessageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        
    }

}

extension ChatController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MessageCell
        cell.message = messages[indexPath.row]
        cell.message?.user = user
        return cell
    }
}

extension ChatController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 0, bottom: 16, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let estimatedSizeCell = MessageCell(frame: frame)
        estimatedSizeCell.message = messages[indexPath.row]
        estimatedSizeCell.layoutIfNeeded()
        

        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = estimatedSizeCell.systemLayoutSizeFitting(targetSize)

        return .init(width: view.frame.width, height: estimatedSize.height)
    }
}

extension ChatController: EDInputAccessoryViewDelegate {
    func inputView(_ inputView: EDInputAccessoryView, wantsToSend message: String) {
        
        
        Service.uploadMessage(message, to: user) { error in
            if let error = error {
                print("DEBUG: Failed to upload message with error \(error.localizedDescription)")
                return
            }
            
            inputView.clearMessageText()
        }
    }
}

extension ChatController: EmoteVisionViewControllerDelegate {
    func emoteVisionController(_ controller: EmoteVisionViewController, request: VNCoreMLRequest, regionOfInterest: CGRect, didCapture buffer: CVImageBuffer) {
        
        
        let ciImage = CIImage(cvPixelBuffer: buffer)
        
        
//
        guard let image = ciImage.toUIImage() else {
            return
        }
        
        let size = CGSize(width: 299, height: 299)

        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
//
//        let zarOriginalImage = CIImage(image: image)
//
//        // Create a filter to darken the image
//        let blackAndWhiteFilter = CIFilter(name: "CIColorControls")!
//        blackAndWhiteFilter.setValue(zarOriginalImage, forKey: kCIInputImageKey)
//        //            darkenFilter.setValue(1.5, forKey: kCIInputBrightnessKey)
//        blackAndWhiteFilter.setValue(0, forKey: kCIInputSaturationKey)
//
//
//        // Create a filter to sharpen the image
//        let sharpenFilter = CIFilter(name: "CIUnsharpMask")!
//        sharpenFilter.setValue(blackAndWhiteFilter.outputImage, forKey: kCIInputImageKey)
//        sharpenFilter.setValue(2.0, forKey: kCIInputRadiusKey)
//        sharpenFilter.setValue(0.5, forKey: kCIInputIntensityKey)
//
//        // Convert the CIImage to a UIImage and display it
//        ////            let outputImage = CIImage(image: sharpenFilter.outputImage!)
//        let outputImage = UIImage(ciImage: sharpenFilter.outputImage!)
        
        self.getRecoginationFace(controller, image: CIImage(image: image)!)
    }
    
    func getRecoginationFace(_ controller: EmoteVisionViewController, image: CIImage) {
        
//        guard let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [:]) else { return }
//
//        let image = CIImage(cvImageBuffer: buffer, options: [:])
//
//        let faceFeatures = detector.features(in: image)
//
//        for feature in faceFeatures as! [CIFaceFeature] {
//            print(feature)
////            if feature.mouthPosition.y > 0 {
////                print("Face is smiling!")
////            } else {
////                print("Face is not smiling.")
////            }
//        }

        
        let imageRequestHandler = VNImageRequestHandler(ciImage: image, options: [:])

        do {
            try imageRequestHandler.perform([controller.request])
        } catch {
            print(error)
        }
    }
    
    func emoteTextRecognitionHandler(_ controller: EmoteVisionViewController, request: VNRequest, error: Error?) {
        
        var emotes = [String]()
        
        guard let results = request.results as? [VNClassificationObservation] else {
            return
        }
        
//        if let firstResult = results.first {
//            if firstResult.identifier == "smile" {
//                print("Smiling")
//            }
//            else if firstResult.identifier == "non_smile" {
//                print("Not Smiling")
//            }
//        }
        
        for face in results {
//            print(face.identifier)
//            if face.identifier == "happy" {
//                print("Smiling")
//            }
            
//            emotes.append(face.identifier)
//            switch face.identifier {
//            case "happy":
//                print("Smiling")
//            case "sad":
//                print("Sad")
//            default:
//                print("Normal")
//            }
        }
        
        
//        // Log any found numbers.
//        controller.emoteTracker.logFrame(strings: emotes)
//
//        //            print(controller.numberTracker.bestCount)
//
//
//        // Check if we have any temporally stable numbers.
//        if let sureEmote = controller.emoteTracker.getStableString() {
//
//            controller.emoteTracker.reset(string: sureEmote)
//
////            print(sureEmote)
//
//            return
//        }
    }
    
    
}

extension CIImage {
    func toUIImage() -> UIImage? {
        let context: CIContext = CIContext.init(options: nil)
        
        if let cgImage: CGImage = context.createCGImage(self, from: self.extent) {
            return UIImage(cgImage: cgImage)
        } else {
            return nil
        }
    }
}
