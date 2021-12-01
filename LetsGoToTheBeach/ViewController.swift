//
//  ViewController.swift
//  LetsGoToTheBeach
//
//  Created by Julia Alberti Maia on 30/11/21.
//

import UIKit
import Lottie

class ViewController: UIViewController {

    
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var findOutButton: UIButton!
    @IBOutlet weak var reloadButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        animationView!.animationSpeed = 0.8
        
    }

    private func showBeach() {
        animationView?.play(fromFrame: 17, toFrame: 45, loopMode: .none)
    }
    
    private func showSnow() {
        animationView?.play(fromFrame: 51, toFrame: 75, loopMode: .none)
    }

    @IBAction func findOutButton(_ sender: Any) {
        performSegue(withIdentifier: "searchBarScreen", sender: nil)
    }
    
    @IBAction func reloadButton(_ sender: Any) {
    }
}

