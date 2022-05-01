//
//  Extensions.swift
//  CameraColorPicker
//
//  Created by Nick on 29.04.2022.
//

import UIKit

public extension UIImage {

    var getAverageColour: UIColor? {
        //A CIImage object is the image data you want to process.
        guard let inputImage = CIImage(image: self) else { return nil }
        // A CIVector object representing the rectangular region of inputImage .
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}


extension CGImage {
    func pixel(x: Int, y: Int) -> UIColor? { // swiftlint:disable:this large_tuple
        guard let pixelData = dataProvider?.data,
              let data = CFDataGetBytePtr(pixelData) else { return nil }
        let pixelInfo = ((width  * y) + x ) * 4
        let red = CGFloat(Double(Int(data[pixelInfo])) / 255.0)
        let green = CGFloat(Double(Int(data[(pixelInfo + 1)])) / 255.0)
        let blue = CGFloat(Double(Int(data[(pixelInfo + 2)])) / 255.0)
        let alpha = CGFloat(Double(Int(data[(pixelInfo + 3)])) / 255.0)

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
