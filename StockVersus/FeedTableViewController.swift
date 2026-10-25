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
    @IBOutlet weak var logout_button: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "bg"))
        logout_button.setTitleTextAttributes( [NSAttributedString.Key.font : UIFont(name: "Euphemia UCAS", size: 18)!], for: .normal)
        
        getPortfolios()
    }

    override func viewDidAppear(_ animated: Bool) {
        getPortfolios()
    }

    func getPortfolios() {
        CoreDataHandler.fetchUser() { user, err in
            if err != nil {
                print(err!)
                return
            }

            if user == nil {
                self.performSegue(withIdentifier: "FeedToNoUser", sender: nil)
                return
            }

            CoreDataHandler.fetchPortfolios(belongingTo: user!) { portfolios, err in
                if err != nil {
                    print(err!)
                    return
                }

                self.portfolios = portfolios!

                DispatchQueue.main.async() {
                    self.tableView.reloadData()
                }
            }

            NetworkHandler.getPortfolios(belongingTo: user!) { portfolios, err in
                if err != nil {
                    print(err!)
                    return
                }
                
                self.portfolios = portfolios!

                DispatchQueue.main.async() {
                    self.tableView.reloadData()
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 1 ? portfolios.count : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GreetingCell", for: indexPath)
            // hack attack! (safe though!)
            (cell.subviews[0].subviews[0] as? UILabel)?.text = "Good Day \(USER_NAME)!"
            return cell
        } else if indexPath.section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeedTableViewCell", for: indexPath) as! FeedTableViewCell
            cell.portfolio = portfolios[indexPath.row]


            cell.fillCanvas()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewPortfolioCell", for: indexPath)
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 1 ? view.frame.width : 100
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < portfolios.count {
            performSegue(withIdentifier: "FeedToPortfolio", sender: portfolios[indexPath.row])
        }
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

    @IBAction func newPortfolioTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "New Portfolio", message: "Enter the name of the new portfolio you'd like to create.", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        let saveAction = UIAlertAction(title: "Create", style: .default, handler: {
            alert -> Void in
            let field = alertController.textFields![0] as UITextField
            if let name = field.text {
                NetworkHandler.createPortfolio(named: name) { portfolio, err in
                    if err != nil {
                        print(err!)
                        return
                    }

                    self.getPortfolios()
                }
            }
        })

        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "My Portfolio"
        }

        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)

        self.present(alertController, animated: true, completion: nil)
    }

    @IBAction func logout(_ sender: Any) {
        let alertController = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)

        let cancel_action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        let logout_action = UIAlertAction(title: "Logout", style: .default, handler: {
            alert -> Void in
            CoreDataHandler.deleteEverything() { err in
                if err != nil {
                    print(err!)
                    return
                }
                
                self.getPortfolios()
            }
        })

        alertController.addAction(cancel_action)
        alertController.addAction(logout_action)

        self.present(alertController, animated: true, completion: nil)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let next = segue.destination as? PortfolioViewController {
            next.portfolio = sender as? Portfolio
        }
    }
}
