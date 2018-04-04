//
//  ViewController.swift
//  Modified on 2018/02/20.
//
import UIKit
import AVFoundation
import CoreML

class ViewController: UIViewController, FrameExtractorDelegate {
    let newHeight: CGFloat = 240.0
    let newWidth: CGFloat = 240.0

    var frameExtractor: FrameExtractor!
    let newModel = Car10()
    
    var prediction: Car10Output?

    var predictionReady = false
    var flag = 0

    var maxProb:Double = 0.0
    var labelWithMaxProb = "0"
    
    var secondMaxProb:Double = 0.0
    var labelWithSecondMaxProb = "0"

    var sortedPredictions: [(key: String, value: Double)] = []
    
    var predictionList: [String : Int] = ["Try Again" : 0, "Bugatti Chiron" : 0, "Ferrari LaFerrai" : 0, "Rolls Royce Wraith Black Badge" : 0, "Hennessey Venom GT" : 0, "Lamborghini Huracan Performante" : 0, "Pagani Huayra Roadster" : 0, "Mercedes AMG GTR" : 0, "Porsche 918 Spyder" : 0, "Tesla Model S P100D" : 0, "McLaren P1 GTR" : 0, "Mercedes G63 AMG" : 0]
    
    @IBOutlet weak var resultButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func onResultButtonPressed(_ sender: Any) {
        if labelWithMaxProb == "Try Again"{
            return
        }
        
        resultButton.setTitle("Fetching data ...", for: .normal)
        
        self.predictionReady = true
        self.frameExtractor.stopSession()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        HTMLScrapper.scrapeInformation(forCar: self.labelWithMaxProb) { [weak self] () -> () in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self?.performSegue(withIdentifier: "CarDetail", sender: nil)
            self?.predictionReady = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        frameExtractor = FrameExtractor()
        frameExtractor.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        resultButton.setTitle("Classifying Car ...", for: .normal)

        frameExtractor.startSession()
    }
    
    func captured(image: CMSampleBuffer) {
        if let imageBuffer = CMSampleBufferGetImageBuffer(image) {
            let ciImage = CIImage(cvPixelBuffer: imageBuffer)
            let context = CIContext(options: nil)
            if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(cgImage: cgImage)
                }
                DispatchQueue.global(qos: .userInteractive).async {
                    let newImageBuffer = self.newPixelBufferFrom(cgImage: cgImage)
                    guard let prediction = try? self.newModel.prediction(image__0: newImageBuffer!) else {
                        fatalError("Unexpected runtime error.")
                    }
                    let dict = prediction.prediction__0
                    
                    if !dict.isEmpty {
                        self.sortedPredictions = dict.sorted{ $0.value > $1.value }
                        if self.sortedPredictions.count == 1 {
                            self.labelWithMaxProb = self.sortedPredictions.first!.key
                            self.maxProb = self.sortedPredictions.first!.value
                        }
                        else {
                            self.labelWithMaxProb = self.sortedPredictions.first!.key
                            self.maxProb = self.sortedPredictions.first!.value
                            
                            self.labelWithSecondMaxProb = self.sortedPredictions[1].key
                            self.secondMaxProb = self.sortedPredictions[1].value
                        }
                    }
                }
            }
        }
        
        //  Start of logic which deals with prediction tweaking
        if self.maxProb > 0.75 && !self.predictionReady {
            print(maxProb)
            guard self.flag < 8 else {
                for (key, value) in self.predictionList {
                    print(key, value)
                    if value >= 6 {
                        DispatchQueue.main.async {
                            self.resultButton.setTitle(key, for: .normal)
                            print(key)
                            //                        self.resultLabel.text = self.sortedPredictions.count == 1
                            //                            ? self.labelWithMaxProb : "1. \(self.labelWithMaxProb)\n 2. \(self.labelWithSecondMaxProb)"
                            
                            //self.resultProbLabel.text = self.sortedPredictions.count == 1
                            //  ? String(format:"%.8f%", self.maxProb) : String(format:"%.8f%", self.maxProb) + "\n" + String(format:"%.8f%", self.secondMaxProb)
                            
                            
                        }
                        
                        break
                    }
                }
                
                self.flag = 0
                self.predictionList = self.predictionList.mapValues({ $0 * 0 })
                
                return
            }
            
            self.predictionList[self.labelWithMaxProb]! += 1
            
            self.flag = self.flag + 1
            //  End of logic which deals with prediction tweaking
        }
    }

    func newPixelBufferFrom(cgImage:CGImage) -> CVPixelBuffer?{
        let options:[String: Any] = [kCVPixelBufferCGImageCompatibilityKey as String: true, kCVPixelBufferCGBitmapContextCompatibilityKey as String: true]
        var pxbuffer:CVPixelBuffer?
        let frameWidth = newWidth
        let frameHeight = newHeight

        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(frameWidth), Int(frameHeight), kCVPixelFormatType_32ARGB, options as CFDictionary?, &pxbuffer)
        assert(status == kCVReturnSuccess && pxbuffer != nil, "newPixelBuffer failed")
        
        CVPixelBufferLockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pxdata = CVPixelBufferGetBaseAddress(pxbuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pxdata, width: Int(frameWidth), height: Int(frameHeight), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pxbuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        assert(context != nil, "context is nil")

        context!.concatenate(CGAffineTransform.identity)
        context!.draw(cgImage, in: CGRect(x: 0, y: 0, width: frameWidth, height: frameHeight))
        CVPixelBufferUnlockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0))
        return pxbuffer
    }

}
