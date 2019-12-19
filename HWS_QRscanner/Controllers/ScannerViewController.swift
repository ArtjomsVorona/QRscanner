//
//  ScannerViewController.swift
//  HWS_QRscanner
//
//  Created by Artjoms Vorona on 19/12/2019.
//  Copyright © 2019 Artjoms Vorona. All rights reserved.
//

import AVFoundation
import UIKit

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        verifyAuthorizationForCapture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        verifyAuthorizationForCapture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if captureSession.isRunning == true {
            captureSession.stopRunning()
        }
    }
    
    func verifyAuthorizationForCapture() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            print("Authorized")
            if captureSession.isRunning == false {
                captureSession.startRunning()
            }
        case .notDetermined:
            print("Not derminted")
        case .denied, .restricted:
            openSettingsAlert(title: "Camera usage is not allowed!")
        @unknown default:
            print("unknown default")
            return
        }
    }
    
    func setupCaptureSession() {
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            basicAlert(title: "Error!", message: "Unable ot star scanning.")
            return
        }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch  {
            print(error.localizedDescription)
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            failedCapture()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failedCapture()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    func failedCapture() {
        basicAlert(title: "Scanning not supported!", message: "Please use device that supports scanning a code.")
        captureSession = nil
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            found(code: stringValue)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func found(code: String) {
        print(code)
        captureSession.stopRunning()
        basicAlert(title: "QR code:", message: code)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
}
