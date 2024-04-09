/// Copyright (c) 2024 RICOH Company, Ltd. All rights reserved.

import Foundation
import UIKit
import INSCameraSDK

import Foundation

class Insta360NanoS: Insta360Resolution {
    
    func getResolutions(closure: @escaping ((INSVideoResolution) -> Void)) -> [UIMenuElement] {
        var actions = [UIMenuElement]()
        actions.append(UIAction(title: "3840x1920 30FPS", handler: {(_) in
            closure(INSVideoResolution3840x1920x30)
        }))
        actions.append(UIAction(title: "3072x1536 30FPS", handler: {(_) in
            closure(INSVideoResolution3072x1536x30)
        }))
        actions.append(UIAction(title: "2560x1280 30FPS", handler: {(_) in
            closure(INSVideoResolution2560x1280x30)
        }))
        actions.append(UIAction(title: "2240x1120 30FPS", handler: {(_) in
            closure(INSVideoResolution2240x1120x30)
        }))
        actions.append(UIAction(title: "2240x1120 24FPS", handler: {(_) in
            closure(INSVideoResolution2240x1120x24)
        }))
        actions.append(UIAction(title: "1920x960 30FPS", handler: {(_) in
            closure(INSVideoResolution1920x960x30)
        }))
        actions.append(UIAction(title: "1440x720 30FPS", handler: {(_) in
            closure(INSVideoResolution1440x720x30)
        }))
        return actions
    }
    
}
