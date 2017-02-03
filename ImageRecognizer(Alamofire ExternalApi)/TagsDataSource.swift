//
//  CustomDataSource.swift
//  ImageRecognizer(Alamofire ExternalApi)
//
//  Created by Gennadii Tsypenko on 02.02.17.
//  Copyright © 2017 Gennadii Tsypenko. All rights reserved.
//

import Foundation
import UIKit

class TagsDataSource : NSObject, UITableViewDataSource {
    
    
    let cellTagsId : String
    let tags : [String]
    
    init(cellTagsId : String, tags:[String]){
        self.cellTagsId = cellTagsId
        self.tags = tags
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellTagsId, for: indexPath)
        cell.textLabel?.text = tags[indexPath.row]
        return cell
    }
    
    
}
