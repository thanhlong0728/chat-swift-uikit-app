//
//  MessageModel.swift
//  ChatApp
//
//  Created by Mac on 03/04/2025.
//

import Foundation
import FirebaseDatabase

struct MessageModel {
    static let reference = Database.database().reference().child("messages")
    let id: String
    let senderId: String
    let username: String
    let text: String
    let createdAt: Date
    var avatar: URL?
    var displayDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: createdAt)
    }
    
    init?(data: (key: String, value: Any)) {
        self.id = data.key
        guard let messageValue = data.value as? [String: Any] else {
            return nil
        }
        guard let senderId = messageValue["senderId"] as? String else {
            return nil
        }
        guard let text = messageValue["text"] as? String else {
            return nil
        }
        guard let username = messageValue["username"] as? String else {
            return nil
        }
        guard let createdAt = messageValue["createdAt"] as? Double else {
            return nil
        }
        let createdAtDate = Date(timeIntervalSince1970: createdAt)
        
        self.senderId = senderId
        self.username = username
        self.text = text
        self.createdAt = createdAtDate
        
        if let avatar = messageValue["avatarURL"] as? String,
           let avatarURL = URL(string: avatar) {
            self.avatar = avatarURL
        }
    }
    
    init?(snapshot: DataSnapshot) {
        guard let data = snapshot.value as? [String: Any] else {
            return nil
        }
        guard let senderId = data["senderId"] as? String else {
            return nil
        }
        guard let text = data["text"] as? String else {
            return nil
        }
        guard let username = data["username"] as? String else {
            return nil
        }
        guard let createdAt = data["createdAt"] as? Double else {
            return nil
        }
        let createdAtDate = Date(timeIntervalSince1970: createdAt)
        self.id = snapshot.key
        self.senderId = senderId
        self.username = username
        self.text = text
        self.createdAt = createdAtDate
        if let avatar = data["avatarURL"] as? String,
           let avatarURL = URL(string: avatar) {
            self.avatar = avatarURL
        }
    }
    
}

