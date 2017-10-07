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


import Foundation
import SwiftyJSON
/*
 Sample:
 {
 "category": "Quizzes",
 "description": "Steps of the scientific process for science fair project",
 "name": "Scientific Method Quiz",
 "percent": "86.96",
 "score": "20",
 "letterGrade": "A",
 "pointsPossible": "23.0",
 "date": "2017-09-11T16:00:00.000Z",
 "weight": "0.43",
 "includeInFinalGrade": "1"
 },
 {
 "category": "Quizzes",
 "description": null,
 "name": "Scientific Notation Quiz",
 "percent": null,
 "score": null,
 "letterGrade": null,
 "pointsPossible": "10.0",
 "date": "2017-09-05T16:00:00.000Z",
 "weight": "1.0",
 "includeInFinalGrade": "1"
 }
 */
class Assignment {
    
    var isNew = false
    var title: String
    var date: String
    var percentage: String
    var score: String
    var letterGrade: String
    var category: String
    var includeInFinalGrade: Bool
    var weight: String
    var maximumScore: String
    
    init(json: JSON) {
        
        title = json["name"].stringValue
        date = json["date"].stringValue //TODO: change into normal format
        percentage = json["percent"].string ?? "--"
        score = json["score"].string ?? "--"
        letterGrade = json["letterGrade"].string ?? "--"
        category = json["category"].stringValue
        includeInFinalGrade = json["includeInFinalGrade"].stringValue == "1"
        weight = json["weight"].stringValue
        maximumScore = json["pointsPossible"].stringValue
    }
    
    func getDividedScore() -> String { return score+"/"+maximumScore; }
}