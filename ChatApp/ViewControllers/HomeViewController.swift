//
//  HomeViewController.swift
//  ChatApp
//
//  Created by mac on 1/4/2025.
//

import UIKit
import SDWebImage
import FirebaseDatabase
import FirebaseAuth

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileBarButtonItem: UIBarButtonItem!
    var user: UserModel?
    var rooms: [RoomModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowRoomSegue" {
            let destinationVC = segue.destination as! RoomViewController
            let room = sender as! RoomModel
            destinationVC.user = user
            destinationVC.room = room
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Chat App"
        observeUserProfile()
        observeRooms()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func observeRooms() {
        RoomModel.reference.observe(.value) { [weak self] snapshot in
            guard let strongSelf = self else { return }
            guard let rooms = snapshot.value as? [String: Any] else { return }
            let unorderedRooms = rooms.compactMap { RoomModel(data: $0) }
            let orderedRooms = unorderedRooms.sorted { room1, room2 in
                room1.createdAt > room2.createdAt
            }
            strongSelf.rooms = orderedRooms
        }
    }
    
    func observeUserProfile() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        UserModel.reference.child(userId).observe(.value) { snapshot in
            if let user = UserModel(snapshot: snapshot) {
                self.user = user
                if let avatarURL = user.avatarURL {
                    self.createLeftBarButtonItem(avatarURL: avatarURL)
                }
            }
        }
    }
    
    func createLeftBarButtonItem(avatarURL: URL) {
        SDWebImageManager.shared.loadImage(with: avatarURL, progress: nil) { image, _, error, _, _, _ in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            let button = UIButton()
            button.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
            button.setImage(image, for: .normal)
            button.addTarget(self, action: #selector(self.goToProfileVC), for: .touchUpInside)
            button.imageView?.contentMode = .scaleAspectFill
            button.clipsToBounds = true
            button.layer.cornerRadius = 17
            let customView = UIView(frame: CGRect(x: 0, y: 0, width: 34, height: 34))
            let barButton = UIBarButtonItem(customView: customView)
            barButton.customView?.addSubview(button)
            self.navigationItem.leftBarButtonItem = barButton
        }
    }
    
    @objc func goToProfileVC() {
        performSegue(withIdentifier: "ProfileSegue", sender: nil)
    }
    
    @IBAction func profileButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "ProfileSegue", sender: nil)
    }
    
    @IBAction func createRoomButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "CreateRoomSegue", sender: nil)
    }
    

}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let room = rooms[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: RoomTableViewCell.identifier, for: indexPath) as! RoomTableViewCell
        cell.configure(room: room)
        return cell
    }
    
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let room = rooms[indexPath.row]
        performSegue(withIdentifier: "ShowRoomSegue", sender: room)
    }
    
}


