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

final class LiveGameVC: UIViewController {
    
    //GameState Object
    private var gameState = GameState()

    //  // MARK: Storyboards Connections
    @IBOutlet weak var previewView: PreviewView!
    @IBOutlet weak var cameraUnavailableLabel: UILabel!
    @IBOutlet weak var overlayView: OverlayView!
    @IBOutlet weak var gameEventLabel: UILabel!
    @IBOutlet weak var resumeButton: UIButton!

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
    //  private var inferenceViewController: InferenceViewController?

    // MARK: View Handling Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        guard objectDetectionHelper != nil else {
            fatalError("Failed to create the ObjectDetectionHelper. See the console for the error.")
        }
        cameraFeedManager.delegate = self
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
    //    overlayView.clearsContextBeforeDrawing = true
    //    addPanGesture()
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
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
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

  // MARK: Storyboard Segue Handlers
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      super.prepare(for: segue, sender: sender)

      if segue.identifier == "EMBED" {
//      inferenceViewController = segue.destination as? InferenceViewController

//      inferenceViewController?.currentThreadCount = threadCount
//      inferenceViewController?.maxResults = maxResults
//      inferenceViewController?.scoreThreshold = scoreThreshold
//      inferenceViewController?.modelSelectIndex =
//        ModelType.allCases.firstIndex(where: { $0 == detectionModel }) ?? 0
//      inferenceViewController?.delegate = self

//      guard let tempResult = result else {
//        return
//      }
//      inferenceViewController?.inferenceTime = tempResult.inferenceTime
      }
    }
}

// MARK: InferenceViewControllerDelegate Methods
//extension LiveGameVC: InferenceViewControllerDelegate {
//  func viewController(
//    _ viewController: InferenceViewController,
//    didReceiveAction action: InferenceViewController.Action
//  ) {
//    switch action {
//    case .changeThreadCount(let threadCount):
//      if self.threadCount == threadCount { return }
//      self.threadCount = threadCount
//    case .changeMaxResults(let maxResults):
//      if self.maxResults == maxResults { return }
//      self.maxResults = maxResults
//    case .changeModel(let detectionModel):
//      if self.detectionModel == detectionModel { return }
//      self.detectionModel = detectionModel
//    case .changeScoreThreshold(let scoreThreshold):
//      if self.scoreThreshold == scoreThreshold { return }
//      self.scoreThreshold = scoreThreshold
//    }
//    inferenceQueue.async {
//      self.objectDetectionHelper = ObjectDetectionHelper(
//        modelFileInfo: self.detectionModel.modelFileInfo,
//        threadCount: self.threadCount,
//        scoreThreshold: self.scoreThreshold,
//        maxResults: self.maxResults
//      )
//    }
//  }
//}

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

    DispatchQueue.main.async {

      // Display results by handing off to the InferenceViewController
//      self.inferenceViewController?.resolution = CGSize(width: width, height: height)

      var inferenceTime: Double = 0
      if let resultInferenceTime = self.result?.inferenceTime {
        inferenceTime = resultInferenceTime
      }
//      self.inferenceViewController?.inferenceTime = inferenceTime
//      self.inferenceViewController?.tableView.reloadData()

      // Draws the bounding boxes and displays class names and confidence scores.
      self.drawAfterPerformingCalculations(
        onDetections: displayResult.detections,
        withImageSize: CGSize(width: CGFloat(width), height: CGFloat(height)))
    }
  }

  /**
   This method takes the results, translates the bounding box rects to the current view, draws the bounding boxes, classNames and confidence scores of inferences.
   */
  func drawAfterPerformingCalculations(
    onDetections detections: [Detection], withImageSize imageSize: CGSize
  ) {

    self.overlayView.objectOverlays = []
    self.overlayView.setNeedsDisplay()

    guard !detections.isEmpty else {
      return
    }

    var objectOverlays: [ObjectOverlay] = []

    for detection in detections {

      guard let category = detection.categories.first else { continue }

      // Translates bounding box rect to current view.
      var convertedRect = detection.boundingBox.applying(
        CGAffineTransform(
          scaleX: self.overlayView.bounds.size.width / imageSize.width,
          y: self.overlayView.bounds.size.height / imageSize.height))

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

      let objectDescription = String(
        format: "\(category.label ?? "Unknown") (%.2f)",
        category.score)

      let displayColor = colors[category.index % colors.count]

      let size = objectDescription.size(withAttributes: [.font: self.displayFont])
        
        // Get x coordinate of the center of the object
        //print("Origin: ", convertedRect.origin.x)
        let xCoord = convertedRect.origin.x + (0.5 * convertedRect.size.width)
        //print("Center: ", xCoord)
        
        // Get y coordinate of the center of the object
        //print("Origin: ", convertedRect.origin.y)
        let yCoord = convertedRect.origin.y + (0.5 * convertedRect.size.height)
        //print("Center: ", yCoord)
        
        switch category.label {
            
        case "player":
            break // To be written in MVP
        case "ball":
            gameState.updateBallCoordinates(xCoord:xCoord, yCoord:yCoord)
        case "rim":
            gameState.updateRimCoordinates(xCoord:xCoord, yCoord:yCoord)
        case "net":
            gameState.updateNetCoordinates(xCoord:xCoord, yCoord:yCoord)
        default:
            break
        }
        
        let shouldDrawShotLabel = gameState.checkShotAttempt()
        if (shouldDrawShotLabel) {
            gameEventLabel.text = "Shot Attempted" 
        }
        
        if let recentShot = gameState.recentShotAttempt {
            print(recentShot)
            if (Date.now > recentShot.advanced(by: 3)) {
                gameEventLabel.text = ""
            }
        }
        

      let objectOverlay = ObjectOverlay(
        name: objectDescription, borderRect: convertedRect, nameStringSize: size,
        color: displayColor,
        font: self.displayFont)

      objectOverlays.append(objectOverlay)
    }

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

// MARK: Bottom Sheet Interaction Methods
extension LiveGameVC {

  // MARK: Bottom Sheet Interaction Methods
  /**
   This method adds a pan gesture to make the bottom sheet interactive.
   */
//  private func addPanGesture() {
//    let panGesture = UIPanGestureRecognizer(
//      target: self, action: #selector(LiveGameVC.didPan(panGesture:)))
//    bottomSheetView.addGestureRecognizer(panGesture)
//  }
//
//  /** Change whether bottom sheet should be in expanded or collapsed state.
//   */
//  private func changeBottomViewState() {
//    guard let inferenceVC = inferenceViewController else {
//      return
//    }
//
//    if bottomSheetViewBottomSpace.constant == inferenceVC.collapsedHeight
//      - bottomSheetView.bounds.size.height
//    {
//      bottomSheetViewBottomSpace.constant = 0.0
//    } else {
//      bottomSheetViewBottomSpace.constant =
//        inferenceVC.collapsedHeight - bottomSheetView.bounds.size.height
//    }
//    setImageBasedOnBottomViewState()
//  }

  /**
   Set image of the bottom sheet icon based on whether it is expanded or collapsed
   */
//  private func setImageBasedOnBottomViewState() {
//    if bottomSheetViewBottomSpace.constant == 0.0 {
//      bottomSheetStateImageView.image = UIImage(named: "down_icon")
//    } else {
//      bottomSheetStateImageView.image = UIImage(named: "up_icon")
//    }
//  }

  /**
   This method responds to the user panning on the bottom sheet.
   */
//  @objc func didPan(panGesture: UIPanGestureRecognizer) {
//    // Opens or closes the bottom sheet based on the user's interaction with the bottom sheet.
//    let translation = panGesture.translation(in: view)
//
//    switch panGesture.state {
//    case .began:
//      initialBottomSpace = bottomSheetViewBottomSpace.constant
//      translateBottomSheet(withVerticalTranslation: translation.y)
//    case .changed:
//      translateBottomSheet(withVerticalTranslation: translation.y)
//    case .cancelled:
//      setBottomSheetLayout(withBottomSpace: initialBottomSpace)
//    case .ended:
//      translateBottomSheetAtEndOfPan(withVerticalTranslation: translation.y)
//      setImageBasedOnBottomViewState()
//      initialBottomSpace = 0.0
//    default:
//      break
//    }
//  }

  /**
   This method sets bottom sheet translation while pan gesture state is continuously changing.
   */
//  private func translateBottomSheet(withVerticalTranslation verticalTranslation: CGFloat) {
//    let bottomSpace = initialBottomSpace - verticalTranslation
//    guard
//      (bottomSpace <= 0.0)
//        && (bottomSpace >=
//          inferenceViewController!.collapsedHeight - bottomSheetView.bounds.size.height)
//    else {
//      return
//    }
//    setBottomSheetLayout(withBottomSpace: bottomSpace)
//  }

  /**
   This method changes bottom sheet state to either fully expanded or closed at the end of pan.
   */
//  private func translateBottomSheetAtEndOfPan(withVerticalTranslation verticalTranslation: CGFloat)
//  {
//
//    // Changes bottom sheet state to either fully open or closed at the end of pan.
//    let bottomSpace = bottomSpaceAtEndOfPan(withVerticalTranslation: verticalTranslation)
//    setBottomSheetLayout(withBottomSpace: bottomSpace)
//  }
//
//  /**
//   Return the final state of the bottom sheet view (whether fully collapsed or expanded) that is to be retained.
//   */
//  private func bottomSpaceAtEndOfPan(withVerticalTranslation verticalTranslation: CGFloat)
//    -> CGFloat
//  {
//
//    // Calculates whether to fully expand or collapse bottom sheet when pan gesture ends.
//    var bottomSpace = initialBottomSpace - verticalTranslation
//
//    var height: CGFloat = 0.0
//    if initialBottomSpace == 0.0 {
//      height = bottomSheetView.bounds.size.height
//    } else {
//      height = inferenceViewController!.collapsedHeight
//    }
//
//    let currentHeight = bottomSheetView.bounds.size.height + bottomSpace
//
//    if currentHeight - height <= collapseTransitionThreshold {
//      bottomSpace = inferenceViewController!.collapsedHeight - bottomSheetView.bounds.size.height
//    } else if currentHeight - height >= expandTransitionThreshold {
//      bottomSpace = 0.0
//    } else {
//      bottomSpace = initialBottomSpace
//    }
//
//    return bottomSpace
//  }

  /**
   This method layouts the change of the bottom space of bottom sheet with respect to the view managed by this controller.
   */
//  func setBottomSheetLayout(withBottomSpace bottomSpace: CGFloat) {
//    view.setNeedsLayout()
//    bottomSheetViewBottomSpace.constant = bottomSpace
//    view.setNeedsLayout()
//  }

}

// MARK: - Display handler function

/// TFLite model types
enum ModelType: CaseIterable {
  case model_v0

  var modelFileInfo: FileInfo {
    switch self {
    case .model_v0:
        return FileInfo("model_v0", "tflite")
    }
  }

  var title: String {
    switch self {
    case .model_v0:
      return "model_v0"
  }
  }
}

/// Default configuration
struct ConstantsDefault {
  static let modelType: ModelType = .model_v0
  static let threadCount = 1
  static let scoreThreshold: Float = 0.2
  static let maxResults: Int = 10
  static let theadCountLimit = 10
}
