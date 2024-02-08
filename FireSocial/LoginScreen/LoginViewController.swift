//
//  ViewController.swift
//  FireSocial
//
//  Created by Manu on 06/02/24.
//

import UIKit
import FirebaseAuth


class LoginViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var sendOTPButton: UIButton!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var mobileNumberView: UIView!
    @IBOutlet weak var centralStackView: UIView!
    
    //MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        handleNotifications()
        
    }

    
    //MARK: - IBActions
    @IBAction func sendOTPButtonPressed(_ sender: UIButton) {
        view.activityStartAnimating()
        PhoneAuthProvider.provider()
            .verifyPhoneNumber("+91\(mobileNumberTextField.text ?? "")", uiDelegate: nil) { verificationID, error in
                DispatchQueue.main.async {
                    self.view.activityStopAnimating()
                    if let error = error {
                        self.showMessagePrompt(title: "Error", message: error.localizedDescription)
                      return
                    }
                    UserDefaults.standard.set(verificationID, forKey: Constants.kVERIFICATIONID)
                    let vc = OTPViewController.customInit()
                    vc.modalPresentationStyle = .overFullScreen
                    self.present(vc, animated: true)
                }
              
          }
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text {
            print("Updated text: \(text)")
            sendOTPButton.isEnabled = isValidPhoneNumber(textField.text ?? "")
        }
    }
    
    
    
    //MARK: - functions
    func setupViews(){
        sendOTPButton.layer.cornerRadius = sendOTPButton.bounds.height / 2
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        mobileNumberView.addShadow()
        mobileNumberTextField.delegate = self
        mobileNumberView.layer.cornerRadius = 10
        sendOTPButton.isEnabled = false
        mobileNumberTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    func handleNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification: )), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification: )), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let phoneNumberRegex = #"^\d{10}$"#
        let phoneNumberPredicate = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex)
        return phoneNumberPredicate.evaluate(with: phoneNumber)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0 {
                print((view.frame.height - centralStackView.frame.maxY))
                print(keyboardSize.height)
                self.view.frame.origin.y -= keyboardSize.height - (view.frame.height - centralStackView.frame.maxY) + 50
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}


extension LoginViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

