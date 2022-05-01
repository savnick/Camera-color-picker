//
//  SimpleSlider.swift
//  CameraColorPicker
//
//  Created by Nick on 30.04.2022.
//

import UIKit

class SimpleSlider: UISlider {
    
    @IBInspectable var sliderColor: UIColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
    
    @IBInspectable var heightTrack: Double = 5
    @IBInspectable var heightThumb: Double = 20
    @IBInspectable var widthThumb: Double = 5
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        unitedInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        unitedInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        unitedInit()
    }
    
    func unitedInit() {
        if heightTrack > Double(self.frame.size.height) {
            heightTrack = Double(self.frame.size.height)
        }
        
        if heightThumb > Double(self.frame.size.height) {
            heightThumb = Double(self.frame.size.height)
        }
        
        if widthThumb > heightThumb {
            widthThumb = heightThumb
        }
        
        let sizeTrack = CGSize(width: Double(self.frame.size.width), height: heightTrack)
        let sizeThumb = CGSize(width: widthThumb, height: heightThumb)
        
        for state: UIControl.State in [.normal, .selected, .application, .reserved, .highlighted] {
            setThumbImage(getImageWithColor(color: sliderColor, size: sizeThumb), for: state)
            setMinimumTrackImage(getImageWithColor(color: sliderColor, size: sizeTrack), for: state)
            setMaximumTrackImage(getImageWithColor(color: sliderColor, size: sizeTrack), for: state)
        }
    }
    
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
