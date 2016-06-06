//
//  DataSource.swift
//  ReactiveKitSwappableDatasource
//
//  Created by Ian Dundas on 04/05/2016.
//  Copyright © 2016 IanDundas. All rights reserved.
//

import Foundation
import ReactiveKit

public protocol DataSourceType {
    associatedtype ItemType : Equatable

    // Access a (currently unsorted) array of items:
    func items() -> [ItemType]

    // Access a feed of mutation events:
    func mutations() -> Stream<CollectionChangeset<[ItemType]>>

    func encloseInContainer() -> DatasourceContainer<ItemType>
    
    func eraseType() -> AnyDataSource<ItemType>
}

public extension DataSourceType{
    public func encloseInContainer() -> DatasourceContainer<ItemType>{
        let wrapper = AnyDataSource(self)
        let datasourceContainer = DatasourceContainer(datasource: wrapper)
        return datasourceContainer
    }
    public func eraseType() -> AnyDataSource<ItemType>{
        return AnyDataSource(self)
    }
}

public class ManualDataSource<Item: Equatable>: DataSourceType {

    public func items() -> [Item] {
        return collection.filter{_ in true}
    }
    
    // only available publicly on ManualDataSource (because it's.. manual)
    public func replaceItems(items: [Item]) {
        collection.replace(items, performDiff: true)
    }

    public func mutations() -> Stream<CollectionChangeset<[Item]>>{
        return collection.filter {_ in true}
    }

    private let collection: CollectionProperty<Array<Item>>

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
