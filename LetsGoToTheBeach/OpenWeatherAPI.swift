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
    
//    let openWeatherParser = OpenWeatherParser()
    let openWeatherAPI = OpenWeatherAPI()
    
    func getWeatherFromCity(cityName: String, completionHandler: @escaping (City) -> Void) {
        var city: City = City(id: 0, title: "", temperature: 0.0, main: "", description: "")

        openWeatherAPI.requestWeatherData(city: cityName) { (weatherData) in
            city.temperature = weatherData["temp"] as? Double ?? 0.0
        }
        
        openWeatherAPI.requestWeatherDescription(city: cityName) { (weatherDescription) in
            city.id = weatherDescription.first?["id"] as? Int ?? 0
            city.description = weatherDescription.first?["description"] as? String ?? ""
            city.main = weatherDescription.first?["main"] as? String ?? ""
            completionHandler(city)
        }
    }
}

// MARK: MovieDB Parser
//struct OpenWeatherParser {
//
//    func parseCityDictionary(dictionary: [String: Any]) -> City? {
//        guard let id = dictionary["id"] as? Int,
//              let title = dictionary["main"] as? String,
//              let description = dictionary["description"] as? String
//        else { return nil }
//
//        return City(id: id, title: title, temperature: temperature, main: main, description: description)
//    }
//
//}

// MARK: MovieDB API
struct OpenWeatherAPI {
    
//    func requestCity(city: String, completionHandler: @escaping ((String) -> Void)) {
//        let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=1d9576992b3fe043d3b5ada5c464f223")!
//
//        URLSession.shared.dataTask(with: url) { (data, response, error) in
//            guard let data = data,
//                  let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any],
//                  let name = json["name"] as? String
//            else {
//                completionHandler("")
//                return
//            }
//            completionHandler(name)
//        }
//        .resume()
//    }
//
    func requestWeatherDescription(city: String, completionHandler: @escaping ([[String: Any]]) -> Void) {
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=1d9576992b3fe043d3b5ada5c464f223&units=metric")!
        
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
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=1d9576992b3fe043d3b5ada5c464f223&units=metric")!
        
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
    
    
    //    func requestCharacters(completionHandler: @escaping ([[String: Any]]) -> Void) {
    //        let url = URL(string: "https://rickandmortyapi.com/api/character")!
    //
    //        typealias WebCharacter = [String: Any]
    //
    //        URLSession.shared.dataTask(with: url) { (data, response, error) in
    //            guard let data = data,
    //                  let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any],
    //                  let charactersDictionary = json["results"] as? [WebCharacter]
    //            else {
    //                completionHandler([])
    //                return
    //            }
    //            completionHandler(charactersDictionary)
    //        }
    //        .resume()
    //    }
    
    //    func requestCharactersResult(completionHandler: @escaping (Result<[[String: Any]], Error>) -> Void) {
    //        let url = URL(string: "https://rickandmortyapi.com/api/character")!
    //
    //        URLSession.shared.dataTask(with: url) { (data, response, error) in
    //            guard let data = data,
    //                  let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any],
    //                  let charactersDictionary = json["results"] as? [[String: Any]]
    //            else {
    //                completionHandler(Result.failure(error!))
    //                return
    //            }
    //            completionHandler(Result.success(charactersDictionary))
    //        }
    //        .resume()
    //    }
    //
}
