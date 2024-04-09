/// Copyright (c) 2024 RICOH Company, Ltd. All rights reserved.

import Foundation
import UIKit
import INSCameraSDK

import Foundation

class Insta360X3: Insta360Resolution {
    
    func getResolutions(closure: @escaping ((INSVideoResolution) -> Void)) -> [UIMenuElement] {
        var actions = [UIMenuElement]()
        actions.append(UIAction(title: "3840x1920 30FPS", handler: {(_) in
            closure(INSVideoResolution3840x1920x30)
        }))
        actions.append(UIAction(title: "2560x1280 30FPS", handler: {(_) in
            closure(INSVideoResolution2560x1280x30)
        }))
        actions.append(UIAction(title: "1440x720 30FPS", handler: {(_) in
            closure(INSVideoResolution1440x720x30)
        }))
        return actions
    }
    
}
