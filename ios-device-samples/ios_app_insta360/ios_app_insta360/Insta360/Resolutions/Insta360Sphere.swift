/// Copyright (c) 2024 RICOH Company, Ltd. All rights reserved.

import Foundation
import UIKit
import INSCameraSDK

import Foundation

class Insta360Sphere: Insta360Resolution {
    
    func getResolutions(closure: @escaping ((INSVideoResolution) -> Void)) -> [UIMenuElement] {
        var actions = [UIMenuElement]()
        actions.append(UIAction(title: "2880x2880 30FPS", handler: {(_) in
            closure(INSVideoResolution2880x2880x30)
        }))
        actions.append(UIAction(title: "2720x2720 25FPS", handler: {(_) in
            closure(INSVideoResolution2720x2720x25)
        }))
        actions.append(UIAction(title: "2560x1440 50FPS", handler: {(_) in
            closure(INSVideoResolution2560x1440x50)
        }))
        actions.append(UIAction(title: "2560x1440 30FPS", handler: {(_) in
            closure(INSVideoResolution2560x1440x30)
        }))
        actions.append(UIAction(title: "2560x1440 24FPS", handler: {(_) in
            closure(INSVideoResolution2560x1440x24)
        }))
        actions.append(UIAction(title: "1920x1080 120FPS", handler: {(_) in
            closure(INSVideoResolution1920x1080x120)
        }))
        actions.append(UIAction(title: "1920x1080 50FPS", handler: {(_) in
            closure(INSVideoResolution1920x1080x50)
        }))
        actions.append(UIAction(title: "1920x1080 30FPS", handler: {(_) in
            closure(INSVideoResolution1920x1080x30)
        }))
        actions.append(UIAction(title: "1440x2560 50FPS", handler: {(_) in
            closure(INSVideoResolution1440x2560x50)
        }))
        actions.append(UIAction(title: "1440x2560 24FPS", handler: {(_) in
            closure(INSVideoResolution1440x2560x24)
        }))
        actions.append(UIAction(title: "1280x1280 30FPS", handler: {(_) in
            closure(INSVideoResolution1280x1280x30)
        }))
        actions.append(UIAction(title: "1080x1920 50FPS", handler: {(_) in
            closure(INSVideoResolution1080x1920x50)
        }))
        actions.append(UIAction(title: "1080x1920 30FPS", handler: {(_) in
            closure(INSVideoResolution1080x1920x30)
        }))
        actions.append(UIAction(title: "1080x1920 24FPS", handler: {(_) in
            closure(INSVideoResolution1080x1920x24)
        }))
        actions.append(UIAction(title: "854x854 30FPS", handler: {(_) in
            closure(INSVideoResolution854x854x30)
        }))
        return actions
    }
    
}
