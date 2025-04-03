//
//  RoomViewController.swift
//  ChatApp
//
//  Created by Mac on 03/04/2025.
//

import UIKit
import FirebaseDatabase

class RoomViewController: UIViewController {
    
    @IBOutlet weak var bottomInputViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    var user: UserModel?
    var room: RoomModel?
    var messages: [MessageModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 83
        tableView.separatorStyle = .none
        tableView.reloadData()
        fetchMessages()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sendButton.layer.cornerRadius = sendButton.frame.height / 2
    }
    
    func fetchMessages() {
        guard let room = room else {
            presentErrorAlert(title: "Messages Error", message: "We could not get messages right now.")
            return
        }
        MessageModel.reference.child(room.title).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let strongSelf = self else { return }
            guard let messages = snapshot.value as? [String: Any] else { return }
            strongSelf.messages = messages.compactMap { MessageModel(data: $0) }
            strongSelf.messages.sort { message1, message2 in
                message1.createdAt > message2.createdAt
            }
            strongSelf.tableView.reloadData()
            strongSelf.observeMessages()
        }
    }
    
    func observeMessages() {
        guard let room = room else {
            return
        }
        MessageModel.reference.child(room.title).observe(.childAdded) { [weak self] snapshot in
            guard let strongSelf = self else { return }
            guard let message = MessageModel(snapshot: snapshot) else {
                return
            }
            let isMessageFound = strongSelf.messages.contains(where: { queryMessage in
                message.id == queryMessage.id
            })
            if !isMessageFound {
                strongSelf.messages.insert(message, at: 0)
                strongSelf.tableView.beginUpdates()
                strongSelf.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
                strongSelf.tableView.endUpdates()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardNotifications()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        messageTextView.layer.cornerRadius = 6
    }
    
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardOffset = view.convert(keyboardFrame.cgRectValue, from: nil).size.height
        bottomInputViewConstraint.constant -= keyboardOffset
        view.layoutIfNeeded()
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        bottomInputViewConstraint.constant = 0
        view.layoutIfNeeded()
    }
    
    @IBAction func sendMessageButtonTapped(_ sender: Any) {
        
        guard let user = user,
            let room = room else {
            presentErrorAlert(title: "Cannot Send Message", message: "Sending messages is not possible right now.")
            return
        }
        
        guard let message = messageTextView.text,
              message.count >= 1 else {
            presentErrorAlert(title: "Cannot Send Message", message: "Please ensure that you have entered at least one character")
            return
        }
        var messageData: [String: Any] = [
            "text": message,
            "senderId": user.id,
            "createdAt": Date().timeIntervalSince1970,
            "username": user.username
        ]
        
        if let avatarURL = user.avatarURL {
            messageData["avatarURL"] = avatarURL.absoluteString
        }
        
        Database.database().reference().child("messages").child(room.title).childByAutoId().setValue(messageData)
        
        messageTextView.text = nil
        view.endEditing(true)
    }
    

}

extension RoomViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        if let userId = user?.id,
           message.senderId == userId {
            let cell = tableView.dequeueReusableCell(withIdentifier: SentTableViewCell.identifier) as! SentTableViewCell
            cell.configure(message: message)
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ReceivedTableViewCell.identifier) as! ReceivedTableViewCell
            cell.configure(message: message)
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            return cell
        }
    }
    
    
}
