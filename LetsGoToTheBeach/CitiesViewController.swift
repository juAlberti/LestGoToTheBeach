//
//  CitiesViewController.swift
//  LetsGoToTheBeach
//
//  Created by Diego Henrique on 02/12/21.
//

import MapKit
import UIKit

class CitiesViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    let openWeatherService = OpenWeatherService()
    var searchCompleter: MKLocalSearchCompleter = MKLocalSearchCompleter()
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var citiesPage: Int = 1
    var citiesTotalPages: Int = 0
    
    var filteredCities: [City] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.isHidden = self.cities.isEmpty
                self.activityIndicator.isHidden = !self.cities.isEmpty
            }
        }
    }
    
    var cities: [City] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        
        searchCompleter = MKLocalSearchCompleter()
        searchCompleter.delegate = self
        searchCompleter.region = MKCoordinateRegion(.world)
        searchCompleter.resultTypes = MKLocalSearchCompleter.ResultType([.address])
        
        openWeatherService.getWeatherFromCity(cityName: "Porto+Alegre") { (city) in
            print(city.temperature)
        }
        activityIndicator.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    func getCityList(results: [MKLocalSearchCompletion]) -> [(city: String, country: String)]{
        
        var searchResults: [(city: String, country: String)] = []
        
        for result in results {
            
            let titleComponents = result.title.components(separatedBy: ", ")
            let subtitleComponents = result.subtitle.components(separatedBy: ", ")
            
            buildCityTypeA(titleComponents, subtitleComponents){place in
                
                if place.city != "" && place.country != ""{
                    
                    searchResults.append(place)
                }
            }
            
            buildCityTypeB(titleComponents, subtitleComponents){place in
                
                if place.city != "" && place.country != ""{
                    
                    searchResults.append(place)
                }
            }
        }
        
        return searchResults
    }
    
    func buildCityTypeA(_ title: [String],_ subtitle: [String], _ completion: @escaping ((city: String, country: String)) -> Void){
        
        var city: String = ""
        var country: String = ""
        
        if title.count > 1 && subtitle.count >= 1 {
            
            city = title.first!
            country = subtitle.count == 1 && subtitle[0] != "" ? subtitle.first! : title.last!
        }
        
        completion((city, country))
    }
    
    func buildCityTypeB(_ title: [String],_ subtitle: [String], _ completion: @escaping ((city: String, country: String)) -> Void){
        
        var city: String = ""
        var country: String = ""
        
        if title.count >= 1 && subtitle.count == 1 {
            
            city = title.first!
            country = subtitle.last!
        }
        
        completion((city, country))
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func updateData() {
        DispatchQueue.main.async {
            let searchText = self.navigationItem.searchController?.searchBar.text ?? ""
            self.updateData(searchText: searchText)
            self.tableView.reloadData()
        }
    }
    
    func updateData(searchText: String) {
        if searchText.isEmpty {
            filteredCities = cities
        }
        
        else {
            filteredCities = []
            for city in cities {
                if city.title.lowercased().contains(searchText.lowercased()) {
                    if cities.contains(city) && !filteredCities.contains(city) {
                        filteredCities.append(city)
                    }
                }
            }
        }
    }
}

extension CitiesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath) as! CityTableViewCell
        
        cell.name.text = filteredCities[indexPath.row].title
        return cell
    }
    
   
}

extension CitiesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // call delegate
        //   let movie = filteredCities[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Lembrem-se de colocar um booleano pra controlar as requisições
        // E lembrem-se de controlarem em que página estamos para pedirmos apenas a próxima
        //            if (indexPath.row == filteredCities.count - 1 && citiesPage <= citiesTotalPages) {
        //                movieDBService.getcities(page: citiesPage) { movies in
        //                    self.cities = self.cities + movies
        //                    for index in 0...self.cities.count-1 {
        //                        self.movieDBService.getMoviePoster(url: self.cities[index].posterURL) { poster in
        //                            self.cities[index].poster = poster
        //                            self.updateData()
        //                        }
        //                        self.movieDBService.getGenres(genreIDs: self.cities[index].genreIDs) { genres in
        //                            self.cities[index].genres = genres
        //                            self.updateData()
        //
        //                        }
        //                    }
        //                    self.citiesPage+=1
        //                }
        //            }
    }
}

extension CitiesViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        
        let searchResults = self.getCityList(results: completer.results)
        
        print(searchResults)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        
        print(error.localizedDescription)
    }
}

extension CitiesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchText
        let localSearch = MKLocalSearch(request: searchRequest)
        localSearch.start { (searchResponse, _) in
            guard (searchResponse?.mapItems) != nil else {
                return
            }
            print(searchResponse)
        }
        //        let searchText = searchController.searchBar.text ?? ""
        //        self.updateData(searchText: searchText)
        //        self.tableView.reloadData()
    }
}
