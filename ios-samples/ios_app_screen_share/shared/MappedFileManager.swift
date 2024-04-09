/// Copyright (c) 2024 RICOH Company, Ltd. All rights reserved.

import Foundation
import CoreMedia
import ImageIO

class MappedFileManager {
    
    private let FILE_SIZE = 10 * 1024 * 1024
    private let BYTE_SIZE_8 = 4 + 4
    private let BYTE_SIZE_12 = 4 + 4 + 4
    private let BYTE_SIZE_16 = 4 + 4 + 4 + 4
    private let BYTE_SIZE_20 = 4 + 4 + 4 + 4 + 4
    
    private let FILE_NAME = "framedata.txt"
    
    private var filePath: String?
    private var mappedFile: MemoryMappedFile?
    
    public init() {
        self.filePath = getFilePath()
        
        guard let filePath = self.filePath else {
            return
        }
        
        if let mappedFile = MemoryMappedFile(path: filePath, createIfNotExists: true) {
            self.mappedFile = mappedFile
            if mappedFile.size < FILE_SIZE {
                mappedFile.size = FILE_SIZE
            }
        }
    }
    
    public func getFrame() -> (pixelBuffer: CVPixelBuffer?, orientation: CGImagePropertyOrientation?) {
        guard let mappedFile = mappedFile else {
            return (nil, nil)
        }
        var orientationVal: Int32 = 0
        memcpy(&orientationVal, mappedFile.memoryPointer.advanced(by: 0), 4)
        let orientation = CGImagePropertyOrientation(rawValue: UInt32(bitPattern: orientationVal)) ?? .up
        let data = Data(bytesNoCopy: mappedFile.memoryPointer.advanced(by: 4), count: mappedFile.size - 4, deallocator: .none)
        return (createPixelBufferFromData(data: data), orientation)
    }
    
    public func setFrame(data: Data, orientation: CGImagePropertyOrientation) {
        if let mappedFile = self.mappedFile, mappedFile.size >= data.count {
            let _ = data.withUnsafeBytes { bytes in
                var orientationValue = Int32(bitPattern: orientation.rawValue)
                memmove(mappedFile.memoryPointer, &orientationValue, 4)
                memcpy(mappedFile.memoryPointer.advanced(by: 4), bytes.baseAddress!, data.count)
            }
        }
    }
    
    public func clear() {
        guard let mappedFile = mappedFile else {
            return
        }
        mappedFile.clear()
    }
    
    public func createDataFromPixelBuffer(buffer: CVPixelBuffer) -> Data? {
        let pixelFormatType = CVPixelBufferGetPixelFormatType(buffer)
        
        switch pixelFormatType {
        case kCVPixelFormatType_420YpCbCr8BiPlanarFullRange, kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange:
            let result = CVPixelBufferLockBaseAddress(buffer, .readOnly)
            if result != kCVReturnSuccess {
                return nil
            }
            defer {
                CVPixelBufferUnlockBaseAddress(buffer, .readOnly)
            }

            let pixelWidth = CVPixelBufferGetWidth(buffer)
            let pixelHeight = CVPixelBufferGetHeight(buffer)

            guard let yPlane = CVPixelBufferGetBaseAddressOfPlane(buffer, 0) else {
                return nil
            }
            let yStride = CVPixelBufferGetBytesPerRowOfPlane(buffer, 0)
            let yPlaneSize = yStride * pixelHeight

            guard let uvPlane = CVPixelBufferGetBaseAddressOfPlane(buffer, 1) else {
                return nil
            }
            let uvStride = CVPixelBufferGetBytesPerRowOfPlane(buffer, 1)
            let uvPlaneSize = uvStride * (pixelHeight / 2)

            let dataSize = BYTE_SIZE_20 + yPlaneSize + uvPlaneSize
            let createdBytes = malloc(dataSize)!

            var pixelFormatValue = pixelFormatType
            memcpy(createdBytes.advanced(by: 0), &pixelFormatValue, 4)
            var widthValue = Int32(pixelWidth)
            memcpy(createdBytes.advanced(by: 4), &widthValue, 4)
            var heightValue = Int32(pixelHeight)
            memcpy(createdBytes.advanced(by: BYTE_SIZE_8), &heightValue, 4)
            var yStrideValue = Int32(yStride)
            memcpy(createdBytes.advanced(by: BYTE_SIZE_12), &yStrideValue, 4)
            var uvStrideValue = Int32(uvStride)
            memcpy(createdBytes.advanced(by: BYTE_SIZE_16), &uvStrideValue, 4)

            memcpy(createdBytes.advanced(by: BYTE_SIZE_20), yPlane, yPlaneSize)
            memcpy(createdBytes.advanced(by: BYTE_SIZE_20 + yPlaneSize), uvPlane, uvPlaneSize)

            return Data(bytesNoCopy: createdBytes, count: dataSize, deallocator: .free)
        default:
            return nil
        }
    }
    
    public func createPixelBufferFromData(data: Data) -> CVPixelBuffer? {
        if data.count < BYTE_SIZE_16 {
            return nil
        }
        let count = data.count
        return data.withUnsafeBytes { bytes -> CVPixelBuffer? in
            let dataBytes = bytes.baseAddress!
            
            var pixelFormat: UInt32 = 0
            memcpy(&pixelFormat, dataBytes.advanced(by: 0), 4)
            
            switch pixelFormat {
            case kCVPixelFormatType_420YpCbCr8BiPlanarFullRange, kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange:
                break
            default:
                return nil
            }
            
            var pixelWidth: Int32 = 0
            memcpy(&pixelWidth, dataBytes.advanced(by: 4), 4)
            var pixelHeight: Int32 = 0
            memcpy(&pixelHeight, dataBytes.advanced(by: BYTE_SIZE_8), 4)
            var yStride: Int32 = 0
            memcpy(&yStride, dataBytes.advanced(by: BYTE_SIZE_12), 4)
            var uvStride: Int32 = 0
            memcpy(&uvStride, dataBytes.advanced(by: BYTE_SIZE_16), 4)
            
            if pixelWidth < 0 || pixelWidth > 8192 {
                return nil
            }
            if pixelHeight < 0 || pixelHeight > 8192 {
                return nil
            }
                       
            let yPlaneSize = Int(yStride * pixelHeight)
            let uvPlaneSize = Int(uvStride * pixelHeight / 2)
            let dataSize = BYTE_SIZE_20 + yPlaneSize + uvPlaneSize
            
            if dataSize > count {
                return nil
            }
            
            var buffer: CVPixelBuffer? = nil
            CVPixelBufferCreate(nil, Int(pixelWidth), Int(pixelHeight), pixelFormat, nil, &buffer)
            if let buffer = buffer {
                let status = CVPixelBufferLockBaseAddress(buffer, [])
                if status != kCVReturnSuccess {
                    return nil
                }
                defer {
                    CVPixelBufferUnlockBaseAddress(buffer, [])
                }
                
                guard let destYPlane = CVPixelBufferGetBaseAddressOfPlane(buffer, 0) else {
                    return nil
                }
                let destYStride = CVPixelBufferGetBytesPerRowOfPlane(buffer, 0)
                if destYStride != Int(yStride) {
                    return nil
                }
                
                guard let destUvPlane = CVPixelBufferGetBaseAddressOfPlane(buffer, 1) else {
                    return nil
                }
                let destUvStride = CVPixelBufferGetBytesPerRowOfPlane(buffer, 1)
                if destUvStride != Int(uvStride) {
                    return nil
                }
                
                memcpy(destYPlane, dataBytes.advanced(by: BYTE_SIZE_20), yPlaneSize)
                memcpy(destUvPlane, dataBytes.advanced(by: BYTE_SIZE_20 + yPlaneSize), uvPlaneSize)
                
                return buffer
            } else {
                return nil
            }
        }
    }
    
    private func getFilePath() -> String {
        let fileManager = FileManager.default
        let sharedContainerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: APP_GROUP_NAME)
        let sharedFileURL = sharedContainerURL?.appendingPathComponent(FILE_NAME)
        return sharedFileURL!.path
    }
    
}
