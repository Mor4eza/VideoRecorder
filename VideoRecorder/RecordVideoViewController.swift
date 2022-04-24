//
//  RecordVideoViewController.swift
//  VideoRecorder
//
//  Created by Morteza on 4/18/22.
//

import UIKit
import AVFoundation
import AVKit

enum RecordingStates {
    case readyToRecord
    case recording
    case done
}

class RecordVideoViewController: UIViewController {

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var startEndButton: UIButton!
    
    var blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
    var blurEffectView: UIVisualEffectView!
    let session = AVCaptureSession()
    var player = AVPlayer()
    var playerLayer = AVPlayerLayer()
    var name: String = ""
    var activeInput: AVCaptureDeviceInput!
    var soundActiveInput: AVCaptureDeviceInput!
    var videoDataOutput: AVCaptureVideoDataOutput!
    var videoDataOutputQueue: DispatchQueue!
    var previewLayer:AVCaptureVideoPreviewLayer!
    var movieOutput = AVCaptureMovieFileOutput()
    var outputURL: URL?
    let storkeLayer = CAShapeLayer()
    var timer: Timer!
    let maxVideoDuration = 5 //seconds
    let minVideoDuration = 5 //seconds
    var state: RecordingStates = .readyToRecord {
        didSet {
            switch state {
                case .readyToRecord:
                    readyToStartRecording()
                case .recording:
                    recording()
                case .done:
                    recorded()
            }
        }
    }
    
    var videoIsPlaying = false {
        didSet {
            if videoIsPlaying {
                player.play()
                previewView.layer.addSublayer(playerLayer)
            } else {
                player.pause()
                playerLayer.removeFromSuperlayer()
            }
            blurEffectView.isHidden = videoIsPlaying
            playButton.isHidden = videoIsPlaying
        }
    }
    
    var recordedTime = 0 {
        didSet {
            if recordedTime == maxVideoDuration {
                state = .done
                stopRecording()
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupAVCapture(position: .front)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewView.layer.cornerRadius = previewView.frame.size.height / 2
        cameraView.layer.cornerRadius = cameraView.frame.size.height / 2
    }
    
    func setupView() {
            //previewImageView.transform = previewImageView.transform.rotated(by: .pi / 2)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = previewView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        previewView.addSubview(blurEffectView)
        previewView.clipsToBounds = true
        previewView.isHidden = true
        previewView.bringSubviewToFront(playButton)
//        backButton.tintColor = FPTheme.current.titleTextColor
//        trashContainerView.backgroundColor = FPTheme.current.nationalCodeImageCameraBackgroundColor
//        subtitleLabel.text = "recordVideo.textTitle".localized.replace("@", withString: name)
    }
    
    func animateBorder() {
        storkeLayer.fillColor = UIColor.clear.cgColor
        storkeLayer.strokeColor = UIColor.cyan.cgColor
        storkeLayer.lineWidth = 10
        storkeLayer.path = CGPath.init(roundedRect: cameraView.bounds, cornerWidth: cameraView.frame.size.height / 2, cornerHeight: cameraView.frame.size.height / 2, transform: nil)
        cameraView.layer.addSublayer(storkeLayer)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = CGFloat(0)
        animation.toValue = CGFloat(1)
        animation.duration = CFTimeInterval(maxVideoDuration)
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        storkeLayer.add(animation, forKey: "circleAnimation")
    }
    
    func readyToStartRecording() {
        recordedTime = 0
        if timer != nil {
            timer.invalidate()
        }
        storkeLayer.removeFromSuperlayer()
        outputURL = nil
//        trashView.isHidden = true
//        checkButton.isHidden = true
        startEndButton.setTitle("start", for: .normal)
        startEndButton.isHidden = false
        previewView.isHidden = true
        videoIsPlaying = false
    }
    
    func recording() {
        recordedTime = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { t in
            self.recordedTime += 1
        })
        animateBorder()
        outputURL = nil
//        trashView.isHidden = true
//        checkButton.isHidden = true
        startEndButton.setTitle("stop", for: .normal)
        startEndButton.isHidden = false
        previewView.isHidden = true
        videoIsPlaying = false
    }
    
    func recorded() {
        storkeLayer.removeAllAnimations()
        storkeLayer.removeFromSuperlayer()
        timer.invalidate()
//        trashView.isHidden = false
//        checkButton.isHidden = false
        startEndButton.isHidden = true
        previewView.isHidden = false
        videoIsPlaying = false
    }
    
    func setupAVCapture(position: AVCaptureDevice.Position) {
        session.sessionPreset = AVCaptureSession.Preset.vga640x480
        beginSession(position: position)
    }
    
    func beginSession(position: AVCaptureDevice.Position) {
        
        guard let audioDevice = AVCaptureDevice.default(for: .audio) else { return }
        guard let videoDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: .video, position: position) else { return }
        
        do {
            activeInput = try AVCaptureDeviceInput(device: videoDevice)
            soundActiveInput = try AVCaptureDeviceInput(device: audioDevice)
            
            guard activeInput != nil else {
                print("error: cant get deviceInput")
                return
            }
            
            if session.canAddInput(soundActiveInput) {
                session.addInput(soundActiveInput)
            }
            
            if session.canAddInput(activeInput) {
                session.addInput(activeInput)
            }
            
            videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
            
            if session.canAddOutput(videoDataOutput) {
                session.addOutput(videoDataOutput)
            }
            
            videoDataOutput.connection(with: .video)?.isEnabled = true
            
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
            
            let rootLayer: CALayer = cameraView.layer
            rootLayer.masksToBounds = true
            previewLayer.frame = cameraView.bounds
            previewLayer.videoGravity = .resizeAspectFill
            rootLayer.addSublayer(previewLayer)
            session.startRunning()
            
            if session.canAddOutput(movieOutput) {
                session.addOutput(movieOutput)
            }
        } catch let error as NSError {
            activeInput = nil
            print("error: \(error.localizedDescription)")
        }
    }

    @IBAction func recordButtonTapped(_ sender: Any) {
        if state == .readyToRecord {
            state = .recording
            startRecording()
        } else if state == .recording {
            if recordedTime < minVideoDuration {
                state = .readyToRecord
                print("Error")
            } else {
                state = .done
            }
            stopRecording()
        }
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        guard let url = outputURL else { return }
        configurePlayer(url)
        videoIsPlaying = true
    }
    
    func configurePlayer(_ url: URL) {
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerLayer.frame = previewView.bounds
        playerLayer.cornerRadius = previewView.frame.size.height / 2
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        videoIsPlaying = false
    }
    
    func startRecording() {
        if !movieOutput.isRecording {
            if let connection = movieOutput.connection(with: AVMediaType.video) {
                if connection.isVideoStabilizationSupported {
                    connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
                }
                
                let device = activeInput.device
                if device.isSmoothAutoFocusSupported {
                    do {
                        try device.lockForConfiguration()
                        device.isSmoothAutoFocusEnabled = false
                        device.unlockForConfiguration()
                    } catch {
                        print("Error setting configuration: \(error)")
                    }
                }
                
                outputURL = tempURL()
                guard let url = outputURL else { return }
                movieOutput.startRecording(to: url, recordingDelegate: self)
            }
        } else {
            stopRecording()
        }
    }
    
    func stopRecording() {
        if movieOutput.isRecording {
            movieOutput.stopRecording()
        }
    }
    
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        
        return nil
    }
}

extension RecordVideoViewController: AVCaptureFileOutputRecordingDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if (error != nil) {
            print("Error recording movie: \(error!.localizedDescription)")
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    }
    
    func makeVideoReady(completed: @escaping (Data?) -> ()) {
        guard let url = outputURL else { return }
        guard let data = try? Data(contentsOf: url) else {
            return
        }
        
        print("File size before compression: \(Double(data.count / 1048576)) mb")
        
        let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + UUID().uuidString + ".mp4")
        compressVideo(inputURL: url,
                      outputURL: compressedURL) { exportSession in
            guard let session = exportSession else {
                return
            }
            
            switch session.status {
                case .unknown:
                    break
                case .waiting:
                    break
                case .exporting:
                    break
                case .completed:
                    guard let compressedData = try? Data(contentsOf: compressedURL) else {
                        completed(nil)
                        return
                    }
                    
                    completed(compressedData)
                    print("File size after compression: \(Double(compressedData.count / 1048576)) mb")
                case .failed:
                    completed(nil)
                case .cancelled:
                    completed(nil)
                @unknown default:
                    break
            }
        }
    }
    
    func compressVideo(inputURL: URL, outputURL: URL, handler: @escaping (_ exportSession: AVAssetExportSession?) -> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
            handler(nil)
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.exportAsynchronously {
            handler(exportSession)
        }
    }
    
}
