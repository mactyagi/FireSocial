//
//  OTPViewController.swift
//  FireSocial
//
//  Created by Manu on 06/02/24.
//

import UIKit
import FirebaseAuth

class OTPViewController: UIViewController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var otpTextFieldView: OTPFieldView!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var centralStackView: UIView!
    
    
    //MARK: - properties
    private var verificationId: String = ""
    private var otp: String = ""
    //MARK: - lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        handleNotifications()
    }
    
    //MARK: - Static functions
    static func customInit() -> OTPViewController{
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OTPViewController") as! OTPViewController
        return vc
    }
    
    
    //MARK: - IBActions
    @IBAction func verifyButtonPressed(_ sender: UIButton) {
        let verificationID = UserDefaults.standard.string(forKey: Constants.kVERIFICATIONID) ?? ""
        let credential = PhoneAuthProvider.provider().credential(
          withVerificationID: verificationID,
          verificationCode: otp
        )
        
        
        Auth.auth().signIn(with: credential) { authDataResult, error in
            if let error{
                self.showMessagePrompt(title: "Error", message: error.localizedDescription)
            }else{
                print()
                UserDefaults.standard.set(authDataResult?.user.uid, forKey: Constants.kUSERID)
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                        sceneDelegate.showTabBarController()
                    }
                
                print("Logged in")
            }
        }
    }
    
    
    
    
    
    
    //MARK: - functions
    func setupViews(){
        verifyButton.isEnabled = false
        otpTextFieldView.superview?.addShadow()
        otpTextFieldView.superview?.layer.cornerRadius = 10
//        otpTextFieldView.superview?.clipsToBounds = true
        verifyButton.layer.cornerRadius = verifyButton.bounds.height / 2
        verifyButton.backgroundColor = .red
        setupOtpView()
    }
    
    func setupOtpView(){
        self.otpTextFieldView.fieldsCount = 6
        self.otpTextFieldView.fieldBorderWidth = 0
        self.otpTextFieldView.defaultBorderColor = UIColor.black
        self.otpTextFieldView.filledBorderColor = UIColor.green
        self.otpTextFieldView.cursorColor = UIColor.red
        self.otpTextFieldView.displayType = .square
        self.otpTextFieldView.fieldSize = 40
        self.otpTextFieldView.separatorSpace = 8
        self.otpTextFieldView.shouldAllowIntermediateEditing = false
        self.otpTextFieldView.delegate = self
        self.otpTextFieldView.initializeUI()
    }
    
    func handleNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification: )), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification: )), name: UIResponder.keyboardWillHideNotification, object: nil)
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


//MARK: - OTP Textfield Delegate

extension OTPViewController: OTPFieldViewDelegate{
    func shouldBecomeFirstResponderForOTP(otpTextFieldIndex index: Int) -> Bool {
          true
    }
    
    func enteredOTP(otp: String) {
        print(otp)
        self.otp = otp
        verifyButton.isEnabled = otp.count == 6
    }
    
    func hasEnteredAllOTP(hasEnteredAll: Bool) -> Bool {
        return false
    }
}
