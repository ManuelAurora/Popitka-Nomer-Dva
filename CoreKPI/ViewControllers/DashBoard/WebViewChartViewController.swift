//
//  WebViewChartViewController.swift
//  CoreKPI
//
//  Created by Семен Осипов on 08.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit
import WebKit

struct InfoBox
{
    let payer: String
    let value: String
    let netValue: String
    let timestamp: String
}

enum TypeOfChart: String
{
    case PieChart = "Pie chart"
    case PointChart = "Point chart"
    case LineChart = "Line chart"
    case BarChart = "Negative bar chart"
    case Funnel = "Funnel chart"
    case PositiveBar = "Positive bar chart"
    case AreaChart = "Area chart"
}

class WebViewChartViewController: UIViewController
{    
    @IBOutlet weak var webView: UIWebView!

    var typeOfChart = TypeOfChart.PieChart
    var index = 0
    var header: String = " "
    var isAllowed = false
    var service: IntegratedServices!
    
    lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
        return df
    }()
    
    //data for charts
    var rawDataArray: resultArray = []
    var pieChartData: [(number: String, rate: String)] = []
    var pointChartData: [(country: String, life: String, population: String, gdp: String, color: String, kids: String, median_age: String)] = []
    var lineChartData: [[InfoBox]] = []
    var barChartData: [(value: String, val: String)] = []
    var funnelChartData: [(name: String, value: String)] = []
    var positiveBarData: [(value: String, val: String)] = []
    var areaChartData: [(date: String, kermit: String, piggy: String, gonzo: String, lol: String)] = []
    
    deinit {
        print("DEBUG: WebViewVC deinitialized")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = false
        webView.backgroundColor = UIColor.white
        webView.frame = view.bounds
        
        guard rawDataArray.count > 0 else { return }
        
        createCharts()
    }
    
    private func createCharts() {
        
        guard let tabBarHeight        = self.tabBarController?.tabBar.frame.size.height,
              let navigationBarHeight = self.navigationController?.navigationBar.frame.size.height else { return }
        
        
        let statusBarHeight     = UIApplication.shared.statusBarFrame.height
        let height = webView.bounds.size.height - (tabBarHeight + navigationBarHeight + statusBarHeight)
        let width  = webView.bounds.size.width
        
        switch typeOfChart
        {
        case .PieChart:
            let htmlFile = Bundle.main.path(forResource:"index", ofType: "html")
            let cssFile = Bundle.main.path(forResource:"style", ofType: "css")
            let jsFile1 = Bundle.main.path(forResource:"Rd3.v3.min", ofType: "js")
            let jsFile2 = Bundle.main.path(forResource:"round", ofType: "js")
            let accountingFile = Bundle.main.path(forResource: "accounting.min", ofType: "js")
            
            let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
            let css = try? String(contentsOfFile: cssFile!, encoding: String.Encoding.utf8)
            let js1 = try? String(contentsOfFile: jsFile1!, encoding: String.Encoding.utf8)
            let js2 = try? String(contentsOfFile: jsFile2!, encoding: String.Encoding.utf8)
            let acc = try? String(contentsOfFile: accountingFile!, encoding: String.Encoding.utf8)
            
            let endOfJS = "pie((\(width)), \(height), data_pie);"
            let topOfJS2 = generateDataForJS()
            let htmlString: String = html! + "<style>" + css! + "</style>" +
                "<script>" + acc! + "</script><script>" + js1! +
                "</script><script>" + topOfJS2 + js2! + endOfJS + "</script>"
                      
            webView.loadHTMLString(htmlString, baseURL: nil)
            
        case .PointChart:
            let htmlFile = Bundle.main.path(forResource:"points", ofType: "html")
            let cssFile = Bundle.main.path(forResource:"points", ofType: "css")
            let jsFile1 = Bundle.main.path(forResource:"d3", ofType: "js")
            let jsFile2 = Bundle.main.path(forResource:"points", ofType: "js")
            
            let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
            let css = try? String(contentsOfFile: cssFile!, encoding: String.Encoding.utf8)
            let js1 = try? String(contentsOfFile: jsFile1!, encoding: String.Encoding.utf8)
            let js2 = try? String(contentsOfFile: jsFile2!, encoding: String.Encoding.utf8)
            
            let topOfJS = "var margin = {top: 50, right: 30, bottom: 30, left: 30}; var width = \(width) - margin.left - margin.right; var height = \(height) - margin.top - margin.bottom;" + generateDataForJS()
            
            webView.loadHTMLString( html! + "<style>" + css! + "</style>" + "<script>" + js1! + "</script><script>" + topOfJS + js2! + "</script>", baseURL: nil)
            
        case .LineChart:
            let htmlFile = Bundle.main.path(forResource:"Lines", ofType: "html")
            let cssFile = Bundle.main.path(forResource:"Lines", ofType: "css")
            let jsFile1 = Bundle.main.path(forResource:"d3", ofType: "js")
            let jsFile2 = Bundle.main.path(forResource:"Lines", ofType: "js")
            
            let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
            let css = try? String(contentsOfFile: cssFile!, encoding: String.Encoding.utf8)
            let js1 = try? String(contentsOfFile: jsFile1!, encoding: String.Encoding.utf8)
            let js2 = try? String(contentsOfFile: jsFile2!, encoding: String.Encoding.utf8)
                        
            let topOfJS2 = "const lineChartHeight = \(height);" +
                generateDataForJS()
            
            webView.loadHTMLString( html! + "<style>" + css! + "</style>" + "<script>" + js1! + "</script><script>" + topOfJS2 + js2! + "</script>", baseURL: nil)
            
        case  .BarChart:
            let htmlFile = Bundle.main.path(forResource:"bar", ofType: "html")
            let cssFile = Bundle.main.path(forResource:"bar", ofType: "css")
            let jsFile1 = Bundle.main.path(forResource:"Rd3.v3.min", ofType: "js")
            let jsFile2 = Bundle.main.path(forResource:"bar", ofType: "js")
            
            let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
            let css = try? String(contentsOfFile: cssFile!, encoding: String.Encoding.utf8)
            let js1 = try? String(contentsOfFile: jsFile1!, encoding: String.Encoding.utf8)
            let js2 = try? String(contentsOfFile: jsFile2!, encoding: String.Encoding.utf8)
            
            let topOfJsFile = "var margin  = {top: 50, right: 30, bottom: 30, left: 30}; var width   = \(width) - (margin.left + margin.right); var height  = \(height) - (margin.top + margin.bottom);"  + generateDataForJS()
            
            let htmlstring = html! + "<style>" + css! + "</style>" + "<script>" + js1! + "</script><script>" + topOfJsFile + js2! + "</script>"
            
            webView.loadHTMLString(htmlstring, baseURL: nil)
            
        case .Funnel:
            let htmlFile = Bundle.main.path(forResource:"funnel", ofType: "html")
            let cssFile = Bundle.main.path(forResource:"funnel", ofType: "css")
            let jsJquerryFile = Bundle.main.path(forResource:"jquery.min", ofType: "js")
            let jsD3File = Bundle.main.path(forResource:"d3V442.min", ofType: "js")
            let jsD3FunnelFile = Bundle.main.path(forResource:"d3-funnel", ofType: "js")
            let jsFile = Bundle.main.path(forResource:"funnel", ofType: "js")
            
            let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
            let css = try? String(contentsOfFile: cssFile!, encoding: String.Encoding.utf8)
            let jsJquerry = try? String(contentsOfFile: jsJquerryFile!, encoding: String.Encoding.utf8)
            let jsD3 = try? String(contentsOfFile: jsD3File!, encoding: String.Encoding.utf8)
            let jsD3Funnel = try? String(contentsOfFile: jsD3FunnelFile!, encoding: String.Encoding.utf8)
            let js = try? String(contentsOfFile: jsFile!, encoding: String.Encoding.utf8)
            
            let jsHead = "var FunnelWidth = \(width), FunnelHeight = \(height);" + generateDataForJS()
            
            webView.loadHTMLString( html! + "<style>" + css! + "</style>" + "<script>" + jsJquerry! + "</script><script>" + jsD3! + "</script><script>" + jsD3Funnel! + "</script><script>" + jsHead + js! + "</script>", baseURL: nil)
            
        case .PositiveBar:
            let htmlFile = Bundle.main.path(forResource:"positiveBar", ofType: "html")
            let cssFile = Bundle.main.path(forResource:"positiveBar", ofType: "css")
            let jsFile1 = Bundle.main.path(forResource:"Rd3.v3.min", ofType: "js")
            let jsFile2 = Bundle.main.path(forResource:"positiveBar", ofType: "js")
            
            let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
            let css = try? String(contentsOfFile: cssFile!, encoding: String.Encoding.utf8)
            let js1 = try? String(contentsOfFile: jsFile1!, encoding: String.Encoding.utf8)
            let js2 = try? String(contentsOfFile: jsFile2!, encoding: String.Encoding.utf8)
            let downOfJsFile = generateDataForJS() + "positiveBar(\(width), \(height), data, 180, 0.35);"
            
            webView.loadHTMLString( html! + "<style>" + css! + "</style>" + "<script>" + js1! + "</script><script>" + js2! + downOfJsFile + "</script>", baseURL: nil)
            
        case .AreaChart:
            let htmlFile = Bundle.main.path(forResource:"stackArea", ofType: "html")
            let cssFile = Bundle.main.path(forResource:"stackArea", ofType: "css")
            let jsFile1 = Bundle.main.path(forResource:"Rd3.v3.min", ofType: "js")
            let jsFile2 = Bundle.main.path(forResource:"stackArea", ofType: "js")
            
            let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
            let css = try? String(contentsOfFile: cssFile!, encoding: String.Encoding.utf8)
            let js1 = try? String(contentsOfFile: jsFile1!, encoding: String.Encoding.utf8)
            let js2 = try? String(contentsOfFile: jsFile2!, encoding: String.Encoding.utf8)
            let downOfJsFile = "stack_area(\(width) - 0, \(height), data_stack_area);"
            
            webView.loadHTMLString( html! + "<style>" + css! + "</style>" + "<script>" + js1! + "</script><script>" + generateDataForJS() + js2! + downOfJsFile + "</script>", baseURL: nil)
        }
    }
    
    private func generateDataForJS() -> String {
        
        switch typeOfChart
        {
        case .PieChart:
            var dataForJS = "var lable = '\(header)'; var data_pie = ["
            
            if let service = service
            {
                if service == .Quickbooks
                {
                    let hundredPercent = 100
                    let value  = rawDataArray[0].rightValue
                    let truncatedValue = value.substring(to: value.index(before: value.endIndex))
                    let resultValue = hundredPercent - (Int(truncatedValue) ?? 0)
                    let object = (leftValue: rawDataArray[0].leftValue, centralValue: "", rightValue: truncatedValue)
                    let agonist = (leftValue: "", centralValue: "", rightValue: String(resultValue))
                    
                    rawDataArray.removeAll()
                    rawDataArray.append(object)
                    rawDataArray.append(agonist)
                }
                
                if service == .HubSpotCRM
                {
                    let wonDeals  = rawDataArray.filter { $0.centralValue == "Won" }
                    let lostDeals = rawDataArray.filter { $0.centralValue == "Lost" }
                    
                    rawDataArray.removeAll()
                    rawDataArray.append((leftValue: "Won",
                                         centralValue: "",
                                         rightValue: "\(wonDeals.count)"))
                    rawDataArray.append((leftValue: "Lost",
                                         centralValue: "",
                                         rightValue: "\(lostDeals.count)"))
                }
            }
            
            for (index,item) in rawDataArray.enumerated() {
                if index > 0 {
                    dataForJS += ","
                }
                let pieData = "{number: '\(item.leftValue)', rate: \(item.rightValue)}"
                dataForJS += pieData
            }
            dataForJS += "];"
            
            return dataForJS
            
        case .PointChart:
            let calendar  = Calendar.current
            let formatter = DateFormatter()
            
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            
            pointChartData = rawDataArray.map {
                let dateStr = $0.leftValue
                let date    = formatter.date(from: dateStr)!
                let day     = calendar.component(.day, from: date)
                
                return ("Algeria",
                        $0.rightValue,
                        "35468208",
                        "6300",
                        "blue",
                        "\(day)",
                        "50")
            }
            
            header = "This is PointChart"
           
            var dataForJS = "var label = '\(header)'; var pointJson = ["
            
            for (index,item) in pointChartData.enumerated() {
                if index > 0 {
                    dataForJS += ","
                }
                let pointData = "{'country':'\(item.country)','life':\(item.life),'population':\(item.population),'gdp':\(item.gdp),'color':'\(item.color)','kids': \(item.kids),'median_age': \(item.median_age)}"
                dataForJS += pointData
            }
            dataForJS += "]"
            return dataForJS
            
        case .LineChart:
            if let service = service
            {
                switch service
                {
                case .PayPal:
                    lineChartData = formLineChartPaypalData()
                    
                case .Quickbooks:
                    lineChartData = formLineChartQuickbooksData()
                    
                case .GoogleAnalytics:
                    lineChartData = formLineChartGAData()
                    
                case .HubSpotCRM, .HubSpotMarketing:
                    lineChartData = formLineChartHSData()
                    
                case .SalesForce:
                    lineChartData = formLineChartSFData()
                    
                default: break
                }
            }
            else
            {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss +zzzz"
                
                let infoboxes = rawDataArray.map { tuple -> InfoBox in
                    
                    let dateString = tuple.leftValue
                    let date       = formatter.date(from: dateString)!
                    let timeStamp  = date.timeIntervalSince1970
                    let infoBox    = InfoBox(payer: "",
                                             value: "",
                                             netValue: tuple.rightValue,
                                             timestamp: "\(timeStamp)")
                    
                    return infoBox
                }
                let sortedArr = infoboxes.sorted {$0.timestamp < $1.timestamp }
                lineChartData = [sortedArr]
            }
            
            header = "Line chart"
            
            var dataForJS = "var label = '\(header)'; const dataIn = [["
            
            if lineChartData.count > 0
            {
                let lastArrayIndex = lineChartData.count - 1
                
                for (index, arrayOfData) in lineChartData.enumerated()
                {
                    for (index, item) in arrayOfData.enumerated()
                    {
                        if index > 0 { dataForJS += "," }
                        let lineData = "{date: new Date(\(item.timestamp)), rate: \(item.netValue)}"
                        dataForJS += lineData
                    }
                    
                    dataForJS += index == lastArrayIndex ? "]] ;" : "], ["
                }
            }
            
            return dataForJS
            
        case .BarChart:
            
            rawDataArray.forEach {
                barChartData.append(($0.leftValue, $0.rightValue))
            }
            
            header = "This is BarChart"
            //<-Debug
            
            var dataForJS = "var label = '\(header)'; var data = ["
            for (index,item) in barChartData.enumerated() {
                if index > 0 {
                    dataForJS += ","
                }
                let barData = "{'name':'\(randomString(10))','value':\(item.value),'val':\(item.val)}"
                dataForJS += barData
            }
            dataForJS += "]"
            return dataForJS
            
        case .Funnel:
           
            funnelChartData = rawDataArray.map { tuple -> (name: String, value: String) in
                return (name: tuple.leftValue, value: tuple.rightValue)
            }
            
            header = "This is FunnelChart"
            //<-Debug
            var dataForJS = "var label = '\(header)'; var dataByFunnel = ["
            for (index,item) in funnelChartData.enumerated() {
                if index > 0 {
                    dataForJS += ","
                }
                let funnelData = "['\(item.name)', \(item.value), '#87d37c']"
                dataForJS += funnelData
            }
            dataForJS += "];"
            return dataForJS
            
        case .PositiveBar:
                  
            rawDataArray.forEach {
                 positiveBarData.append(($0.leftValue, $0.rightValue))                
            }

            header = "This is PositiveBar))";
            
            var dataForJS = "var label = '\(header)'; var data = ["
            for (index,item) in positiveBarData.enumerated() {
                if index > 0 {
                    dataForJS += ","
                }
                let positiveBar = "{'name': '\(randomString(10))','value': \(item.value),'val': \(item.val)}"
                dataForJS += positiveBar
            }
            dataForJS += "];"
            return dataForJS
        case .AreaChart:
            
            
            areaChartData = [
                ("13-Oct-31","85.44","150","80.57","50"),
                ("13-Nov-30","130","200.85","168.97","150"),
                ("13-Dec-31","113.46","350.88","40.57","200"),
                ("14-Jan-30","140.46","350.88","40.57","100")
            ]
            
            header = "This is AreaChart"
            //<-Debug
            var dataForJS = "var label = '\(header)'; var data_stack_area = ["
            for (index,item) in areaChartData.enumerated() {
                if index > 0 {
                    dataForJS += ","
                }
                
                let areaChart = "{'date': '\(item.date)','Kermit': \(item.kermit),'piggy': \(item.piggy),'Gonzo': \(item.gonzo),'Lol': \(item.lol)}"
                dataForJS += areaChart
            }
            dataForJS += "];"
            return dataForJS
        }
    }
    
    private func timestampStringFrom(date: String) -> String {
        
        if let date = dateFormatter.date(from: date)
        {
            let timestamp = date.timeIntervalSince1970
            return String(Int(timestamp))
        }
        
        print("DEBUG: Timestamp error")
        
        return "";
    }
    
    private func lineChartDataFrom(result: [InfoBox]) -> [[InfoBox]] {
        
        let sorted = result.sorted { $0.timestamp < $1.timestamp }
        let lineChartData: [[InfoBox]] = [sorted]
        
        return lineChartData
    }
    
    private func formLineChartSFData() -> [[InfoBox]] {
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss z"
        
        let revenueNewLeadsArray = rawDataArray.map { tuple -> InfoBox in
            let date      = df.date(from: tuple.leftValue)
            var timestamp = ""
            var res: Float = 0
            
            if let stamp = date?.timeIntervalSince1970
            {
                timestamp = String(Int(stamp))
            }
            
            if let value = Float(tuple.centralValue)
            {
                res = value
            }
            
            let infoBox = InfoBox(payer: "",
                                  value: "",
                                  netValue: "\(res)",
                timestamp: timestamp)
            
            return infoBox
        }
        
        return [revenueNewLeadsArray.sorted { $0.timestamp < $1.timestamp }]
    }
    
    private func formLineChartHSData() -> [[InfoBox]] {
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss z"
        
        if service == .HubSpotCRM
        {
            let dealRevenueArray: [InfoBox] = rawDataArray.map { tuple -> InfoBox in
                let date      = df.date(from: tuple.leftValue)
                var timestamp = ""
                let dealValue = Float(tuple.rightValue) ?? 0
                let revenue   = Float(tuple.centralValue) ?? 0
                var result: Float = 0
                
                if dealValue > 0
                {
                    result = revenue / dealValue
                }
                
                if let stamp = date?.timeIntervalSince1970
                {
                    timestamp = String(Int(stamp))
                }
                
                let infoBox = InfoBox(payer: "",
                                      value: "",
                                      netValue: "\(result)",
                    timestamp: timestamp)
                
                return infoBox
            }
            return [dealRevenueArray.sorted { $0.timestamp < $1.timestamp }]
        }
        else
        {
            let visitsContactsArray: [InfoBox] = rawDataArray.map { tuple -> InfoBox in
                let date      = df.date(from: tuple.leftValue)
                var timestamp = ""
                let value     = tuple.rightValue
                if let stamp = date?.timeIntervalSince1970
                {
                    timestamp = String(Int(stamp))
                }
                
                let infoBox = InfoBox(payer: "",
                                      value: "",
                                      netValue: "\(value)",
                                      timestamp: timestamp)
                
                return infoBox
            }
            return [visitsContactsArray]
        }
    }
        
    private func formLineChartGAData() -> [[InfoBox]] {
        
        let df = DateFormatter()
        df.dateFormat = "yyyy/MM/dd"
        
        let result: [InfoBox] = rawDataArray.map {
            let date = df.date(from: $0.leftValue)
            var timestamp = ""
             
            if let stamp = date?.timeIntervalSince1970
            {
                timestamp = String(Int(stamp))
            }
            
            let infoBox   = InfoBox(payer: "",
                                    value: "",
                                    netValue: $0.rightValue,
                                    timestamp: timestamp)
            return infoBox
        }
        
        return lineChartDataFrom(result: result)
    }
    
    private func formLineChartQuickbooksData() -> [[InfoBox]] {
        
        let result: [InfoBox] = rawDataArray.map {
            let timestamp = timestampStringFrom(date: $0.leftValue)
            let invoice = InfoBox(payer: "",
                                  value: "",
                                  netValue: $0.rightValue,
                                  timestamp: timestamp)
            return invoice
        }
        
        return lineChartDataFrom(result: result)
    }

    private func formLineChartPaypalData() -> [[InfoBox]] {
        
        var payers = [String]()
        
        _ = rawDataArray.map { if !payers.contains($0.leftValue) { payers.append($0.leftValue) } } //Filling payers array
        
        let salesByPayers = payers.map { payer -> [InfoBox] in
            
            let dataArray: resultArray = rawDataArray.filter { $0.leftValue == payer }
            
            let result: [InfoBox] = dataArray.map {
                (leftValue: String, centralValue: String, rightValue: String) -> InfoBox in
                let timestamp = timestampStringFrom(date: rightValue)
                let values = centralValue.components(separatedBy: "&")
                let sale = InfoBox(payer: leftValue,
                                   value: values[1],
                                   netValue: values[0],
                                   timestamp: timestamp)
                
                return sale
            }
            return result
        }
        
        return salesByPayers
    }
    
    private func randomString(_ length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    func refreshView() {
        createCharts()
    }
}
