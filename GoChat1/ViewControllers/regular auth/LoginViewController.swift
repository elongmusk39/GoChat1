//
//  LoginViewController.swift
//  GoChat
//
//  Created by Long Nguyen on 7/29/21.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    private var viewModel = ViewModelLogin()
    
//MARK: - Components
    
    private let appLabel: UILabel = {
        let lb = UILabel()
        lb.text = "GoChat"
        lb.textColor = .black
        lb.textAlignment = .center
        lb.font = UIFont.monospacedSystemFont(ofSize: 24, weight: .semibold)
        
        return lb
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "tesla")
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .black //image's color is black
        
        return iv
    }()
    
    let emailTextField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.font = UIFont.systemFont(ofSize: 20)
        field.keyboardType = .emailAddress
        field.returnKeyType = .continue
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
    
    private let logInButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Sign in", for: .normal)
        btn.setTitleColor(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), for: .normal)
        btn.backgroundColor = #colorLiteral(red: 0.3928793073, green: 0.7171890736, blue: 0.1947185397, alpha: 1)
        btn.isEnabled = false
        btn.alpha = 0.8
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        btn.layer.cornerRadius = 14
        btn.layer.borderWidth = 1
        btn.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) //we got black here
        btn.setHeight(height: 50)
        btn.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        
        return btn
    }()
    
    private let switchSignUpButton: UIButton = {
        let btn = UIButton(type: .system)
        let textColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) //we have black
        let attributedTitle = NSMutableAttributedString (string: "Don't have an account?  ", attributes: [.font: UIFont.systemFont(ofSize: 22), .foregroundColor: textColor])
        
        attributedTitle.append(NSMutableAttributedString(string: "Register", attributes: [.font: UIFont.boldSystemFont(ofSize: 22), .foregroundColor: UIColor.blue]))
        btn.setAttributedTitle(attributedTitle, for: .normal)
        
        //let's add some action
        btn.addTarget(self, action: #selector(switchToSignUp), for: .touchUpInside)
        
        return btn
    }()
    
//MARK: - View Scenes
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isHidden = true
        configureGradientLayer(from: 0, to: 2.2)
        configureUI()
        HideKeyBoard()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    
    private func configureUI() {
        view.addSubview(iconImageView)
        iconImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 42, width: 120, height: 120)
        iconImageView.centerX(inView: view)
        
        view.addSubview(appLabel)
        appLabel.anchor(top: iconImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 30, paddingRight: 30)
        
        let stack = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, logInButton])
        stack.distribution = .equalSpacing
        stack.axis = .vertical
        stack.spacing = 12
        
        view.addSubview(stack)
        stack.anchor(top: appLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 40, paddingRight: 40)
        
        view.addSubview(switchSignUpButton)
        switchSignUpButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 20, paddingBottom: 20, paddingRight: 20)
    }
    
//MARK: - keyboard
    //let's deal with the keyboard without the use of IQKeyboardManager (tap anywhere to dismiss it)
    func HideKeyBoard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func DismissKeyboard() {
        print("DEBUG-LoginVC: dismissing keyboard..")
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
        
        checkFormStatus() //we have the viewModel all filled up with text
    }
    
    func checkFormStatus () {
        if viewModel.formIsValid {
            //this code is executed when viewModel.formIsValid == true
            logInButton.isEnabled = true
            logInButton.backgroundColor = #colorLiteral(red: 0.166891329, green: 0.9990101915, blue: 0.6152754615, alpha: 1)
            logInButton.alpha = 1
        } else {
            logInButton.isEnabled = false
            logInButton.alpha = 0.8
            logInButton.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            logInButton.setTitleColor(.black, for: .normal)
        }
    }
    
//MARK: - Actions
    
    @objc func switchToSignUp() {
        let vc = SignUpViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
   
    @objc func signInButtonTapped() {
        print("DEBUG-LoginVCn: logging user in..")
        DismissKeyboard()
        showLoadingView(true, message: "Logging in..")
        
        guard let emailTyped = emailTextField.text else {return}
        guard let passwordtyped = passwordTextField.text else {return}
        
        Auth.auth().signIn(withEmail: emailTyped, password: passwordtyped) { result, error in
            
            self.showLoadingView(false, message: "Logging in..")
            
            guard error == nil else {
                guard let e = error?.localizedDescription else { return }
                print("DEBUG-LoginVC: error login \(e)")
                self.alert(error: "Oops, \(e)", buttonNote: "Try again")
                return
            }
            
            print("DEBUG-LoginVC: successfully log in \(emailTyped)")
            self.dismiss(animated: true, completion: nil)
            
            //let's send the notification to ScrollVC to present load the camera
            NotificationCenter.default.post(name: .didLogIn, object: nil)
        }
        
    }
    
    

}


//MARK: - Protocol textField
//this is the default protocol for textField in Swift
//Remember to write ".delegate = self" for 2 textfields in the ViewDidLoad
extension LoginViewController: UITextFieldDelegate {
    
    //this func will let u dictate what happens when the return key tapped
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        }
        else if textField == passwordTextField {
            print("DEBUG-LoginVC: logging user in..")
            passwordTextField.resignFirstResponder()
            signInButtonTapped()
        }
        
        return true
    }
    
}
