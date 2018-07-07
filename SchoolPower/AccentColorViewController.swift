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

class AccentColorViewController: UICollectionViewController {
    
    fileprivate let itemDiameter: CGFloat = 70.0
    fileprivate var indexSelected: Int = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = "accent_color".localize
        collectionView?.backgroundColor = ThemeManager.currentTheme().windowBackgroundColor
        
        indexSelected = userDefaults.integer(forKey: ACCENT_COLOR_KEY_NAME)
    }
    
    func loadAccentColors() -> Array<UIColor> {
        return Colors.accentColors
    }
}

//MARK: Collection View
extension AccentColorViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return loadAccentColors().count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        collectionView.register(UINib(nibName: "AccentColorCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: itemDiameter, height: itemDiameter)
        
        let position = indexPath.row
        let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        collectionCell.layer.cornerRadius = itemDiameter / 2
        collectionCell.layer.masksToBounds = true
        
        collectionCell.viewWithTag(1)!.backgroundColor = loadAccentColors()[position]
        collectionCell.viewWithTag(2)!.backgroundColor = .clear
        collectionCell.viewWithTag(2)!.borderColor = .white
        collectionCell.viewWithTag(2)!.borderWidth = 5
        collectionCell.viewWithTag(2)!.layer.cornerRadius = (itemDiameter - 10) / 2
        
        if position == indexSelected { collectionCell.viewWithTag(2)!.isHidden = false }
        else { collectionCell.viewWithTag(2)!.isHidden = true }
        
        return collectionCell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let position = indexPath.row
        if position != indexSelected {
            
            for item in collectionView.visibleCells {
                if item.viewWithTag(2)!.isHidden == false {
                    UIView.animate(withDuration: 0.2, delay: 0,options: UIViewAnimationOptions.curveEaseOut,animations: {
                        item.viewWithTag(2)!.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                    }, completion: { finish in item.viewWithTag(2)!.isHidden = true })
                }
            }
            
            indexSelected = position
            let selectedView = collectionView.cellForItem(at: indexPath)?.viewWithTag(2)!
            selectedView?.isHidden = false
            selectedView?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            
            UIView.animate(withDuration: 0.2, delay: 0,options: UIViewAnimationOptions.curveEaseOut,animations: {
                selectedView?.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
            
            userDefaults.set(indexSelected, forKey: ACCENT_COLOR_KEY_NAME)
            ThemeManager.applyTheme(theme: ThemeManager.currentTheme())
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateTheme"), object: nil)
        }
    }
}
