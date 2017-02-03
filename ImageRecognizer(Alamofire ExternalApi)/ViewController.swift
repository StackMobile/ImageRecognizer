//
//  ViewController.swift
//  ImageRecognizer(Alamofire ExternalApi)
//
//  Created by Gennadii Tsypenko on 02.02.17.
//  Copyright © 2017 Gennadii Tsypenko. All rights reserved.
//

import UIKit
import Alamofire
import ChameleonFramework

class ViewController: UIViewController, UINavigationControllerDelegate ,UIImagePickerControllerDelegate {
    
    let urlUpload = "http://api.imagga.com/v1/content"
    let urlTagging = "http://api.imagga.com/v1/tagging"
    let urlColors = "http://api.imagga.com/v1/colors"
    
    @IBOutlet var imageView : UIImageView!
    @IBOutlet var progressView : UIProgressView!
    @IBOutlet var activityIndicator : UIActivityIndicatorView!
    @IBOutlet var tagsTable : UITableView!
    @IBOutlet var colorTable : UITableView!
    let cellTagsId = "tag"
    let cellColorId = "color"
    var colors = [(color : UIColor , colorName : String)]()
    
    var contentId : String!
    var tagsDataSource : TagsDataSource!
    var colorsDataSource : ColorsDataSource!
    @IBAction func selectPhoto(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        present(picker, animated: true, completion: nil)
        
    }
    
    func uploadEncodingCompletion(encodgingResult : SessionManager.MultipartFormDataEncodingResult) -> Void{
        switch encodgingResult {
        case .success(let request, _, _):
            request.uploadProgress(closure: {(progress) in
              self.progressView.setProgress(Float(progress.fractionCompleted), animated: true)
            })
            
            request.responseJSON(completionHandler: uploadResponseProccesing)
            
        case .failure(let error): print(error)
        }
    }
    
    func uploadResponseProccesing(response: DataResponse<Any>){
        guard let JSONData = response.result.value as? [String : Any] else{
            print ("error response from service")
            return
        }
        
        guard let contentId = ((JSONData["uploaded"] as? [[String : Any]])?.first)?["id"] as? String else {
            print("Error in json data from service")
            return
        }
        activityIndicator.stopAnimating()
        progressView.isHidden = true
        self.contentId = contentId
        fillTags()
        fillColors()
    }
    
    func fillColors(){
        let request = Alamofire.request(urlColors ,parameters: ["content": contentId], headers: authHeader)
        request.responseJSON(completionHandler: {(response) in
        
            guard let colorsData = ((response.result.value as? [String : Any])?["results"] as? [[String : Any]])?.first?["info"] as? [String : Any] else{
                  print("wrong response colors data")
                  return
               }
           
            let backgroundColors = colorsData["background_colors"] as! [[String : Any]]
            let foregroundColors = colorsData["foreground_colors"] as! [[String :Any]]
            let imageColors = colorsData["image_colors"] as! [[String : Any]]
            
            self.colors.append((color: UIColor.white, colorName : "Background:"))
            self.grabAllColors(colors: backgroundColors)
            self.colors.append((color: UIColor.white, colorName : "Foreground:"))
            self.grabAllColors(colors: foregroundColors)
            self.colors.append((color: UIColor.white, colorName : "Image:"))
            self.grabAllColors(colors: imageColors)
           
          
            self.colorsDataSource = ColorsDataSource(cellColorsId: self.cellColorId, colors: self.colors)
            self.colorTable.dataSource = self.colorsDataSource
            self.colorTable.reloadData()
            
        })
    }
    func grabAllColors(colors array : [[String : Any]] ){
        
        for x in array {
            let red  = Float(x["r"]! as! String)! / 255
            let green = Float(x["g"]! as! String)! / 255
            let blue = Float(x["b"]! as! String)! / 255
            let label = x["closest_palette_color"] as! String
            let color = UIColor(colorLiteralRed: red, green: green, blue: blue, alpha: 1)
            colors.append((color: color, colorName : label))
        }
    }
    
    func fillTags() {
        let request = Alamofire.request(urlTagging, parameters: ["content" : contentId], headers: authHeader)
        request.responseJSON(completionHandler: {(response) in
            guard let tagsData = ((response.result.value as? [String : Any])?["results"] as? [[String : Any]])?.first?["tags"] as? [[String : Any]] else {
                print ("wrong response data")
                return
            }
            
            let tags = tagsData.map({ $0["tag"] as? String ?? "tag not found" })
            
            self.tagsDataSource = TagsDataSource(cellTagsId: self.cellTagsId, tags: tags)
            self.tagsTable.dataSource = self.tagsDataSource
            self.tagsTable.reloadData()
            
            
        })
    }
    
    let authHeader = ["Authorization" : "Basic YWNjXzE2ZTQzMWM1NDU3ZmM3NDo4ZmQ3OTkwNWIzMTFjMzVlMjZmN2Q4YzNlNDAzZWJmMw=="]
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageView.image = info[UIImagePickerControllerOriginalImage] as! UIImage?
        let imageData = UIImageJPEGRepresentation(imageView.image!, 0.5)
        
        Alamofire.upload(multipartFormData: { (multipart) in
            multipart.append(imageData!, withName: "imageFile", fileName: "image.jpg", mimeType: "image/jpeg")
    
        }, to: urlUpload, headers: authHeader, encodingCompletion: uploadEncodingCompletion)
        
        picker.dismiss(animated: true, completion: nil)
        activityIndicator.startAnimating()
        progressView.isHidden = false
        progressView.setProgress(0, animated: true)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.init(randomFlatColorOf: .light)
        tagsTable.register(UITableViewCell.self, forCellReuseIdentifier: cellTagsId)
        colorTable.register(UITableViewCell.self, forCellReuseIdentifier:  cellColorId)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
}

