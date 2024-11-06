//
//  ScanQRCodeViewController.swift
//  Browser
//
//  Created by xyxy on 2024/10/31.
//

import AVFoundation
import QRCodeReader
import UIKit

class ScanQRCodeViewController: ViewController, AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    // 回调闭包，用于传递扫描结果
    var scanResultHandler: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "相册", style: .plain, target: self, action: #selector(selectImageFromPhotoLibrary))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (navigationController as? NavigationController)?.defaultStyle()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        (navigationController as? NavigationController)?.clearStyle()
    }

    override func initUI() {
        super.initUI()
        title = "二维码扫描"
    }

    private func setupCaptureSession() {
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    @objc func selectImageFromPhotoLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            detectQRCode(from: image)
        }
    }

    func detectQRCode(from image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil)
        let features = detector?.features(in: CIImage(cgImage: cgImage)) as? [CIQRCodeFeature]

        if let feature = features?.first, let code = feature.messageString {
            processQRCodeResult(code)

        } else {
            print("未识别到二维码")
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            processQRCodeResult(stringValue)
        }
    }

    private func processQRCodeResult(_ code: String) {
        navigationController?.popViewController(animated: false)
        print("扫描到的二维码: \(code)")
        captureSession.stopRunning()
        scanResultHandler?(code) // 调用回调闭包传递扫描结果
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
