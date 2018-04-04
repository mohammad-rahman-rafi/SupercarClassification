//
//  HTMLScrapper.swift
//  CoreMLClassifierDemo
//
//  Modified on 3/11/18.
//  Copyright © 2018. All rights reserved.
//

import Alamofire
import SwiftSoup

public class HTMLScrapper {
 
    public static var carName = ""

    public static var profile = ""
    public static var rivals = ""

    public static var generalInformations: [(title: String, subtitle: String)] = []
    public static var engineInformations: [(title: String, subtitle: String)] = []
    public static var performanceInformations: [(title: String, subtitle: String)] = []
    public static var dimensionInformations: [(title: String, subtitle: String)] = []
    public static var pricingInformations: [(title: String, subtitle: String)] = []
    
    private static let generalInformationTypes = ["Class", "Body", "Layout", "Transmission", "Number Built"]
    private static let engineInformationTypes = ["Type", "Details", "Capacity", "Max Power", "Max Torque", "Power to Weight", "Torque to Weight", "Specific Output", "Compression", "Bore x Stroke", "Fuel Cons", "Emissions"]
    private static let performanceInformationTypes = ["Top Speed", "0 - 60 mph"]
    private static let dimensionInformationTypes = ["Length", "Width", "Height", "Weight", "Wheels (F/R)", "Tyres (F/R)", "Fuel Capacity"]
    private static let pricingInformationTypes = ["New Price", "Used Price"]
    
    public static func scrapeInformation(forCar car: String, completion: @escaping () -> ()) {
        carName = car

        let informationLink = link(forCar: car)
        
        Alamofire.request(informationLink).responseString { response in
            let htmlContent = response.result.value!
            let carInfoContent = carInformationTableContent(fromHTMLContent: htmlContent)
            
            profileData(fromCarInfo: carInfoContent)
            rivalData(fromCarInfo: carInfoContent)
            performanceData(fromCarInfo: carInfoContent)
            
            generalInformations.removeAll()
            engineInformations.removeAll()
            dimensionInformations.removeAll()
            pricingInformations.removeAll()
            
            carData(fromSource: carInfoContent.slice(from: "General", to: "Engine Type")!, forTypes: generalInformationTypes, withSearchDelimiter: " ", andCategory: "General")
            carData(fromSource: "Type \(carInfoContent.slice(from: "Engine Type", to: "Performance")!) Performance", forTypes: engineInformationTypes, withSearchDelimiter: "Performance", andCategory: "Engine")
            carData(fromSource: "\(carInfoContent.slice(from: "Dimensions", to: "Pricing")!) Pricing", forTypes: dimensionInformationTypes, withSearchDelimiter: "Pricing", andCategory: "Dimension")
            carData(fromSource: "\(carInfoContent.slice(from: "Pricing", to: "Profile")!) Profile", forTypes: pricingInformationTypes, withSearchDelimiter: "Profile", andCategory: "Pricing")

            completion()
        }
    }
    
    private static func link(forCar car: String) -> String {
        switch car {
            case "Bugatti Chiron": return "http://www.supercarworld.com/cgi-bin/showgeneral.cgi?596"
            case "Ferrari LaFerrai": return "http://www.supercarworld.com/cgi-bin/showgeneral.cgi?457"
            case "Rolls Royce Wraith Black Badge": return "http://www.supercarworld.com/cgi-bin/showgeneral.cgi?625"
            case "Hennessey Venom GT": return "http://www.supercarworld.com/cgi-bin/showgeneral.cgi?465"
            case "Lamborghini Huracan Performante": return "http://www.supercarworld.com/cgi-bin/showgeneral.cgi?718"
            case "Mercedes AMG GTR": return "http://www.supercarworld.com/cgi-bin/showgeneral.cgi?707"
            case "Pagani Huayra Roadster": return "http://www.supercarworld.com/cgi-bin/showgeneral.cgi?720"
            case "Porsche 918 Spyder": return "http://www.supercarworld.com/cgi-bin/showgeneral.cgi?459"
            case "Tesla Model S P100D": return "http://www.supercarworld.com/cgi-bin/showgeneral.cgi?496"
            case "McLaren P1 GTR": return "http://www.supercarworld.com/cgi-bin/showgeneral.cgi?652"
            case "Mercedes G63 AMG": return "http://www.supercarworld.com/cgi-bin/showgeneral.cgi?642"
            default: return ""
        }
    }
    
    private static func carInformationTableContent(fromHTMLContent content: String) -> String {
        do {
            let doc = try SwiftSoup.parse(content)
            let table = try doc.select("table").first()
            let tableContents = try table!.text()

            return tableContents
        } catch {
            return ""
        }
    }
    
    private static func profileData(fromCarInfo carInfo: String) {
        profile = carInfo.slice(from: "Profile ", to: " Ratings")!.replacingOccurrences(of: "\\", with: "").trimmingCharacters(in: .whitespaces)
    }
    
    private static func rivalData(fromCarInfo carInfo: String) {
        rivals = carInfo.slice(from: "Compare rivals", to: "Variants")!.trimmingCharacters(in: .whitespaces)
    }
    
    private static func performanceData(fromCarInfo carInfo: String) {
        performanceInformations.removeAll()

        performanceInformations.append((title: "Top Speed", subtitle: carInfo.slice(from: "Top Speed", to: "0 - 30 mph")!.trimmingCharacters(in: .whitespaces)))
        performanceInformations.append((title: "0 - 60 mph", subtitle: carInfo.slice(from: "0 - 100 kmh", to: "0 - 100 mph")!.trimmingCharacters(in: .whitespaces)))
    }
    
    private static func carData(fromSource source: String, forTypes types: [String], withSearchDelimiter delimiter: String, andCategory category: String) {
        for (index, infoType) in types.enumerated() {
            if index == types.count - 1 {
                switch category {
                    case "General" : source.slice(from: "\(infoType)", to: delimiter)!.trimmingCharacters(in: .whitespaces) == "" ? generalInformations.append((title: infoType, subtitle: "--")) : generalInformations.append((title: infoType, subtitle: source.slice(from: "\(infoType)", to: delimiter)!.trimmingCharacters(in: .whitespaces)))
                    case "Engine" : source.slice(from: "\(infoType)", to: delimiter)!.trimmingCharacters(in: .whitespaces) == "" ? engineInformations.append((title: infoType, subtitle: "--")) : engineInformations.append((title: infoType, subtitle: source.slice(from: "\(infoType)", to: delimiter)!.trimmingCharacters(in: .whitespaces)))
                    case "Dimension" : source.slice(from: "\(infoType)", to: delimiter)!.trimmingCharacters(in: .whitespaces) == "" ? dimensionInformations.append((title: infoType, subtitle: "--")) : dimensionInformations.append((title: infoType, subtitle: source.slice(from: "\(infoType)", to: delimiter)!.trimmingCharacters(in: .whitespaces)))
                    case "Pricing" : source.slice(from: "\(infoType)", to: delimiter)!.trimmingCharacters(in: .whitespaces) == "" ? pricingInformations.append((title: infoType, subtitle: "--")) : pricingInformations.append((title: infoType, subtitle: source.slice(from: "\(infoType)", to: delimiter)!.trimmingCharacters(in: .whitespaces)))
                    default : break
                }
                
                break
            }
            
            switch category {
                case "General" : source.slice(from: "\(infoType)", to: "\(types[index + 1])")!.trimmingCharacters(in: .whitespaces) == "" ? generalInformations.append((title: infoType, subtitle: "--")) : generalInformations.append((title: infoType, subtitle: source.slice(from: "\(infoType)", to: "\(types[index + 1])")!.trimmingCharacters(in: .whitespaces)))
                case "Engine" : source.slice(from: "\(infoType)", to: "\(types[index + 1])")!.trimmingCharacters(in: .whitespaces) == "" ? engineInformations.append((title: infoType, subtitle: "--")) : engineInformations.append((title: infoType, subtitle: source.slice(from: "\(infoType)", to: "\(types[index + 1])")!.trimmingCharacters(in: .whitespaces)))
                case "Dimension" : source.slice(from: "\(infoType)", to: "\(types[index + 1])")!.trimmingCharacters(in: .whitespaces) == "" ? dimensionInformations.append((title: infoType, subtitle: "--")) : dimensionInformations.append((title: infoType, subtitle: source.slice(from: "\(infoType)", to: "\(types[index + 1])")!.trimmingCharacters(in: .whitespaces)))
                case "Pricing" : source.slice(from: "\(infoType)", to: "\(types[index + 1])")!.trimmingCharacters(in: .whitespaces) == "" ? pricingInformations.append((title: infoType, subtitle: "--")) : pricingInformations.append((title: infoType, subtitle: source.slice(from: "\(infoType)", to: "\(types[index + 1])")!.trimmingCharacters(in: .whitespaces)))
                default : break
            }
        }
    }
}

extension String {
    
    func slice(from: String, to: String) -> String? {
        
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}
