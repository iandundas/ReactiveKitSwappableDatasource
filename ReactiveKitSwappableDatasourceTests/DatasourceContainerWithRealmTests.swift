//
//  DatasourceContainerTests.swift
//  ReactiveKitSwappableDatasource
//
//  Created by Ian Dundas on 15/05/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
import ReactiveKit
import Nimble
import RealmSwift

@testable import ReactiveKitSwappableDatasource

class DatasourceContainerWithRealmTests: XCTestCase {
    
    var emptyRealm: Realm!
    var nonEmptyRealm: Realm!
    
    var disposeBag = DisposeBag()
    
    var container: DatasourceContainer<Cat>!
    
    override func setUp() {
        super.setUp()
        
        nonEmptyRealm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: NSUUID().UUIDString))
        emptyRealm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: NSUUID().UUIDString))
        
        try! nonEmptyRealm.write {
            nonEmptyRealm.add(Cat(value: ["name" : "Cat A", "miceEaten": 0]))
            nonEmptyRealm.add(Cat(value: ["name" : "Cat D", "miceEaten": 3]))
            nonEmptyRealm.add(Cat(value: ["name" : "Cat M", "miceEaten": 5]))
            nonEmptyRealm.add(Cat(value: ["name" : "Cat Z", "miceEaten": 100]))
        }
    }
    
    override func tearDown() {
        disposeBag.dispose()
        
        emptyRealm = nil
        nonEmptyRealm = nil
        
        container = nil
        
        super.tearDown()
    }
    
    func testBasicInsertBinding() {
        var insertions = -1
        container = RealmDataSource<Cat>(items:emptyRealm.objects(Cat)).encloseInContainer()
        
        container.collection.observeNext { changeset in
            insertions = changeset.inserts.count
            }.disposeIn(disposeBag)
        
        try! emptyRealm.write {
            emptyRealm.add(Cat(value: ["name" : "Mr Catzz"]))
            emptyRealm.add(Cat(value: ["name" : "Mr Lolz"]))
        }
        
        expect(insertions).toEventually(equal(2), timeout: 3)
    }
    
    
    /* Test it sends a single event containing 0 insert, 0 update, 0 delete when initially an empty container */
    func testInitialSubscriptionSendsASingleCurrentStateEventWhenInitially(){
        
        var observeCallCount = 0
        var inserted = false
        var updated = false
        var deleted = false
        
        container = RealmDataSource<Cat>(items:emptyRealm.objects(Cat)).encloseInContainer()
        
        container.collection
            .distinct {!($0.collection.elementsEqual($1.collection))} // filter double initial event
            .observeNext { changes in
                observeCallCount += 1
                
                inserted = inserted || changes.inserts.count > 0
                updated = updated || changes.updates.count > 0
                deleted = deleted || changes.deletes.count > 0
                
            }.disposeIn(disposeBag)
        
        expect(observeCallCount).toEventually(equal(1), timeout: 1)
        expect(inserted).toEventually(equal(false), timeout: 1)
        expect(updated).toEventually(equal(false), timeout: 1)
        expect(deleted).toEventually(equal(false), timeout: 1)
    }
    
    
    /* Test it sends an event containing 0 insert, 0 update, 0 delete when initially non-empty container */
    func testInitialSubscriptionSendsASingleCurrentStateEventWhenInitiallyNonEmpty(){
        
        container = RealmDataSource<Cat>(items:nonEmptyRealm.objects(Cat)).encloseInContainer()
        
        var observeCallCount = 0
        var inserted = false
        var updated = false
        var deleted = false
        
        container.collection
            .distinct {!($0.collection.elementsEqual($1.collection))} // filter double initial event
            .observeNext { changes in
                observeCallCount += 1
                
                inserted = inserted || changes.inserts.count > 0
                updated = updated || changes.updates.count > 0
                deleted = deleted || changes.deletes.count > 0
                
            }.disposeIn(disposeBag)
        
        expect(observeCallCount).toEventually(equal(1), timeout: 1)
        expect(inserted).toEventually(equal(false), timeout: 1)
        expect(updated).toEventually(equal(false), timeout: 1)
        expect(deleted).toEventually(equal(false), timeout: 1)
    }
    
    func testReplacingEmptyDatasourceWithAnotherEmptyDatasourceProducedNoUpdateSignals(){
        
        let emptyRealmDataSource = AnyDataSource(RealmDataSource<Cat>(items:emptyRealm.objects(Cat)))
        let emptyManualDataSource = AnyDataSource(ManualDataSource(items: [Cat]()))
        
        var observeCallCount = 0
        
        container = DatasourceContainer(datasource: emptyRealmDataSource)
        container.collection
            .distinct {!($0.collection.elementsEqual($1.collection))} // filter double initial event
            .observeNext { changes in
                observeCallCount += 1
            }.disposeIn(disposeBag)
        
        container.datasource = emptyManualDataSource
        
        // expect only to have the initial insert changeset (when first binded) and not the subsequent insert.
        expect(observeCallCount).toEventually(equal(1), timeout: 3)
    }
    
    func testReplacingEmptyDatasourceWithAnotherEmptyDatasourceAndAddingItemsToInitialDataSourceProducesNoUpdateSignals(){
        
        let emptyRealmDataSource = AnyDataSource(RealmDataSource<Cat>(items:emptyRealm.objects(Cat)))
        let emptyManualDataSource = AnyDataSource(ManualDataSource(items: [Cat]()))
        
        var observeCallCount = 0
        
        container = DatasourceContainer(datasource: emptyRealmDataSource)
        container.collection
            .distinct {!($0.collection.elementsEqual($1.collection))} // filter double initial event
            .observeNext { changes in
                observeCallCount += 1
            }.disposeIn(disposeBag)
        
        container.datasource = emptyManualDataSource
        
        try! emptyRealm.write {
            emptyRealm.add(Cat(value: ["name" : "Mr Catzz"]))
        }
        
        // expect only to have the initial insert changeset (when first binded) and not the subsequent insert.
        expect(observeCallCount).toEventually(equal(1), timeout: 3)
        
    }
    
    func testReplacingNonEmptyDatasourceWithAnEmptyDatasourceProducesCorrectDeleteSignals(){
        
        // contains 4 items
        let nonEmptyRealmDataSource = AnyDataSource(RealmDataSource<Cat>(items:nonEmptyRealm.objects(Cat)))
        let emptyManualDataSource = AnyDataSource(ManualDataSource(items: [Cat]()))
        
        var observeCallCount = 0
        var deleteCount = 0
        
        container = DatasourceContainer(datasource: nonEmptyRealmDataSource)
        container.collection
            .distinct {!($0.collection.elementsEqual($1.collection))} // filter double initial event
            .observeNext { changes in
                observeCallCount += 1
                deleteCount += changes.deletes.count
                
            }.disposeIn(disposeBag)
        
        container.datasource = emptyManualDataSource
        
        // expect only to have the initial insert changeset (when first binded) and not the subsequent insert.
        expect(observeCallCount).toEventually(equal(2), timeout: 3)
        expect(deleteCount).toEventually(equal(4), timeout: 3)
        
    }
    
    func testReplacingEmptyDatasourceWithANonEmptyDatasourceProducesCorrectInsertSignals(){
        
        // contains 4 items
        let emptyManualDataSource = AnyDataSource(ManualDataSource(items: [Cat]()))
        let nonEmptyRealmDataSource = AnyDataSource(RealmDataSource<Cat>(items:nonEmptyRealm.objects(Cat)))
        
        var observeCallCount = 0
        var deleteCount = 0
        
        container = DatasourceContainer(datasource: nonEmptyRealmDataSource)
        container.collection
            .distinct {!($0.collection.elementsEqual($1.collection))} // filter double initial event
            .observeNext { changes in
                observeCallCount += 1
                deleteCount += changes.deletes.count
                
            }.disposeIn(disposeBag)
        
        container.datasource = emptyManualDataSource
        
        // expect only to have the initial insert changeset (when first binded) and not the subsequent insert.
        expect(observeCallCount).toEventually(equal(2), timeout: 3)
        expect(deleteCount).toEventually(equal(4), timeout: 3)
        
    }
    
    func testReplacingNonEmptyDatasourceWithAnotherNonEmptyDatasourceContainingSomeDifferentItemsProducesCorrectMutationSignals(){
        
        let dataSourceA = AnyDataSource(RealmDataSource<Cat>(items:nonEmptyRealm.objects(Cat).filter("miceEaten < 5"))) // 2 items (0, 3)
        let dataSourceB = AnyDataSource(RealmDataSource<Cat>(items:nonEmptyRealm.objects(Cat).filter("miceEaten > 0"))) // 3 items (   3, 5, 100)
        
        var observeCallCount = 0
        var insertCount = 0
        var updateCount = 0
        var deleteCount = 0
        
        container = DatasourceContainer(datasource: dataSourceA)
        container.collection
            .distinct {!($0.collection.elementsEqual($1.collection))} // filter double initial event
            .observeNext { changes in
                observeCallCount += 1
                insertCount += changes.inserts.count
                updateCount += changes.updates.count
                deleteCount += changes.deletes.count
                
            }.disposeIn(disposeBag)
        
        container.datasource = dataSourceB
        
        // expect only to have the initial insert changeset (when first binded) and not the subsequent insert.
        expect(observeCallCount).toEventually(equal(2), timeout: 3)
        expect(insertCount).toEventually(equal(2), timeout: 3)
        expect(updateCount).toEventually(equal(0), timeout: 3)
        expect(deleteCount).toEventually(equal(1), timeout: 3)
    }
}
