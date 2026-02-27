//
//  FeedPaneView.swift
//  StockVersus
//
//  Created by Charlie DiGiovanna on 5/2/17.
//  Copyright © 2017 Charlie DiGiovanna. All rights reserved.
//

import UIKit

class FeedPaneView: UIView {
    @IBOutlet var content_view: UIView!
    @IBOutlet weak var inner_border_view: UIView!
    @IBOutlet weak var balance_label: UILabel!
    @IBOutlet weak var date_label: UILabel!
    @IBOutlet weak var name_label: UILabel!
    @IBOutlet weak var dollar_change_label: UILabel!
    @IBOutlet weak var percent_change_label: UILabel!
    @IBOutlet weak var period_label: UILabel!
    @IBOutlet weak var ranking_label: UILabel!
    @IBOutlet weak var next_period_label: UILabel!

    var portfolio: Portfolio?

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    // override func draw(_ rect: CGRect) {
        // Drawing code
    // }

    override init(frame: CGRect) { // for using CustomView in code
        super.init(frame: frame)
        self.loadNib()
    }

    required init?(coder aDecoder: NSCoder) { // for using CustomView in IB
        super.init(coder: aDecoder)
        self.loadNib()
    }

    private func loadNib() {
        Bundle.main.loadNibNamed("FeedPaneView", owner: self, options: nil)
        guard let content = content_view else { return }
        content.frame = self.bounds
        addSubview(content)
    }

    func drawLabels() {
        if portfolio == nil { return }

        inner_border_view.layer.borderWidth = 1
        inner_border_view.layer.borderColor = UIColor.darkGray.cgColor

        balance_label.text = portfolio!.balance.dollarString
        date_label.text = portfolio!.updated_at!.prettyButShortDateTimeDescription
        name_label.text = portfolio!.name!

        dollar_change_label.text = dollarChangeString(for: portfolio!.balance, since: portfolio!.balance_d)
        dollar_change_label.textColor = changeColor(for: portfolio!.balance, since: portfolio!.balance_d)
        percent_change_label.text = percentChangeString(for: portfolio!.balance, since: portfolio!.balance_d)
        percent_change_label.textColor = changeColor(for: portfolio!.balance, since: portfolio!.balance_d)

        period_label.text = "Day:"
        ranking_label.text = rankPercentString(for: portfolio!.ranking_d)
//        next_period_label.text = ...
    }
}
