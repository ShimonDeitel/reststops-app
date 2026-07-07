import XCTest
@testable import reststops

@MainActor
final class RestStopStoreTests: XCTestCase {
    var store: Store!

    override func setUp() async throws {
        store = Store()
    }

    func testSeedDataLoadsBelowFreeLimit() {
        XCTAssertLessThan(store.items.count, Store.freeLimit)
    }

    func testCanAddMoreWhenUnderLimit() {
        XCTAssertTrue(store.canAddMore)
    }

    func testAddIncreasesCount() {
        let before = store.items.count
        store.add(RestStop(stopName: "Sample Stopname 10", highway: "Sample Highway 10", rating: 12, hasFood: false, hasFuel: false, hasRestrooms: false, notes: "Sample Notes 10"))
        XCTAssertEqual(store.items.count, before + 1)
    }

    func testAddBeyondFreeLimitIsBlocked() {
        while store.canAddMore {
            store.add(RestStop(stopName: "Sample Stopname 2", highway: "Sample Highway 2", rating: 4, hasFood: false, hasFuel: false, hasRestrooms: false, notes: "Sample Notes 2"))
        }
        let countAtLimit = store.items.count
        store.add(RestStop(stopName: "Sample Stopname 3", highway: "Sample Highway 3", rating: 5, hasFood: true, hasFuel: true, hasRestrooms: true, notes: "Sample Notes 3"))
        XCTAssertEqual(store.items.count, countAtLimit)
    }

    func testProUnlockBypassesLimit() {
        while store.canAddMore {
            store.add(RestStop(stopName: "Sample Stopname 2", highway: "Sample Highway 2", rating: 4, hasFood: false, hasFuel: false, hasRestrooms: false, notes: "Sample Notes 2"))
        }
        store.isProUnlocked = true
        XCTAssertTrue(store.canAddMore)
    }

    func testDeleteRemovesItem() {
        let item = store.items[0]
        store.delete(item)
        XCTAssertFalse(store.items.contains(item))
    }

    func testUpdateModifiesItem() {
        var item = store.items[0]
        item.stopName = "Sample Stopname 6"
        store.update(item)
        XCTAssertEqual(store.items.first(where: { $0.id == item.id })?.stopName, item.stopName)
    }

    func testDeleteAtOffsetsRemovesCorrectItem() {
        let target = store.items[0]
        store.delete(at: IndexSet(integer: 0))
        XCTAssertFalse(store.items.contains(target))
    }
}
