import XCTest

import BusMADCoreTests

var tests = [XCTestCaseEntry]()
tests += LoadNearestStopsFromRemoteUseCaseTests.allTests()
tests += URLSessionHTTPClientTests.allTests()
tests += LoadAccessTokenFromRemoteUseCase.allTests()
XCTMain(tests)
