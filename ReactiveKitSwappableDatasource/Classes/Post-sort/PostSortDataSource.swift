//
//  PostSortDataSource.swift
//  ReactiveKitSwappableDatasource
//
//  Created by Ian Dundas on 05/06/2016.
//  Copyright © 2016 IanDundas. All rights reserved.
//

import Foundation
import ReactiveKit


///* Wraps an existing DataSource allowing a sort order to be applied to it */
//public class PostSortDataSource<Item: Equatable>: DataSourceType {
//    
//    public func items() -> [Item] {
//        return collection.sort(isOrderedBefore)
//    }
//    
//    public func mutations() -> Stream<CollectionChangeset<[Item]>>{
//        return collection.sort(isOrderedBefore)
//    }
//
//    private let internalDataSource: AnyDataSource<Item>
//    private let collection: CollectionProperty<Array<Item>>
//    private let isOrderedBefore: (Item, Item) -> Bool
//    
//    public init(datasource: AnyDataSource<Item>, isOrderedBefore: (Item, Item)->Bool){
//        self.internalDataSource = datasource
//        self.isOrderedBefore = isOrderedBefore
//        
//        collection = CollectionProperty<[Item]>(datasource.items())
//        
//        internalDataSource.mutations().bindTo(collection)
//    }
//}
