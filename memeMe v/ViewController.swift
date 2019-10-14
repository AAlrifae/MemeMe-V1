//
//  ViewController.swift
//  memeMe v
//
//  Created by Abdulrahman Alrifae on 10/14/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

class ViewController: UIViewController ,UIImagePickerControllerDelegate ,UINavigationControllerDelegate ,UITextFieldDelegate {

    
       struct Meme {
           let topText: String
           let bottomText:String
           let originalImage:UIImage
           let memedImage: UIImage

       }
       
  
    @IBOutlet weak var imageViewPicker: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var shareBtn: UIBarButtonItem!
    @IBOutlet weak var cameraBtn: UIBarButtonItem!
  
      override func viewDidLoad() {
        super.viewDidLoad()
        configureUITextField(topTextField, text: "TOP" )
        configureUITextField(bottomTextField, text: "BOTTOM")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
        cameraBtn.isEnabled=UIImagePickerController.isSourceTypeAvailable(.camera)
        if imageViewPicker.image == nil {
            shareBtn.isEnabled = false
        }else{
            shareBtn.isEnabled = true
        
        }
         subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    func configureUITextField(_ textField: UITextField ,text:String) {
        textField.defaultTextAttributes = [
        NSAttributedString.Key.strokeColor : UIColor.black,
        NSAttributedString.Key.foregroundColor : UIColor.white,
        NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-CondensedBlack", size: 50)!,
        NSAttributedString.Key.strokeWidth : -6
        ]
        textField.textAlignment = .center
        textField.delegate = self
        textField.text = text
    }
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
  
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isEditing{
             view.frame.origin.y = -getKeyboardHeight(notification)
        }
    
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    // text field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
    return true
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
          let image = info [.originalImage] as? UIImage
          updateImageView(image: image)
          picker.dismiss(animated: true, completion: nil)
          
      }
      func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
          picker.dismiss(animated: false, completion: nil)
      }
      func updateImageView (image:UIImage?){
          imageViewPicker.image = image
          shareBtn.isEnabled = (image != nil)
      }
    
    func textFieldDidBeginEditing(_ textField:UITextField){
     if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
    }
    @IBAction func pickAnImage(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = (sender.tag == 0) ? .camera : .photoLibrary
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func textFieldDidEndEditing(_ textField : UITextField){
        let isEmpty = textField.text?.isEmpty ?? false
        if isEmpty && textField == topTextField {
            topTextField.text = "TOP"
        }else
            if isEmpty && textField == bottomTextField {
            bottomTextField.text = "BOTTOM"
        }
    }
    
 
    
    @IBAction func cancelAll(_ sender: UIBarButtonItem) {
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        updateImageView(image:nil)
    }
    
    @IBAction func share(_ sender: UIBarButtonItem) {
        let activityViewController = UIActivityViewController(activityItems: [generateMemedImage()], applicationActivities: nil)
        
        activityViewController.completionWithItemsHandler = { (activity, completed,items, error)in
            if completed {
                self.save()
            }
        }
         present(activityViewController , animated:true, completion:nil)
    }
    func generateMemedImage() -> UIImage{
        UIGraphicsBeginImageContext(imageViewPicker.frame.size)
        view.drawHierarchy(in: imageViewPicker.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return memedImage
    }
   
    func save(){
        _ = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageViewPicker.image!, memedImage: generateMemedImage())
    }
    

}
