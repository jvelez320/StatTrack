//
//  FinalStatsVC.swift
//  StatTrack
//
//  Created by Ryan Hamby on 11/3/22.
//

import UIKit

final class FinalStatsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var invisibleLabelTableBorder: UILabel!
    @IBOutlet weak var labelTotalPoints: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        // Do any additional setup after loading the view.
        invisibleLabelTableBorder.layer.borderWidth = 3
        invisibleLabelTableBorder.layer.borderColor = UIColor.black.cgColor
        labelTotalPoints.layer.zPosition = 2
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
