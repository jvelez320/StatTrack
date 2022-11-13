//
//  GameSetupVC.swift
//  StatTrack
//
//  Created by Ryan Hamby on 11/3/22.
//

import UIKit

final class GameSetupVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var gameSetupTitle: UILabel!
    @IBOutlet weak var homeTeamName: UITextField!
    @IBOutlet weak var awayTeamName: UITextField!
    @IBOutlet weak var Start: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        overrideUserInterfaceStyle = .light
        gameSetup()
    }
    
    private func gameSetup() {
        homeTeamName.text = ""
        homeTeamName.placeholder = "Home Team Name"
        awayTeamName.text = ""
        awayTeamName.placeholder = "Away Team Name"
        
        homeTeamName.delegate = self
        awayTeamName.delegate = self
        
        homeTeamName.clearButtonMode = .always
        awayTeamName.clearButtonMode = .always
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func verifyStart(_ sender: Any) {
        print("I am clicked!")
        if (homeTeamName.text != "" && awayTeamName.text != "") {
            print("Yuh")
            performSegue(withIdentifier: "CameraSetup", sender: nil)
        } else {
            print("No can do")
        }
    }
}
