//
//  WeatherManager.swift
//  Clima
//
//  Created by Alline de Lara on 08.01.25.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation


protocol WeatherManagerDelegate{
    func didUpdateWeather(_ weatherManager: WeatherManager,weatherModel: WeatherModel)
    func didFailWithError( error: Error)
}

struct WeatherManager {
     let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=76d8f562fb4e9590785fd8dc77fc1c98&units=metric"
    
    func fetchWeather ( cityName: String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        performeRequest(with: urlString)
    }
    
    var delegate : WeatherManagerDelegate?
    
    func fetchWeather( lat: CLLocationDegrees, lon: CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(lat)&lon\(lon)"
        performeRequest(with: urlString)
    }
        
    
    func performeRequest( with urlString: String){
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task =  session.dataTask(with: url) { (data, response, error) in
                
                if error != nil{
                    delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = parseJSON(weather: safeData){
                        let weatherVC = WeatherViewController()
                        self.delegate?.didUpdateWeather(self, weatherModel: weather)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    func parseJSON ( weather : Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do {
            let decodeData = try decoder.decode(WeatherData.self, from: weather)
            let id = decodeData.weather[0].id
            let temp = decodeData.main.temp
            let name = decodeData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temp: temp)
            
            return weather
            
            
        }catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
