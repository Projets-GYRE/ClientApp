//
//  ViewController.swift
//  Sudoku
//
//  Created by David Kalajdzic
//  Copyright © 2018 David Kalajdzic. All rights reserved.
//

import UIKit
import AVFoundation


class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
	
	var wholeDataCalculated:WholeData?
	
	var captureSession: AVCaptureSession!
	var videoPreviewLayer: AVCaptureVideoPreviewLayer!
	var cameraOutput : AVCapturePhotoOutput!
	
	
	@IBOutlet weak var previewView: UIView!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    
	@IBAction func takePicture(_ sender: Any) {
		let photoSettings = AVCapturePhotoSettings()
		photoSettings.flashMode = .auto
		photoSettings.isHighResolutionPhotoEnabled = false
		photoSettings.isAutoStillImageStabilizationEnabled = true
		cameraOutput?.capturePhoto(with: photoSettings, delegate: self)
        
	}
	
    fileprivate func displayLoading(){
        progressIndicator.isHidden = false
        progressIndicator.startAnimating()
    }
    
    fileprivate func hideLoading(){
        progressIndicator.isHidden = true
        progressIndicator.stopAnimating()
    }
    
	fileprivate func acceptCameraAcess() {
		AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
			if response {
				//access granted
			} else {
			}
		}
	}
	
	fileprivate func videoPreviewSetup() {
		videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession!)
		videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
		videoPreviewLayer?.frame = view.layer.bounds
		previewView.layer.addSublayer(videoPreviewLayer!)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
        hideLoading()
        
		acceptCameraAcess()
		captureSession = AVCaptureSession()
		captureSession?.sessionPreset = AVCaptureSession.Preset.photo
		cameraOutput = AVCapturePhotoOutput()
		
		let device = AVCaptureDevice.default(for: AVMediaType.video)
		do {
			let input = try AVCaptureDeviceInput(device: device!)
			self.captureSession?.addInput(input)
			captureSession.addOutput(cameraOutput)
			videoPreviewSetup()
			captureSession.startRunning()
		} catch {
			print(error)
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if(segue.identifier == "showNext"){
            hideLoading()
			let _:ResultViewController = segue.destination as! ResultViewController
			let wholeData = sender as! WholeData
			ResultViewController.wholeData = wholeData
		}
	}
	
	func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        displayLoading()
		let imageData = photo.fileDataRepresentation()
		let capturedImage = UIImage.init(data: imageData! , scale: 1.0)
//        let orientedImage = rotateCameraImageToProperOrientation(imageSource: capturedImage!, maxResolution: 1080)
		
		let base64Image = capturedImage!.pngData()!.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
		send(base64Imsge: base64Image)
	}
	
    func getServerUrl() -> String{
        let url: URL = URL(string: "https://textuploader.com/dnd2o/raw")!
        let request: NSURLRequest = NSURLRequest(url: url)
        var response: URLResponse?
        var serverIp = ""
        do {
            let data = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: &response) as NSData?
            serverIp = String(data: data! as Data, encoding: String.Encoding.utf8)!
        } catch{}
        return serverIp
    }
	
	func send(base64Imsge:String){
		let parameters = ["photoBase64": "\(base64Imsge)"] as [String : Any]
		let url = URL(string: "\(getServerUrl())/api/default")
		var request = URLRequest(url: url!)
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
		request.httpBody = httpBody
		let session = URLSession.shared
		session.dataTask(with: request) { (data, response, error) in
			do {
				if let data = data, let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]{
					let imageBase64:String = json["fullyResolvedImage"] as! String
					let defaultNumbers:[Cell] = self.jsonDefaultNumbers(jsonDefaultNumbers: (json["defaultNumbers"] as? [[String: Any]])!)
                    let hintData = json["hint"] as! [String: Any]
                    let hint:Cell = Cell(row: hintData["row"] as! Int, col: hintData["col"] as! Int)
                    let wholedatacalculated = WholeData(fullyResolvedImage: imageBase64, defaultNumbers: defaultNumbers, intelligentHint: hint)
					DispatchQueue.main.async {
						self.performSegue(withIdentifier: "showNext", sender: wholedatacalculated)
					}
				}
			} catch {}
			}.resume()
		
	}
	
	fileprivate func jsonDefaultNumbers(jsonDefaultNumbers:[[String: Any]]) -> [Cell]{
		var cells:[Cell] = []
		for cellDefaultNumber in jsonDefaultNumbers {
			cells.append(Cell(row: cellDefaultNumber["row"] as! Int,col: cellDefaultNumber["col"] as! Int))
		}
		return cells
	}
}
