////
////  Forecast.swift
////  Lab03-WeatherApp
////
////  Created by RNLD on 2023-11-15.
////
////
//import Foundation
//import SwiftUI
//import UIKit
//
//
//func loadForecast( search : String? ) {
//    
//    guard let search = search else {
//        return
//    }
//    
//    guard let url = forecastURL( que : search ) else {
//        return
//    }
//    
//    let session = URLSession.shared
//    
//    let forecastTask = session.dataTask( with: url ) { data, response, error in
//        
//        guard error == nil else {
//            print( "Received Error in Forecast" )
//            return
//        }
//
//        guard let data = data else {
//            print( "No data found in Forecast" )
//            return
//        }
//        
//        if let forecastResponse = forecastParseJson( data: data ) {
//            
//            DispatchQueue.main.async {
//                
//                print( "FORECAST : \( forecastResponse.forecast.forecastday ) ")
//                
//            }
//            
//        }
//    }
//    
//    forecastTask.resume()
//}
//
//func forecastURL( que : String ) -> URL? {
//    
//    let baseURL         = "https://api.weatherapi.com/v1/"
//    let currentEndpoint = "forecast.json"
//    let apikey          = "4ac348c97bf14a03b26230656231111"
//    let daysCount       = 1
//    
//    guard let url = "\( baseURL )\( currentEndpoint )?key=\( apikey )&q=\( que )&days=\( daysCount )&aqi=no&alerts=no".addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed ) else {
//        
//        return nil
//        
//    }
//    
//    return URL( string : url )
//
//}
//
//private func forecastParseJson( data : Data ) -> Forecast? {
//    
//    let decoder = JSONDecoder()
//    var forecast : Forecast?
//    
//    do {
//        
//        forecast = try decoder.decode( Forecast.self, from : data )
//        
//    } catch {
//        
//        print( "Error decoding for Forecast" )
//        
//    }
//    
//    return forecast
//    
//}
//
//
//    struct Forecast : Decodable {
//        
//        let location    :   Location
//        let forecast    :   Forecasts
//        
//    }
//
//    struct Location : Decodable {
//        
//        let name    : String
//        let region  : String
//        let country : String
//        
//    }
//
//    struct Forecasts : Decodable {
//        
//        let forecastday : [ Forecastday ]
//        
//    }
//
//
//    struct Forecastday : Decodable {
//        
//        let date    : String
//        let day     : Day
//        let astro   : Astronomies
//        let hour    : [ Hours ]
//        
//    }
//
//    struct Day : Decodable {
//        
//        let avgtemp_c   : Float
//        let avgtemp_f   : Float
//        
//    }
//    
//    struct Astronomies : Decodable {
//        
//        let sunrise : String
//        let sunset  : String
//        
//    }
//
//    struct Hours : Decodable {
//        
//        let time    :   String
//        let temp_c  :   Float
//        let temp_f  :   Float
//        let condition   : Conditions
//        
//    }
//
//    struct Conditions : Decodable {
//        
//        let text    :   String
//        let icon    :   String  //"icon": "//cdn.weatherapi.com/weather/64x64/night/248.png",
//        let code    :   Int
//    }
