/// Copyright (c) 2024 RICOH Company, Ltd. All rights reserved.

import Foundation
import UIKit
import INSCameraSDK

protocol Insta360Resolution {
    
    func getResolutions(closure: @escaping((_ resolution: INSVideoResolution) -> Void)) -> [UIMenuElement]
    
}
