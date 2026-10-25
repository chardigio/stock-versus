//
//  StockRowsView.swift
//  StockVersus
//
//  Created by Charlie DiGiovanna on 5/4/17.
//  Copyright © 2017 Charlie DiGiovanna. All rights reserved.
//

import UIKit

class StockRowsView: UIView, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var content_view: UIView!
    @IBOutlet weak var table_view: UITableView!
    @IBOutlet weak var title_label: UILabel!

    var stocks = [Stock]()
    var mode = TimeUnit.day
    var vc: PortfolioViewController?
    var buy: Bool?
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override init(frame: CGRect) { // for using CustomView in code
        super.init(frame: frame)
        self.loadNib()
    }


    required init?(coder aDecoder: NSCoder) { // for using CustomView in IB
        super.init(coder: aDecoder)
        self.loadNib()
    }

    private func loadNib() {
        Bundle.main.loadNibNamed("StockRowsView", owner: self, options: nil)
        guard let content = content_view else { return }
        content.frame = self.bounds
        addSubview(content)
        table_view.register(StockRowsViewCell.self, forCellReuseIdentifier: "StockRowsViewCell")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stocks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let nib = Bundle.main.loadNibNamed("StockRowsViewCell", owner: self, options: nil)!
        let cell = nib[0] as? StockRowsViewCell

        if stocks.count > indexPath.row {
            cell!.stock = stocks[indexPath.row]
            cell!.buy = buy
            cell!.setTickerLabel()
            cell!.setPriceChangeLabel(for: mode)
        }

        return cell!
    }

    @IBAction func plusPressed(_ sender: Any) {
        vc!.presentNewOrderView(buy: buy!, plus: true)
    }

    @IBAction func minusPressed(_ sender: Any) {
        vc!.presentNewOrderView(buy: buy!, plus: false)
    }

    public func updateCells(for tu: TimeUnit) {
        mode = tu
        print(mode.rawValue)
        for cell in table_view.visibleCells {
            if let c = cell as? StockRowsViewCell {
                c.setPriceChangeLabel(for: mode)
            }
        }
    }
}
