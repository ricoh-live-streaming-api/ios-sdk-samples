/// Copyright (c) 2024 RICOH Company, Ltd. All rights reserved.

import Foundation
import UIKit
import INSCameraSDK

import Foundation

class Insta360OneR: Insta360Resolution {
    
    func getResolutions(closure: @escaping ((INSVideoResolution) -> Void)) -> [UIMenuElement] {
        var actions = [UIMenuElement]()
        actions.append(UIAction(title: "5472x3078 30FPS", handler: {(_) in
            closure(INSVideoResolution5472x3078x30)
        }))
        actions.append(UIAction(title: "5312x2988 30FPS", handler: {(_) in
            closure(INSVideoResolution5312x2988x30)
        }))
        actions.append(UIAction(title: "5312x2988 25FPS", handler: {(_) in
            closure(INSVideoResolution5312x2988x25)
        }))
        actions.append(UIAction(title: "5312x2988 24FPS", handler: {(_) in
            closure(INSVideoResolution5312x2988x24)
        }))
        actions.append(UIAction(title: "4000x3000 25FPS", handler: {(_) in
            closure(INSVideoResolution4000x3000x25)
        }))
        actions.append(UIAction(title: "4000x3000 24FPS", handler: {(_) in
            closure(INSVideoResolution4000x3000x24)
        }))
        actions.append(UIAction(title: "3840x2160 60FPS", handler: {(_) in
            closure(INSVideoResolution3840x2160x60)
        }))
        actions.append(UIAction(title: "3840x2160 30FPS", handler: {(_) in
            closure(INSVideoResolution3840x2160x30)
        }))
        actions.append(UIAction(title: "3840x2160 25FPS", handler: {(_) in
            closure(INSVideoResolution3840x2160x25)
        }))
        actions.append(UIAction(title: "3840x2160 24FPS", handler: {(_) in
            closure(INSVideoResolution3840x2160x24)
        }))
        actions.append(UIAction(title: "2720x2040 30FPS", handler: {(_) in
            closure(INSVideoResolution2720x2040x30)
        }))
        actions.append(UIAction(title: "2720x2040 25FPS", handler: {(_) in
            closure(INSVideoResolution2720x2040x25)
        }))
        actions.append(UIAction(title: "2720x2040 24FPS", handler: {(_) in
            closure(INSVideoResolution2720x2040x24)
        }))
        actions.append(UIAction(title: "2720x1530 100FPS", handler: {(_) in
            closure(INSVideoResolution2720x1530x100)
        }))
        actions.append(UIAction(title: "2720x1530 60FPS", handler: {(_) in
            closure(INSVideoResolution2720x1530x60)
        }))
        actions.append(UIAction(title: "2720x1530 30FPS", handler: {(_) in
            closure(INSVideoResolution2720x1530x30)
        }))
        actions.append(UIAction(title: "2720x1530 25FPS", handler: {(_) in
            closure(INSVideoResolution2720x1530x25)
        }))
        actions.append(UIAction(title: "2720x1530 24FPS", handler: {(_) in
            closure(INSVideoResolution2720x1530x24)
        }))
        actions.append(UIAction(title: "1920x1440 30FPS", handler: {(_) in
            closure(INSVideoResolution1920x1440x30)
        }))
        actions.append(UIAction(title: "1920x1440 25FPS", handler: {(_) in
            closure(INSVideoResolution1920x1440x25)
        }))
        actions.append(UIAction(title: "1920x1440 24FPS", handler: {(_) in
            closure(INSVideoResolution1920x1440x24)
        }))
        actions.append(UIAction(title: "1920x1080 240FPS", handler: {(_) in
            closure(INSVideoResolution1920x1080x240)
        }))
        actions.append(UIAction(title: "1920x1080 60FPS", handler: {(_) in
            closure(INSVideoResolution1920x1080x60)
        }))
        actions.append(UIAction(title: "1920x1080 25FPS", handler: {(_) in
            closure(INSVideoResolution1920x1080x25)
        }))
        actions.append(UIAction(title: "1920x1080 24FPS", handler: {(_) in
            closure(INSVideoResolution1920x1080x24)
        }))
        actions.append(UIAction(title: "1280x960 30FPS", handler: {(_) in
            closure(INSVideoResolution1280x960x30)
        }))
        actions.append(UIAction(title: "1280x720 30FPS", handler: {(_) in
            closure(INSVideoResolution1280x720x30)
        }))
        actions.append(UIAction(title: "1152x768 30FPS", handler: {(_) in
            closure(INSVideoResolution1152x768x30)
        }))
        return actions
    }
    
}
