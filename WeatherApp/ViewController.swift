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
    
    
    
    private let locationManager = CLLocationManager()
    private var cityGlobal: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        imageMain.image = UIImage(systemName: "sun.max.fill")
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
//        if sender.selectedSegmentIndex == 0{
//            
//        } else {
//            
//        }
//        if searchBar.hasText{
//            updateWeather(for: searchBar.text!)
//        } else 
        
        if let locationCity = cityGlobal{
            updateWeather(for: locationCity)
        } else {
            print("Search bar is empty")
            searchBar.placeholder = "TYPE CITY NAME!"
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
            self.cityLabel.text = result.location.name
            self.weatherCondition.text = result.current.condition.text
            if self.tempSelected.selectedSegmentIndex == 0{
                self.temperatureLabel.text = String(result.current.temp_c)
            } else {
                self.temperatureLabel.text = String(result.current.temp_f)
            }
            
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


