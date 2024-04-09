/// Copyright (c) 2024 RICOH Company, Ltd. All rights reserved.

import Foundation
import UIKit
import INSCameraSDK

import Foundation

class Insta360One: Insta360Resolution {
    
    func getResolutions(closure: @escaping ((INSVideoResolution) -> Void)) -> [UIMenuElement] {
        var actions = [UIMenuElement]()
        actions.append(UIAction(title: "3840x1920 30FPS", handler: {(_) in
            closure(INSVideoResolution3840x1920x30)
        }))
        actions.append(UIAction(title: "3328x832 60FPS", handler: {(_) in
            closure(INSVideoResolution3328x832x60)
        }))
        actions.append(UIAction(title: "2560x1280 60FPS", handler: {(_) in
            closure(INSVideoResolution2560x1280x60)
        }))
        actions.append(UIAction(title: "2560x1280 30FPS", handler: {(_) in
            closure(INSVideoResolution2560x1280x30)
        }))
        actions.append(UIAction(title: "2048x512 120FPS", handler: {(_) in
            closure(INSVideoResolution2048x512x120)
        }))
        actions.append(UIAction(title: "1920x960 30FPS", handler: {(_) in
            closure(INSVideoResolution1920x960x30)
        }))
        return actions
    }
    
}
