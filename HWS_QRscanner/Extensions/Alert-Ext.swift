//
//  Alert-Ext.swift
//  HWS_QRscanner
//
//  Created by Artjoms Vorona on 19/12/2019.
//  Copyright © 2019 Artjoms Vorona. All rights reserved.
//

import AVFoundation
import UIKit

extension UIViewController {
    func basicAlert(title: String?, message: String?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openSettingsAlert(title: String?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: "Would you like to open Settings?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Open", style: .default, handler: { (alert) in
                guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                if UIApplication.shared.canOpenURL(settingsURL) {
                    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func scanAgainAlert(code: String, captureSession: AVCaptureSession) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "QR code:", message: code, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Open", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Scan Again", style: .default, handler: { (alert) in
                captureSession.startRunning()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
