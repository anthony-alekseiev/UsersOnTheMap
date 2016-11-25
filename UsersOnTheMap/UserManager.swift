    //
//  UserManager.swift
//  UsersOnTheMap
//
//  Created by Anton Aleksieiev on 11/25/16.
//  Copyright © 2016 fynjy. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase
import FirebaseDatabase

extension User {
    
    init?(data: [String:Any]) {
        guard let id = data["id"] as! String?, let name = data["name"] as! String?, let lat = data["lat"] as! Double?, let lon = data["lon"] as! Double? else { return nil }
        self.ID = id
        self.name = name
        self.currentLocation = CLLocationCoordinate2DMake(lat, lon)
    }
    
}

let kUsersManagerUserAddNotification = NSNotification.Name("kkUsersManagerUserAddNotification")
let kUsersManagerUserChangeNotification = NSNotification.Name("kUsersManagerUserChangeNotification")
let kUsersManagerUserRemoveNotification = NSNotification.Name("kUsersManagerUserRemoveNotification")
let kUsersManagerUserModifyNotification = NSNotification.Name("kUsersManagerUserModifyNotification")

let kUsersManagerUserKey = "kUsersManagerUserKey"

class UserManager {
    
    static let defaultManager : UserManager = {
        return UserManager()
    }()
    
    private var users = Dictionary<String,User>()
    lazy private var rootRef:FIRDatabaseReference = {
        let ref = FIRDatabase.database().reference()
        return ref
    }()
    private var changeHandler : FIRDatabaseHandle?
    private var addHandler : FIRDatabaseHandle?
    private var removeHandler : FIRDatabaseHandle?
    private var timer: Timer?
    private var usersRef: FIRDatabaseQuery!
    
    private init() {
        usersRef = rootRef.child("users")
    }
    
    deinit {
        removeObservers()
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Get Metods
    
    func getUsers() -> [String:User] {
        return self.users
    }
    
    //MARL: - Push Methods

    func updateCurrentUserInDatabase() {
        let user = CurrentUser.sharedUser
        let userRef = self.rootRef.child("users").child(user.id!)
        userRef.child("id").setValue(user.id!)
        userRef.child("lat").setValue(user.currentLocation?.latitude)
        userRef.child("lon").setValue(user.currentLocation?.longitude)
        userRef.child("name").setValue(user.name)
    }
    
    //MARK: - Observer Methods
    private func addObservers() {
        changeHandler = usersRef.observe(.childChanged, with: { [weak self] (snapshot) in
            guard let strongSelf = self else {return}
            if let data = snapshot.value as? [String:Any], let user = User(data: data) {
                strongSelf.users[user.ID!] = user
                let changeNotification = Notification(name: kUsersManagerUserChangeNotification, object: strongSelf, userInfo: [kUsersManagerUserKey:user])
                let modifyNotification = Notification(name: kUsersManagerUserModifyNotification)
                NotificationCenter.default.post(changeNotification)
                strongSelf.postDelayedNotification(modifyNotification)
            }
        })
        addHandler = usersRef.observe(.childAdded, with: { [weak self] (snapshot) in
            guard let strongSelf = self else {return}
            if let data = snapshot.value as? [String:Any], let user = User(data: data) {
                strongSelf.users[user.ID!] = user
                let addNotification = Notification(name: kUsersManagerUserAddNotification, object: strongSelf, userInfo: [kUsersManagerUserKey:user])
                let modifyNotification = Notification(name: kUsersManagerUserModifyNotification)
                NotificationCenter.default.post(addNotification)
                strongSelf.postDelayedNotification(modifyNotification)
            }
        })
        removeHandler = usersRef.observe(.childRemoved, with: { [weak self] (snapshot) in
            guard let strongSelf = self else {return}
            if let data = snapshot.value as? [String:Any], let user = User(data: data) {
                strongSelf.users.removeValue(forKey: user.ID!)  
                let removeNotification = Notification(name: kUsersManagerUserRemoveNotification, object: strongSelf, userInfo: [kUsersManagerUserKey:user])
                let modifyNotification = Notification(name: kUsersManagerUserModifyNotification)
                NotificationCenter.default.post(removeNotification)
                strongSelf.postDelayedNotification(modifyNotification)
            }
        })
    }
    
    private func removeObservers() {
        if addHandler != nil { usersRef.removeObserver(withHandle: addHandler!) }
        if changeHandler != nil { usersRef.removeObserver(withHandle: changeHandler!) }
        if removeHandler != nil { usersRef.removeObserver(withHandle: removeHandler!) }

    }
    
    func updateObservers() {
        removeObservers()
        addObservers()
    }
    
    //MARK: - Notification Methods
    private func postDelayedNotification(_ notification: Notification){
        let timeInterval = 0.3
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(self.rawPostNotification), userInfo: notification, repeats: false)
    }
    
    @objc private func rawPostNotification(_ timer:Timer) {
        if let notification = timer.userInfo as? Notification {
            NotificationCenter.default.post(notification)
        }
    }
}
