/// Copyright (c) 2024 RICOH Company, Ltd. All rights reserved.

import Foundation
import INSCameraSDK

class Insta360CameraResolutionFactory {
    
    static func create(cameraType: String) -> Insta360Resolution? {
        switch cameraType {
        case kInsta360CameraNameNano:
            return Insta360Nano()
        case kInsta360CameraNameOne:
            return Insta360One()
        case kInsta360CameraNameNanoS:
            return Insta360NanoS()
        case kInsta360CameraNameOneX:
            return Insta360OneX()
        case kInsta360CameraNameX3:
            return Insta360X3()
        case kInsta360CameraNameEVO:
            return Insta360EVO()
        case kInsta360CameraNameGo:
            return Insta360Go()
        case kInsta360CameraNameOneR:
            return Insta360OneR()
        case kInsta360CameraNameOneRS:
            return Insta360OneRS()
        case kInsta360CameraNameSphere:
            return Insta360Sphere()
        default:
            return Insta360Default()
        }
    }
    
}
