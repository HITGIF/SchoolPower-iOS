//
//  Copyright 2018 SchoolPower Studio

//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at

//  http://www.apache.org/licenses/LICENSE-2.0

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.


import UIKit
import XLPagerTabStrip

class PromotionViewController: UIViewController, IndicatorInfoProvider {
    
    @IBOutlet weak var QRImageView: UIImageView!
    @IBOutlet weak var androidSegmented: UISegmentedControl!
    
    func setQRAtPosition(position: Int) {
        switch position {
        case 0: QRImageView.image = generateQRCode(from: ANDROID_DOWNLOAD_ADDRESS)
        case 1: QRImageView.image = generateQRCode(from: IOS_DOWNLOAD_ADDRESS)
        default: QRImageView.image = generateQRCode(from: ANDROID_DOWNLOAD_ADDRESS)
        }
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "promotion".localize)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadTheView),
                                               name:NSNotification.Name(rawValue: "updateTheme"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "updateTheme"), object: nil)
    }
    
    @IBAction func androidSegmentChanges(_ sender: UISegmentedControl) {
        setQRAtPosition(position: sender.selectedSegmentIndex)
    }
    
    override func viewDidLoad() {
        loadTheView()
    }
    
    @objc func loadTheView() {
        
        let theme = ThemeManager.currentTheme()
        view.backgroundColor = theme.windowBackgroundColor
        let accent = Colors.accentColors[userDefaults.integer(forKey: ACCENT_COLOR_KEY_NAME)]
        androidSegmented.tintColor = accent
        androidSegmented.borderColor = accent
        setQRAtPosition(position: androidSegmented.selectedSegmentIndex)
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
}
