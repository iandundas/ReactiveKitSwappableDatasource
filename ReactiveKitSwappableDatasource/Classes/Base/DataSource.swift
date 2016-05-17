//
//  DataSource.swift
//  ReactiveKitSwappableDatasource
//
//  Created by Ian Dundas on 04/05/2016.
//  Copyright © 2016 IanDundas. All rights reserved.
//

import UIKit
import ReactiveUIKit
import ReactiveKit

public protocol DataSourceType {
    associatedtype ItemType : Equatable

    // Access a (currently unsorted) array of items:
    func items() -> [ItemType]

    // Access a feed of mutation events:
    func mutations() -> Stream<CollectionChangeset<[ItemType]>>
}

public class ManualDataSource<Item: Equatable>: DataSourceType {

    public func items() -> [Item] {
        return collection.filter{_ in true}
    }

    public func mutations() -> Stream<CollectionChangeset<[Item]>>{
        return collection.filter {_ in true}
    }

    private let collection: CollectionProperty<Array<Item>>
    private let disposeBag = DisposeBag()

    /* TODO: currently only takes Array CollectionType
        init<C: CollectionType where C.Generator.Element == Element>(collection: C){
            self.collection = CollectionProperty<C>(collection)
        }
     */

    public init(items: [Item]){
        self.collection = CollectionProperty(items)
    }
}

// TODO: FetchedResultsControllerDataSource
