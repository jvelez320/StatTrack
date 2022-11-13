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
    @IBOutlet weak var textHelp: UILabel!
    @IBOutlet weak var homeTeamColor: UIColorWell!
    @IBOutlet weak var awayTeamColor: UIColorWell!
    
    var textFilled: Bool!
    var colorFilled: Bool!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        overrideUserInterfaceStyle = .light
        Start.isHidden = true
        textHelp.isHidden = false
        textFilled = false
        colorFilled = false
        gameSetup()
        setupAddTargetIsNotEmpty()
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
    
    func setupAddTargetIsNotEmpty() {
        Start.isHidden = true
        textHelp.isHidden = false
        homeTeamName.addTarget(self, action: #selector(textFieldsNotEmpty), for: .editingChanged)
        awayTeamName.addTarget(self, action: #selector(textFieldsNotEmpty), for: .editingChanged)
        homeTeamColor.addTarget(self, action: #selector(colorFieldsNotEmpty), for: .valueChanged)
        awayTeamColor.addTarget(self, action: #selector(colorFieldsNotEmpty), for: .valueChanged)
    }
    
    @objc func textFieldsNotEmpty(sender: UITextField) {
        sender.text = sender.text?.trimmingCharacters(in: .whitespaces)
        
        guard
            let homeTeamText = homeTeamName.text, !homeTeamText.isEmpty,
            let awayTeamText = awayTeamName.text, !awayTeamText.isEmpty
        else {
            self.Start.isHidden = true
            self.textHelp.isHidden = false
            self.textFilled = false
            return
        }
        textFilled = true
        toggleStart()
    }
    
    @objc func colorFieldsNotEmpty(sender: UIColorWell) {
        sender.title = sender.title?.trimmingCharacters(in: .whitespaces)
        
        guard
            let _ = homeTeamColor.selectedColor,
            let _ = awayTeamColor.selectedColor
        else {
            self.Start.isHidden = true
            self.textHelp.isHidden = false
            self.colorFilled = false
            return
        }
        colorFilled = true
        toggleStart()
    }
    
    private func toggleStart() {
        if textFilled && colorFilled {
            Start.isHidden = false
            textHelp.isHidden = true
        }
    }
}
