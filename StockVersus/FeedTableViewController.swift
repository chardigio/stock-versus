//
//  FeedTableViewController.swift
//  StockVersus
//
//  Created by Charlie DiGiovanna on 5/4/17.
//  Copyright © 2017 Charlie DiGiovanna. All rights reserved.
//

import UIKit

class FeedTableViewController: UITableViewController {
    var portfolios = [Portfolio]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "bg"))
        getPortfolios()
    }

    func getPortfolios() {
        CoreDataHandler.fetchPortfolios(belongingTo: USER) { portfolios, err in
            if err != nil {
                print(err!)
                return
            }

            self.portfolios = portfolios
            print(portfolios)
            tableView.reloadData()
            print("datad")
        }

        NetworkHandler.getPortfolios(belongingTo: USER) { portfolios, err in
            if err != nil {
                print(err!)
                return
            }

            self.portfolios = portfolios
            print(portfolios)
            tableView.reloadData()
            print("networked")
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : portfolios.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GreetingCell", for: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeedTableViewCell", for: indexPath) as! FeedTableViewCell
            cell.portfolio = portfolios[indexPath.row]


            cell.fillCanvas()
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 100 : view.frame.width
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "FeedToPortfolio", sender: portfolios[indexPath.row])
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let next = segue.destination as? PortfolioViewController {
            next.portfolio = sender as? Portfolio
        }
    }
}
