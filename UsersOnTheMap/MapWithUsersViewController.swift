//
//  MapWithUsersViewController.swift
//  UsersOnTheMap
//
//  Created by Anton Aleksieiev on 11/25/16.
//  Copyright © 2016 fynjy. All rights reserved.
//

import UIKit
import GoogleMaps

class MapWithUsersViewController: UIViewController, UITableViewDataSource, CLLocationManagerDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var usersTableView: UITableView!
    @IBOutlet weak var mapView: GMSMapView!

    //MARK: - Properties
    let usersManager = UserManager.defaultManager
    var users = [User]()
    let locationManager = CLLocationManager()
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUsers()
        addUsersObserver()
        setUpMap()
        locationManager.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: - Methods
    func addUsersObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateUsers),
                                               name: kUsersManagerUserModifyNotification,
                                               object: nil)
    }
    
    func removeUsersObserver() {
        NotificationCenter.default.removeObserver(self, name: kUsersManagerUserModifyNotification, object: nil)
    }
    
    func updateUsers() {
        users = [User](usersManager.getUsers().values)
        usersTableView.reloadData()
        updateMarkers()
    }
    
    func updateMarkers() {
        if !users.isEmpty {
            mapView.clear()
            for user in users {
                if let location = user.currentLocation{
                    let marker = GMSMarker(position: location)
                    marker.icon = GMSMarker.markerImage(with: UIColor.blue)
                    marker.appearAnimation = kGMSMarkerAnimationPop
                    marker.map = mapView
                }
            }
        }
    }
    
    func setUpMap() {
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
    }
    
    func setCurrentLocation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [weak self] in
            guard let strongSelf = self else { return }
            if let location = strongSelf.mapView.myLocation {
                strongSelf.mapView.animate(toLocation: location.coordinate)
                strongSelf.mapView.animate(toZoom: 10)
            }
        })
    }
    
    func showEnableLocationServicesAlert(){
        let alert = UIAlertController(title: "Геопозиция запрещена пользователем для этого приложения.", message: "Если вы хотите использовать карты, пожалуйста, разрешите использование геопозиции в настройках приложения.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Открыть настройки", style: .default) { (action) in
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
        })
        present(alert, animated: true, completion: nil)
    }
    
    func checkStatus() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            CLLocationManager().requestWhenInUseAuthorization()
        case .denied:
            self.showEnableLocationServicesAlert()
        case .authorizedWhenInUse:
            setCurrentLocation()
        default:
            print("Default")
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = usersTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        if !users.isEmpty {
            let user = users[indexPath.row]
            cell.textLabel?.text = user.name
        }
        return cell
    }
    
    //MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkStatus()
    }
    
    deinit {
        removeUsersObserver()
    }
    
}
