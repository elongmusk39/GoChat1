//
//  SetttingViewController.swift
//  GoChat
//
//  Created by Long Nguyen on 7/29/21.
//

import UIKit
import Firebase
import SDWebImage

class SettingViewController: UIViewController {
    
    private var currentMail = Auth.auth().currentUser?.email
    
    //when "userInfo" got changed, the "didSet" got called. This var got filled with info fetched by func "fetchUserData"
    var userInfo: User? {
        didSet {
            usernameLabel.text = userInfo?.username
            emailLabel.text = userInfo?.email
            
            profileImageView.sd_setImage(with: profileURL)
        }
    }
    
    private var profileURL: URL? {
        return URL(string: userInfo?.profileImageUrl ?? "no url")
    }
    
//MARK: - Components
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
//        iv.image = UIImage(systemName: "person.circle")
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .white
        iv.isUserInteractionEnabled = true
        
        iv.layer.masksToBounds = true
        iv.layer.borderWidth = 1
        iv.layer.borderColor = UIColor.green.cgColor
        
        return iv
    }()
    
    
    private let emailLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        lb.textColor = .green
        lb.text = "Loading..."
        
        return lb
    }()
    
    private let usernameLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        lb.textColor = .green
        lb.text = "Loading..."
        
        return lb
    }()
    
    private let photosButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Library", for: .normal)
        btn.setTitleColor(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), for: .normal)
        btn.backgroundColor = .clear
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        btn.layer.cornerRadius = 14
        btn.layer.borderWidth = 1
        btn.layer.borderColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        btn.setHeight(height: 50)
        btn.addTarget(self, action: #selector(showLibraryVC), for: .touchUpInside)
        
        return btn
    }()
    
    private let logoutButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Log Out", for: .normal)
        btn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        btn.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        btn.layer.cornerRadius = 14
        btn.layer.borderWidth = 1
        btn.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) //we got black here
        btn.setHeight(height: 50)
        btn.addTarget(self, action: #selector(alertLogout), for: .touchUpInside)
        
        return btn
    }()
    
//MARK: - View Scenes

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        configureNavBar()
        configureUI()
        fetchUserData()
        swipeAndTapGesture()
    }
    
    private func configureNavBar() {
        configureNavigationBar(title: "Setting", preferLargeTitle: false, backgroundColor: .black, buttonColor: .green, interface: .dark)

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .done, target: self, action: #selector(dismissSettingVC))
    }
    
    private func configureUI() {
        
        view.addSubview(profileImageView)
        profileImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 20, width: 200, height: 200)
        profileImageView.layer.cornerRadius = 100
        profileImageView.centerX(inView: view)
        
        view.addSubview(usernameLabel)
        usernameLabel.anchor(top: profileImageView.bottomAnchor, paddingTop: 20)
        usernameLabel.centerX(inView: view)
        
        view.addSubview(emailLabel)
        emailLabel.anchor(top: usernameLabel.bottomAnchor, paddingTop: 12)
        emailLabel.centerX(inView: view)
        
        let stack = UIStackView(arrangedSubviews: [photosButton, logoutButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .equalSpacing
        
        view.addSubview(stack)
        stack.anchor(top: emailLabel.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 36, paddingLeft: 32, paddingRight: 32)
        
    }
    
//MARK: - Actions
    
    private func swipeAndTapGesture() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(dismissSettingVC))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        profileImageView.addGestureRecognizer(tap)
    }
    
    @objc func imageTapped() {
        print("DEBUG-SettingVC: image tapped")
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    @objc func dismissSettingVC() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func showLibraryVC() {
        
    }
    
    @objc func alertLogout() {
        let actionSheet = UIAlertController (title: "Log out?", message: "Are you sure want to log out?", preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Log out", style: .destructive) { _ in
            self.showLoadingView(true, message: "Logging out..")
            self.logOut()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
        actionSheet.addAction(action)
        actionSheet.addAction(cancel)
        present (actionSheet, animated: true, completion: nil)
    }
    
    private func logOut() {
        Authentication.signOut { userMail in
            print("DEBUG-SettingVC: just done sign out \(userMail)")
            self.showLoadingView(false, message: "Logging out..")
            self.dismiss(animated: true, completion: nil)
            
            //let's send the notification to ScrollVC to present Login page
            NotificationCenter.default.post(name: .didLogOut, object: nil)
        }
    }
    
//MARK: - API Call
    
    func fetchUserData() {
        //let's fill in with data
        FetchingStuff.fetchUserInfo(currentEmail: currentMail ?? "no mail") { userStuff in
            self.userInfo = userStuff //pass in the data
            print("DEBUG-SettingVC: done fetching user info")
        }
        
    }
    
    private func uploadNewProfileImage() {
        
        guard let newImage = profileImageView.image else { return }
        guard let email = userInfo?.email else { return }
        
        UploadInfo.uploadProfileImage(image: newImage, mail: email) { imageUrl in
                        
            let data = ["profileImageUrl": imageUrl]
            
            //upload to new profile image database
            Firestore.firestore().collection("users").document(email).updateData(data) { error in
                
                self.showLoadingView(false, message: "Saving..")
                if let e = error?.localizedDescription {
                    print("DEBUG-SettingVC: error changing proImage - \(e)")
                    self.alert(error: "Oops, \(e)", buttonNote: "Try again")
                    return
                }
                print("DEBUG-SettingVC: finish uploading new profileImage")
                
                //send notification to CameraVC and ChatVC
                NotificationCenter.default.post(name: .didChangeUserInfo, object: nil)
            }
        }
    }
    
    

}

//MARK: - Extension for ImagePicker

extension SettingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //this func gets called once user has just chose a pict
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("DEBUG-SettingVC: just finished picking a photo")
        
        guard let selectedImage = info[.editedImage] as? UIImage else {
            print("DEBUG-SettingVC: error setting selectedImage")
            return
        }
        
        //let's set the profileImageView as the selected image
        profileImageView.image = selectedImage
        showLoadingView(true, message: "Saving..")
        uploadNewProfileImage()
        self.dismiss(animated: true, completion: nil)
    }
}
