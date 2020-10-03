import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AccessTokenAPIEndToEndTests.allTests),
        testCase(NearestStopsAPIEndToEndTests.allTests),
    ]
}
#endif
