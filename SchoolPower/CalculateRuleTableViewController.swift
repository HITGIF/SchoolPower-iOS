//
//  Copyright 2017 SchoolPower Studio

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

class CalculateRuleTableViewController: UITableViewController {
    
    @IBOutlet weak var itemAll: UITableViewCell?
    @IBOutlet weak var itemHighest3: UITableViewCell?
    @IBOutlet weak var itemHighest4: UITableViewCell?
    @IBOutlet weak var itemHighest5: UITableViewCell?
    
    @IBOutlet weak var itemAllLabel: UILabel?
    @IBOutlet weak var itemHighest3Label: UILabel?
    @IBOutlet weak var itemHighest4Label: UILabel?
    @IBOutlet weak var itemHighest5Label: UILabel?
    
    var ruleIndex: Int = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = "calculate_rule".localize
        ruleIndex = userDefaults.integer(forKey: CALCULATE_RULE_KEY_NAME)
        loadCells()
    }
    
    func loadCells() {
        
        let itemSet = [itemAll, itemHighest3, itemHighest4, itemHighest5]
        for item in itemSet {
            item?.accessoryType = .none
            if itemSet.index(where: {$0 === item})! == ruleIndex { item?.accessoryType = .checkmark }
        }
        itemAllLabel?.text = CUSTOM_RULES[0].localize
        itemHighest3Label?.text = CUSTOM_RULES[1].localize
        itemHighest4Label?.text = CUSTOM_RULES[2].localize
        itemHighest5Label?.text = CUSTOM_RULES[3].localize
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.isSelected = false
        
        userDefaults.set(indexPath.row, forKey: CALCULATE_RULE_KEY_NAME)
        userDefaults.synchronize()
        
        self.navigationController?.popViewController(animated: true)
    }
}

