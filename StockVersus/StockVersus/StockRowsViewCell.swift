//
//  StockRowsViewCell.swift
//  StockVersus
//
//  Created by Charlie DiGiovanna on 5/4/17.
//  Copyright © 2017 Charlie DiGiovanna. All rights reserved.
//

import UIKit

class StockRowsViewCell: UITableViewCell {
    @IBOutlet weak var content_view: UIView!
    @IBOutlet weak var ticker_label: UILabel!
    @IBOutlet weak var price_change_label: UILabel!
    var stock: Stock?
    var balances: [Float] {
        return [stock!.balance_d, stock!.balance_w, stock!.balance_m, stock!.balance_q, stock!.balance_y, stock!.balance_a]
    }
    var mode: TimeUnit?
    var buy: Bool?
    var dollars = true

    override func awakeFromNib() {
        super.awakeFromNib()

        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cellTapped(_:))))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    func setTickerLabel() {
        if stock?.ticker == nil {
            return
        }

        ticker_label.text = "\(stock!.ticker!) (x\(stock!.shares))"
    }

    public func setPriceChangeLabel(for tu: TimeUnit) {
        mode = tu

        price_change_label.text = dollars ? dollarChangeString(for: Float(stock!.shares) * stock!.balance, since: Float(stock!.shares) * balances[mode!.rawValue]) : percentChangeString(for: stock!.balance, since: balances[mode!.rawValue])


        price_change_label.textColor = changeColor(for: stock!.balance, since: balances[mode!.rawValue], opposite: !buy!)
    }

    func updatePriceChangeLabelAfterTap() {
        price_change_label.text = dollars ? dollarChangeString(for: Float(stock!.shares) * stock!.balance, since: Float(stock!.shares) * balances[mode!.rawValue]) : percentChangeString(for: stock!.balance, since: balances[mode!.rawValue])
    }

    @objc func cellTapped(_ sender: Any?) {
        dollars = !dollars

        DispatchQueue.main.async {
            self.updatePriceChangeLabelAfterTap()
        }
    }
}
