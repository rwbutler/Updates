import XCTest
@testable import Updates

class VersionComparisonTests: XCTestCase {

    // MARK: - Major Numbers
    
    func testMajorComparatorEqualityWhereMajorNumbersEqual() {
        let result = Updates.compareVersions(lhs: "1", rhs: "1", comparator: .major)
        XCTAssertEqual(result, ComparisonResult.orderedSame)
    }
    
    func testMajorComparatorEqualityWhereMajorNumbersAscending() {
        let result = Updates.compareVersions(lhs: "1", rhs: "2", comparator: .major)
        XCTAssertEqual(result, ComparisonResult.orderedAscending)
    }
    
    func testMajorComparatorEqualityWhereMajorNumbersDescending() {
        let result = Updates.compareVersions(lhs: "2", rhs: "1", comparator: .major)
        XCTAssertEqual(result, ComparisonResult.orderedDescending)
    }
    
    func testMajorComparatorEqualityWhereMinorNumbersEqual() {
        let result = Updates.compareVersions(lhs: "1.2", rhs: "1.2", comparator: .major)
        XCTAssertEqual(result, ComparisonResult.orderedSame)
    }
    
    func testMajorComparatorEqualityWhereMinorNumbersAscending() {
        let result = Updates.compareVersions(lhs: "1.2", rhs: "1.3", comparator: .major)
        XCTAssertEqual(result, ComparisonResult.orderedSame)
    }
    
    func testMajorComparatorEqualityWhereMinorNumbersDescending() {
        let result = Updates.compareVersions(lhs: "1.2", rhs: "1.1", comparator: .major)
        XCTAssertEqual(result, ComparisonResult.orderedSame)
    }
    
    // MARK: - Minor Numbers
    
    func testMinorComparatorEqualityWhereMinorNumbersEqual() {
        let result = Updates.compareVersions(lhs: "1.2", rhs: "1.2", comparator: .minor)
        XCTAssertEqual(result, ComparisonResult.orderedSame)
    }
    
    func testMinorComparatorEqualityWhereMinorNumbersAscending() {
        let result = Updates.compareVersions(lhs: "1.2", rhs: "1.3", comparator: .minor)
        XCTAssertEqual(result, ComparisonResult.orderedAscending)
    }
    
    func testMinorComparatorEqualityWhereMinorNumbersDescending() {
        let result = Updates.compareVersions(lhs: "1.2", rhs: "1.1", comparator: .minor)
        XCTAssertEqual(result, ComparisonResult.orderedDescending)
    }
    
    func testMinorComparatorEqualityWherePatchNumbersEqual() {
        let result = Updates.compareVersions(lhs: "1.2.3", rhs: "1.2.3", comparator: .minor)
        XCTAssertEqual(result, ComparisonResult.orderedSame)
    }
    
    func testMinorComparatorEqualityWherePatchNumbersAscending() {
        let result = Updates.compareVersions(lhs: "1.2.3", rhs: "1.2.4", comparator: .minor)
        XCTAssertEqual(result, ComparisonResult.orderedSame)
    }
    
    func testMinorComparatorEqualityWherePatchNumbersDescending() {
        let result = Updates.compareVersions(lhs: "1.2.3", rhs: "1.2.2", comparator: .minor)
        XCTAssertEqual(result, ComparisonResult.orderedSame)
    }
    
    // MARK: - Patch Numbers
    
    func testPatchComparatorEqualityWherePatchNumbersEqual() {
        let result = Updates.compareVersions(lhs: "1.2.3", rhs: "1.2.3", comparator: .patch)
        XCTAssertEqual(result, ComparisonResult.orderedSame)
    }
    
    func testPatchComparatorEqualityWherePatchNumbersAscending() {
        let result = Updates.compareVersions(lhs: "1.2.2", rhs: "1.2.3", comparator: .patch)
        XCTAssertEqual(result, ComparisonResult.orderedAscending)
    }
    
    func testPatchComparatorEqualityWherePatchNumbersDescending() {
        let result = Updates.compareVersions(lhs: "1.2.3", rhs: "1.2.2", comparator: .patch)
        XCTAssertEqual(result, ComparisonResult.orderedDescending)
    }
    
    func testPatchComparatorEqualityWhereAdditionalComponentsEqual() {
        let result = Updates.compareVersions(lhs: "1.2.3.4", rhs: "1.2.3.4", comparator: .patch)
        XCTAssertEqual(result, ComparisonResult.orderedSame)
    }
    
    func testPatchComparatorEqualityWhereAdditionalComponentsAscending() {
        let result = Updates.compareVersions(lhs: "1.2.3.4", rhs: "1.2.3.5", comparator: .patch)
        XCTAssertEqual(result, ComparisonResult.orderedSame)
    }
    
    func testPatchComparatorEqualityWhereAdditionalComponentsDescending() {
        let result = Updates.compareVersions(lhs: "1.2.3.5", rhs: "1.2.3.4", comparator: .patch)
        XCTAssertEqual(result, ComparisonResult.orderedSame)
    }
    
    // Note: Last component will be treated as build number.
    func testBuildComparatorEqualityWhereComponentsEqualSpecifiedAsAdditionalComponent() {
        let result = Updates.compareVersions(lhs: "1.2.3.4", rhs: "1.2.3.4", comparator: .build)
        XCTAssertEqual(result, ComparisonResult.orderedSame)
    }
    
    func testBuildComparatorEqualityWhereComponentsAscendingSpecifiedAsAdditionalComponent() {
        let result = Updates.compareVersions(lhs: "1.2.3.4", rhs: "1.2.3.5", comparator: .build)
        XCTAssertEqual(result, ComparisonResult.orderedAscending)
    }
    
    func testBuildComparatorEqualityWhereComponentsDescendingSpecifiedAsAdditionalComponent() {
        let result = Updates.compareVersions(lhs: "1.2.3.5", rhs: "1.2.3.4", comparator: .build)
        XCTAssertEqual(result, ComparisonResult.orderedDescending)
    }
    
    func testBuildComparatorEqualityWhereComponentsEqual() {
        let result = Updates.compareVersions(
            lhs: "1.2.3",
            lhsBuildNumber: "4",
            rhs: "1.2.3",
            rhsBuildNumber: "4",
            comparator: .build
        )
        XCTAssertEqual(result, ComparisonResult.orderedSame)
    }
    
    func testBuildComparatorEqualityWhereComponentsAscending() {
        let result = Updates.compareVersions(
            lhs: "1.2.3",
            lhsBuildNumber: "4",
            rhs: "1.2.3",
            rhsBuildNumber: "5",
            comparator: .build
        )
        XCTAssertEqual(result, ComparisonResult.orderedAscending)
    }
    
    func testBuildComparatorEqualityWhereComponentsDescending() {
        let result = Updates.compareVersions(
            lhs: "1.2.3",
            lhsBuildNumber: "5",
            rhs: "1.2.3",
            rhsBuildNumber: "4",
            comparator: .build
        )
        XCTAssertEqual(result, ComparisonResult.orderedDescending)
    }

}
