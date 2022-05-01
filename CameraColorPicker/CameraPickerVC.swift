//
//  ViewController.swift
//  CameraColorPicker
//
//  Created by Nick on 28.04.2022.
//

import UIKit
import AVFoundation

class CameraPickerVC: UIViewController {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var colorBtn: UIButton!
    @IBOutlet weak var switchCameraBtn: UIButton!
    @IBOutlet weak var shotCameraBtn: UIButton!
    @IBOutlet weak var previewCamera: UIView!
    @IBOutlet weak var takeColorView: UIView!
    @IBOutlet weak var previewColor: UIView!
    
    @IBOutlet weak var hueLbl: UILabel!
    @IBOutlet weak var satLbl: UILabel!
    @IBOutlet weak var valLbl: UILabel!
    @IBOutlet weak var hueSlider: SimpleSlider!
    @IBOutlet weak var satSlider: SimpleSlider!
    @IBOutlet weak var valSlider: SimpleSlider!
    
    var captureSession: AVCaptureSession!
    
    var backCamera : AVCaptureDevice!
    var frontCamera : AVCaptureDevice!
    var backInput : AVCaptureInput!
    var frontInput : AVCaptureInput!
    
    var videoOutput : AVCaptureVideoDataOutput!
    
    var previewLayer : AVCaptureVideoPreviewLayer!
    
    var backCameraOn = true
    var previewColorOn = false
    var selectedColor: UIColor = .clear
    
    var hue: Float = 0
    var sat: Float = 0
    var val: Float = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if checkPermissions() {
            setupAndStartCaptureSession()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    func setupView() {
        mainView.isHidden = true
        previewCamera.layer.borderWidth = 2
        previewCamera.layer.borderColor = #colorLiteral(red: 0.6039215686, green: 0.6039215686, blue: 0.6039215686, alpha: 1).cgColor
        previewColor.layer.borderWidth = 2
        previewColor.layer.borderColor = #colorLiteral(red: 0.6039215686, green: 0.6039215686, blue: 0.6039215686, alpha: 1).cgColor
        takeColorView.layer.cornerRadius = takeColorView.frame.width / 2
    }
    
    func checkPermissions() -> Bool {
        let cameraAuthStatus =  AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch cameraAuthStatus {
        case .authorized:
            return true
        case .denied:
            return false
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { authorized in
                if authorized {
                    self.setupAndStartCaptureSession()
                }
            })
            return false
        case .restricted:
            return false
        @unknown default:
            return false
        }
    }
    
    func setupAndStartCaptureSession() {
        DispatchQueue.main.async {
            self.mainView.isHidden = false
        }
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession = AVCaptureSession()
            self.captureSession.beginConfiguration()
            self.captureSession.automaticallyConfiguresCaptureDeviceForWideColor = true
            self.setupInputs()
           
            self.setupOutput()
            self.captureSession.commitConfiguration()
            self.captureSession.startRunning()
        }
    }
    
    func setupInputs() {
        guard let backDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back), let frontDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
        backCamera = backDevice
        frontCamera = frontDevice
        
        guard let bInput = try? AVCaptureDeviceInput(device: backDevice), let fInput = try? AVCaptureDeviceInput(device: frontDevice) else { return }
        backInput = bInput
        frontInput = fInput
        
        captureSession.addInput(backInput)
    }
    
    func setupPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer.init(session: captureSession)
        previewLayer.contentsGravity = .resizeAspectFill
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait
        DispatchQueue.main.async {
            self.previewCamera.layer.insertSublayer(self.previewLayer, at: 0)
            self.previewLayer.frame = self.previewCamera.bounds
        }
    }
    
    func setupOutput() {
            videoOutput = AVCaptureVideoDataOutput()
            let videoQueue = DispatchQueue(label: "videoQueue", qos: .userInteractive)
            videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
            
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
                videoOutput.connections.first?.videoOrientation = .portrait
                self.setupPreviewLayer()
            }
        }
    
    func switchCameraInput() {
        switchCameraBtn.isUserInteractionEnabled = false
    
        captureSession.beginConfiguration()
        if backCameraOn {
            captureSession.removeInput(backInput)
            captureSession.addInput(frontInput)
            backCameraOn = false
        } else {
            captureSession.removeInput(frontInput)
            captureSession.addInput(backInput)
            backCameraOn = true
        }
        
        videoOutput.connections.first?.videoOrientation = .portrait
        videoOutput.connections.first?.isVideoMirrored = !backCameraOn
        captureSession.commitConfiguration()
        switchCameraBtn.isUserInteractionEnabled = true
    }
    
    @IBAction func switchCameraBtnWasTapped(_ sender: UIButton) {
        if previewColorOn == false {
            switchCameraInput()
        }
    }
    
    @IBAction func shotCameraBtnWasTapped(_ sender: UIButton) {
        previewColorOn.toggle()
        if previewColorOn {
            previewCamera.isHidden = true
            previewColor.isHidden = false
            shotCameraBtn.setImage(UIImage(named: "shot-camera back"), for: .normal)
        } else {
            previewCamera.isHidden = false
            previewColor.isHidden = true
            shotCameraBtn.setImage(UIImage(named: "shot-camera"), for: .normal)
        }
    }
    
    @IBAction func colorBtnWasTapped(_ sender: UIButton) {
        
    }
    
    func setColorValues(_ color: UIColor) {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        color.getHue(&h, saturation: &s, brightness: &b, alpha: nil)
        
        hue = Float(h * 360).rounded()
        sat = Float(s * 100).rounded()
        val = Float(b * 100).rounded()
        
        hueLbl.text = "HUE: \(Int(hue))"
        satLbl.text = "SAT: \(Int(sat))"
        valLbl.text = "VAL: \(Int(val))"
        valSlider.value = val
    }
    
    
    @IBAction func turningSliderWasChanged(_ sender: SimpleSlider) {
        switch sender.tag {
        case 1:
            if sender.value + hue < 0 {
                sender.setValue(hue * -1, animated: false)
            } else if sender.value + hue > 360 {
                sender.setValue(360 - hue, animated: false)
            } else {
                hueLbl.text = "HUE: \(Int(hueSlider.value + hue))"
                selectedColor = UIColor(hue: CGFloat((hueSlider.value + hue) / 360), saturation: CGFloat((satSlider.value + sat) / 100), brightness: CGFloat(valSlider.value / 100), alpha: 1)
                previewColor.backgroundColor = selectedColor
            }
        case 2:
            if sender.value + sat < 0 {
                sender.setValue(sat * -1, animated: false)
            } else if sender.value + sat > 100 {
                sender.setValue(100 - sat, animated: false)
            } else {
                satLbl.text = "SAT: \(Int(satSlider.value + sat))"
                selectedColor = UIColor(hue: CGFloat((hueSlider.value + hue) / 360), saturation: CGFloat((satSlider.value + sat) / 100), brightness: CGFloat(valSlider.value / 100), alpha: 1)
                previewColor.backgroundColor = selectedColor
            }
        case 3:
            valLbl.text = "VAL: \(Int(valSlider.value))"
            selectedColor = UIColor(hue: CGFloat((hueSlider.value + hue) / 360), saturation: CGFloat((satSlider.value + sat) / 100), brightness: CGFloat(valSlider.value / 100), alpha: 1)
            previewColor.backgroundColor = selectedColor
        default:
            return
        }
    }
}

extension CameraPickerVC {
    func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
        let context = CIContext()
        if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
            return cgImage
        }
        return nil
    }
    
    
}

extension CameraPickerVC: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if previewColorOn {
            return
        }
        guard let cvBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
    
        let ciImage = CIImage(cvImageBuffer: cvBuffer)
        let uiImage = UIImage(ciImage: ciImage)
        guard
            let cgImage = convertCIImageToCGImage(inputImage: ciImage),
            let color = cgImage.pixel(x: cgImage.width / 2, y: cgImage.height / 2)
        else { return }

        DispatchQueue.main.async {
            self.previewColor.backgroundColor = color
            self.takeColorView.backgroundColor = color
            self.setColorValues(color)
        }
    }
}

