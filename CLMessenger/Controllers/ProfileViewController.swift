//
//  ProfileViewController.swift
//  CLMessenger
//
//  Created by ChengLu on 2024/6/24.
//

import UIKit
import FirebaseAuth
import SDWebImage



final class ProfileViewController: UIViewController {
    
    @IBOutlet var tableVew: UITableView!
    
    var data = [ProfileViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableVew.register(ProfileTabelViewCell.self, forCellReuseIdentifier: ProfileTabelViewCell.identifier)
        data.append(ProfileViewModel(viewModelType: .info,
                                     title: "名字: \(UserDefaults.standard.value(forKey: "name") ?? "No name")",
                                     handler: nil))
        data.append(ProfileViewModel(viewModelType: .info,
                                     title: "信箱: \(UserDefaults.standard.value(forKey: "email") ?? "No Email")",
                                     handler: nil))
        data.append(ProfileViewModel(viewModelType: .logout,
                                     title: "Log Out",
                                     handler: { [weak self] in
            guard let self = self else { return }
            let actionSheet = UIAlertController(title: "是否要登出？",
                                                message: "",
                                                preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "登出",
                                                style: .destructive,
                                                handler: { [weak self] _ in
                guard let self = self else { return }
                
                // 移除暫存Email, name
                UserDefaults.standard.setValue(nil, forKey: "email")
                UserDefaults.standard.setValue(nil, forKey: "name")
                
                do {
                    try FirebaseAuth.Auth.auth().signOut()
                    
                    let vc = LoginViewController()
                    let nav = UINavigationController(rootViewController: vc)
                    nav.modalPresentationStyle = .fullScreen
                    self.present(nav, animated: false)
                } catch {
                    print("登出錯誤！")
                }
                
            }))
            actionSheet.addAction(UIAlertAction(title: "取消",
                                                style: .default,
                                                handler: nil))
            
            self.present(actionSheet, animated: true)
        }))
        
        tableVew.register(UITableViewCell.self,
                          forCellReuseIdentifier: "cell")
        tableVew.delegate = self
        tableVew.dataSource = self
        tableVew.tableHeaderView = createTableHeader()
        
    }
    
    func createTableHeader() -> UIView? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let filename = safeEmail + "_profile_picture.png"
        let path = "images/"+filename
        
        let headerView = UIView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: self.view.width,
                                              height: 300))
        headerView.backgroundColor = .link
        
        let imageView = UIImageView(frame: CGRect(x: (headerView.width-150)/2,
                                                  y: 75,
                                                  width: 150,
                                                  height: 150))
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.width/2
        headerView.addSubview(imageView)
        
        StorageManager.shared.downloadURL(for: path) { result in
            switch result {
            case .success(let url):
                imageView.sd_setImage(with: url, completed: nil)
            case .failure(let error):
                print("Failed to get download url: \(error)")
            }
        }
        return headerView
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTabelViewCell.identifier, for: indexPath) as! ProfileTabelViewCell
        let viewModel = data[indexPath.row]
        cell.setUp(with: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        data[indexPath.row].handler?()
        
    }
}

class ProfileTabelViewCell: UITableViewCell {
    
    static let identifier = "ProfileTabelViewCell"
    
    public func setUp(with viewModel: ProfileViewModel) {
        var cellContext = self.defaultContentConfiguration()
        cellContext.text = viewModel.title
        cellContext.secondaryText = ""
        switch viewModel.viewModelType {
        case .info:
            cellContext.textProperties.alignment = .natural
            self.selectionStyle = .none
        case .logout:
            cellContext.textProperties.color = .red
            cellContext.textProperties.alignment = .center
        }
        contentConfiguration = cellContext

    }
}
