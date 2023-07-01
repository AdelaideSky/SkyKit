//
//  ColorMind.swift
//  
//
//  Created by Adélaïde Sky on 03/06/2023.
//

import Foundation
import SwiftUI
import Alamofire
import SwiftyJSON

public class SKColorMind: ObservableObject {
    
    static public var shared: SKColorMind = .init()
    
    @Published public var models: [String] = []
    @Published public var palette: [Color] = []
    
    @Published public var model: String = "default"
    
    private var modelsURL = URL(string: "http://colormind.io/list/")!
    private var apiURL = URL(string: "http://colormind.io/api/")!
    
    private var body: [String : Any] {
        return [ "model": self.model ]
    }
    
    public init() {
        let modelsRequest = AF.request(modelsURL, method: .get)
            .validate()
            .responseString() { response in
                guard response.data != nil else {
                    print(response.error as Any)
                    return
                }
                
                self.models = []
                
                do {
                    var json = try? JSON(data: response.data!)
                    for model in json!["result"].arrayValue {
                        self.models.append(model.stringValue)
                    }
                }
            }
        let request = AF.request(self.apiURL, method: .post, parameters: self.body, encoding: JSONEncoding.default)
            .validate()
            .responseString() { response in
                guard response.data != nil else {
                    print(response.error as Any)
                    return
                }
                
                do {
                    var json = try? JSON(data: response.data!)
                    for color in json!["result"].arrayValue {
                        #if os(macOS)
                        let color = NSColor(red: CGFloat(color[0].floatValue), green: CGFloat(color[1].floatValue), blue: CGFloat(color[2].floatValue), alpha: CGFloat(1))
                        self.palette.append(Color(nsColor: color))
                        #else
                        let color = UIColor(red: CGFloat(color[0].floatValue/255), green: CGFloat(color[1].floatValue/255), blue: CGFloat(color[2].floatValue/255), alpha: CGFloat(1))
                        self.palette.append(Color(uiColor: color))
                        #endif
                    }
                }
            }
    }
}

public extension SKColorMind {
    func generate(using model: String) {
        self.model = model
        let request = AF.request(self.apiURL, method: .post, parameters: self.body, encoding: JSONEncoding.default)
            .validate()
            .responseString() { response in
                guard response.data != nil else {
                    print(response.error as Any)
                    return
                }
                
                do {
                    var json = try? JSON(data: response.data!)
                    for color in json!["result"].arrayValue {
                        
                        #if os(macOS)
                        let color = NSColor(red: CGFloat(color[0].floatValue), green: CGFloat(color[1].floatValue), blue: CGFloat(color[2].floatValue), alpha: CGFloat(1))
                        self.palette.append(Color(nsColor: color))
                        #else
                        let color = UIColor(red: CGFloat(color[0].floatValue/255), green: CGFloat(color[1].floatValue/255), blue: CGFloat(color[2].floatValue/255), alpha: CGFloat(1))
                        self.palette.append(Color(uiColor: color))
                        #endif
                    }
                }
            }
    }
    
    func getModels() {
        let modelsRequest = AF.request(modelsURL, method: .get)
            .validate()
            .responseString() { response in
                guard response.data != nil else {
                    print(response.error as Any)
                    return
                }
                
                self.models = []
                
                do {
                    var json = try? JSON(data: response.data!)
                    for model in json!["result"].arrayValue {
                        self.models.append(model.stringValue)
                    }
                }
            }
    }
    
    func shufflePalette() {
        let shuffledPalette = self.palette.shuffled()
        self.palette = []
        self.palette = shuffledPalette
    }
}
