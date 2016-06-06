//
//  RealmDatasourceTests.swift
//  ReactiveKitSwappableDatasource
//
//  Created by Ian Dundas on 05/06/2016.
//  Copyright © 2016 IanDundas. All rights reserved.
//

import UIKit
import XCTest
import RealmSwift
import ReactiveKit
import Nimble

@testable import ReactiveKitSwappableDatasource

class RealmDatasourceTests: XCTestCase {

    var realm: Realm!
    var disposeBag: DisposeBag!
    
    var datasource: RealmDataSource<Cat>!
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        
        realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: NSUUID().UUIDString))
        
        datasource = RealmDataSource<Cat>(items: realm.objects(Cat))
    }
    
    override func tearDown() {
        disposeBag.dispose()
        
        realm = nil
        disposeBag = nil
        datasource = nil
        
        super.tearDown()
    }
    
//    func testStartingConditions() {
//        
//        expect(self.realm.objects(Cat).count).to(equal(0))
//        expect(self.datasource.items().count).to(equal(0))
//    }
//    
//    func testInsertMutationWorking(){
//        var insertions = -1
//        
//        datasource.mutations().observeNext({ changeset in
//            insertions = changeset.inserts.count
//        }).disposeIn(disposeBag)
//        
//        try! realm.write {
//            realm.add(Cat(value: ["name" : "Mr Catzz"]))
//            realm.add(Cat(value: ["name" : "Mr Lolz"]))
//        }
//        
//        expect(insertions).toEventually(equal(2), timeout: 3)
//    }
}
