/// Copyright (c) 2024 RICOH Company, Ltd. All rights reserved.

import Foundation

public class MemoryMappedFile {
    
    private var handle: Int32
    private var currentBytes: Int
    private(set) var memoryPointer: UnsafeMutableRawPointer
    
    private let pathStr: String

    var size: Int {
        get {
            return self.currentBytes
        } set(value) {
            if value != self.currentBytes {
                munmap(self.memoryPointer, self.currentBytes)
                ftruncate(self.handle, off_t(value))
                
                self.currentBytes = value
                self.memoryPointer = mmap(nil, self.currentBytes, PROT_READ | PROT_WRITE, MAP_SHARED, self.handle, 0)
            }
        }
    }
    
    public init?(path: String, createIfNotExists: Bool) {
        self.pathStr = path

        var flags: Int32 = O_RDWR | O_APPEND
        if createIfNotExists {
            flags |= O_CREAT
        }
        self.handle = open(path, flags, S_IRUSR | S_IWUSR)

        if self.handle < 0 {
            return nil
        }

        var value = stat()
        stat(path, &value)
        self.currentBytes = Int(value.st_size)

        self.memoryPointer = mmap(nil, self.currentBytes, PROT_READ | PROT_WRITE, MAP_SHARED, self.handle, 0)
    }

    public func clear() {
        memset(self.memoryPointer, 0, self.currentBytes)
    }
    
    deinit {
        munmap(self.memoryPointer, self.currentBytes)
        close(self.handle)
    }
    
}
