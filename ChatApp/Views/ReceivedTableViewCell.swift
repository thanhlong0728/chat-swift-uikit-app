//
//  ReceivedTableViewCell.swift
//  ChatApp
//
//  Created by Mac on 03/04/2025.
//

import UIKit

class ReceivedTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var bubbleImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var messageTextLabel: UILabel!
    static let identifier = "ReceivedTableViewCell"
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.layer.cornerRadius = 25
    }

    func configure(message: MessageModel) {
        let bubbleImage = UIImage(named: "chat-bubble-left")
        bubbleImageView.tintColor = UIColor.bubbleReceived
        bubbleImageView.image = bubbleImage?.resizableImage(withCapInsets: UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21), resizingMode: .stretch).withRenderingMode(.alwaysTemplate)
        messageTextLabel.text = message.text
        createdAtLabel.text = message.displayDate
        usernameLabel.text = message.username
        avatarImageView.sd_setImage(with: message.avatar, placeholderImage: UIImage(systemName: "person.fill"))
        selectionStyle = .none
    }

}

