//
//  NetworkHandler.swift
//  StockVersus
//
//  Created by Charlie DiGiovanna on 5/2/17.
//  Copyright © 2017 Charlie DiGiovanna. All rights reserved.
//

import Foundation

class NetworkHandler {
//    private static func simulateGetPortfolios(belongingTo user: User, _ cb: @escaping ([Portfolio], Error?) -> ()) {
//        CoreDataHandler.deleteAllPortfolios(belongingTo: user) { err in
//            if err != nil {
//                cb([], err)
//                return
//            }
//            
//            let aapl = Stock(context: CoreDataHandler.context)
//            aapl.ticker = "AAPL"
//            aapl.balance = 133.44
//            aapl.balance_d = 133.19
//            aapl.balance_w = 130.90
//            aapl.balance_m = 121.41
//            aapl.balance_q = 120.01
//            aapl.balance_y = 111.31
//            aapl.balance_a = 100.44
//            aapl.shares = 178
//
//            let msft = Stock(context: CoreDataHandler.context)
//            msft.ticker = "MSFT"
//            msft.balance = 133.44
//            msft.balance_d = 133.19
//            msft.balance_w = 130.90
//            msft.balance_m = 121.41
//            msft.balance_q = 120.01
//            msft.balance_y = 111.31
//            msft.balance_a = 100.44
//            msft.shares = 10
//
//            let p1 = Portfolio(context: CoreDataHandler.context)
//            p1.name = "iPad > Surface"
//            p1.time_init = NSDate()
//            p1.user = User(context: CoreDataHandler.context)
//            p1.user!.username = user.username!
//            p1.balance = 11133.44
//            p1.balance_d = 11133.19
//            p1.balance_w = 11130.90
//            p1.balance_m = 11121.41
//            p1.balance_q = 11120.01
//            p1.balance_y = 10111.31
//            p1.ranking_d = 1
//            p1.ranking_w = 50
//            p1.ranking_m = 51
//            p1.ranking_q = 60
//            p1.ranking_y = 100
//            p1.ranking_a = 7
//            p1.addToBuys(aapl)
//            p1.addToPuts(msft)
//            
//            CoreDataHandler.save { err in
//                CoreDataHandler.fetchPortfolios(belongingTo: user) { portfolios, err in
//                    cb(portfolios!, err)
//                }
//            }
//        }
//    }

    private static func get(_ endpoint: String, _ cb: @escaping ([String:Any]?, Error?) -> ()) {
        var request = URLRequest(url: URL(string: "\(API_URL)\(endpoint)")!)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { // check for fundamental networking error
                print("error=\(error!)")
                cb(nil, error)
                return
            }

            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 { // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response!)")
            }

            do {
                let data = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
                cb(data, nil)
            } catch let error {
                print(error)
                cb(nil, error)
            }
        }
        
        task.resume()
    }

    private static func put(_ endpoint: String, _ data: [String: Any], _ cb: @escaping ([String:Any]?, Error?) -> ()) {
        var request = URLRequest(url: URL(string: "\(API_URL)\(endpoint)")!)
        request.httpMethod = "PUT"

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch let error {
            print(error.localizedDescription)
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { // check for fundamental networking error
                print("error=\(error!)")
                cb(nil, error)
                return
            }

            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 201 { // check for http errors
                print("statusCode should be 201, but is \(httpStatus.statusCode)")
                print("response = \(response!)")
            }

            do {
                let data = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
                cb(data, nil)
            } catch let error {
                print(error)
                cb(nil, error)
            }
        }
        
        task.resume()
    }

    private static func post(_ endpoint: String, _ data: [String: Any], _ cb: @escaping ([String:Any]?, Error?) -> ()) {
        var request = URLRequest(url: URL(string: "\(API_URL)\(endpoint)")!)
        request.httpMethod = "POST"

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch let error {
            print(error.localizedDescription)
            cb(nil, error)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { // check for fundamental networking error
                print("error=\(error!)")
                cb(nil, error)
                return
            }

            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 201 { // check for http errors
                print("statusCode should be 201, but is \(httpStatus.statusCode)")
                print("response = \(response!)")
            }

            do {
                let data = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
                cb(data, nil)
            } catch let error {
                print(error)
                cb(nil, error)
            }
        }

        task.resume()
    }

    public static func getPortfolios(belongingTo user: User, _ cb: @escaping ([Portfolio]?, Error?) -> ()) {
        // simulateGetPortfolios(belongingTo: user, cb)

        get("/portfolios/\(USER_ID)") { data, err in
            if err != nil {
                print(err!)
                cb(nil, err)
                return
            }

            var network_portfolios = [Portfolio]()

            if let portfolios_data = data?["portfolios"] as? [[String: Any]] {
                for portfolio_data in portfolios_data {
                    DataParser.parseAndSavePortfolio(portfolio_data) { portfolio, err in
                        if err != nil {
                            print(err!)
                            cb(nil, err)
                            return
                        }

                        network_portfolios.append(portfolio!)
                    }
                }
            }

            CoreDataHandler.fetchPortfolios(belongingTo: user) { portfolios, err in
                if err != nil {
                    print(err!)
                    cb(nil, err)
                    return
                }

                var portfolios_to_delete = [Portfolio]()

                for portfolio in portfolios! {
                    if !network_portfolios.contains(portfolio) {
                        portfolios_to_delete.append(portfolio)
                    } else {
                        print("matched portfolio: \(portfolio.name!)")
                    }
                }

                print("portfolios to delete: \(portfolios_to_delete.map {$0.name })")

                CoreDataHandler.deleteAndSave(portfolios_to_delete) { err in
                    if err != nil {
                        cb(nil, err)
                    } else {
                        cb(network_portfolios, nil)
                    }
                }
            }
        }
    }

    public static func createOrder(buy: Bool, ticker: String, shares: Int, portfolio: Portfolio, _ cb: @escaping (Portfolio?, Error?) -> ()) {
        put("/portfolios/order", ["buy": buy, "ticker": ticker, "shares": shares, "portfolio": portfolio.id!]) { data, err in
            if err != nil {
                print("Error creating order: \(err!)")
                cb(nil, err)
                return
            }

            if let portfolio_data = data?["portfolio"] as? [String: Any] {
                DataParser.parseAndSavePortfolio(portfolio_data) { portfolio, err in
                    if err != nil {
                        print(err!)
                        cb(nil, err)
                        return
                    }

                    cb(portfolio, nil)
                }
            }
        }
    }

    public static func getPrice(of ticker: String, _ cb: @escaping (Float?, Error?) -> ()) {
        get("/stocks/\(ticker)") { data, err in
            if err != nil {
                print(err!)
                cb(nil, err)
                return
            }

            if let stockData = data?["stock"] as? [String:Any],
               let balance = stockData["balance"] as? NSNumber {
                cb(balance.floatValue, nil)
            } else {
                cb(nil, NSError(domain: "bad response", code: 400, userInfo: nil))
            }

        }
    }

    public static func createUser(name: String, username: String, password: String, _ cb: @escaping (User?, Error?) -> ()) {
        post("/users", ["name": name, "username": username, "password": password]) { data, err in
            if err != nil {
                print("Error creating user: \(err!)")
                cb(nil, err)
                return
            }

            if let user = data?["user"] as? [String: Any] {
                USER_ID = user["id"] as! String
                USER_NAME = user["name"] as! String
                USER_USERNAME = user["username"] as! String

                CoreDataHandler.storeUser { user, err in
                    if err != nil {
                        print("err: \(err!)")
                        cb(nil, err)
                        return
                    }

                    cb(user, err)
                }
            }
        }
    }

    public static func createPortfolio(named name: String, _ cb: @escaping (Portfolio?, Error?) -> ()) {
        post("/portfolios", ["name": name, "username": USER_USERNAME, "balance": "\(PORTFOLIO_START_VALUE)", "cash": "\(PORTFOLIO_START_VALUE)"]) { data, err in
            if err != nil {
                print("Error creating portfolio: \(err!)")
                cb(nil, err)
                return
            }

            if let portfolio_data = data!["portfolio"] as? [String: Any] {
                DataParser.parseAndSavePortfolio(portfolio_data) { portfolio, err in
                    if err != nil {
                        print(err!)
                        cb(nil, err)
                        return
                    }

                    cb(portfolio, nil)
                }
            }
        }
    }
}
