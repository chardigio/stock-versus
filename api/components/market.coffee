request = require 'request'
_ = require 'lodash'
rek = require 'rekuire'
configs = rek 'config'
Stock = rek 'models/stock'

YAHOO_BASE = "https://query1.finance.yahoo.com/v8/finance/chart"
HEADERS = { 'User-Agent': 'Mozilla/5.0' }

# Get current price for a stock
module.exports.getStockNow = (ticker, stock, cb) ->
  request
    url: "#{YAHOO_BASE}/#{ticker}?interval=1d&range=1d"
    method: 'GET'
    json: true
    headers: HEADERS
    (error, response, body) ->
      if error then return cb error
      if response.statusCode isnt 200 then return cb new Error "unable to get stock: #{response.statusCode}"
      if not body?.chart?.result?[0] then return cb new Error "no data for #{ticker}"

      meta = body.chart.result[0].meta
      stock_pieces = {}
      stock_pieces.ticker = ticker
      stock_pieces.balance = meta.regularMarketPrice
      stock_pieces.num_portfolios = 0

      cb null, stock, stock_pieces

# Get current + historical prices for a stock
module.exports.getStockHistory = (ticker, stock, cb) ->
  request
    url: "#{YAHOO_BASE}/#{ticker}?interval=1d&range=1y"
    method: 'GET'
    json: true
    headers: HEADERS
    (error, response, body) ->
      if error then return cb error
      if response.statusCode isnt 200 then return cb new Error "unable to get stock: #{response.statusCode}"
      if not body?.chart?.result?[0] then return cb new Error "no data for #{ticker}"

      result = body.chart.result[0]
      meta = result.meta
      closes = result.indicators.quote[0].close
      timestamps = result.timestamp

      now = new Date()
      stock_pieces = {}
      stock_pieces.ticker = ticker
      stock_pieces.balance = meta.regularMarketPrice

      # Helper: find the close price on or before a target date
      findCloseOnOrBefore = (targetDate) ->
        targetTs = targetDate.getTime() / 1000
        best = null
        for i in [0...timestamps.length]
          if timestamps[i] <= targetTs and closes[i]?
            best = closes[i]
        best or stock_pieces.balance

      # Yesterday / previous trading day
      if closes.length >= 2
        # Find last non-null close before today
        stock_pieces.balance_d = stock_pieces.balance
        for i in [closes.length - 2..0] by -1
          if closes[i]?
            stock_pieces.balance_d = closes[i]
            break
      else
        stock_pieces.balance_d = stock_pieces.balance

      # 1 week ago
      weekAgo = new Date(now)
      weekAgo.setDate weekAgo.getDate() - 7
      stock_pieces.balance_w = findCloseOnOrBefore weekAgo

      # 1 month ago
      monthAgo = new Date(now)
      monthAgo.setMonth monthAgo.getMonth() - 1
      stock_pieces.balance_m = findCloseOnOrBefore monthAgo

      # 1 quarter ago
      quarterAgo = new Date(now)
      quarterAgo.setMonth quarterAgo.getMonth() - 3
      stock_pieces.balance_q = findCloseOnOrBefore quarterAgo

      # 1 year ago (use earliest available data point)
      yearAgo = new Date(now)
      yearAgo.setFullYear yearAgo.getFullYear() - 1
      stock_pieces.balance_y = findCloseOnOrBefore yearAgo

      cb null, stock, stock_pieces
