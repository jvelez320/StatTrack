//
//  HomeScreenVC.swift
//  StatTrack
//
//  Created by Ryan Hamby on 11/1/22.
//

import UIKit

final class HomeScreenVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.addBackground(imageName: "statTrack")
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

extension UIView {
    func addBackground(imageName: String) {
        // screen width and height:
        let imageViewBackground = UIImageView(frame: UIScreen.main.bounds)
        imageViewBackground.image = UIImage(named: imageName)

        // you can change the content mode:
        imageViewBackground.contentMode = UIView.ContentMode.scaleAspectFill

        self.addSubview(imageViewBackground)
        self.sendSubviewToBack(imageViewBackground)
    }
}
