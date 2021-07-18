import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(VolonbolonKitTests.allTests),
        testCase(URLBuilderTests.allTests),
    ]
}
#endif
