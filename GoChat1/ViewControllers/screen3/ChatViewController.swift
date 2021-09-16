//
//  ChatViewController.swift
//  GoChat
//
//  Created by Long Nguyen on 7/29/21.
//

import UIKit
import Firebase
import SDWebImage

protocol ChatViewControllerDelegate: AnyObject {
    
}

class ChatViewController: UIViewController {
    
    let btnDimension: CGFloat = 36
    let cellHeight: CGFloat = 100
    let numberOfRow: CGFloat = 15
    
    private let tableView = UITableView()
    private let cellIndentifier = "chatCell"
    
    weak var delegate: ChatViewControllerDelegate?
    
//MARK: - User Info
        
    private let emailUser = Auth.auth().currentUser?.email
    
    //when "userInfo" got changed, the "didSet" got called. This var got filled with info fetched by func "fetchUserData"
    private var userInfo: User? {
        didSet {
            //hey
        }
    }
    
    private var profileURL: URL? {
        let urlString = userInfo?.profileImageUrl ?? "no url"
        print("DEBUG-CameraVC: profile urlString is \(urlString)")
        return URL(string: urlString)
    }
    
    
//MARK: - Components
    
    private let rabbitEarCover: UIView = {
        let vw = UIView()
        vw.backgroundColor = .black
        
        return vw
    }()
    
    private let header: ChatHeader = {
        let vw = ChatHeader()
        vw.backgroundColor = .black
        
        return vw
    }()
    
    private let topSeparator: UIView = {
        let vw = UIView()
        vw.backgroundColor = .black
        
        return vw
    }()
    
    
    //let's deal with the SearchBar
    private let searchBarController = UISearchController(searchResultsController: nil)
    
    //this var is dynamics, which changes its value all the time depending on the searchBar's behavior
    private var isSearchMode: Bool {
        return searchBarController.isActive && !searchBarController.searchBar.text!.isEmpty
        //returns true only if searchBar is active and searchText is NOT empty
    }
    
//MARK: - View Scenes
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        
        fetchUserData()
        configureNavAndSearchBar() //we hide this navBar (only show it when enabling tabBar)
        configureUI()
        configureTableView()
    }
    
    
//MARK: - NavBar
    
    private func configureNavAndSearchBar() {
        configureNavigationBar(title: "", preferLargeTitle: false, backgroundColor: .black, buttonColor: .green, interface: .dark)

        configureSearchBarController()
        navigationController?.navigationBar.isHidden = true
    }
    
    func configureSearchBarController() {
        searchBarController.obscuresBackgroundDuringPresentation = true
        searchBarController.hidesNavigationBarDuringPresentation = true
        searchBarController.searchBar.placeholder = "Search.."
        searchBarController.searchBar.barStyle = UIBarStyle.black
        navigationItem.searchController = searchBarController //got affect by the UIInterfaceStyle of the navBar
        definesPresentationContext = false
        
        searchBarController.searchBar.delegate = self
//        searchBarController.searchResultsUpdater = self
    }
    
    
//MARK: - Regular UI
    
    private func configureUI() {
        
        view.addSubview(header)
        header.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 8+btnDimension+8)
        header.delegate = self
        
        view.addSubview(rabbitEarCover)
        rabbitEarCover.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: header.topAnchor, right: view.rightAnchor)
        
    }
    
    
//MARK: - TableView
    
    private func configureTableView() {
        tableView.backgroundColor = .black
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIndentifier)
        tableView.rowHeight = cellHeight
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(topSeparator) //to create a space with the header
        topSeparator.anchor(top: header.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 2)
        
        view.addSubview(tableView)
        tableView.anchor(top: topSeparator.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingBottom: 44)
        
        
    }
    
//MARK: - Actions
    
    private func showNavVC(viewController: UIViewController) {
        let vc = viewController
        let nav = UINavigationController(rootViewController: vc)
        nav.modalTransitionStyle = .coverVertical
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    private func enableSearch() {
        UIView.animate(withDuration: 0.2) {
            self.header.alpha = 0
            self.rabbitEarCover.alpha = 0
        } completion: { _ in
            self.navigationController?.navigationBar.isHidden = false
            self.header.isHidden = true
            self.rabbitEarCover.isHidden = true
            self.searchBarController.searchBar.becomeFirstResponder()
        }
        
        //send notification to scrollVC
        NotificationCenter.default.post(name: .disableScroll, object: nil)
    }
    
    @objc func addFriends() {
        print("DEBUG-ChatVC: presenting addFriendListVC..")
        
    }
    
    @objc func showSettingPage() {
        print("DEBUG-ChatVC: showing setting page..")
    }
    
    
    func fetchUserData() {
        //let's fill in with data
        FetchingStuff.fetchUserInfo(currentEmail: emailUser ?? "mail") { userStuff in
            self.userInfo = userStuff //pass in the data
            self.header.userInfo = userStuff
        }
        
    }
    
    
    

}

//MARK: - SearchBar Delegate
//this extension declares what happen when user clicks on the searchBar or the "cancel" button
//remember to write "searchBarController.searchBar.delegate = self"
extension ChatViewController: UISearchBarDelegate {
    
    //this is what happens when searchBar is clicked
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        print("DEBUG-ChatVC: SearchBar is active")
        
    }
    
    //what happens when cancel button is clicked
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true) //dismiss the keyboard
        searchBar.showsCancelButton = false
        searchBar.text = ""
        
        navigationController?.navigationBar.isHidden = true
        header.isHidden = false
        rabbitEarCover.isHidden = false
        
        UIView.animate(withDuration: 0.4) {
            self.header.alpha = 1
            self.rabbitEarCover.alpha = 1
        }
        
        //send notification to ScrollVC
        NotificationCenter.default.post(name: .enableScroll, object: nil)
    }
}

//MARK: - tableView Datasource

//remember to write ".datasource = self" in ViewDidLoad
extension ChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(numberOfRow)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIndentifier, for: indexPath)
        cell.backgroundColor = .black
        cell.textLabel?.textColor = .white
        cell.textLabel?.text = "cell \(indexPath.row)"
        
        return cell
    }
    
    
}

//MARK: - tableView Delegate
//remember to write ".datasource = self" in ViewDidLoad
extension ChatViewController: UITableViewDelegate {
    
    
    
}

//MARK: - Protocol from ChatHeader
//remember to write ".delegate = self" in ViewDidLoad
extension ChatViewController: ChatHeaderDelegate {
    func presentSettingVC() {
        print("DEBUG-ChatVC: protocol from CHatHeader, showing setting page..")
        let vc = SettingViewController()
        showNavVC(viewController: vc)
    }
    
    func activateSearch() {
        print("DEBUG-ChatVC: protocol from ChatHeader, enabling search....")
        enableSearch()
    }
    
    
}
