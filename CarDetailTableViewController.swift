//
//  CarDetailTableViewController.swift
//  CoreMLClassifierDemo
//
//  Modified on 3/25/18.
//  Copyright © 2018. All rights reserved.
//

import UIKit

public class CarDetailTableViewController: UITableViewController {

    private let rowsInSection = [0 : 1, 1 : HTMLScrapper.generalInformations.count, 2 : HTMLScrapper.engineInformations.count, 3 : HTMLScrapper.performanceInformations.count, 4 : HTMLScrapper.dimensionInformations.count, 5 : 1,  6 : HTMLScrapper.pricingInformations.count]
    
    private let headerForSection = [0 : "Profile", 1 : "General", 2 : "Engine", 3 : "Performance", 4 : "Dimension", 5 : "Rivals", 6 : "Pricing"]
    
    private let carDetails = [1 : HTMLScrapper.generalInformations, 2 : HTMLScrapper.engineInformations, 3 : HTMLScrapper.performanceInformations, 4 : HTMLScrapper.dimensionInformations, 6 : HTMLScrapper.pricingInformations]
    
    override public func viewDidLoad() {
        title = HTMLScrapper.carName
    }
    
    
    // MARK: DataSource and Delegate methods

    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsInSection[section]!
    }

    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerForSection[section]
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "carInfoCell", for: indexPath)

        if indexPath.section == 0 {
            cell.textLabel?.text = ""
            
            cell.detailTextLabel?.numberOfLines = 0
            cell.detailTextLabel?.text = HTMLScrapper.profile

            return cell
        } else if indexPath.section == 5 {
            cell.textLabel?.text = ""
            
            cell.detailTextLabel?.numberOfLines = 0
            cell.detailTextLabel?.text = HTMLScrapper.rivals

            return cell
        }

        cell.textLabel?.text = carDetails[indexPath.section]![indexPath.row].title
        cell.detailTextLabel?.text = carDetails[indexPath.section]![indexPath.row].subtitle

        return cell
    }
}
