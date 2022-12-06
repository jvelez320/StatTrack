//
//  CameraSetupVC.swift
//  StatTrack
//
//  Created by Ryan Hamby on 11/3/22.
//

import UIKit
import AVFoundation

final class CameraSetupVC: UIViewController {
    
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var setupLabel: UILabel!
    @IBOutlet weak var InstrLabel: UILabel!

    var session: AVCaptureSession?
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    var homeColor: UIColor!
    var awayColor: UIColor!
    var homeName: String = ""
    var awayName: String = ""
    
    // This function is called before the segue
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

       // Get a reference to the second view controller
       let liveGameViewController = segue.destination as! LiveGameVC

       // Set a variable in the second view controller with the String to pass
       liveGameViewController.homeColor = homeColor
       liveGameViewController.awayColor = awayColor
       liveGameViewController.homeName = homeName
       liveGameViewController.awayName = awayName
	   liveGameViewController.gameState.teamA.name = homeName
	   liveGameViewController.gameState.teamB.name = awayName
	   liveGameViewController.gameState.teamA.shirtColor = homeColor
	   liveGameViewController.gameState.teamB.shirtColor = awayColor
   }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black;
        view.layer.addSublayer(previewLayer)
        checkCameraPermissions()
        
        switch UIApplication.shared.statusBarOrientation {
        case .landscapeLeft:
            previewLayer.connection?.videoOrientation = .landscapeLeft
        case .landscapeRight:
            previewLayer.connection?.videoOrientation = .landscapeRight
        default:
            break
        }
        
        goButton.layer.zPosition = 2
        setupLabel.layer.zPosition = 2
        InstrLabel.layer.zPosition = 2
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
    }
    
    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else {
                    return
                }
                DispatchQueue.main.async {
                    self?.setUpCamera()
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setUpCamera()
        @unknown default:
            break
        }
    }
    
    private func setUpCamera() {
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                session.startRunning()
                self.session = session
            }
            catch {
                print(error)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.session?.stopRunning()
    }
    
    var screenRect: CGRect! = nil
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        screenRect = UIScreen.main.bounds
        previewLayer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)

        switch UIDevice.current.orientation {
        case UIDeviceOrientation.portraitUpsideDown:
            previewLayer.connection?.videoOrientation = .portraitUpsideDown
        case UIDeviceOrientation.landscapeLeft:
            previewLayer.connection?.videoOrientation = .landscapeRight
        case UIDeviceOrientation.landscapeRight:
            previewLayer.connection?.videoOrientation = .landscapeLeft
        case UIDeviceOrientation.portrait:
            previewLayer.connection?.videoOrientation = .portrait
        default:
            break
        }
    }
}

