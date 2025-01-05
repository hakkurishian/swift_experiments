
final class LeakChecker {
    typealias Checkable = AnyObject & Sendable

    func checkForMemoryLeak<T: Checkable>(sourceLocation: SourceLocation = .here,
                                          _ instanceFactory: @autoclosure () -> T) -> T
    {
        let instance = instanceFactory()
        checks.append(.init(instance,
                            sourceLocation: sourceLocation))
        return instance
    }

    fileprivate struct LeakCheck {
        let sourceLocation: SourceLocation
        private weak var weakReference: Checkable?
        var isLeaking: Bool { weakReference != nil }
        init(_ weakReference: Checkable, sourceLocation: SourceLocation) {
            self.weakReference = weakReference
            self.sourceLocation = sourceLocation
        }
    }

    private var checks = [LeakCheck]()

    typealias Scope = (LeakChecker) -> Void

    let scope: Scope

    @discardableResult
    init(scope: @escaping Scope) {
        self.scope = scope
        scope(self)
    }

    deinit {
        for check in checks {
            #expect(check.isLeaking == false, "Potential Memory Leak detected", sourceLocation: check.sourceLocation)
        }
    }
}

extension SourceLocation {
    static let here = Self(fileID: #fileID, filePath: #filePath, line: #line, column: #column)
}
