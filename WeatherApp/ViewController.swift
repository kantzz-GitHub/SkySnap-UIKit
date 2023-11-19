//
//  ViewController.swift
//  WeatherApp
//
//  Created by Shermukhammad Usmonov on 2023-11-17.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var imageMain: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var tempSelected: UISegmentedControl!
    @IBOutlet weak var weatherCondition: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    
    
    
    private let locationManager = CLLocationManager()
    private var cityGlobal: String?
    
    let configOne = UIImage.SymbolConfiguration(paletteColors: [.systemGray, .systemYellow])
    let configTwo = UIImage.SymbolConfiguration(paletteColors: [.systemYellow])
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        imageMain.image = UIImage(systemName: "sun.max")
        imageMain.tintColor = .systemYellow
        
//        let imageView = UIImageView(image: UIImage(named: "daylight_background"))
//        imageView.frame = view.bounds
//        imageView.contentMode = .scaleAspectFit
//        view.addSubview(imageView)
    }
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        if searchBar.hasText{
            updateWeather(for: searchBar.text!)
            cityGlobal = searchBar.text!
            searchBar.text = ""
        } else {
            print("Search bar is empty")
            searchBar.placeholder = "Please type city name"
        }
    }
    
    @IBAction func locationButtonTapped(_ sender: UIButton) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    @IBAction func temperatureSelected(_ sender: UISegmentedControl) {
        if let locationCity = cityGlobal{
            updateWeather(for: locationCity)
        } else {
            print("Search bar is empty")
            searchBar.placeholder = "Please type city name"
        }
    }
    
    
    private func updateWeather(for cityName: String){
        
        if let urlString = createURL(for: cityName){
            getWeatherData(for: urlString)
        } else {
            print("Could not form a urlString")
        }
    }
    
    
    private func getWeatherData(for urlString: String){
        guard let url = URL(string: urlString) else {
            print("Error getting a url")
            return
        }
        
        let urlSession = URLSession(configuration: .default)
        
        let dataTask = urlSession.dataTask(with: url) { data, urlResponse, error in
            guard error == nil else {
                print(error!)
                return
            }
            
            guard data != nil else {
                print("Cannot retrieve data...")
                return
            }
            
            print("Getting some data... xD")
            
            let result = self.parseJSON(for: data!)
            
            guard result != nil else {
                print("ParseJSON did not return data")
                return
            }
            
            self.cityGlobal = result!.location.name
            self.updateUI(with: result!)
            
        }
        
        dataTask.resume()
    }
    
    private func updateUI(with result: WeatherData){
        DispatchQueue.main.async {
            if result.current.is_day == 0 {
                self.backgroundImage.image = UIImage(named: "night_background")
                self.cityLabel.textColor = .white
                self.temperatureLabel.textColor = .white
                self.weatherCondition.textColor = .white
                self.tempSelected.backgroundColor = .white
                self.searchButton.backgroundColor = .white
                self.locationButton.backgroundColor = .white
            } else {
                self.cityLabel.textColor = .black
                self.temperatureLabel.textColor = .black
                self.weatherCondition.textColor = .black
                self.tempSelected.backgroundColor = .gray
                self.searchButton.backgroundColor = .none
                self.locationButton.backgroundColor = .none
                self.backgroundImage.image = UIImage(named: "daylight_background")
            }
            let image = self.updateImageMain(code: result.current.condition.code, isDay: result.current.is_day)
            self.imageMain.image = UIImage(systemName: image)
            if(image == "sun.max"){
                self.imageMain.preferredSymbolConfiguration = self.configTwo
            } else {
                self.imageMain.preferredSymbolConfiguration = self.configOne
            }
            self.cityLabel.text = result.location.name
            self.weatherCondition.text = result.current.condition.text
            if self.tempSelected.selectedSegmentIndex == 0{
                self.temperatureLabel.text = String(result.current.temp_c)
            } else {
                self.temperatureLabel.text = String(result.current.temp_f)
            }
        }
    }
    
    private func updateImageMain(code: Int, isDay: Int) -> String{
        switch code {
        case 1000:
            if isDay == 1{return "sun.max"}
            return "moon.stars.fill"
        case 1003...1009:
            if isDay == 1{return "cloud.sun"}
            return "cloud.moon.fill"
        case 1030:
            return "cloud.fog"
        case 1063:
            if isDay == 1{return "cloud.sun.rain"}
            return "cloud.moon.rain.fill"
        case 1066:
            return "cloud.snow"
        case 1069:
            return "cloud.sleet"
        case 1072:
            return "cloud.drizzle"
        case 1087:
            return "cloud.bolt.fill"
        case 1114...1117:
            return "wind.snow"
        case 1135...1147:
            return "cloud.fog"
        case 1150...1201:
            return "cloud.drizzle"
        case 1204...1207:
            return "cloud.sleet"
        case 1210...1237:
            return "snowflake"
        case 1240...1246:
            return "cloud.rain"
        case 1249...1264:
            return "cloud.sleet"
        case 1273...1276:
            return "cloud.bolt.rain.fill"
        default:
            return "snowflake"
        }
    }
    
    private func createURL(for cityName: String) -> String?{
        let baseURL = "https://api.weatherapi.com/"
        let endPoint = "v1/current.json"
        let apiKey = "e007a7943c4e48cf9a2195955231711"
        let query = "q=\(cityName)"
        
        guard let urlString = "\(baseURL)\(endPoint)?key=\(apiKey)&\(query)&aqi=no".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        return urlString
    }
    
    private func parseJSON(for data: Data) -> WeatherData?{
        let decoder = JSONDecoder()
        
        var wrapper: WeatherData?
        
        do{
            wrapper = try decoder.decode(WeatherData.self, from: data)
        } catch{
            print(error)
        }
        
        return wrapper
        
    }
}

struct WeatherData: Decodable{
    let location: Location
    let current: CurrentWeather
}

struct Location: Decodable{
    let name: String
    let country: String
    let localtime: String
}

struct CurrentWeather: Decodable{
    let temp_c: Float
    let temp_f: Float
    let condition: Condition
    let is_day: Int
}
struct Condition: Decodable{
    let code: Int
    let text: String
}

extension ViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Got location")
        
        guard let location = locations.last else { return }
        
        print(location.coordinate.latitude)
        print(location.coordinate.longitude)
        
        fetchCityAndCountry(from: location) { city, country, error in
            guard let city = city, let country = country, error == nil else { return }
            print(city + ", " + country)
            self.cityGlobal = city
            self.updateWeather(for: city)
            
        }
    }
    func fetchCityAndCountry(from location: CLLocation, completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            completion(placemarks?.first?.locality,
                       placemarks?.first?.country,
                       error)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
