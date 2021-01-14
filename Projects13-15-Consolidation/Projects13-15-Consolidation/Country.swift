//
//  Country.swift
//  Projects13-15-Consolidation
//
//  Created by Usama Fouad on 12/01/2021.
//

import Foundation

struct Country: Codable {
    var name: String
    var topLevelDomain: [String]
    var alpha2Code: String
    var alpha3Code: String
    var callingCodes: [String]
    var capital: String
    var altSpellings: [String]
    var region: String
    var subregion: String
    var population: Int
    var latlng: [Double]
    var demonym: String
//    var area: Double
//    var gini: Double
    var timezones: [String]
    var borders: [String]
    var nativeName: String
//    var numericCode: String
//    var currencies: [[String:String]]
//    var languages: [[String:String]]
//    var translations: [String:String]
    var flag: String
//    var regionalBlocs: [[String:String]]
//    var cioc: String
}
