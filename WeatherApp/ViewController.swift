//
//  ViewController.swift
//  WeatherApp
//
//  Created by Shermukhammad Usmonov on 2023-11-17.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var imageMain: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var searchBar: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageMain.image = UIImage(systemName: "sun.max.fill")
    }
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        guard searchBar.text != nil else {
            print("Search bar is empty")
            searchBar.placeholder = "TYPE CITY NAME!"
            return
        }
        updateWeather(for: searchBar.text!)
    }
    
    @IBAction func locationButtonTapped(_ sender: UIButton) {
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
            
            self.updateUI(with: result!)
            
        }
        
        dataTask.resume()
    }
    
    private func updateUI(with result: WeatherData){
        DispatchQueue.main.async {
            self.cityLabel.text = result.location.name
            self.temperatureLabel.text = String(result.current.temp_c)
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
}


