    //
    //  CapturePhotoViewController.swift
    //  VideoRecorder
    //
    //  Created by Morteza on 4/19/22.
    //

import UIKit
import AVFoundation

class CapturePhotoViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var frameView: UIView!
    
    private let photoOutput = AVCapturePhotoOutput()
    private let captureSession = AVCaptureSession()

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        openCamera()
        cameraView.layer.cornerRadius = cameraView.frame.size.height / 2
        frameView.backgroundColor = .clear
        frameView.layer.cornerRadius = cameraView.frame.size.height / 2
        frameView.layer.borderWidth = 2.0
        frameView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    private func openCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized: // the user has already authorized to access the camera.
                self.setupCaptureSession()
                
            case .notDetermined: // the user has not yet asked for camera access.
                AVCaptureDevice.requestAccess(for: .video) { (granted) in
                    if granted { // if user has granted to access the camera.
                        print("the user has granted to access the camera")
                        DispatchQueue.main.async {
                            self.setupCaptureSession()
                        }
                    } else {
                        print("the user has not granted to access the camera")
                        self.handleDismiss()
                    }
                }
                
            case .denied:
                print("the user has denied previously to access the camera.")
                self.handleDismiss()
                
            case .restricted:
                print("the user can't give camera access due to some restriction.")
                self.handleDismiss()
                
            default:
                print("something has wrong due to we can't access the camera.")
                self.handleDismiss()
        }
    }
    
    @IBAction func takePhotoTapped(_ sender: Any) {
        handleTakePhoto()
    }
    
    private func setupCaptureSession() {
        
        if let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front) {
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }
            } catch let error {
                print("Failed to set input device with error: \(error)")
            }
            
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            
            let cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            cameraLayer.frame = cameraView.bounds
            cameraLayer.videoGravity = .resizeAspectFill
            self.cameraView.layer.addSublayer(cameraLayer)
            
            captureSession.startRunning()
        }
    }
    
    @objc private func handleDismiss() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func handleTakePhoto() {
        let photoSettings = AVCapturePhotoSettings()
        if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        guard let previewImage = UIImage(data: imageData) else { return }
        
        let flippedImage = UIImage(cgImage: previewImage.cgImage!, scale: previewImage.scale, orientation: .leftMirrored)

        let previewVC = self.storyboard?.instantiateViewController(withIdentifier: "PhotoPreviewViewController") as? PhotoPreviewViewController
        previewVC?.photo = flippedImage
        previewVC?.photoPath = saveImageToDocumentDirectory(flippedImage)
        self.navigationController?.pushViewController(previewVC!, animated: true)

    }
    
    func saveImageToDocumentDirectory(_ image: UIImage) -> String? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "Selfie_Photo.jpeg"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        if let data = image.jpegData(compressionQuality: 1.0){
            do {
                try data.write(to: fileURL)
            } catch {
                print("unable to save photo")
            }
        }
        return fileURL.path
    }
}
