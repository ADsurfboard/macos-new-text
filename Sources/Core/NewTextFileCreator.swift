import Foundation
import Darwin

enum NewTextFileCreator {
    static let baseName = "新建文本文档"
    static let fileExtension = "txt"

    enum CreationError: LocalizedError {
        case invalidDirectory
        case tooManyNameCollisions
        case posix(code: Int32)

        var errorDescription: String? {
            switch self {
            case .invalidDirectory:
                return "目标位置不是可用的文件夹。"
            case .tooManyNameCollisions:
                return "同名文件过多，无法生成新名称。"
            case let .posix(code):
                return String(cString: strerror(code))
            }
        }
    }

    static func create(in directoryURL: URL) throws -> URL {
        guard directoryURL.isFileURL else {
            throw CreationError.invalidDirectory
        }

        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(
            atPath: directoryURL.path,
            isDirectory: &isDirectory
        ), isDirectory.boolValue else {
            throw CreationError.invalidDirectory
        }

        for index in 1...9_999 {
            let destination = directoryURL.appendingPathComponent(
                fileName(for: index),
                isDirectory: false
            )

            let descriptor = destination.path.withCString { path in
                Darwin.open(path, O_WRONLY | O_CREAT | O_EXCL, mode_t(0o644))
            }

            if descriptor >= 0 {
                Darwin.close(descriptor)
                return destination
            }

            if errno != EEXIST {
                throw CreationError.posix(code: errno)
            }
        }

        throw CreationError.tooManyNameCollisions
    }

    static func fileName(for index: Int) -> String {
        if index <= 1 {
            return "\(baseName).\(fileExtension)"
        }
        return "\(baseName) (\(index)).\(fileExtension)"
    }
}

