//
//  FinalStatsVC.swift
//  StatTrack
//
//  Created by Ryan Hamby on 11/3/22.
//

import UIKit

final class FinalStatsVC: UIViewController {

    @IBOutlet weak var homeNameLabel: UILabel!
    @IBOutlet weak var awayNameLabel: UILabel!
    @IBOutlet weak var homeScoreLabel: UILabel!
    @IBOutlet weak var awayScoreLabel: UILabel!
    @IBOutlet weak var rematchButton: UIButton!
    
    var homeColor: UIColor!
    var awayColor: UIColor!
    var homeName: String = ""
    var awayName: String = ""
    var homeScore: String = ""
    var awayScore: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        // Do any additional setup after loading the view.
        self.homeNameLabel.text = homeName
        self.homeNameLabel.textColor = .black
        self.awayNameLabel.text = awayName
        self.awayNameLabel.textColor = .black
        self.awayScoreLabel.text = awayScore
        self.awayScoreLabel.textColor = .black
        self.homeScoreLabel.text = homeScore
        self.homeScoreLabel.textColor = .black
        self.homeNameLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 30.0)
        self.awayNameLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 30.0)
        self.homeScoreLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 20.0)
        self.awayScoreLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 20.0)
    }
    
    // This function is called before the segue
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

       if segue.identifier == "rematchButton" {
           // Get a reference to the second view controller
           let cameraSetupViewController = segue.destination as! CameraSetupVC

           // Set a variable in the second view controller with the String to pass
           cameraSetupViewController.homeColor = homeColor
           cameraSetupViewController.awayColor = awayColor
           cameraSetupViewController.homeName = homeName
           cameraSetupViewController.awayName = awayName
       }
       
   }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

}
