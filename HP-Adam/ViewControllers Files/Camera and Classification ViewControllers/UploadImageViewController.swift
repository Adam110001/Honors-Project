//
//  UploadImageViewController.swift
//  HP-Adam
//
//  Created by Adam Dovciak on 22/01/2021.
//

import UIKit
import CoreML
import Vision
import ImageIO
import FirebaseAuth

class UploadImageViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var takePictureButton: UIButton!
    @IBOutlet weak var animalPredictionLabel: UILabel!
    @IBOutlet weak var classificationView: UIView!
    @IBOutlet var mainUIView: UIView!
    
    private var animalDetected: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Upload Image"
        
        imageView.backgroundColor = .systemGray5
        
        classificationView.isHidden = true
        
        mainUIView.backgroundColor = .systemGray5
        
        animalPredictionLabel.text = ""
        animalPredictionLabel.textAlignment = .center
        
        takePictureButton.backgroundColor = .white
        takePictureButton.setTitle("Upload Picture", for: .normal)
        takePictureButton.setTitleColor(.black, for: .normal)
    }
    
    @IBAction func didTakePicture(_ sender: Any) {
        let pc = UIImagePickerController()
        pc.sourceType = .photoLibrary
        pc.delegate = self
        present(pc, animated: true)
        
    }
    
    // MARK - Rezise Image Function
    // Code: https://stackoverflow.com/questions/31314412/how-to-resize-image-in-swift
    
    private let trainedImageSized = CGSize(width: 64, height: 64)
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    // MARK - Classification Process
    // Code: https://developer.apple.com/documentation/vision/classifying_images_with_vision_and_core_ml
    
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            /// Add the correct model here
            let model = try VNCoreMLModel(for: Inceptionv3().model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: {
                [weak self] request, error in
                
                self?.processClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    /// - Tag: PerformRequests
    func updateClassifications(for image: UIImage) {
        animalPredictionLabel.text = "Classifying..."
        
        let resizedImage = resizeImage(image: image, targetSize: trainedImageSized)
        
        let orientation = CGImagePropertyOrientation(resizedImage.imageOrientation)
        guard let ciImage = CIImage(image: resizedImage) else { fatalError("Unable to create \(CIImage.self) from \(resizedImage).") }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }
    
    /// Updates the UI with the results of the classification.
    /// - Tag: ProcessClassifications
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                self.animalPredictionLabel.text = "Unable to classify image.\n\(error!.localizedDescription)"
                return
            }
            // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
            let classifications = results as! [VNClassificationObservation]
            
            if classifications.isEmpty {
                self.animalPredictionLabel.text = "Nothing recognized."
            } else {
                // Display top classifications ranked by confidence in the UI.
                let topClassifications = classifications.prefix(1)
                let descriptions = topClassifications.map {
                    classification in
                    
                    return String(format: "  (%.2f) %@", classification.confidence, classification.identifier)
                }
                
                self.classificationView.isHidden = false
                self.animalPredictionLabel.text = "Classification \n" + descriptions.joined(separator: "\n")
                self.animalDetected = descriptions.joined(separator: " ")
            }
        }
    }
}

extension UploadImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        
        if picker.isBeingDismissed == true {
            
            if FirebaseAuth.Auth.auth().currentUser != nil {
                
                KeyVariables.MyVaraibles.foundAnimalUpload = animalDetected
                
                let animalToBeProcessedForURL = animalDetected.replacingOccurrences(of: " ", with: "_")
                
                KeyVariables.MyVaraibles.foundAnimalURLUpload = animalToBeProcessedForURL
                
                if animalToBeProcessedForURL.isEmpty == false {
                    print(animalToBeProcessedForURL)
                    
                    guard let image = imageView.image, let data = image.pngData() else {
                        return
                    }
                    
                    guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
                        return
                    }
                                        
                    let safeEmail = DatabaseManager.preprocessedEmail(emailAddress: email)
                    
                    let fileName = "\(safeEmail)_picture_\(animalToBeProcessedForURL).png"
                    
                    StorageManager.storageManager.uploadAnImageTakenByUser(with: data, fileName: fileName, completion: {
                        result in
                        
                        switch result {
                            case.success(let downloadURL):
                                UserDefaults.standard.set(downloadURL, forKey: "picture_url")
                                print(downloadURL)
                                
                            case.failure(let error):
                                print("Storage manager error: \(error)")
                        }
                    })
                    
                    let alert = UIAlertController(title: "Alert", message: "Would you like to learn more about your animal?", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Open", style: UIAlertAction.Style.default, handler: {
                        action in
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(identifier: "ADVC")
                        self.present(vc, animated: true)
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
        imageView.image = image
        updateClassifications(for: image)
    }
}
