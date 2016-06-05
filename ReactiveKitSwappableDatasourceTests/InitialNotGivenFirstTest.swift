//
//  InitialNotGivenFirstTest.swift
//  ReactiveKitSwappableDatasource
//
//  Created by Ian Dundas on 05/06/2016.
//  Copyright © 2016 IanDundas. All rights reserved.
//

import UIKit
import XCTest
import RealmSwift
import Nimble

@testable import ReactiveKitSwappableDatasource

class InitialNotGivenFirstTest: XCTestCase {
    
    var realm: Realm!
    var token: NotificationToken?
    
    override func setUp() {
        super.setUp()
        
        realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: NSUUID().UUIDString))
    }
    
    override func tearDown() {
        token?.stop()
        token = nil
        
        realm = nil
        super.tearDown()
    }
    
    func testStartingConditions() {
        expect(self.realm.objects(Cat).count).to(equal(0))
    }
    
    func testInitialNotificationReceivedAfterInsert(){
        var insertions = 0
        
        token = realm.objects(Cat).addNotificationBlock { (changeSet:RealmCollectionChange) in
            switch changeSet {
            case .Initial(let dogs):
                insertions += dogs.count
            case .Update(_):
                fail("Update should never be called in this example")
            case .Error:
                fail("Error should never be called")
            }
        }
        
        try! realm.write {
            realm.add(Cat(value: ["name" : "Mr Catzz"]))
            realm.add(Cat(value: ["name" : "Mr Lolz"]))
        }
        
        expect(insertions).toEventually(equal(2), timeout: 3)
    }
}
