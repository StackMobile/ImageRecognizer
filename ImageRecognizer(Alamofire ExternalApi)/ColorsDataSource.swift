//
//  ColorsDataSource.swift
//  ImageRecognizer(Alamofire ExternalApi)
//
//  Created by Gennadii Tsypenko on 02.02.17.
//  Copyright © 2017 Gennadii Tsypenko. All rights reserved.
//

import Foundation
import UIKit

class ColorsDataSource : NSObject, UITableViewDataSource{
    
    let cellColorsId : String
    let colors : [(color : UIColor , colorName : String)]
    
    init(cellColorsId : String, colors:[(color : UIColor , colorName : String)]){
        self.cellColorsId = cellColorsId
        self.colors = colors
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellColorsId, for: indexPath)
        cell.textLabel?.text = colors[indexPath.row].colorName
        cell.textLabel?.textColor = UIColor.init(contrastingBlackOrWhiteColorOn: colors[indexPath.row].color, isFlat: true)
        cell.backgroundColor = colors[indexPath.row].color
        return cell
    }

    
    
    
}
