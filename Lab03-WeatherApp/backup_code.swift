//
//import UIKit
//
//class ViewController: UIViewController {
//    
//    @IBOutlet weak var txtPlaceLocation: UITextField!
//    @IBOutlet weak var txtTempFC: UILabel!
//    @IBOutlet weak var txtLocation: UILabel!
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//    }
//    
//    
//    
//    @IBAction func btnSearch(_ sender: UIButton ) {
//        
//        loadWeather( search : txtPlaceLocation.text )
//        
//    }
//    
//    private func loadWeather( search : String? ) {
//        
//        guard let search = search else {
//            
//            return
//            
//        }
//        
//        guard let url = apiURL( que : search ) else {
//            
//            return
//            
//        }
//        
//        let sesssion = URLSession.shared
//        
//        let dataTask = sesssion.dataTask( with: url ) {
//            
//            data, response, error in
//            
//            guard error == nil else {
//                
//                print( "Received error" )
//                return
//                
//            }
//            
//            guard let data = data else {
//                
//                print( "No data found" )
//                return
//                
//            }
//            
//            if let weatherResponse = self.parseJson(data: data ) {
//                
//                print( weatherResponse.location.name )
//                print( weatherResponse.current.temp_c )
//                
//                DispatchQueue.main.async {
//                
//                    self.txtLocation.text = weatherResponse.location.name
//                    self.txtTempFC.text = "\(weatherResponse.current.temp_c)°"
//                    
//                }
//            }
//        }
//        
//        dataTask.resume()
//        
//        self.txtPlaceLocation.text = ""
//    }
//    
//    private func apiURL( que : String ) -> URL? {
//        
////    https://api.weatherapi.com/v1/current.json?key=4ac348c97bf14a03b26230656231111&q=Dubai&aqi=no
//        
//        let baseURL         = "https://api.weatherapi.com/v1/"
//        let currentEndpoint = "current.json"
//        let apikey          = "4ac348c97bf14a03b26230656231111"
//
//        guard let url       = "\( baseURL )\( currentEndpoint )?key=\( apikey )&q=\( que )".addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed ) else {
//            
//            return nil
//            
//        }
//        
//        return URL( string: url )
//
//    }
//    
//    private func parseJson( data : Data ) -> WeatherResponse? {
//        
//        let decoder = JSONDecoder()
//        var weather : WeatherResponse?
//        
//        do {
//            
//            weather = try decoder.decode( WeatherResponse.self, from: data )
//            
//        } catch {
//            
//            print( "Error decoding" )
//            
//        }
//        
//        return weather
//        
//    }
//    
//} // * * * * E N D    P O I N T * * * * *
//
//
//struct WeatherResponse : Decodable {
//    
//    let location    :   Locations
//    let current     :   Current
//    
//}
//
//struct Locations : Decodable {
//    
//    let name    :   String
//    
//}
//
//struct Current : Decodable {
//    
//    let temp_c  : Float
////    let temp_f  : Float
//    
//}
