//
//  MapWithUsersViewController.swift
//  UsersOnTheMap
//
//  Created by Anton Aleksieiev on 11/25/16.
//  Copyright © 2016 fynjy. All rights reserved.
//

import UIKit
import GoogleMaps

class MapWithUsersViewController: UIViewController, UITableViewDataSource {
    
    //MARK: - Outlets
    @IBOutlet weak var usersTableView: UITableView!
    @IBOutlet weak var mapView: GMSMapView!

    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = usersTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = "Abooooolalaaaa"
        return cell
    }
    
}
