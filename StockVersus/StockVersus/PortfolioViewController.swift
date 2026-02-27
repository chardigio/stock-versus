//
//  PortfolioViewController.swift
//  StockVersus
//
//  Created by Charlie DiGiovanna on 5/2/17.
//  Copyright © 2017 Charlie DiGiovanna. All rights reserved.
//

import UIKit

class PortfolioViewController: UIViewController {
    @IBOutlet weak var balance_label: UILabel!
    @IBOutlet weak var change_label: UILabel!
    @IBOutlet weak var d_button: UIButton!
    @IBOutlet weak var w_button: UIButton!
    @IBOutlet weak var m_button: UIButton!
    @IBOutlet weak var q_button: UIButton!
    @IBOutlet weak var y_button: UIButton!
    @IBOutlet weak var a_button: UIButton!
    var time_unit_buttons: [UIButton] {
        return [d_button, w_button, m_button, q_button, y_button, a_button]
    }
    @IBOutlet weak var underline_view: UIView!
    @IBOutlet weak var buys_canvas: UIView!
    @IBOutlet weak var puts_canvas: UIView!
    @IBOutlet weak var cash_label: UILabel!

    var portfolio: Portfolio?
    let buys_table = StockRowsView()
    let puts_table = StockRowsView()
    var stock_tables: [StockRowsView] {
        return [buys_table, puts_table]
    }
    var mode = TimeUnit.day

    var outside_of_new_order_view: UIView?
    var new_order_view: NewOrderView?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "bg"))
        navigationItem.title = portfolio!.name
        navigationItem.backBarButtonItem?.title = "Feed"

        setLabels()
    }

    override func viewDidAppear(_ animated: Bool) {
        addTablesToCanvases()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setLabels() {
        let balances = [portfolio!.balance_d, portfolio!.balance_w, portfolio!.balance_m, portfolio!.balance_q, portfolio!.balance_y, PORTFOLIO_START_VALUE]

        balance_label.text = portfolio!.balance.dollarString
        change_label.text = priceChangeString(for: portfolio!.balance, since: balances[mode.rawValue])
        change_label.textColor = changeColor(for: portfolio!.balance, since: balances[mode.rawValue])

        cash_label.text = portfolio!.cash.dollarString
    }

    func addTablesToCanvases() {
        buys_table.stocks = portfolio!.buys!.map { $0 as! Stock }
        buys_table.frame = buys_canvas.bounds
        buys_table.title_label.text = "BUYS"
        buys_table.vc = self
        buys_table.buy = true
        buys_canvas.addSubview(buys_table)

        puts_table.stocks = portfolio!.puts!.map { $0 as! Stock }
        puts_table.frame = puts_canvas.bounds
        puts_table.title_label.text = "SHORTS"
        puts_table.vc = self
        puts_table.buy = false
        puts_canvas.addSubview(puts_table)
    }

    func timeUnitPressed() {
        print(mode)
        moveUnderline()
        for t in stock_tables {
            t.updateCells(for: mode)
        }
    }

    @IBAction func dPressed(_ sender: Any) {
        mode = .day
        timeUnitPressed()
    }

    @IBAction func wPressed(_ sender: Any) {
        mode = .week
        timeUnitPressed()
    }

    @IBAction func mPressed(_ sender: Any) {
        mode = .month
        timeUnitPressed()
    }

    @IBAction func qPressed(_ sender: Any) {
        mode = .quarter
        timeUnitPressed()
    }

    @IBAction func yPressed(_ sender: Any) {
        mode = .year
        timeUnitPressed()
    }

    @IBAction func aPressed(_ sender: Any) {
        mode = .alltime
        timeUnitPressed()
    }

    func moveUnderline() {
        UIView.animate(withDuration: 0.25, animations: {
            self.underline_view.frame = self.underline_view.frame.offsetBy(dx: 5 + self.time_unit_buttons[self.mode.rawValue].frame.minX - self.underline_view.frame.minX , dy: 0)
        })
    }

    public func presentNewOrderView(buy: Bool, plus: Bool) {
        dimEverything()

        outside_of_new_order_view = UIView(frame: view.bounds)
        outside_of_new_order_view!.alpha = 0.1
        outside_of_new_order_view!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(outsideOfNewOrderViewTapped(_:))))
        outside_of_new_order_view!.isUserInteractionEnabled = true
        view.addSubview(outside_of_new_order_view!)

        new_order_view = NewOrderView()
        new_order_view!.vc = self
        new_order_view!.cash = portfolio!.cash
        new_order_view!.buy = buy
        new_order_view!.plus = plus
        new_order_view!.initLabels()

        let w: CGFloat = 220
        let h: CGFloat = 220
        new_order_view!.frame = CGRect(x: view.frame.width/2-w/2, y: view.frame.height/2-h/2, width: w, height: h)

        view.addSubview(new_order_view!)
    }

    @objc func outsideOfNewOrderViewTapped(_ sender: Any?) {
        UIView.animate(withDuration: 0.25, animations: {
            self.new_order_view?.alpha = 0
        }, completion: { _ in
            self.new_order_view?.removeFromSuperview()
            self.new_order_view = nil
            self.outside_of_new_order_view?.removeFromSuperview()
            self.outside_of_new_order_view = nil

            self.undimEverything()
        })

    }

    public func placeOrder(buy: Bool, ticker: String, shares: Int) {
        NetworkHandler.createOrder(buy: buy, ticker: ticker, shares: shares, portfolio: portfolio!) { portfolio, err in
            if err != nil {
                print(err!)
            }

            self.portfolio = portfolio

            DispatchQueue.main.async() {
                self.setLabels()
                self.buys_table.stocks = self.portfolio!.buys!.map { $0 as! Stock }
                self.buys_table.table_view.reloadData()
                self.puts_table.stocks = self.portfolio!.puts!.map { $0 as! Stock }
                self.puts_table.table_view.reloadData()
            }
        }

        outsideOfNewOrderViewTapped(nil)
    }

    func dimEverything() {
        for sv in view.subviews { // dim errything
            sv.alpha = 0.6
        }
    }

    func undimEverything() {
        for sv in view.subviews { // undim errything
            sv.alpha = 1
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
