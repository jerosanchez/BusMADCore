import XCTest

import BusMADCoreTests

var tests = [XCTestCaseEntry]()
tests += LoadNearestStopsFromRemoteUseCaseTests.allTests()
XCTMain(tests)
