//
//  ViewController.swift
//  MeMe2
//
//  Created by Jorge Guerrero on 13/05/21.
//

import UIKit


class AddMemeViewController: UIViewController , UIImagePickerControllerDelegate,UINavigationControllerDelegate , UITextFieldDelegate{
    
    
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var topNavigationBar: UIToolbar!
    @IBOutlet weak var uiImagePicker: UIImageView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cameraPicker: UIBarButtonItem!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topTextField: UITextField!
    
    var textFieldRealYPosition: CGFloat = 0.0
    var MemedImageGenerated : UIImage?
    var meme : Meme?
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth: -4.0
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shareButton.isEnabled = false
        textFieldStatus(textField: topTextField, defaultWord: "TOP")
        textFieldStatus(textField: bottomTextField, defaultWord: "BOTTOM")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraPicker.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func textFieldStatus (textField: UITextField , defaultWord: String){
        let memeTextAttribute = [
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth: -5] as [NSAttributedString.Key : Any]
        textField.delegate = self
        textField.textColor = UIColor.white
        textField.tintColor = UIColor.white
        textField.text = defaultWord
        textField.defaultTextAttributes = memeTextAttribute
        textField.textAlignment = .center
    }
    
    
    func getImage (source : UIImagePickerController.SourceType){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cameraButton(_ sender: Any) {
        getImage(source: .camera)
    }
    
    @IBAction func pickImage(_ sender: Any) {
        getImage(source: .photoLibrary)
    }
    
    @IBAction func shareButton(_ sender: Any) {
        let memImage = generateMemedImage()
        let imageToShare = [ memImage ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook , UIActivity.ActivityType.message]
        
        self.present(activityViewController, animated: true, completion: nil)
        
        activityViewController.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) -> Void in
            if completed == true {
                self.save()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let imagee = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            uiImagePicker.image = imagee
        }
        shareButton.isEnabled = true
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func save() {
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: uiImagePicker.image!, memedImage: MemedImageGenerated)
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
    }
    
    
    func generateMemedImage() -> UIImage {
        self.topNavigationBar.isHidden = true
        self.bottomToolBar.isHidden = true
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        MemedImageGenerated = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        self.bottomToolBar.isHidden = false
        self.topNavigationBar.isHidden = false
        return MemedImageGenerated!
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            let distanceBetweenTextfielAndKeyboard = self.view.frame.height - textFieldRealYPosition - keyboardSize.height
            
            if distanceBetweenTextfielAndKeyboard < 0{
                if self.view.frame.origin.y == 0 {
                    self.view.frame.origin.y -= keyboardSize.height
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
        textFieldRealYPosition = textField.frame.origin.y + textField.frame.height
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
