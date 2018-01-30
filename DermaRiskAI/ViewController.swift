//
//  ViewController.swift
//  DermaRiskAI
//
//  Created by Vic Boo on 1/21/18.
//  Copyright © 2018 Arjun Moorthy. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    //@IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        guard let image = UIImage(named: "ISIC_0000000") else {
            fatalError("no starting image")
        }
        
        imageView.image = image
        
        guard let ciImage = CIImage(image: (imageView?.image)!) else {
            fatalError("Convert CIImage from UIImage failed")
        }
        
        analyseImage(image: ciImage)
    }
    
    func analyseImage(image: CIImage) {
        print("bar");
        resultLabel.text = "Analyzing the image .........."
        
        guard let model = try? VNCoreMLModel(for: VGG16().model) else {
            fatalError("Cannot Load ML model")
        }
        
        //Create a vision request
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            print("request" , request)
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first else {
                    fatalError("unexpected result type from VNCoreMLRequest")
            }
            
            
            //Update UI with the result
            DispatchQueue.main.async {
                [weak self] in
                self!.resultLabel?.text = "identifier = \(topResult.identifier)"
                print(topResult.identifier)
            }
        }
        
        guard let ciImage = CIImage(image: (imageView?.image)!) else {
            fatalError("Convert CIImage from UIImage failed")
        }
        
        //Run the classifier
        let imageHandle = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try imageHandle.perform([request])
            } catch {
                print ("Error : \(error)")
            }
        }
        
    }
    
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func predictResult(_ sender: Any) {
        guard let ciImage = CIImage(image: (imageView?.image)!) else {
            fatalError("Convert CIImage from UIImage failed")
        }

        
        analyseImage(image: ciImage)
        
        print("foo")
    }
    
    @IBAction func chooseImage(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self;
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary

        image.allowsEditing = false;
        self.present(image, animated: true) {}
        
        
        
    }
    
    // To show the image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
        }
        self.dismiss(animated: true, completion: nil)
        
    }
}



//    func predictingResult(image: CIImage) {
//        guard let model = try? VNCoreMLModel(for: melanoma_new().model) else {
//            fatalError("Cannot Load ML model")
//        }
//
//        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
//            guard let results = request.results as? [VNClassificationObservation],
//                let topResult = results.first else {
//                    fatalError("unexpected result type from VNCoreMLRequest")
//            }
//    }
//



//        let pickerController = UIImagePickerController()
//        pickerController.delegate = self
//        pickerController.sourceType = .savedPhotosAlbum
//        present(pickerController, animated: true)
