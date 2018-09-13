import Foundation

class StreamReader {

    let encoding: String.Encoding
    let chunkSize: Int
    var fileHandle: FileHandle!
    let delimData: Data
    var buffer: Data
    var atEof: Bool
    private var filePath: String

    init?(path: String, delimiter: String = "\n", encoding: String.Encoding = .utf8,
          chunkSize: Int = 4096) {

        guard let fileHandle = FileHandle(forReadingAtPath: path),
            let delimData = delimiter.data(using: encoding) else {

                return nil
        }
        self.encoding = encoding
        self.chunkSize = chunkSize
        self.fileHandle = fileHandle
        self.delimData = delimData
        self.buffer = Data(capacity: chunkSize)
        self.atEof = false
        self.filePath = path
    }

    deinit {

        self.close()
    }

    /// Return next line, or nil on EOF.
    func nextLine() -> String? {

        precondition(fileHandle != nil, "Attempt to read from closed file")

        // Read data chunks from file until a line delimiter is found:
        while !atEof {

            if let range = buffer.range(of: delimData) {

                // Convert complete line (excluding the delimiter) to a string:
                let line = String(data: buffer.subdata(in: 0..<range.lowerBound), encoding: encoding)
                // Remove line (and the delimiter) from the buffer:
                buffer.removeSubrange(0..<range.upperBound)
                return line
            }
            let tmpData = fileHandle.readData(ofLength: chunkSize)
            if tmpData.count > 0 {

                buffer.append(tmpData)
            } else {

                // EOF or read error.
                atEof = true
                if buffer.count > 0 {

                    // Buffer contains last line in file (not terminated by delimiter).
                    let line = String(data: buffer as Data, encoding: encoding)
                    buffer.count = 0
                    return line
                }
            }
        }
        return nil
    }

    /// Start reading from the beginning of file.
    func rewind() -> Void {

        fileHandle.seek(toFileOffset: 0)
        buffer.count = 0
        atEof = false
    }

    /// Close the underlying file. No reading must be done after calling this method.
    func close() -> Void {

        fileHandle?.closeFile()
        fileHandle = nil
    }

    func seek(offset: UInt64) {

        fileHandle.seek(toFileOffset: offset)
        buffer.count = 0
        atEof = false
    }

    var offsetInFile: UInt64 {

        return fileHandle.offsetInFile
    }

    var fileSize: UInt64 {

        return FileManager.default.size(ofFileAtPath: filePath)
    }
}

extension StreamReader : Sequence {

    func makeIterator() -> AnyIterator<String> {

        return AnyIterator {

            return self.nextLine()
        }
    }
}

extension FileManager {

    func size(ofFileAtPath filePath: String) -> UInt64 {

        let size: UInt64
        if let attr = try? attributesOfItem(atPath: filePath),
            let fileSizeNumber = attr[FileAttributeKey.size] as? NSNumber {

            size = fileSizeNumber.uint64Value
        } else {

            size = 0
        }
        return size
    }
}
