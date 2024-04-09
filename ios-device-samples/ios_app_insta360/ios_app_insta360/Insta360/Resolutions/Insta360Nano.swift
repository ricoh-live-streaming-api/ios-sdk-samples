/// Copyright (c) 2024 RICOH Company, Ltd. All rights reserved.

import Foundation
import UIKit
import INSCameraSDK

class Insta360Nano: Insta360Resolution {
    
    func getResolutions(closure: @escaping((_ resolution: INSVideoResolution) -> Void)) -> [UIMenuElement] {
        var actions = [UIMenuElement]()
        actions.append(UIAction(title: "2560x1280 30FPS", handler: {(_) in
            closure(INSVideoResolution2560x1280x30)
        }))
        actions.append(UIAction(title: "2160x1080 30FPS", handler: {(_) in
            closure(INSVideoResolution2160x1080x30)
        }))
        actions.append(UIAction(title: "1920x960 30FPS", handler: {(_) in
            closure(INSVideoResolution2160x1080x30)
        }))
        return actions
    }
    
}
