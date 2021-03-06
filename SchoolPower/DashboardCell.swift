//
//  Copyright 2019 SchoolPower Studio
//

import UIKit
import MaterialComponents

class DashboardCell: FoldingCell {
    
    @IBOutlet weak var foldTeacherName: UILabel!
    @IBOutlet weak var foldBlockLetter: UILabel!
    @IBOutlet weak var foldLetterGrade: UILabel!
    @IBOutlet weak var foldSubjectTitle: UILabel!
    @IBOutlet weak var foldPercentageGrade: UILabel!
    @IBOutlet weak var foldBackground: UIView!
    @IBOutlet weak var foldBorderView: UIView!
    @IBOutlet weak var foldForegroundView: RotatedView!
    
    @IBOutlet weak var unFoldTeacherName: UILabel!
    @IBOutlet weak var unFoldSubjectTitle: UILabel!
    @IBOutlet weak var unFoldPercentageGrade: UILabel!
    @IBOutlet weak var unfoldBackground: UIView!
    @IBOutlet weak var unfoldBorderView: UIView!
    @IBOutlet weak var unfoldTrendBackground: UIView!
    @IBOutlet weak var unfoldTrendImage: UIImageView!
    @IBOutlet weak var unfoldTrendLabel: UILabel!
    @IBOutlet weak var periodGradeCollectionView: UICollectionView!
    
    var number: Int = 0 {
        didSet {
            periodGradeCollectionView.tag = number
        }
    }
    
    var infoItem: Subject! {
        
        didSet {
            
            let theme = ThemeManager.currentTheme()
            let periodGradeItem = Utils.getLatestItemGrade(grades: infoItem.grades)
            foldSubjectTitle.text = infoItem.title
            foldTeacherName.text = infoItem.teacherName
            foldBlockLetter.text = "Block " + infoItem.blockLetter
            foldLetterGrade.text = periodGradeItem.letter
            foldPercentageGrade.text = periodGradeItem.percentage
            unFoldSubjectTitle.text = infoItem.title
            unFoldTeacherName.text = infoItem.teacherName
            unFoldPercentageGrade.text = periodGradeItem.percentage
            foldBackground.backgroundColor = Utils.getColorByGrade(item: periodGradeItem)
            unfoldBackground.backgroundColor = Utils.getColorByGrade(item: periodGradeItem)
            unfoldTrendBackground.isHidden = true
            
            unfoldBorderView.backgroundColor = theme.cardBackgroundColor
            foldBorderView.backgroundColor = theme.cardBackgroundColor
            foldSubjectTitle.textColor = theme.primaryTextColor
            foldTeacherName.textColor = theme.secondaryTextColor
            foldBlockLetter.textColor = theme.secondaryTextColor
            
            for assignmentItem in infoItem.assignments {
                if assignmentItem.isNew {
                    
                    foldBorderView.backgroundColor = Utils.getAccent()
                    foldSubjectTitle.textColor = .white
                    foldTeacherName.textColor = UIColor(rgb: Int(Colors.white_0_20))
                    foldBlockLetter.textColor = UIColor(rgb: Int(Colors.white_0_20))
                    
                    // Show increase/decrease badge
                    unfoldTrendBackground.isHidden = false
                    if assignmentItem.margin > 0 {
                        // Increase
                        unfoldTrendImage.image = #imageLiteral(resourceName: "ic_trending_up_white").withRenderingMode(.alwaysTemplate)
                        unfoldTrendImage.tintColor = UIColor.init(rgb: Colors.B_score_green_dark)
                        unfoldTrendLabel.textColor = UIColor.init(rgb: Colors.B_score_green_dark)
                    } else if assignmentItem.margin < 0 {
                        // Decrease
                        unfoldTrendImage.image = #imageLiteral(resourceName: "ic_trending_down_white").withRenderingMode(.alwaysTemplate)
                        unfoldTrendImage.tintColor = UIColor.init(rgb: Colors.Cm_score_red)
                        unfoldTrendLabel.textColor = UIColor.init(rgb: Colors.Cm_score_red)
                    } else {
                        // Not changed
                        unfoldTrendImage.image = #imageLiteral(resourceName: "ic_trending_flat_white").withRenderingMode(.alwaysTemplate)
                        unfoldTrendImage.tintColor = UIColor.init(rgb: Colors.gray)
                        unfoldTrendLabel.textColor = UIColor.init(rgb: Colors.gray)
                    }
                    unfoldTrendLabel.text = String.init(abs(assignmentItem.margin))
                    unfoldTrendBackground.layer.shadowOffset = CGSize.init(width: 0, height: 2.5)
                    unfoldTrendBackground.layer.shadowRadius = 2
                    unfoldTrendBackground.layer.shadowOpacity = 0.3
                    
                    break
                }
            }
        }
    }
    
    override func awakeFromNib() {
        
        foregroundView.layer.shouldRasterize = true
        foregroundView.layer.rasterizationScale = UIScreen.main.scale
        foregroundView.layer.shadowOffset = CGSize.init(width: 0, height: 2.5)
        foregroundView.layer.shadowRadius = 2
        foregroundView.layer.shadowOpacity = 0.2
        foregroundView.layer.backgroundColor = UIColor.clear.cgColor
        
        containerView.layer.shouldRasterize = true
        containerView.layer.rasterizationScale = UIScreen.main.scale
        containerView.layer.shadowOffset = CGSize.init(width: 0, height: 2.5)
        containerView.layer.shadowRadius = 2
        containerView.layer.shadowOpacity = 0.2
        containerView.layer.backgroundColor = UIColor.clear.cgColor
        
        foldBorderView.layer.cornerRadius = 10
        foldBorderView.layer.masksToBounds = true
        unfoldBorderView.layer.cornerRadius = 10
        unfoldBorderView.layer.masksToBounds = true
        
        super.awakeFromNib()
    }
    
    override func animationDuration(_ itemIndex:NSInteger, type:AnimationType)-> TimeInterval {
        
        // durations count equals its itemCount
        let durations = [0.33, 0.26, 0.26] // timing animation for each view
        return durations[itemIndex]
    }
}


// MARK: - CollectionView
extension DashboardCell {
    
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
        
        periodGradeCollectionView.delegate = dataSourceDelegate
        periodGradeCollectionView.dataSource = dataSourceDelegate
        periodGradeCollectionView.tag = row
        periodGradeCollectionView.setContentOffset(periodGradeCollectionView.contentOffset, animated:false)
        periodGradeCollectionView.backgroundColor = ThemeManager.currentTheme().cardBackgroundColor
        periodGradeCollectionView.reloadData()
    }
    
    var collectionViewOffset: CGFloat {
        
        set { periodGradeCollectionView.contentOffset.x = newValue }
        get { return periodGradeCollectionView.contentOffset.x }
    }
}
