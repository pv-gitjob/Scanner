//
//  ViewController.swift
//  Scanner
//
//  Created by Praveen V on 2/23/20.
//  Copyright © 2020 Praveen Vandeyar. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var textField: UITextView!
    var keyboard = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.becomeFirstResponder()
    }

    @IBAction func clearBtn(_ sender: Any) {
        self.textField.text.removeAll()
    }
    
    @IBAction func cameraBtn(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .camera
        }else{
            picker.sourceType = .photoLibrary
        }
        present(picker,animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as! UIImage
        recognizeText(image: image.pngData())
        dismiss(animated: true, completion: nil)
    }
    
    func recognizeText(image: Data?) {
        let url = "http://ec2-54-241-187-187.us-west-1.compute.amazonaws.com/scanner/scan.php"
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(image!, withName: "fileToUpload", fileName: "poop.png", mimeType: "image/png")
        },
            to: url,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        if let jsonResponse = response.result.value as? [String: Any] {
                            self.textField.text = jsonResponse["text"] as? String
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
            }
        )
    }
    
    @IBAction func keyboardBtn(_ sender: Any) {
        if (keyboard) {
            textField.resignFirstResponder()
            keyboard = false
        } else {
            textField.becomeFirstResponder()
            keyboard = true
        }
    }
    
    @IBAction func copyBtn(_ sender: Any) {
        UIPasteboard.general.string = self.textField.text
    }
    
    @IBAction func pasteBtn(_ sender: Any) {
        self.textField.text += UIPasteboard.general.string ?? ""
    }
    
    @IBAction func saveBtn(_ sender: Any) {
        let text = self.textField.text
        let filename = getDocumentsDirectory().appendingPathComponent("output.txt")
        do {
            try text?.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Unable to save file")
        }
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

}

