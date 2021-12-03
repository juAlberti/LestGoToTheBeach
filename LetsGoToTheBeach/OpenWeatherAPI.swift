//
//  OpenWeatherAPI.swift
//  LetsGoToTheBeach
//
//  Created by Diego Henrique on 02/12/21.
//

import Foundation

// MARK: Movie Struct
struct City: CustomStringConvertible, Equatable {
    var id: Int
    var title: String
    var temperature: Double
    var main: String
    var description: String
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title && lhs.description == rhs.description
    }
}
// MARK: MovieDB Service
struct OpenWeatherService {
    
    let openWeatherAPI = OpenWeatherAPI()
    
    func getWeatherFromCity(cityName: String, completionHandler: @escaping (City) -> Void) {
        
        var city: City = City(id: 0, title: cityName, temperature: 0.0, main: "", description: "")

        openWeatherAPI.requestWeatherData(city: cityName) { (weatherData) in
            city.temperature = weatherData["temp"] as? Double ?? -1000.0
        }
        
        openWeatherAPI.requestWeatherDescription(city: cityName) { (weatherDescription) in
            city.id = weatherDescription.first?["id"] as? Int ?? 0
            city.description = weatherDescription.first?["description"] as? String ?? ""
            city.main = weatherDescription.first?["main"] as? String ?? ""
            completionHandler(city)
        }
    }
}

// MARK: MovieDB API
struct OpenWeatherAPI {
    
    func requestWeatherDescription(city: String, completionHandler: @escaping ([[String: Any]]) -> Void) {
        var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather?appid=1d9576992b3fe043d3b5ada5c464f223&units=metric")
        components?.queryItems?.append(URLQueryItem(name: "q", value: city))
        let url = components!.url!

        typealias WebCityDescription = [String: Any]
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any],
                  let weatherData = json["weather"] as? [WebCityDescription]
            else {
                completionHandler([])
                return
            }
            completionHandler(weatherData)
        }
        .resume()
    }
    
    func requestWeatherData(city: String, completionHandler: @escaping ([String: Any]) -> Void) {
        var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather?appid=1d9576992b3fe043d3b5ada5c464f223&units=metric")
        components?.queryItems?.append(URLQueryItem(name: "q", value: city))
        let url = components!.url!
        
        typealias WebCityData = [String: Any]
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any],
                  let weatherData = json["main"] as? WebCityData
            else {
                completionHandler([:])
                return
            }
            completionHandler(weatherData)
        }
        .resume()
    }

}
