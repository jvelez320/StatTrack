//
//  LiveGameVC.swift
//  StatTrack
//
//  Created by Ryan Hamby on 11/3/22.
//
// Copyright 2019 The TensorFlow Authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import TensorFlowLiteTaskVision
import UIKit
import VideoToolbox

final class LiveGameVC: UIViewController {
    
    //GameState Object
	var gameState = GameState()

    //  // MARK: Storyboards Connections
    @IBOutlet weak var previewView: PreviewView!
    @IBOutlet weak var cameraUnavailableLabel: UILabel!
    @IBOutlet weak var overlayView: OverlayView!
    @IBOutlet weak var gameEventLabel: UILabel!
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var homeNameLabel: UILabel!
    @IBOutlet weak var awayNameLabel: UILabel!
    @IBOutlet weak var homeScoreLabel: UILabel!
    @IBOutlet weak var awayScoreLabel: UILabel!

    var homeColor: UIColor!
    var awayColor: UIColor!
    var homeName: String = ""
    var awayName: String = ""
    
    // MARK: Constants
    private let displayFont = UIFont.systemFont(ofSize: 14.0, weight: .medium)
    private let edgeOffset: CGFloat = 2.0
    private let labelOffset: CGFloat = 10.0
    private let animationDuration = 0.5
    private let collapseTransitionThreshold: CGFloat = -30.0
    private let expandTransitionThreshold: CGFloat = 30.0
    private let colors = [
        UIColor.red,
        UIColor(displayP3Red: 90.0 / 255.0, green: 200.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0),
        UIColor.green,
        UIColor.orange,
        UIColor.blue,
        UIColor.purple,
        UIColor.magenta,
        UIColor.yellow,
        UIColor.cyan,
        UIColor.brown,
    ]

    // MARK: Model config variables
    private var threadCount: Int = 1
    private var detectionModel: ModelType = ConstantsDefault.modelType
    private var scoreThreshold: Float = ConstantsDefault.scoreThreshold
    private var maxResults: Int = ConstantsDefault.maxResults

    // MARK: Instance Variables
    private var initialBottomSpace: CGFloat = 0.0

    // Holds the results at any time
    private var result: Result?
    private let inferenceQueue = DispatchQueue(label: "org.tensorflow.lite.inferencequeue")
    private var isInferenceQueueBusy = false

    // MARK: Controllers that manage functionality
    private lazy var cameraFeedManager = CameraFeedManager(previewView: previewView)
    private var objectDetectionHelper: ObjectDetectionHelper? = ObjectDetectionHelper(
    modelFileInfo: ConstantsDefault.modelType.modelFileInfo,
    threadCount: ConstantsDefault.threadCount,
    scoreThreshold: ConstantsDefault.scoreThreshold,
    maxResults: ConstantsDefault.maxResults
    )

    // MARK: View Handling Methods
    
    // This function is called before the segue
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

       // Get a reference to the second view controller
       let finalStatsViewController = segue.destination as! FinalStatsVC

       // Set a variable in the second view controller with the String to pass
       finalStatsViewController.homeColor = homeColor
       finalStatsViewController.awayColor = awayColor
       finalStatsViewController.homeName = homeName
       finalStatsViewController.awayName = awayName
       finalStatsViewController.homeScore = gameState.teamA?.numMakes != nil ? "\(String(describing: gameState.teamA?.numMakes))" : "0"
       finalStatsViewController.awayScore = gameState.teamB?.numMakes != nil ? "\(String(describing: gameState.teamB?.numMakes))" : "0"
       
   }
    override func viewDidLoad() {
        super.viewDidLoad()
        guard objectDetectionHelper != nil else {
            fatalError("Failed to create the ObjectDetectionHelper. See the console for the error.")
        }
        cameraFeedManager.delegate = self
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        self.homeNameLabel.text = homeName
        self.homeNameLabel.textColor = .black
        self.awayNameLabel.text = awayName
        self.awayNameLabel.textColor = .black
        self.homeScoreLabel.text = gameState.teamA?.numMakes != nil ? "\(String(describing: gameState.teamA?.numMakes))" : "0"
        self.homeScoreLabel.textColor = .black
        self.awayScoreLabel.text = gameState.teamB?.numMakes != nil ? "\(String(describing: gameState.teamB?.numMakes))" : "0"
        self.awayScoreLabel.textColor = .black

        self.homeNameLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 25.0)
        self.awayNameLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 25.0)
        self.homeScoreLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 25.0)
        self.awayScoreLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 25.0)
        self.homeNameLabel.textAlignment = .center
        self.awayNameLabel.textAlignment = .center
        self.homeScoreLabel.textAlignment = .center
        self.awayScoreLabel.textAlignment = .center
        self.homeNameLabel.backgroundColor = .white
        self.homeScoreLabel.backgroundColor = .white
        self.awayNameLabel.backgroundColor = .white
        self.awayScoreLabel.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		switch UIApplication.shared.statusBarOrientation {
		case .landscapeLeft:
			previewView.previewLayer.connection?.videoOrientation = .landscapeLeft
		case .landscapeRight:
			previewView.previewLayer.connection?.videoOrientation = .landscapeRight
		default:
			break
		}
	}

    var screenRect: CGRect! = nil
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		screenRect = UIScreen.main.bounds
		previewView.previewLayer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)

		switch UIDevice.current.orientation {
		case UIDeviceOrientation.portraitUpsideDown:
			previewView.previewLayer.connection?.videoOrientation = .portraitUpsideDown
		case UIDeviceOrientation.landscapeLeft:
			previewView.previewLayer.connection?.videoOrientation = .landscapeRight
		case UIDeviceOrientation.landscapeRight:
			previewView.previewLayer.connection?.videoOrientation = .landscapeLeft
		case UIDeviceOrientation.portrait:
			previewView.previewLayer.connection?.videoOrientation = .portrait
		default:
			break
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        cameraFeedManager.checkCameraConfigurationAndStartSession()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        cameraFeedManager.stopSession()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

  // MARK: Button Actions
  @IBAction func onClickResumeButton(_ sender: Any) {
      cameraFeedManager.resumeInterruptedSession { (complete) in

      if complete {
          self.resumeButton.isHidden = true
          self.cameraUnavailableLabel.isHidden = true
      } else {
          self.presentUnableToResumeSessionAlert()
      }
    }
  }

  func presentUnableToResumeSessionAlert() {
      let alert = UIAlertController(
        title: "Unable to Resume Session",
        message: "There was an error while attempting to resume session.",
        preferredStyle: .alert
      )
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

      self.present(alert, animated: true)
  }
}


// MARK: CameraFeedManagerDelegate Methods
extension LiveGameVC: CameraFeedManagerDelegate {

  func didOutput(pixelBuffer: CVPixelBuffer) {
    // Drop current frame if the previous frame is still being processed.
    guard !self.isInferenceQueueBusy else { return }

    inferenceQueue.async {
      self.isInferenceQueueBusy = true
      self.detect(pixelBuffer: pixelBuffer)
      self.isInferenceQueueBusy = false
    }
  }

  // MARK: Session Handling Alerts
  func sessionRunTimeErrorOccurred() {
    // Handles session run time error by updating the UI and providing a button if session can be manually resumed.
    self.resumeButton.isHidden = false
  }

  func sessionWasInterrupted(canResumeManually resumeManually: Bool) {
    // Updates the UI when session is interrupted.
    if resumeManually {
      self.resumeButton.isHidden = false
    } else {
      self.cameraUnavailableLabel.isHidden = false
    }
  }

  func sessionInterruptionEnded() {
    // Updates UI once session interruption has ended.
    if !self.cameraUnavailableLabel.isHidden {
      self.cameraUnavailableLabel.isHidden = true
    }

    if !self.resumeButton.isHidden {
      self.resumeButton.isHidden = true
    }
  }

  func presentVideoConfigurationErrorAlert() {
    let alertController = UIAlertController(
      title: "Configuration Failed", message: "Configuration of camera has failed.",
      preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alertController.addAction(okAction)

    present(alertController, animated: true, completion: nil)
  }

  func presentCameraPermissionsDeniedAlert() {
    let alertController = UIAlertController(
      title: "Camera Permissions Denied",
      message:
        "Camera permissions have been denied for this app. You can change this by going to Settings",
      preferredStyle: .alert)

    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    let settingsAction = UIAlertAction(title: "Settings", style: .default) { (action) in

      UIApplication.shared.open(
        URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }

    alertController.addAction(cancelAction)
    alertController.addAction(settingsAction)

    present(alertController, animated: true, completion: nil)

  }

  /** This method runs the live camera pixelBuffer through tensorFlow to get the result.
   */
  func detect(pixelBuffer: CVPixelBuffer) {
    result = self.objectDetectionHelper?.detect(frame: pixelBuffer)

    guard let displayResult = result else {
      return
    }

    let width = CVPixelBufferGetWidth(pixelBuffer)
    let height = CVPixelBufferGetHeight(pixelBuffer)

      DispatchQueue.main.async { [self] in

      var inferenceTime: Double = 0
      if let resultInferenceTime = self.result?.inferenceTime {
        inferenceTime = resultInferenceTime
      }
        
        //Remove shot attempt/made label if its been too long
		// TODO: verify this condition through testing
        if (Date() > self.gameState.recentShotAttempt.advanced(by: 3) && Date() > self.gameState.recentMadeShot.advanced(by: 3)) {
            self.gameEventLabel.text = ""
        }

        let cameraImage = CIImage(cvPixelBuffer: pixelBuffer)
      // Draws the bounding boxes and displays class names and confidence scores.
      self.drawAfterPerformingCalculations(
        onDetections: displayResult.detections,
        withImageSize: CGSize(width: CGFloat(width), height: CGFloat(height)),
      withImage: cameraImage)
    }
  }

  /**
   This method takes the results, translates the bounding box rects to the current view, draws the bounding boxes, classNames and confidence scores of inferences.
   */
  func drawAfterPerformingCalculations(
    onDetections detections: [Detection], withImageSize imageSize: CGSize, withImage img: CIImage
  ) {

    self.overlayView.objectOverlays = []
    self.overlayView.setNeedsDisplay()

    guard !detections.isEmpty else {
      return
    }

    var objectOverlays: [ObjectOverlay] = []

      var seenNet = false
      var seenRim = false
      var seenBall = false
      var playerCount = 0
	  var teamACoords: [(Double, Double)] = []
	  var teamBCoords: [(Double, Double)] = []
      for detection in detections {

          guard let category = detection.categories.first else { continue }

          // Translates bounding box rect to current view.
          var convertedRect = detection.boundingBox.applying(
            CGAffineTransform(
                scaleX: self.previewView.viewWidth / imageSize.width,
                y: self.previewView.viewHeight / imageSize.height))
          
          if convertedRect.origin.x < 0 {
              convertedRect.origin.x = self.edgeOffset
          }
          
          if convertedRect.origin.y < 0 {
              convertedRect.origin.y = self.edgeOffset
          }
          
          if convertedRect.maxY > self.overlayView.bounds.maxY {
              convertedRect.size.height =
              self.overlayView.bounds.maxY - convertedRect.origin.y - self.edgeOffset
          }
          
          if convertedRect.maxX > self.overlayView.bounds.maxX {
              convertedRect.size.width =
              self.overlayView.bounds.maxX - convertedRect.origin.x - self.edgeOffset
          }
          
          // model tends to predict large portions of the screen are ball, rim, or net
          let maxObjectWidthThreshold = self.overlayView.frame.width / 4
          let maxPlayerWidthThreshold = self.overlayView.frame.width / 3
          
          let isTroublesomeLabel = (category.label == "ball" || category.label == "net" || category.label == "rim")
          let exceedsWidthThreshold = convertedRect.maxX - convertedRect.origin.x > maxObjectWidthThreshold
          let exceedsPlayerWidthThreshold = convertedRect.maxX - convertedRect.origin.x > maxPlayerWidthThreshold
          let detectionIsReasonableSize =  !(isTroublesomeLabel && exceedsWidthThreshold) && !((category.label == "player") && exceedsPlayerWidthThreshold)
          
          // Only show the highest confidence rim, net, and ball
          let seenRimAndIsRim = category.label == "rim" && seenRim == true
          let seenNetAndIsNet = category.label == "net" && seenNet == true
          let seenBallAndIsBall = category.label == "ball" && seenBall == true
          
          if detectionIsReasonableSize && !seenRimAndIsRim && !seenNetAndIsNet && !seenBallAndIsBall && playerCount < 10 {
              var objectDescription = String(
                format: "\(category.label ?? "Unknown") (%.2f)",
                category.score)
              
              var displayColor = colors[category.index % colors.count]
              
              let size = objectDescription.size(withAttributes: [.font: self.displayFont])
              
              // Get x coordinate of the center of the object
              let xCoord = convertedRect.origin.x + (0.5 * convertedRect.size.width)
              
              // Get y coordinate of the center of the object
              let yCoord = convertedRect.origin.y + (0.5 * convertedRect.size.height)
              
              switch category.label {
                  
              case "player":
                  playerCount += 1
				  var imgPlayerCoords = convertedRect.applying(
					CGAffineTransform(
						scaleX: imageSize.width / self.previewView.viewWidth,
						y: imageSize.height / self.previewView.viewHeight))

				  // CIImage coordinates have the origin in the bottom left instead of top left
				  imgPlayerCoords.origin.y = imageSize.height - imgPlayerCoords.origin.y - imgPlayerCoords.size.height

//                    let ogImgCrop = img.cropped(to: imgPlayerCoords)
				  
				  imgPlayerCoords.origin.x = imgPlayerCoords.origin.x + imgPlayerCoords.size.width / 3
				  imgPlayerCoords.origin.y = imgPlayerCoords.origin.y + imgPlayerCoords.size.height * (2/3)
				  imgPlayerCoords.size.height = imgPlayerCoords.size.height / 5
				  imgPlayerCoords.size.width = imgPlayerCoords.size.width / 3
				  
//                   let afterSecondCrop = img.cropped(to: imgPlayerCoords)
				  
				  // take a slice of the player's bounding box
				  let inputExtent = CIVector(x: imgPlayerCoords.origin.x, y:imgPlayerCoords.origin.y, z: imgPlayerCoords.size.width, w: imgPlayerCoords.size.height)

				  // get the average pixel value of this predicted shirt area
				  let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: img, kCIInputExtentKey: inputExtent])!
				  let outputPixelCI = filter.outputImage!

				  // convert it to UIColor
				  var bitmap = [UInt8](repeating: 0, count: 4)
				  let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
				  context.render(outputPixelCI, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: CIFormat.RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
				  let playerDetectedJerseyColor = UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
				  
				  // compare the color with home and away, and label the player with the most similar color. CIE94 is a color comparison algo.
				  // color difference function from: https://github.com/Boris-Em/ColorKit#installation
				  let homeColorDifference = playerDetectedJerseyColor.difference(from: homeColor, using: .CIE94)
				  let awayColorDifference = playerDetectedJerseyColor.difference(from: awayColor, using: .CIE94)
				  // print(homeColorDifference)
				  // print(awayColorDifference)
				  
				  // Uncomment these to show which pixels represent the shirt of each player
//                   convertedRect.origin.x = convertedRect.origin.x + convertedRect.size.width / 3
//                   convertedRect.origin.y = convertedRect.origin.y + convertedRect.size.height * (1/3)
//                   convertedRect.size.height = convertedRect.size.height / 5
//                   convertedRect.size.width = convertedRect.size.width / 3

				  if homeColorDifference < awayColorDifference {
					  // if home team
					  teamACoords.append((xCoord, yCoord))
					  displayColor = homeColor
					  objectDescription = String(format: "\(homeName) \(category.label ?? "Unknown") (%.2f)", category.score)
				  } else {
					  // if away team
					  teamBCoords.append((xCoord, yCoord))
					  displayColor = awayColor
					  objectDescription = String(format: "\(awayName) \(category.label ?? "Unknown") (%.2f)", category.score)
				  }
              case "ball":
                  gameState.updateBallCoordinates(xCoord:xCoord, yCoord:yCoord)
                  gameState.updateBallSize(height: convertedRect.size.height, width: convertedRect.size.width)
                  seenBall = true
              case "rim":
                  gameState.updateRimCoordinates(xCoord:xCoord, yCoord:yCoord)
				          gameState.updateRimSize(height: convertedRect.size.height, width: convertedRect.size.width)
                  seenRim = true
              case "net":
                  gameState.updateNetCoordinates(xCoord:xCoord, yCoord:yCoord)
				          gameState.updateNetSize(height: convertedRect.size.height, width: convertedRect.size.width)
                  seenNet = true
              default:
                  break
              }
              
              let shouldDrawShotLabel = gameState.checkShotAttempt()
              if (shouldDrawShotLabel) {
                  gameEventLabel.text = "Shot Attempted"
              }
			  
			  print(gameState.teamAHasOfficialPossesion)
			  if let shouldDrawShotMadeMissed = gameState.checkMadeBasket() {
				  if shouldDrawShotMadeMissed {
					  gameEventLabel.text = "Shot Made"
				  } else {
					  gameEventLabel.text = "Shot Missed"
				  }
			  }

              let objectOverlay = ObjectOverlay(
                name: objectDescription, borderRect: convertedRect, nameStringSize: size,
                color: displayColor,
                font: self.displayFont)
              
              objectOverlays.append(objectOverlay)
          }
      }
	  
	  gameState.updateOfficialPossesion(teamACoords: teamACoords, teamBCoords: teamBCoords)
	  //print("Does team A have possession: \(gameState.teamAHasOfficialPossesion)")
    // Hands off drawing to the OverlayView
    self.draw(objectOverlays: objectOverlays)

  }

  /** Calls methods to update overlay view with detected bounding boxes and class names.
   */
  func draw(objectOverlays: [ObjectOverlay]) {

    self.overlayView.objectOverlays = objectOverlays
    self.overlayView.setNeedsDisplay()
  }

}

// MARK: - Display handler function

/// TFLite model types
enum ModelType: CaseIterable {
  case model_v0
  case model_v1

  var modelFileInfo: FileInfo {
    switch self {
    case .model_v0:
        return FileInfo("model_v0", "tflite")
    case .model_v1:
        return FileInfo("model_v1", "tflite")
    }
  }

  var title: String {
    switch self {
    case .model_v0:
      return "model_v0"
    case .model_v1:
      return "model_v1"
  }
  }
}

/// Default configuration
struct ConstantsDefault {
  static let modelType: ModelType = .model_v1
  static let threadCount = 1
    static let scoreThreshold: Float = 0.2
  static let maxResults: Int = 40
  static let theadCountLimit = 10
}
