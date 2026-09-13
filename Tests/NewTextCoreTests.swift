import Foundation

@main
enum NewTextCoreTests {
    static func main() throws {
        let temporaryRoot = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(
            at: temporaryRoot,
            withIntermediateDirectories: true
        )
        defer { try? FileManager.default.removeItem(at: temporaryRoot) }

        let first = try NewTextFileCreator.create(in: temporaryRoot)
        let second = try NewTextFileCreator.create(in: temporaryRoot)
        let third = try NewTextFileCreator.create(in: temporaryRoot)

        precondition(first.lastPathComponent == "新建文本文档.txt")
        precondition(second.lastPathComponent == "新建文本文档 (2).txt")
        precondition(third.lastPathComponent == "新建文本文档 (3).txt")
        precondition(FileManager.default.fileExists(atPath: first.path))
        precondition(FileManager.default.fileExists(atPath: second.path))
        precondition(FileManager.default.fileExists(atPath: third.path))
        let firstContents = try Data(contentsOf: first)
        precondition(firstContents.isEmpty)

        do {
            _ = try NewTextFileCreator.create(
                in: temporaryRoot.appendingPathComponent("missing", isDirectory: true)
            )
            preconditionFailure("不存在的文件夹应创建失败")
        } catch NewTextFileCreator.CreationError.invalidDirectory {
            // Expected.
        }

        print("测试通过：唯一命名、空文件创建和无效路径防护正常。")
    }
}
