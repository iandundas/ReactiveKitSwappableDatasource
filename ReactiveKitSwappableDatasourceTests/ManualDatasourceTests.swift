//
//  ManualDatasource.swift
//  ReactiveKitSwappableDatasource
//
//  Created by Ian Dundas on 05/06/2016.
//  Copyright © 2016 IanDundas. All rights reserved.
//

import XCTest
import ReactiveKit
import Nimble

@testable import ReactiveKitSwappableDatasource

/* 
 Rules: 
  - Observers should receive the current contents of the internal container in an "initial" notification.
  - Observers should receive correct diff notifications when things change
 */

class ManualDatasourceTests: XCTestCase {

    var datasource: ManualDataSource<Cat>!
    
    let catA = Cat(value: ["name" : "Mr A"])
    let catB = Cat(value: ["name" : "Mr B"])
    let catC = Cat(value: ["name" : "Mr C"])
    
    let bag = DisposeBag()
    
    override func setUp() {
        super.setUp()
        datasource = ManualDataSource<Cat>(items: [catA, catB])
    }
    
    override func tearDown() {
        bag.dispose()
        datasource = nil
        super.tearDown()
    }
    
    func testStartingState() {
        expect(self.datasource.items().count) == 2
    }
    
    func testInitialNotificationIsReceived(){
        var (inserts, deletes, updates) = (-1,-1,-1)
        
        datasource.mutations().observeNext { changes in
            // We identify initial notification as being when inserts == 0, deletes == 0, updates == 0
            inserts = changes.inserts.count
            deletes = changes.deletes.count
            updates = changes.updates.count
        }.disposeIn(bag)
        
        expect(inserts).toEventually(equal(0))
        expect(deletes).toEventually(equal(0))
        expect(updates).toEventually(equal(0))
    }
    
    func testInsertEventIsReceived(){
        var (inserts, deletes, updates) = (-1,-1,-1)
        
        datasource.mutations().observeNext { changes in
            inserts = changes.inserts.count
            deletes = changes.deletes.count
            updates = changes.updates.count
        }.disposeIn(bag)
        
        datasource.replaceItems([catA, catB, catC])

        expect(inserts).toEventually(equal(1))
        expect(deletes).toEventually(equal(0))
        expect(updates).toEventually(equal(0))
    }
    
    func testDeleteEventIsReceived(){
        var (inserts, deletes, updates) = (-1,-1,-1)
        
        datasource.mutations().observeNext { changes in
            inserts = changes.inserts.count
            deletes = changes.deletes.count
            updates = changes.updates.count
        }.disposeIn(bag)
        
        datasource.replaceItems([])
        
        expect(inserts).toEventually(equal(0))
        expect(deletes).toEventually(equal(2)) // see ReactiveKitBugs/DemonstrateFilterIssueTests
        expect(updates).toEventually(equal(0))
    }

}
