//
//  ProfileViewController.swift
//  CLMessenger
//
//  Created by ChengLu on 2024/6/24.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    @IBOutlet var tableVew: UITableView!
    
    let data = ["Log Out"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableVew.register(UITableViewCell.self,
                          forCellReuseIdentifier: "cell")
        tableVew.delegate = self
        tableVew.dataSource = self

    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textColor = .red
        cell.textLabel?.textAlignment = .center
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let actionSheet = UIAlertController(title: "是否要登出？",
                                      message: "",
                                      preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "登出",
                                      style: .destructive,
                                      handler: { [weak self] _ in
            guard let self = self else { return }
            
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
        
        present(actionSheet, animated: true)

        
        
    }
    
    
    
}
