//
//  ViewController.swift
//  Lab03-WeatherApp
//
//  Created by RNLD on 2023-11-11.
//

import SwiftUI
import UIKit


class ViewController: UIViewController, UITextFieldDelegate {

    private var locationManager = LocationManager()
    private var latitude        : Double = 42.94
    private var longitude       : Double = -81.33
    private var isCelsius       = true
    private var lastValidSearchQuery: String?
    
    @IBOutlet weak var txtTempFC            : UILabel!
    @IBOutlet weak var txtLocation          : UILabel!
    @IBOutlet weak var txtRegionCountry     : UILabel!
    @IBOutlet weak var txtAction            : UILabel!
    @IBOutlet weak var lblSunrise           : UILabel!
    @IBOutlet weak var lblSunset            : UILabel!
    @IBOutlet weak var txtPlaceLocation     : UITextField!
    @IBOutlet weak var wallpaper            : UIImageView!
    @IBOutlet weak var imgIconCondition     : UIImageView!
    @IBOutlet weak var forecastingScroll    : UIScrollView!
    @IBOutlet weak var risesetBlurd         : UIVisualEffectView!
    @IBOutlet weak var currentInfoBlurdTop  : UIVisualEffectView!
    @IBOutlet weak var segmentControl       : UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if txtPlaceLocation.text == nil || txtPlaceLocation.text?.isEmpty == true {

            let currentLoc = "\( latitude ),\( longitude )"
            loadWeather( search: currentLoc, changeTemp: true )
            
        } else {
            
            loadWeather( search: txtPlaceLocation.text, changeTemp: true )
            
        }
    
        locationManager.requestLocationAuthorization()
        
        txtPlaceLocation.delegate = self
        
        wallpaper.image = UIImage( named: "cloudy" )
//      wallpaper.image = UIImage( named: "sky-sun" )
        
        wallpaper.alpha                 = 0.50
        currentInfoBlurdTop.alpha       = 0.50
        
        risesetBlurd.layer.cornerRadius             = 10
        currentInfoBlurdTop.layer.cornerRadius      = 10
        
        risesetBlurd.layer.masksToBounds            = true
        currentInfoBlurdTop.layer.masksToBounds     = true
        
    }
    
    // KEYBAORD FOR "SEARCH" BUTTON FUNCTION * * * * * * *
    func textFieldShouldReturn(_ textField: UITextField ) -> Bool {
        
        loadWeather( search: txtPlaceLocation.text, changeTemp: true )
        txtPlaceLocation.resignFirstResponder()
        segmentControl.selectedSegmentIndex = 0
        textField.endEditing( true )
        return true
        
    }
    
    @IBAction func btnCurrentLoc(_ sender: UIButton ) {

        let currentLoc = "\( latitude ),\( longitude )"
        if let searchQuery = txtPlaceLocation.text, !searchQuery.isEmpty {
            
            self.txtPlaceLocation.text = ""
            txtPlaceLocation.resignFirstResponder()
            
        } else {

            loadWeather( search: currentLoc, changeTemp: true )
            txtPlaceLocation.resignFirstResponder()

       }
        
        segmentControl.selectedSegmentIndex = 0
        
    }
    
    @IBAction func btnSearch(_ sender: UIButton ) {
        
        let userSearchQuery = txtPlaceLocation.text
        if let query = userSearchQuery, !query.isEmpty {

            lastValidSearchQuery = query

        }

        loadWeather( search: userSearchQuery, changeTemp: true )
        txtPlaceLocation.resignFirstResponder()
        
        segmentControl.selectedSegmentIndex = 0
        
    }
    
    @IBAction func tempSegment(_ sender: UISegmentedControl) {
        
        isCelsius = sender.selectedSegmentIndex == 0
        let searchQuery = lastValidSearchQuery ?? "\( latitude ),\( longitude )"
        loadWeather( search: searchQuery, changeTemp: isCelsius )

    }
    
    private func loadWeather( search: String?, changeTemp: Bool ) {
        print( "SEARCH : \( search ?? "" )" )
        
        if let search = search {
            
            lastValidSearchQuery = search
            
        }
        guard let search = search else {
            
            return
            
        }
        guard let url = apiURL( que: search ) else {

            return
            
        }
        guard let astroUrl = astroURL( que: search ) else {
            
            return
            
        }
        guard let forecastURL = forecastURL( que : search ) else {
            return
        }
        
        let session = URLSession.shared
        
        // DATATASK FOR THE FORECAST API
        let forecastTask = session.dataTask( with: forecastURL ) { data, response, error in
            
            guard error == nil else {
                
                print( "Received Error in Forecast" )
                return
                
            }
            guard let data = data else {
                
                print( "No data found in Forecast" )
                return
                
            }
            
            if let forecastResponse = self.forecastParseJson( data: data ) {
                
                DispatchQueue.main.async { [ self ] in
                    self.forecastingScroll.subviews.forEach { $0.removeFromSuperview() }
                    
                    // * * * CONVERTION OF DATE AND GET ONLY THE HOUR * * *
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                    
                    var currentX: CGFloat   = -8
                    let spacing: CGFloat    = 10
                  
                    for forecastday in forecastResponse.forecast.forecastday {
                        
                        for hour in forecastday.hour {
                            
                            let timeLabel       = UILabel()
                            let iconImageView   = UIImageView()
                            let tempLabel       = UILabel()
                            
                            timeLabel.textAlignment     = .center
                            iconImageView.contentMode   = .scaleAspectFit
                            tempLabel.textAlignment     = .center
                            
                            timeLabel.frame     =   CGRect  ( x : currentX, y: 10, width : 60, height : 30 )
                            iconImageView.frame =   CGRect  ( x : currentX, y: 40, width : 60, height : 30 )
                            tempLabel.frame     =   CGRect  ( x : currentX, y: 73, width : 60, height : 30 )
                            
                            
                            // * * * CONVERTION OF TEMPERATURE * * *
                            let temperature: Int
                            let tempC = hour.temp_c
                            let tempF = hour.temp_f

                            temperature = changeTemp ? Int( tempC ) : Int( tempF )
                            
                            tempLabel.text = "\( temperature )°"
                            
                            // * * * GETTING THE TIME * * *
                            if let date = dateFormatter.date( from: hour.time ) {
                                
                                let timeFormatter = DateFormatter()
                                timeFormatter.dateFormat = "ha"
                                timeLabel.text = "\( timeFormatter.string( from: date ) )"
                                
                            } else {
                                
                                timeLabel.text = hour.time
                                
                            }
                            
                            
                            
                            // * * * ASSIGNING OF ICON * * *
                            let iconCode = "\( hour.condition.icon )"

                            if iconCode.lowercased().contains( "night" ) {

                                if let codeStringValue = hour.condition.codeStringValueNight {

                                    iconImageView.image = UIImage( systemName : codeStringValue )?.withRenderingMode(.alwaysOriginal)

                                }
                                
                            } else if iconCode.lowercased().contains( "day" ) {

                                if let codeStringValue = hour.condition.codeStringValueDay {

                                    iconImageView.image = UIImage( systemName : codeStringValue )?.withRenderingMode(.alwaysOriginal)

                                }
                            }
                            
                            self.forecastingScroll.addSubview( timeLabel )
                            self.forecastingScroll.addSubview( iconImageView )
                            self.forecastingScroll.addSubview( tempLabel )
                            
                            currentX += timeLabel.frame.width + spacing
                            
                        }
                    }
                    
                    self.forecastingScroll.contentSize = CGSize( width: currentX, height: 10 )
                    
                }
            }
        }
        
        // DATATASK FOR THE ASTRONOMY API
        let astroTask = session.dataTask( with: astroUrl ) { data, response, error in
            
            guard error == nil else {
                
                print( "Received error" )
                return
                
            }
            guard let data = data else {
                
                print( "No data found" )
                return
                
            }
            
            if let astronomyRespose = self.astroparseJson( data: data ) {
                
                DispatchQueue.main.async {
                    
                    self.lblSunrise.text = "Sunrise | \( astronomyRespose.astronomy.astro.sunrise )"
                    self.lblSunset.text  = "\( astronomyRespose.astronomy.astro.sunset ) | Sunset"
                    
                }
            }
        }
        
        // DATATASK FOR THE CURRENT API
        let dataTask = session.dataTask( with: url ) { data, response, error in
            
            guard error == nil else {
                
                print( "Received error" )
                return
                
            }
            guard let data = data else {
                
                print( "No data found" )
                return
                
            }
            
            if let weatherResponse = self.parseJson( data: data ) {

                DispatchQueue.main.async {
                    
                    let temperature: Int
                    let tempC = weatherResponse.current.temp_c
                    let tempF = weatherResponse.current.temp_f

                    temperature = changeTemp ? Int( tempC ) : Int( tempF )

                    self.txtTempFC.text = "\( temperature )°"
                                        
                    self.txtLocation.text       = weatherResponse.location.name
                    self.txtRegionCountry.text  = "\( weatherResponse.location.region ) \( weatherResponse.location.country )"
                    self.txtAction.text         = "\( weatherResponse.current.condition.text )"
                                        
                    let iconCode = "\( weatherResponse.current.condition.icon )"

                    if iconCode.lowercased().contains( "night" ) {

                        if let codeStringValue = weatherResponse.current.condition.codeStringValueNight {

                            self.imgIconCondition.image = UIImage( systemName : codeStringValue )?.withRenderingMode(.alwaysOriginal)
                            

                        }
                        
                    } else if iconCode.lowercased().contains( "day" ) {
                        
                        if let codeStringValue = weatherResponse.current.condition.codeStringValueDay {

                            self.imgIconCondition.image = UIImage( systemName : codeStringValue )?.withRenderingMode(.alwaysOriginal)

                        }
                    }
                }
            }
        }
        
        dataTask.resume()
        astroTask.resume()
        forecastTask.resume()
        self.txtPlaceLocation.text = ""

    }
    
    private func apiURL( que : String ) -> URL? {
        
        let baseURL         = "https://api.weatherapi.com/v1/"
        let currentEndpoint = "current.json"
        let apikey          = "4ac348c97bf14a03b26230656231111"
        
        guard let url = "\( baseURL )\( currentEndpoint )?key=\( apikey )&q=\( que )".addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed ) else {
            
            return nil
            
        }
        
        return URL( string : url )

    }
    
    private func parseJson( data : Data ) -> WeatherResponse? {
        
        let decoder = JSONDecoder()
        var weather : WeatherResponse?
        
        do {
            
            weather = try decoder.decode( WeatherResponse.self, from : data )
            
        } catch {
            
            print( "Error decoding" )
            
        }
        
        return weather
        
    }
    
    // * * * * * * * * * * * * ASTRONOMY API * * * * * * * * * * * *
    private func astroURL( que : String ) -> URL? {
        
        let baseURL         = "https://api.weatherapi.com/v1/"
        let currentEndpoint = "astronomy.json"
        let apikey          = "4ac348c97bf14a03b26230656231111"
        
        
        guard let url = "\( baseURL )\( currentEndpoint )?key=\( apikey )&q=\( que )&dt=".addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed ) else {
            
            return nil
            
        }
        
        return URL( string : url )
        

    }

    private func astroparseJson( data : Data ) -> AstronomyResponse? {
        
        let decoder = JSONDecoder()
        var astronomy : AstronomyResponse?
        
        do {
            
            astronomy = try decoder.decode( AstronomyResponse.self, from : data )
            
        } catch {
            
            print( "Error decoding" )
            
        }
        
        return astronomy
        
    }
    
    // * * * * * * * * * * * * FORECAST API * * * * * * * * * * * *
    private func forecastURL( que : String ) -> URL? {
        
        let baseURL         = "https://api.weatherapi.com/v1/"
        let currentEndpoint = "forecast.json"
        let apikey          = "4ac348c97bf14a03b26230656231111"
        let daysCount       = 1
        
        guard let url = "\( baseURL )\( currentEndpoint )?key=\( apikey )&q=\( que )&days=\( daysCount )&aqi=no&alerts=no".addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed ) else {
            
            return nil
            
        }
        
        return URL( string : url )

    }

    private func forecastParseJson( data : Data ) -> Forecast? {
        
        let decoder = JSONDecoder()
        var forecast : Forecast?
        
        do {
            
            forecast = try decoder.decode( Forecast.self, from : data )
            
        } catch {
            
            print( "Error decoding for Forecast" )
            
        }
        
        return forecast
        
    }
    
    
} // * * * * E N D    P O I N T * * * * *


struct WeatherResponse : Decodable {
    
    let location    :   Locations
    var current     :   Current
    
}

struct Locations : Decodable {
    
    let name        :   String
    let region      :   String
    let country     :   String
    let localtime   :   String
    let lat         :   Float
    let lon         :   Float
    
}

struct Current : Decodable {
    
    let temp_c      :   Float
    let temp_f      :   Float
    var condition   :   Condition
    
}

struct Condition: Decodable {
    
    let text    :   String
    let icon    :   String
    var code    :   Int
    
    var codeStringValueNight : String? {
        
        return codeNightIcon[ code ]
    
    }
    
    var codeStringValueDay: String? {
        
        return codeDayIcon[ code ]
    
    }

}

// * * * * * * * * * * * * ASTRONOMY DECODABLE * * * * * * * * * * * *
struct AstronomyResponse : Decodable {
    
    let location    :   Locations
    let astronomy   :   Astronomy
    
}

struct Astronomy : Decodable {
    
    let astro : Astro
    
}

struct Astro : Decodable {
    
    let sunrise :   String
    let sunset  :   String
    
}

// * * * * * * * * * * * * FORECAST DECODABLE * * * * * * * * * * * *
struct Forecast : Decodable {
    
    let location    :   ForecastLocation
    let forecast    :   Forecasts
    
}

struct ForecastLocation : Decodable {
    
    let name    : String
    let region  : String
    let country : String
    
}

struct Forecasts : Decodable {
    
    let forecastday : [ Forecastday ]
    
}


struct Forecastday : Decodable {
    
    let date    :   String
    let day     :   Day
    let astro   :   Astronomies
    let hour    :   [ Hours ]
    
}

struct Day : Decodable {
    
    let avgtemp_c   : Float
    let avgtemp_f   : Float
    
}

struct Astronomies : Decodable {
    
    let sunrise : String
    let sunset  : String
    
}

struct Hours : Decodable {
    
    let time        :   String
    let temp_c      :   Float
    let temp_f      :   Float
    let condition   : Conditions
    
}

struct Conditions : Decodable {
    
    let text    :   String
    let icon    :   String  //"icon": "//cdn.weatherapi.com/weather/64x64/night/248.png",
    let code    :   Int
    
    var codeStringValueNight : String? {
        
        return codeNightIcon[ code ]
    
    }
    
    var codeStringValueDay: String? {
        
        return codeDayIcon[ code ]
    
    }
    
}

// * * * * * * * * * * * * ICON CODE * * * * * * * * * * * *
let codeNightIcon: [ Int : String ] = [

    1000 : "moon.fill"              , 1003 : "cloud.moon.fill"      , 1006 : "cloud.fill"           , 1009 : "cloud.fill"           , 1030 : "cloud.fog.fill",
    1063 : "cloud.moon.rain"        , 1066 : "moon.snow"            , 1069 : "cloud.sleet.fill"     , 1072 : "cloud.drizzle.fill"   , 1087 : "cloud.moon.bolt",
    1114 : "wind.snow"              , 1117 : "cloud.snow.fil"       , 1135 : "cloud.fog.fill"       , 1147 : "cloud.sleet.fill"     , 1150 : "cloud.drizzle.fill",
    1153 : "cloud.drizzle.fill"     , 1168 : "cloud.snow.fill"      , 1171 : "cloud.rain.fill"      , 1180 : "cloud.rain.fill"      , 1183 : "cloud.rain.fill",
    1186 : "cloud.moon.rain.fill"   , 1189 : "cloud.rain.fill"      , 1192 : "cloud.moon.rain.fill" , 1195 : "cloud.heavyrain.fill" , 1198 : "cloud.sleet.fill",
    1201 : "cloud.sleet.fill"       , 1204 : "cloud.snow.fill"      , 1207 : "cloud.sleet.fill"     , 1210 : "moon.dust.fill"       , 1213 : "cloud.snow.fill",
    1216 : "moon.dust.fill"         , 1219 : "cloud.snow.fill"      , 1222 : "cloud.snow.fill"      , 1225 : "cloud.snow"           , 1237 : "cloud.sleet.fill",
    1240 : "cloud.drizzle.fill"     , 1243 : "cloud.heavyrain.fill" , 1246 : "cloud.rain.fill"      , 1249 : "cloud.drizzle.fill"   , 1252 : "cloud.heavyrain.fill",
    1255 : "cloud.snow.fill"        , 1258 : "cloud.snow.fill"      , 1261 : "cloud.sleet.fill"     , 1264 : "cloud.sleet.fill"     , 1273 : "cloud.hail.fill",
    1276 : "cloud.bolt.rain.fill"   , 1279 : "cloud.sleet.fill"     , 1282 : "cloud.snow.fill"
    
]

let codeDayIcon: [ Int : String ] = [

    1000 : "sun.max"            , 1003 : "cloud.sun.fill"   , 1006 : "cloud.fill"       , 1009 : "cloud.fill"       , 1030 : "cloud.fog",
    1063 : "cloud.sun.rain"     , 1066 : "sun.snow"         , 1069 : "cloud.sleet"      , 1072 : "cloud.drizzle"    , 1087 : "cloud.sun.bolt",
    1114 : "wind.snow"          , 1117 : "cloud.snow"       , 1135 : "cloud.fog"        , 1147 : "cloud.sleet"      , 1150 : "cloud.drizzle",
    1153 : "cloud.drizzle"      , 1168 : "cloud.snow"       , 1171 : "cloud.rain"       , 1180 : "cloud.rain.fill"  , 1183 : "cloud.rain.fill",
    1186 : "cloud.sun.rain"     , 1189 : "cloud.rain"       , 1192 : "cloud.sun.rain"   , 1195 : "cloud.heavyrain"  , 1198 : "cloud.sleet",
    1201 : "cloud.sleet"        , 1204 : "cloud.snow"       , 1207 : "cloud.sleet"      , 1210 : "sun.snow"         , 1213 : "cloud.snow",
    1216 : "sun.snow"           , 1219 : "cloud.snow"       , 1222 : "cloud.snow"       , 1225 : "cloud.snow"       , 1237 : "cloud.sleet",
    1240 : "cloud.drizzle"      , 1243 : "cloud.heavyrain"  , 1246 : "cloud.rain"       , 1249 : "cloud.drizzle"    , 1252 : "cloud.heavyrain",
    1255 : "cloud.snow"         , 1258 : "cloud.snow"       , 1261 : "cloud.sleet"      , 1264 : "cloud.sleet"      , 1273 : "cloud.hail",
    1276 : "cloud.bolt.rain"    , 1279 : "cloud.sleet"      , 1282 : "cloud.snow"
    
]
