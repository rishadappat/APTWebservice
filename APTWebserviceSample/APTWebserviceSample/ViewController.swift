//
//  ViewController.swift
//  APTWebserviceSample
//
//  Created by Rishad Appat on 6/18/18.
//  Copyright © 2018 Rishad Appat. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var response: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        APTWebservice.baseUrl = "https://reqres.in"
        APTWebservice.header.setValue("application/json", forKey: "Content-Type")
        APTWebservice.errorMessages.setValue("Server Error", forKey: "500")
        APTWebservice.errorMessages.setValue("Unauthorized", forKey: "403")
        APTWebservice.errorMessages.setValue("Unauthorized", forKey: "401")
        APTWebservice.errorMessages.setValue("URL Error", forKey: "404")
        APTWebservice.errorMessages.setValue("Bad Request", forKey: "400")
        APTWebservice.errorMessages.setValue("Server not responding", forKey: "noResponse")
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func testGetClicked(_ sender: Any) {
        APTWebservice.GET(urlPath: "/api/users/2", success: { (dict) in
            let data = dict["data"] as! NSDictionary
            self.response.text = "\(data["first_name"] as! String) \(data["last_name"] as! String)"
            APTWebservice.Download(urlPath: data["avatar"] as! String, success: { (data) in
                let image = UIImage.init(data: data)
                self.avatar.image = image
            }, failed: { (error) in
                self.response.text = error
            })
        }) { (error) in
            self.response.text = error
        }
    }
    
    @IBAction func testPostClicked(_ sender: Any) {
        let postBody: NSMutableDictionary = NSMutableDictionary()
        postBody.setValue("Rishad", forKey: "name")
        postBody.setValue("Developer", forKey: "job")
        APTWebservice.POST(urlPath: "/api/users", msgBody: postBody, success: { (dict) in
            self.response.text = "\(dict["name"] as! String) \(dict["id"] as! String)"
        }) { (error) in
            self.response.text = error
        }
    }
    
    @IBAction func testUploadClicked(_ sender: Any) {
        
    }
}

