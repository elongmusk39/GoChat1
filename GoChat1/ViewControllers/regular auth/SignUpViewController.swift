//
//  SignUpViewController.swift
//  GoChat
//
//  Created by Long Nguyen on 7/29/21.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    private var viewModel = ViewModelSignUp()
    
    private var loadingViewObserver: NSObjectProtocol?
    
//MARK: - Components
    
    private let appLabel: UILabel = {
        let lb = UILabel()
        lb.text = "GoChat"
        lb.textColor = .black
        lb.textAlignment = .center
        lb.font = UIFont.monospacedSystemFont(ofSize: 24, weight: .semibold)
        
        return lb
    }()
    
    let emailTextField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.font = UIFont.systemFont(ofSize: 20)
        field.returnKeyType = .continue
        field.keyboardType = .emailAddress
        field.layer.borderColor = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)
        field.layer.borderWidth = 2
        field.layer.cornerRadius = 10
        field.attributedPlaceholder = NSAttributedString(string: "Email address..", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray]) //let customize the placeHolder
        field.keyboardAppearance = .dark
        field.textColor = .black
        field.setHeight(height: 40)
        field.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        //let's make the text in the textfield NOT slush into the left
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .clear
        
        return field
    }()
    
    let usernameTextField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.font = UIFont.systemFont(ofSize: 20)
        field.returnKeyType = .continue
        field.layer.borderColor = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)
        field.layer.borderWidth = 2
        field.layer.cornerRadius = 10
        field.attributedPlaceholder = NSAttributedString(string: "Username..", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray]) //let customize the placeHolder
        field.keyboardAppearance = .dark
        field.textColor = .black
        field.setHeight(height: 40)
        field.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        //let's make the text in the textfield NOT slush into the left
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .clear
        
        return field
    }()
    
    
    let passwordTextField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.font = UIFont.systemFont(ofSize: 20)
        field.returnKeyType = .go
        field.layer.borderColor = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)
        field.layer.borderWidth = 2
        field.layer.cornerRadius = 10
        field.attributedPlaceholder = NSAttributedString(string: "Password..", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray ]) //let customize the placeHolder
        field.keyboardAppearance = .dark
        field.textColor = .black
        field.setHeight(height: 40)
        field.isSecureTextEntry = true
        field.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        //let's make the text in the textfield NOT slush into the left
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .clear
        
        return field
    }()
    
    private let registerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Register", for: .normal)
        btn.setTitleColor(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), for: .normal)
        btn.backgroundColor = #colorLiteral(red: 0.8357778192, green: 0.7860863209, blue: 0.2553475201, alpha: 1)
        btn.isEnabled = false
        btn.alpha = 0.8
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        btn.layer.cornerRadius = 14
        btn.layer.borderWidth = 1
        btn.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) //we got black here
        btn.setHeight(height: 50)
        btn.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        
        return btn
    }()
    
    private let switchSignInButton: UIButton = {
        let btn = UIButton(type: .system)
        let textColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) //we have black
        let attributedTitle = NSMutableAttributedString (string: "Already have an account?  ", attributes: [.font: UIFont.systemFont(ofSize: 22), .foregroundColor: textColor])
        
        attributedTitle.append(NSMutableAttributedString(string: "Sign In", attributes: [.font: UIFont.boldSystemFont(ofSize: 22), .foregroundColor: UIColor.blue]))
        btn.setAttributedTitle(attributedTitle, for: .normal)
        
        //let's add some action
        btn.addTarget(self, action: #selector(switchToSignIn), for: .touchUpInside)
        
        return btn
    }()
    
//MARK: - View Scenes
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureGradientLayer(from: 0, to: 2.2)
        configureUI()
        HideKeyBoard()
        
        emailTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
    }
    
    private func configureUI() {
        
        view.addSubview(appLabel)
        appLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 30, paddingRight: 30)
        
        let stack = UIStackView(arrangedSubviews: [emailTextField, usernameTextField, passwordTextField, registerButton])
        stack.distribution = .equalSpacing
        stack.axis = .vertical
        stack.spacing = 12
        
        view.addSubview(stack)
        stack.anchor(top: appLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 40, paddingRight: 40)
        
        view.addSubview(switchSignInButton)
        switchSignInButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 20, paddingBottom: 20, paddingRight: 20)
    }
    
    
//MARK: - keyboard
    //let's deal with the keyboard without the use of IQKeyboardManager (tap anywhere to dismiss it)
    func HideKeyBoard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func DismissKeyboard() {
        print("DEBUG-SignUpVC: dismissing keyboard..")
        view.endEditing(true)
    }
    
    
//MARK: - checking form
    
    @objc func textDidChange (sender: UITextField) {
        if sender == emailTextField {
            viewModel.email = sender.text
        }
        else if sender == passwordTextField {
            viewModel.password = sender.text
        }
        else if sender == usernameTextField {
            viewModel.username = sender.text
        }
        
        checkFormStatus() //we have the viewModel all filled up with text
    }
    
    func checkFormStatus () {
        if viewModel.formIsValid {
            //this code is executed when viewModel.formIsValid == true
            registerButton.isEnabled = true
            registerButton.backgroundColor = #colorLiteral(red: 1, green: 0.9501822591, blue: 0.2311506867, alpha: 1)
            registerButton.alpha = 1
        } else {
            registerButton.isEnabled = false
            registerButton.alpha = 0.8
            registerButton.backgroundColor = #colorLiteral(red: 0.8357778192, green: 0.7860863209, blue: 0.2553475201, alpha: 1)
            registerButton.setTitleColor(.black, for: .normal)
        }
    }
    
//MARK: - Actions
    
    
    @objc func switchToSignIn() {
        navigationController?.popViewController(animated: true)
    }
   
    @objc func registerButtonTapped() {
        print("DEBUG-SignUpVC: registering user..")
        DismissKeyboard()
        showLoadingView(true, message: "Creating an account..")
        
        guard let emailTyped = viewModel.email else { return }
        guard let usernameTyped = viewModel.username else { return }
        guard let passwordTyped = viewModel.password else { return }
        
        Auth.auth().createUser(withEmail: emailTyped, password: passwordTyped) { (result, error) in
            
            if let e = error?.localizedDescription {
                print("DEBUG-SignUpVC: error \(e)")
                self.showLoadingView(false, message: "Creating an account")
                self.alert(error: "Oops, \(e)", buttonNote: "Try again")
                return
            }
            
            guard let uid = result?.user.uid else {return}
            guard let defaultProfileImage = UIImage(systemName: "person.circle") else { return }
            
            UploadInfo.uploadProfileImage(image: defaultProfileImage, mail: emailTyped) { imageUrl in
                
                let data = ["username": usernameTyped,
                            "email": emailTyped,
                            "password": passwordTyped,
                            "userID": uid,
                            "profileImageUrl": imageUrl]
                
                //upload to database
                Firestore.firestore().collection("users").document(emailTyped).setData(data) { error in
                    
                    self.showLoadingView(false, message: "Creating an account")
                    
                    if let e = error?.localizedDescription {
                        print("DEBUG-SignUpVC: error registering \(e)")
                        self.alert(error: "Oops, \(e)", buttonNote: "Try again")
                        return
                    }
                    
                    print("DEBUG-SignUpVC: successfully register user \(emailTyped)")
                    self.dismiss(animated: true, completion: nil)
                    
                    //let's send the notification to ScrollVC to present Login page
                    NotificationCenter.default.post(name: .didLogIn, object: nil)
                }
            }
            
        }
        
    }
   

    
    
}


//MARK: - Protocol textField
//this is the default protocol for textField in Swift
//Remember to write ".delegate = self" for 3 textfields in the ViewDidLoad
extension SignUpViewController: UITextFieldDelegate {
    
    //this func will let u dictate what happens when the return key tapped
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailTextField {
            usernameTextField.becomeFirstResponder()
        } else if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        }
        else if textField == passwordTextField {
            print("DEBUG-SignUpVC: registering user..")
            passwordTextField.resignFirstResponder()
            registerButtonTapped()
        }
        
        return true
    }
    
}
