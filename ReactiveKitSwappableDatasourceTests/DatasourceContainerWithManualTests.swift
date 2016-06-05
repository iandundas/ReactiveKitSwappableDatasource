//
//  DatasourceContainerWithManualTests.swift
//  ReactiveKitSwappableDatasource
//
//  Created by Ian Dundas on 05/06/2016.
//  Copyright © 2016 IanDundas. All rights reserved.
//

import XCTest
import ReactiveKit
import Nimble

@testable import ReactiveKitSwappableDatasource

class DatasourceContainerWithManualTests: XCTestCase {

    let bag = DisposeBag()
    
    let emptyCollection = [Cat]()
    
    let nonemptyCollection = [
        Cat(value: ["name" : "Mr A"]),
        Cat(value: ["name" : "Mr B"]),
        Cat(value: ["name" : "Mr C"]),
    ]
    
    override func setUp() {
        super.setUp()

        
    }
    
    override func tearDown() {
        bag.dispose()
        super.tearDown()
    }

    func testInitialEventWhenStartingWithEmptyCollection(){
        
        let dsc = ManualDataSource<Cat>(items: []).encloseInContainer()
        
        var detectedInitialEvent = false
        dsc.collection.observeNext { changes in
            guard changes.collection.count == 0 else {fail("Should have been an empty initial collection");return}
            let noMutations = changes.isInitialEvent
            detectedInitialEvent = noMutations
            
        }.disposeIn(bag)
        
        expect(detectedInitialEvent).toEventually(beTrue())
    }
        
    func testInitialEventWhenStartingWithNonemptyCollection(){
        
        let dsc = ManualDataSource<Cat>(items: nonemptyCollection).encloseInContainer()
        
        var initialItems = [Cat]()
        var detectedInitialEvent = false
        dsc.collection.observeNext { changes in
            let noMutations = changes.isInitialEvent
            detectedInitialEvent = noMutations
            
            initialItems = changes.collection
        }.disposeIn(bag)
    
        expect(detectedInitialEvent).toEventually(beTrue())
        expect(initialItems).toEventually(equal(nonemptyCollection))
    }

    // Expecting a single corrected initial event, rather than any reported updates
    func testInitialEventWhenObservingAfterInsertingOnAnEmptyDataSource(){
        
        let datasource = ManualDataSource<Cat>(items: emptyCollection)
        let dsc = datasource.encloseInContainer()
        
        datasource.replaceItems(nonemptyCollection)
        
        var initialItems = [Cat]()
        var detectedInitialEvent = false
        dsc.collection.observeNext { changes in
            detectedInitialEvent = changes.isInitialEvent
            
            initialItems = changes.collection
        }.disposeIn(bag)
        
        expect(detectedInitialEvent).toEventually(beTrue())
        expect(initialItems).toEventually(equal(nonemptyCollection))
    }
}

