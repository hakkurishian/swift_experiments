import Testing

/// A Generic Superclass for Swift Testing suits, supporting memory leak checking
open class TestCase {
    typealias MemoryLeakCheckable = AnyObject & Sendable

    /// Checks instance for leaking memory when going out of class scope
    /// - Parameters:
    ///   - sourceLocation: where to throw the error at
    ///   - instanceFactory: instance or closure producing the instance
    /// - Returns: instance that should be checked
    func checkForMemoryLeak<T: MemoryLeakCheckable>(sourceLocation: SourceLocation = .here,
                                                    _ instanceFactory: @autoclosure () -> T) -> T
    {
        let instance = instanceFactory()
        checks.append(.init(instance,
                            sourceLocation: sourceLocation))
        return instance
    }

    private struct MemoryLeakCheck {
        let sourceLocation: SourceLocation
        private weak var weakReference: MemoryLeakCheckable?
        var isLeaking: Bool { weakReference != nil }
        init(_ weakReference: MemoryLeakCheckable, sourceLocation: SourceLocation) {
            self.weakReference = weakReference
            self.sourceLocation = sourceLocation
        }
    }

    private var checks = [MemoryLeakCheck]()

    deinit {
        for check in checks {
            #expect(check.isLeaking == false, "Potential Memory Leak detected", sourceLocation: check.sourceLocation)
        }
    }
}
