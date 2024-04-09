/// Copyright (c) 2024 RICOH Company, Ltd. All rights reserved.

import Foundation
import UIKit
import INSCameraSDK

import Foundation

class Insta360EVO: Insta360Resolution {
    
    func getResolutions(closure: @escaping ((INSVideoResolution) -> Void)) -> [UIMenuElement] {
        var actions = [UIMenuElement]()
        actions.append(UIAction(title: "3840x1920 60FPS", handler: {(_) in
            closure(INSVideoResolution3840x1920x60)
        }))
        actions.append(UIAction(title: "3840x1920 50FPS", handler: {(_) in
            closure(INSVideoResolution3840x1920x50)
        }))
        actions.append(UIAction(title: "3840x1920 30FPS", handler: {(_) in
            closure(INSVideoResolution3840x1920x30)
        }))
        actions.append(UIAction(title: "3072x1536 30FPS", handler: {(_) in
            closure(INSVideoResolution3072x1536x30)
        }))
        actions.append(UIAction(title: "3040x1520 30FPS", handler: {(_) in
            closure(INSVideoResolution3040x1520x30)
        }))
        actions.append(UIAction(title: "3008x1504 100FPS", handler: {(_) in
            closure(INSVideoResolution3008x1504x100)
        }))
        actions.append(UIAction(title: "2880x2880 30FPS", handler: {(_) in
            closure(INSVideoResolution2880x2880x30)
        }))
        actions.append(UIAction(title: "2880x2880 25FPS", handler: {(_) in
            closure(INSVideoResolution2880x2880x25)
        }))
        actions.append(UIAction(title: "2880x2880 24FPS", handler: {(_) in
            closure(INSVideoResolution2880x2880x24)
        }))
        actions.append(UIAction(title: "2560x1280 30FPS", handler: {(_) in
            closure(INSVideoResolution2560x1280x30)
        }))
        actions.append(UIAction(title: "2176x1088 30FPS", handler: {(_) in
            closure(INSVideoResolution2176x1088x30)
        }))
        actions.append(UIAction(title: "1440x720 30FPS", handler: {(_) in
            closure(INSVideoResolution1440x720x30)
        }))
        return actions
    }
    
}
