//
//  CitiesViewController.swift
//  LetsGoToTheBeach
//
//  Created by Diego Henrique on 02/12/21.
//

import MapKit
import UIKit

struct CityItem: Equatable {
    var name: String
    var country: String
}

protocol SelectedCityDelegate: AnyObject {
    func didTapSelectedCity(city: City)
}

class CitiesViewController: UIViewController {
    
    weak var selectedCityDelegate: SelectedCityDelegate?
    @IBOutlet weak var tableView: UITableView!
    let openWeatherService = OpenWeatherService()
    var citiesPage: Int = 1
    var citiesTotalPages: Int = 0
    
    var filteredCities: [CityItem] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.isHidden = self.filteredCities.isEmpty
            }
        }
    }
    
    lazy var searchCompleter: MKLocalSearchCompleter = {
         let sC = MKLocalSearchCompleter()
         sC.delegate = self
         sC.region = MKCoordinateRegion(.world)
         sC.resultTypes = MKLocalSearchCompleter.ResultType([.address])
         return sC
     }()
    
    var cities: [CityItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Digite uma cidade..."
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false
        self.navigationController?.navigationBar.topItem?.title = "Voltar"
        // Do any additional setup after loading the view.
    }
    
    func getCityList(results: [MKLocalSearchCompletion]) -> [(city: String, country: String)]{
        
        var searchResults: [(city: String, country: String)] = []
        filteredCities = []
        for result in results {
            
            let titleComponents = result.title.components(separatedBy: ", ")
            let subtitleComponents = result.subtitle.components(separatedBy: ", ")
            
            buildCityTypeA(titleComponents, subtitleComponents){ place in
                
                if place.city != "" && place.country != ""{
                    let cityItem: CityItem = CityItem(name: place.city, country: place.country)
                    self.filteredCities.append(cityItem)
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
            for cityItem in cities {
                if cityItem.name.lowercased().contains(searchText.lowercased()) {
                    if cities.contains(cityItem) && !filteredCities.contains(cityItem) {
                        filteredCities.append(cityItem)
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
        
        cell.title.text = filteredCities[indexPath.row].name
        cell.detail.text = filteredCities[indexPath.row].country
        return cell
    }
    
   
}

extension CitiesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var cityName = filteredCities[indexPath.row].name
        cityName = cityName.components(separatedBy: " - ")[0].trimmingCharacters(in: .whitespaces)
        
        openWeatherService.getWeatherFromCity(cityName: cityName) { (city) in
            DispatchQueue.main.async {
                if city.temperature == -1000.0 {
                    let alert = UIAlertController(title: NSLocalizedString("Não encontrado", comment: ""),
                                                  message: NSLocalizedString("A temperatura atual não foi encontrada para a cidade \(cityName). Tente novamente.", comment: ""),
                                                  preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: { _ in
                    }))
                    self.present(alert, animated: true)
                } else {
                    self.selectedCityDelegate?.didTapSelectedCity(city: city)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
}

extension CitiesViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        _ = self.getCityList(results: completer.results)
        tableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        
        print(error.localizedDescription)
    }
}

extension CitiesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        let searchText = searchController.searchBar.text
        if searchText != nil {
            searchCompleter.queryFragment = searchText!
        } else {
            filteredCities = []
        }
                
    }
}
