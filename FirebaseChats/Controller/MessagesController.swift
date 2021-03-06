//
//  ViewController.swift
//  FirebaseChats
//
//  Created by Satya on 10/16/17.
//  Copyright © 2017 Satya. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {
    let reuseIdentifier  = "tablecell"
    var messages : [Message] = []
    var messageDict : [String : Message] = [:]
    var dataBaseRef : DatabaseReference = Database.database().reference()
    lazy var performReload : () = {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UserCell.self, forCellReuseIdentifier: reuseIdentifier)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleNewMessage))
        self.observUserMessages()
        self.isuserLoggedIn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    func observUserMessages(){
        guard let userID = Auth.auth().currentUser?.uid else{
            return
        }
        dataBaseRef.child("user messages").child(userID).observe(.childAdded, with: { (snapshot) in
            self.dataBaseRef.child("messages").child(snapshot.key).observeSingleEvent(of: .value, with: { (snapshot) in
                if let messageDict = snapshot.value as? [String : Any]{
                    var message = Message()
                    message.content = messageDict["message"] as? String
                    message.receiverId = messageDict["receiverId"] as? String
                    message.senderId = messageDict["senderId"] as? String
                    message.timestamp = messageDict["timestamp"] as? Int
                    var otherUser : String?
                    if userID == message.receiverId{
                        otherUser = message.senderId
                    }
                    else{
                        otherUser = message.receiverId
                    }
                    if let otherUser = otherUser{
                        self.messageDict[otherUser] = message
                        self.messages = Array(self.messageDict.values)
                        self.messages.sort(by: { (m1, m2) -> Bool in
                            return m1.timestamp! > m2.timestamp!
                        })
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    @objc func handleNewMessage(){
       let newMessageController = NewMessageController()
        newMessageController.messageController = self
        present(UINavigationController(rootViewController : newMessageController), animated: true, completion: nil)
    }
    
    func showChatLogController(user : User?){
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        self.navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    func isuserLoggedIn(){
        if let userid = Auth.auth().currentUser?.uid{
            self.updateNavigationBarTitle(userid : userid)
        }
        else{
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
    }
    
    func updateNavigationBarTitle(userid : String){
        Database.database().reference().child("users").child(userid).observeSingleEvent(of: .value, with: {
            (snapshot) in
            guard let user_dictionary = snapshot.value as? [String: Any] else{
                return
            }
            DispatchQueue.main.async {
                let navigationbarHeight = self.navigationController?.navigationBar.frame.height
                self.navigationItem.setTitleView(title: user_dictionary["name"] as? String, imageURL : user_dictionary["profileImageUrl"] as? String, navigationBarHeight: navigationbarHeight)
            }
        }, withCancel: { (error) in
            print(error.localizedDescription)
            return
        })
    }
    
    @objc func handleLogout(){
        do{
            try Auth.auth().signOut()
        }catch let error{
            print(error.localizedDescription)
        }
        
        let loginController = LoginViewController()
        loginController.messageController = self
        present(loginController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! UserCell
        let message = messages[indexPath.row]
        cell.message = message
        return cell
    }
}

