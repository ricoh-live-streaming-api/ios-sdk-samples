/// Copyright (c) 2024 RICOH Company, Ltd. All rights reserved.

import Foundation
import SwiftyJSON

class Insta360OSCManager {
    
    private let ENDPOINT_INFO = "http://192.168.42.1/osc/info"
    
    func getSensorModuleType() -> String? {
        var sensorModuleType: String? = nil
        
        let url = URL(string: ENDPOINT_INFO)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "X-XSRF-Protected": "1",
            "Accept": "application/json"
        ]
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data, data.isEmpty == false else {
                return
            }
            do {
                let json = try JSON(data: data)
                sensorModuleType = json["_sensorModuleType"].string
            } catch {
                sensorModuleType = nil
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        
        return sensorModuleType
    }
    
}
