import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(LoadNearestStopsFromRemoteUseCaseTests.allTests),
        testCase(URLSessionHTTPClientTests.allTests),
        testCase(LoadAccessTokenFromRemoteUseCase.allTests),
    ]
}
#endif
