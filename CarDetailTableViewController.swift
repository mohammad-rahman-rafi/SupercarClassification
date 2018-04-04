//
//  CarDetailTableViewController.swift
//  CoreMLClassifierDemo
//
//  Modified on 3/25/18.
//  Copyright © 2018. All rights reserved.
//

import UIKit

public class CarDetailTableViewController: UITableViewController {

    private let rowsInSection = [0 : 1, 1 : 1, 2 : HTMLScrapper.generalInformations.count, 3 : HTMLScrapper.engineInformations.count, 4 : HTMLScrapper.performanceInformations.count, 5 : HTMLScrapper.dimensionInformations.count, 6 : 1,  7 : HTMLScrapper.pricingInformations.count]
    
    private let headerForSection = [0 : "", 1 : "Profile", 2 : "General", 3 : "Engine", 4 : "Performance", 5 : "Dimension", 6 : "Rivals", 7 : "Pricing"]
    
    private let carDetails = [2 : HTMLScrapper.generalInformations, 3 : HTMLScrapper.engineInformations, 4 : HTMLScrapper.performanceInformations, 5 : HTMLScrapper.dimensionInformations, 7 : HTMLScrapper.pricingInformations]
    
    override public func viewDidLoad() {
        title = HTMLScrapper.carName
        
        tableView.register(UINib(nibName: "BaseCellView", bundle: nil), forCellReuseIdentifier: "cell")
    }
    
    
    // MARK: DataSource and Delegate methods

    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 8
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
            let baseCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BaseCell
            
            baseCell.carPhoto.image = UIImage(named: "\(HTMLScrapper.carName)")
            baseCell.carName.text = HTMLScrapper.carName
            
            baseCell.detailTextLabel?.text = HTMLScrapper.carName
            
            return baseCell
        } else if indexPath.section == 1 {
            cell.textLabel?.text = ""
            
            cell.detailTextLabel?.numberOfLines = 0
            cell.detailTextLabel?.text = HTMLScrapper.profile

            return cell
        } else if indexPath.section == 6 {
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
