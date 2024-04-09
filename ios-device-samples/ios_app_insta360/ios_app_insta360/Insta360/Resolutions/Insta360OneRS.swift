/// Copyright (c) 2024 RICOH Company, Ltd. All rights reserved.

import Foundation
import UIKit
import INSCameraSDK

import Foundation

class Insta360OneRS: Insta360Resolution {
    
    func getResolutions(closure: @escaping ((INSVideoResolution) -> Void)) -> [UIMenuElement] {
        var actions = [UIMenuElement]()
        actions.append(UIAction(title: "6720x2856 25FPS", handler: {(_) in
            closure(INSVideoResolution6720x2856x25)
        }))
        actions.append(UIAction(title: "6720x2856 24FPS", handler: {(_) in
            closure(INSVideoResolution6720x2856x24)
        }))
        actions.append(UIAction(title: "6016x2560 25FPS", handler: {(_) in
            closure(INSVideoResolution6016x2560x25)
        }))
        actions.append(UIAction(title: "6016x2560 24FPS", handler: {(_) in
            closure(INSVideoResolution6016x2560x24)
        }))
        actions.append(UIAction(title: "5472x2328 30FPS", handler: {(_) in
            closure(INSVideoResolution5472x2328x30)
        }))
        actions.append(UIAction(title: "5472x2328 25FPS", handler: {(_) in
            closure(INSVideoResolution5472x2328x25)
        }))
        actions.append(UIAction(title: "5472x2328 24FPS", handler: {(_) in
            closure(INSVideoResolution5472x2328x24)
        }))
        actions.append(UIAction(title: "5312x3552 30FPS", handler: {(_) in
            closure(INSVideoResolution5312x3552x30)
        }))
        actions.append(UIAction(title: "5312x3552 25FPS", handler: {(_) in
            closure(INSVideoResolution5312x3552x25)
        }))
        actions.append(UIAction(title: "5312x3552 24FPS", handler: {(_) in
            closure(INSVideoResolution5312x3552x24)
        }))
        actions.append(UIAction(title: "3920x1920 30FPS", handler: {(_) in
            closure(INSVideoResolution3920x1920x30)
        }))
        actions.append(UIAction(title: "3920x1920 25FPS", handler: {(_) in
            closure(INSVideoResolution3840x1920x25)
        }))
        actions.append(UIAction(title: "3920x1920 24FPS", handler: {(_) in
            closure(INSVideoResolution3840x1920x24)
        }))
        actions.append(UIAction(title: "3840x1634 30FPS", handler: {(_) in
            closure(INSVideoResolution3840x1634x30)
        }))
        actions.append(UIAction(title: "3840x1634 25FPS", handler: {(_) in
            closure(INSVideoResolution3840x1634x25)
        }))
        actions.append(UIAction(title: "3840x1634 24FPS", handler: {(_) in
            closure(INSVideoResolution3840x1634x24)
        }))
        actions.append(UIAction(title: "3072x3072 25FPS", handler: {(_) in
            closure(INSVideoResolution3072x3072x25)
        }))
        actions.append(UIAction(title: "3072x3072 24FPS", handler: {(_) in
            closure(INSVideoResolution3072x3072x24)
        }))
        actions.append(UIAction(title: "3040x3040 30FPS", handler: {(_) in
            closure(INSVideoResolution3040x3040x30)
        }))
        actions.append(UIAction(title: "3040x3040 25FPS", handler: {(_) in
            closure(INSVideoResolution3040x3040x25)
        }))
        actions.append(UIAction(title: "3040x3040 24FPS", handler: {(_) in
            closure(INSVideoResolution3040x3040x24)
        }))
        actions.append(UIAction(title: "3040x1520 50FPS", handler: {(_) in
            closure(INSVideoResolution3040x1520x50)
        }))
        actions.append(UIAction(title: "2944x2880 30FPS", handler: {(_) in
            closure(INSVideoResolution2944x2880x30)
        }))
        actions.append(UIAction(title: "2720x1530 50FPS", handler: {(_) in
            closure(INSVideoResolution2720x1530x50)
        }))
        actions.append(UIAction(title: "1280x1280 25FPS", handler: {(_) in
            closure(INSVideoResolution1280x1280x25)
        }))
        return actions
    }
    
}
