/// Copyright (c) 2024 RICOH Company, Ltd. All rights reserved.

import Foundation
import UIKit
import INSCameraSDK

import Foundation

class Insta360Go: Insta360Resolution {
    
    func getResolutions(closure: @escaping ((INSVideoResolution) -> Void)) -> [UIMenuElement] {
        var actions = [UIMenuElement]()
        actions.append(UIAction(title: "2720x2720 25FPS", handler: {(_) in
            closure(INSVideoResolution2720x2720x25)
        }))
        return actions
    }
    
}
