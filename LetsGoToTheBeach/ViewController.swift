//
//  ViewController.swift
//  LetsGoToTheBeach
//
//  Created by Julia Alberti Maia on 30/11/21.
//

import UIKit
import Lottie

class ViewController: UIViewController {
    
    var city: City?
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var findOutButton: UIButton!
    @IBOutlet weak var reloadButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animationView!.animationSpeed = 0.8
        
        // MARK: Buttons visuals
        temperatureLabel.alpha = 0
        findOutButton.layer.cornerRadius = 20
        findOutButton.backgroundColor = UIColor(named: "Purple")
        findOutButton.tintColor = .black
        findOutButton.setTitle("Descubra", for: .normal)
        defaultState()
    }
    
    private func defaultState() {
        animationView?.play(fromFrame: 0, toFrame: 0, loopMode: .none)
    }
    
    private func showBeach() {
        animationView?.play(fromFrame: 17, toFrame: 45, loopMode: .autoReverse)
    }
    
    private func showSnow() {
        animationView?.play(fromFrame: 51, toFrame: 75, loopMode: .autoReverse)
    }
    
    @IBAction func findOutButton(_ sender: Any) {
        performSegue(withIdentifier: "searchBarScreen", sender: nil)
    }
    
    @IBAction func reloadButton(_ sender: Any) {
        findOutButton.backgroundColor = UIColor(named: "Purple")
        findOutButton.tintColor = .black
        findOutButton.setTitle("Descubra", for: .normal)
        temperatureLabel.alpha = 0
        defaultState()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let viewController = segue.destination as? CitiesViewController else {
            return
        }
        viewController.selectedCityDelegate = self
    }
}

extension ViewController: SelectedCityDelegate {
    func didTapSelectedCity(city: City) {
        self.city = city
        DispatchQueue.main.async {
            self.temperatureLabel.text = String(Int(city.temperature)) + "º"
            self.temperatureLabel.alpha = 1
            self.findOutButton.tintColor = .black
            if ((city.description == "clear sky" || city.description == "few clouds" || city.description == "scattered clouds") && (city.main == "Clouds" || city.main == "Clear") && (city.temperature > 24)) {
                self.findOutButton.setTitle("Sim", for: .normal)
                self.findOutButton.backgroundColor = UIColor(named: "SunnyYellow")
                self.navigationController?.navigationBar.topItem?.title = " "
                self.showBeach()
            } else {
                self.findOutButton.setTitle("Não", for: .normal)
                self.findOutButton.backgroundColor = UIColor(named: "SeaGreen")
                self.navigationController?.navigationBar.topItem?.title = " "
                self.showSnow()
            }
        }
    }
}
