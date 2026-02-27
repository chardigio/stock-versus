//
//  DataParser.swift
//  StockVersus
//
//  Created by Charlie DiGiovanna on 5/8/17.
//  Copyright © 2017 Charlie DiGiovanna. All rights reserved.
//

import Foundation

// Helper extensions for safe JSON number parsing
// JSONSerialization returns NSNumber for all numbers; in Swift 5,
// `as? Float` on a Double-backed NSNumber fails, so we go through NSNumber.
extension Dictionary where Key == String, Value == Any {
    func floatValue(_ key: String) -> Float {
        return (self[key] as? NSNumber)?.floatValue ?? 0
    }
    func int32Value(_ key: String) -> Int32 {
        return (self[key] as? NSNumber)?.int32Value ?? 0
    }
}

class DataParser {
    public static func parseAndSavePortfolio(_ data: [String: Any], _ cb: (Portfolio?, Error?) -> ()) {
        CoreDataHandler.fetchUser() { user, err in
            if err != nil {
                print(err!)
                cb(nil, err)
                return
            }

            CoreDataHandler.fetchPortfolios(belongingTo: user!) { portfolios, err in
                if err != nil {
                    print(err!)
                    cb(nil, err)
                    return
                }

                let id = data["id"] as! String
                let portfolio = portfolios?.filter({ $0.id == id }).first ?? Portfolio(context: CoreDataHandler.context)

                portfolio.id = id
                portfolio.user = user
                portfolio.updated_at = Date()
                portfolio.time_init = Date()
                if let createdAt = dateFromString(data["created_at"] as! String) {
                    portfolio.time_init = createdAt
                }
                portfolio.name = data["name"] as? String
                portfolio.cash = data.floatValue("cash")

                portfolio.ranking_d = data.int32Value("ranking_d")
                portfolio.ranking_w = data.int32Value("ranking_w")
                portfolio.ranking_m = data.int32Value("ranking_m")
                portfolio.ranking_q = data.int32Value("ranking_q")
                portfolio.ranking_y = data.int32Value("ranking_y")
                portfolio.ranking_a = data.int32Value("ranking_a")

                portfolio.balance = data.floatValue("balance")
                portfolio.balance_d = data.floatValue("balance_d")
                portfolio.balance_w = data.floatValue("balance_w")
                portfolio.balance_m = data.floatValue("balance_m")
                portfolio.balance_q = data.floatValue("balance_q")
                portfolio.balance_y = data.floatValue("balance_y")

                var stocks_to_save = [Stock]()
                var stocks_to_delete = [Stock]()

                var buy_data = data["buys"] as? [[String: Any]]
                if buy_data == nil {
                    buy_data = [[String:Any]]()
                }

                if portfolio.buys != nil {
                    // for each of the saved buys
                    for buy in portfolio.buys! {
                        let b = buy as! Stock
                        let before_count = buy_data!.count
                        // if we find a match, sieve it out of the json data because we don't need to do anything with it
                        buy_data = buy_data!.filter {
                            $0["id"] as! String != b.id! ||
                            ($0["stock"] as! [String: Any]).floatValue("balance") != b.balance
                        }
                        // if we didn't sieve it out
                        if buy_data!.count == before_count {
                            // then delete it
                            stocks_to_delete.append(b)
                        }
                    }
                }

                // if there are still things left that weren't sieved out then we want to save them
                for b in buy_data! {
                    let s = Stock(context: CoreDataHandler.context)
                    s.id = b["id"] as? String
                    s.shares = b.int32Value("shares")
                    s.balance_a = b.floatValue("balance_a")

                    let stock = b["stock"] as! [String: Any]
                    s.ticker = stock["ticker"] as? String
                    s.balance = stock.floatValue("balance")
                    s.balance_d = stock.floatValue("balance_d")
                    s.balance_w = stock.floatValue("balance_w")
                    s.balance_m = stock.floatValue("balance_m")
                    s.balance_q = stock.floatValue("balance_q")
                    s.balance_y = stock.floatValue("balance_y")
                    print(s.balance)
                    print(s.balance_a)
                    print("balances-------")

                    s.buy_portfolio = portfolio
                    s.put_portfolio = nil

                    stocks_to_save.append(s)
                }

                var put_data = data["puts"] as? [[String: Any]]
                if put_data == nil {
                    put_data = [[String:Any]]()
                }

                if portfolio.puts != nil {
                    for put in portfolio.puts! {
                        let p = put as! Stock
                        let before_count = put_data!.count
                        put_data = put_data!.filter {
                            $0["id"] as! String != p.id! ||
                            ($0["stock"] as! [String: Any]).floatValue("balance") != p.balance
                        }
                        if put_data!.count == before_count {
                            stocks_to_delete.append(p)
                        }
                    }
                }

                for p in put_data! {
                    let s = Stock(context: CoreDataHandler.context)
                    s.id = p["id"] as? String
                    s.shares = p.int32Value("shares")
                    s.balance_a = p.floatValue("balance_a")

                    let stock = p["stock"] as! [String: Any]
                    s.ticker = stock["ticker"] as? String
                    s.balance = stock.floatValue("balance")
                    s.balance_d = stock.floatValue("balance_d")
                    s.balance_w = stock.floatValue("balance_w")
                    s.balance_m = stock.floatValue("balance_m")
                    s.balance_q = stock.floatValue("balance_q")
                    s.balance_y = stock.floatValue("balance_y")


                    s.buy_portfolio = nil
                    s.put_portfolio = portfolio

                    stocks_to_save.append(s)
                }

                print("stocks to delete: \(stocks_to_delete)")
                print("stocks to save: \(stocks_to_save)")
                CoreDataHandler.deleteAndSave(stocks_to_delete) { err in
                    if err != nil {
                        print(err!)
                        cb(nil, err)
                    } else {
                        cb(portfolio, nil)
                    }
                }
            }
        }
    }
}
