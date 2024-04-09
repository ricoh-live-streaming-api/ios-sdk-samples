/// Copyright (c) 2024 RICOH Company, Ltd. All rights reserved.

import ReplayKit

class SampleHandler: RPBroadcastSampleHandler {
    
    private var fileManager: MappedFileManager?
    
    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        self.fileManager = MappedFileManager()
    }
    
    override func broadcastPaused() {
        // User has requested to pause the broadcast. Samples will stop being delivered.
    }
    
    override func broadcastResumed() {
        // User has requested to resume the broadcast. Samples delivery will resume.
    }
    
    override func broadcastFinished() {
        guard let fileManager = self.fileManager else {
            return
        }
        fileManager.clear()
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case RPSampleBufferType.video:
            Thread.sleep(forTimeInterval:1/30.0)
            
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer), let fileManager = self.fileManager else {
                return
            }
            var orientation = CGImagePropertyOrientation.up
            if #available(iOS 11.0, *) {
                if let orientationAttachment = CMGetAttachment(sampleBuffer, key: RPVideoSampleOrientationKey as CFString, attachmentModeOut: nil) as? NSNumber {
                    orientation = CGImagePropertyOrientation(rawValue: orientationAttachment.uint32Value) ?? .up
                }
            }
            if let data = fileManager.createDataFromPixelBuffer(buffer: pixelBuffer) {
                fileManager.setFrame(data: data, orientation: orientation)
            }
            break
        case RPSampleBufferType.audioApp:
            // Handle audio sample buffer for app audio
            break
        case RPSampleBufferType.audioMic:
            // Handle audio sample buffer for mic audio
            break
        @unknown default:
            // Handle other sample buffer types
            fatalError("Unknown type of sample buffer")
        }
    }
    
}
