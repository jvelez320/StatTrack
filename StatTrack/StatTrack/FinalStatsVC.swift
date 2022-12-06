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
    @IBOutlet weak var homeFGLabel: UILabel!
    @IBOutlet weak var awayFGLabel: UILabel!
    @IBOutlet weak var homeFGPLabel: UILabel!
    @IBOutlet weak var awayFGPLabel: UILabel!
    @IBOutlet weak var homeToPLabel: UILabel!
    @IBOutlet weak var awayToPLabel: UILabel!
    
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
        self.homeNameLabel.textColor = homeColor
        self.awayNameLabel.text = awayName
        self.awayNameLabel.textColor = awayColor
        self.awayScoreLabel.text = awayScore
        self.awayScoreLabel.textColor = awayColor
        self.homeScoreLabel.text = homeScore
        self.homeScoreLabel.textColor = homeColor
        self.homeFGLabel.text = "0"
        self.homeFGLabel.textColor = homeColor
        self.homeFGPLabel.text = "0"
        self.homeFGPLabel.textColor = homeColor
        self.homeToPLabel.text = "0"
        self.homeToPLabel.textColor = homeColor
        self.awayFGLabel.text = "0"
        self.awayFGLabel.textColor = awayColor
        self.awayFGPLabel.text = "0"
        self.awayFGPLabel.textColor = awayColor
        self.awayToPLabel.text = "0"
        self.awayToPLabel.textColor = awayColor
        self.homeNameLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 20.0)
        self.awayNameLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 20.0)
        self.homeScoreLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 20.0)
        self.awayScoreLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 20.0)
        self.homeFGLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 20.0)
        self.awayFGLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 20.0)
        self.homeFGPLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 20.0)
        self.awayFGPLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 20.0)
        self.homeToPLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 20.0)
        self.awayToPLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 20.0)
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
