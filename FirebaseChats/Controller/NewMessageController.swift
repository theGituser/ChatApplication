//
//  NewMessageController.swift
//  FirebaseChats
//
//  Created by Satya on 10/18/17.
//  Copyright © 2017 Satya. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {
    var messageController : MessagesController!
    let cellReuseIdentifier = "cell"
    var users = [User]()
    lazy var executeBlock : () = {[weak self] in
        DispatchQueue.main.async{
            self!.tableView.reloadData()
        }
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "New Message"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissController))
        self.tableView.register(UserCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        fetchUsers()
    }
    
    func fetchUsers(){
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String : Any] else{
                return
            }
            let user = User()
            user.id = snapshot.key
            user.email = dictionary["email"] as? String
            user.name = dictionary["name"] as? String
            user.profileImageURL = dictionary["profileImageUrl"] as? String
            self.users.append(user)
            print(self.users.count)
            _ = self.executeBlock
            }) { (error) in
                print(error.localizedDescription)
        }
    }
    
    @objc func dismissController(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as? UserCell
        tableCell!.textLabel?.text = users[indexPath.row].name
        tableCell!.detailTextLabel?.text = users[indexPath.row].email
        tableCell?.profileImageView.loadImageFromURL(urlString : users[indexPath.row].profileImageURL)
        return tableCell!
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true, completion: {
            self.messageController.showChatLogController(user: self.users[indexPath.row])
        })
    }
}

class UserCell : UITableViewCell{
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 70, y: (textLabel?.frame.origin.y)! - 2.0, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 70, y: detailTextLabel!.frame.origin.y + 2.0, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
        
        
    }
    
    let profileImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "profileImage")
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.addSubview(profileImageView)
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8.0).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48.0).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48.0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


