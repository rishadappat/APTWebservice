//
//  APTWebservice.swift
//  APTWebservice
//
//  Created by Rishad Appat on 6/18/18.
//  Copyright © 2018 Rishad Appat. All rights reserved.
//

import UIKit
import Foundation
import MobileCoreServices
class APTWebservice: NSObject, URLSessionDelegate, URLSessionDataDelegate {
    
    static var baseUrl = ""
    static var ftpUrl = ""
    static var header: NSMutableDictionary = NSMutableDictionary()
    static var errorMessages: NSMutableDictionary = NSMutableDictionary()
    
    class func GET(urlPath: String, success: @escaping (_ dict: NSDictionary) -> Void, failed: @escaping (_ error: String) -> Void)
    {
        let urlString = "\(baseUrl)\(urlPath)"
        var request = URLRequest(url: URL(string: urlString)!)
        for keys in header.allKeys
        {
            let key = keys as! String
            request.setValue(header[key] as? String, forHTTPHeaderField: key)
        }
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            DispatchQueue.main.async {
                do {
                    if(data != nil && response != nil)
                    {
                        let httpResponse: HTTPURLResponse = (response as? HTTPURLResponse)!
                        if(httpResponse.statusCode == 200)
                        {
                            guard let dat = data else {
                                failed((error?.localizedDescription)!)
                                return
                            }
                            guard let json = try JSONSerialization.jsonObject(with: dat, options: []) as? NSDictionary
                                else {
                                    failed((error?.localizedDescription)!)
                                    return
                            }
                            
                            if(json.object(forKey: "error") != nil)
                            {
                                failed((error?.localizedDescription)!)
                            }
                            else
                            {
                                success(json)
                            }
                        }
                        else
                        {
                            failed(self.errorMessages["\(httpResponse.statusCode)"] as! String)
                        }
                    }
                    else
                    {
                        failed(self.errorMessages["noResponse"] as! String)
                    }
                } catch let error {
                    failed(error.localizedDescription)
                }
            }
        }.resume()
    }
    
    class func POST(urlPath: String, msgBody: NSDictionary, success: @escaping (_ dict: NSDictionary) -> Void, failed: @escaping (_ error: String) -> Void)
    {
        let urlString = "\(baseUrl)\(urlPath)"
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        for keys in header.allKeys
        {
            let key = keys as! String
            request.setValue(header[key] as? String, forHTTPHeaderField: key)
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: msgBody, options: .prettyPrinted)
            request.httpBody = jsonData
            URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
                DispatchQueue.main.async {
                    if(data != nil && response != nil)
                    {
                        let httpResponse: HTTPURLResponse = (response as? HTTPURLResponse)!
                        if(httpResponse.statusCode == 200 || httpResponse.statusCode == 201)
                        {
                            do {
                                guard let dat = data else {
                                    failed((error?.localizedDescription)!)
                                    return
                                }
                                guard let json = try JSONSerialization.jsonObject(with: dat, options: []) as? NSDictionary
                                    else {
                                        failed((error?.localizedDescription)!)
                                        return
                                }
                                if(json.object(forKey: "error") != nil)
                                {
                                    failed((error?.localizedDescription)!)
                                    
                                }
                                else
                                {
                                    success(json)
                                }
                                
                            } catch let error {
                                failed(error.localizedDescription)
                            }
                        }
                        else
                        {
                            failed(self.errorMessages["\(httpResponse.statusCode)"] as! String)
                        }
                    }
                    else
                    {
                        failed(self.errorMessages["noResponse"] as! String)
                    }
                }
            }.resume()
        }
        catch
        {
            DispatchQueue.main.async {
                failed(error.localizedDescription)
            }
        }
    }
    
    class func PUT(urlPath: String, msgBody: NSDictionary, success: @escaping (_ dict: NSDictionary) -> Void, failed: @escaping (_ error: String) -> Void)
    {
        let urlString = "\(baseUrl)\(urlPath)"
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "PUT"
        for keys in header.allKeys
        {
            let key = keys as! String
            request.setValue(header[key] as? String, forHTTPHeaderField: key)
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: msgBody, options: .prettyPrinted)
            request.httpBody = jsonData
            URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
                DispatchQueue.main.async {
                    if(data != nil && response != nil)
                    {
                        let httpResponse: HTTPURLResponse = (response as? HTTPURLResponse)!
                        if(httpResponse.statusCode == 200)
                        {
                            do {
                                guard let dat = data else {
                                    failed((error?.localizedDescription)!)
                                    return
                                }
                                guard let json = try JSONSerialization.jsonObject(with: dat, options: []) as? NSDictionary
                                    else {
                                        failed((error?.localizedDescription)!)
                                        return
                                }
                                if(json.object(forKey: "error") != nil)
                                {
                                    failed((error?.localizedDescription)!)
                                }
                                else
                                {
                                    success(json)
                                }
                            } catch let error {
                                failed(error.localizedDescription)
                            }
                        }
                        else
                        {
                            failed(self.errorMessages["\(httpResponse.statusCode)"] as! String)
                        }
                    }
                    else
                    {
                        failed(self.errorMessages["noResponse"] as! String)
                    }
                }
            }.resume()
        }
        catch
        {
            DispatchQueue.main.async {
                failed(error.localizedDescription)
            }
        }
    }
    
    class func Upload(dataArray: NSMutableArray, fileNames: NSMutableArray, urlPath: String, success: @escaping (_ dict: NSDictionary) -> Void, failed: @escaping (_ error: String) -> Void)
    {
        let urlString = "\(self.ftpUrl)\(urlPath)"
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        for keys in self.header.allKeys
        {
            let key = keys as! String
            request.setValue(self.header[key] as? String, forHTTPHeaderField: key)
        }
        let boundary = self.generateBoundaryString()
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = NSMutableData()
        
        //define the data post parameter
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"test\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("hi\r\n".data(using: String.Encoding.utf8)!)
        
        for data in dataArray
        {
            let fileName = fileNames.object(at: (dataArray.index(of: data))) as! String
            let mimetype: String?
            mimetype = MIMEType(fileExtension: (fileName as NSString).pathExtension)
            if(mimetype == nil)
            {
                return
            }
            body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
            body.append("Content-Disposition:form-data; name=\"files\"; filename=\"\(fileName)\"\r\n".data(using: String.Encoding.utf8)!)
            body.append("Content-Type: \(mimetype!)\r\n\r\n".data(using: String.Encoding.utf8)!)
            body.append(data as! Data)
            body.append("\r\n".data(using: String.Encoding.utf8)!)
        }
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        let length = "\(body.length)"
        request.setValue(length, forHTTPHeaderField: "Content-Length")
        request.httpBody = body as Data
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            DispatchQueue.main.async {
                do {
                    if(response != nil)
                    {
                        let httpResponse: HTTPURLResponse = (response as? HTTPURLResponse)!
                        if(httpResponse.statusCode == 200)
                        {
                            guard let _:NSData = data as NSData?, let _:URLResponse = response, error == nil else {
                                failed(self.errorMessages["uploadfailed"] as! String)
                                return
                            }
                            guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                                else {
                                    failed(self.errorMessages["uploadfailed"] as! String)
                                    return
                            }
                            success(json)
                        }
                        else
                        {
                            failed(self.errorMessages["\(httpResponse.statusCode)"] as! String)
                            return
                        }
                        return
                    }
                    else
                    {
                        failed(self.errorMessages["noResponse"] as! String)
                    }
                }
                catch let error {
                    failed(error.localizedDescription)
                }
            }
        }.resume()
    }
    
    class func Download(urlPath: String, success: @escaping (_ data: Data) -> Void, failed: @escaping (_ error: String) -> Void) {
        let urlString = "\(self.ftpUrl)\(urlPath)"
        var request = URLRequest(url: URL(string: urlString)!)
        for keys in self.header.allKeys
        {
            let key = keys as! String
            request.setValue(self.header[key] as? String, forHTTPHeaderField: key)
        }
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            DispatchQueue.main.async {
                do {
                    guard let dat = data else {
                        failed((error?.localizedDescription)!)
                        return
                    }
                    success(dat)
                    return
                }
            }
        }.resume()
    }
    
    class func generateBoundaryString() -> String
    {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    class func MIMEType(fileExtension: String) -> String? {
        if !fileExtension.isEmpty {
            let UTIRef = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil)
            let UTI = UTIRef?.takeUnretainedValue()
            UTIRef?.release()
            
            let MIMETypeRef = UTTypeCopyPreferredTagWithClass(UTI!, kUTTagClassMIMEType)
            if MIMETypeRef != nil
            {
                let MIMEType = MIMETypeRef?.takeUnretainedValue()
                MIMETypeRef?.release()
                return MIMEType as String?
            }
        }
        return nil
    }
}

