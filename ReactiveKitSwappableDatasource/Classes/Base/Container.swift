//
//  Container.swift
//  ReactiveKitSwappableDatasource
//
//  Created by Ian Dundas on 04/05/2016.
//  Copyright © 2016 IanDundas. All rights reserved.
//

import UIKit
import ReactiveKit
import RealmSwift

public class DatasourceContainer<ItemType: Equatable>{

    // Holds onto any subscriptions made. Is replaced when adding a new data source.
    private var disposable = DisposeBag()

    public var datasource: AnyDataSource<ItemType>{
        willSet{
            // we're getting rid of the current data source.
            // First we need to drop any observations on it:
            self.disposable.dispose()
        }
        didSet{

            // Now the data source is in place, we need to replace the items in our
            // collection with the new list of items in the new data source. Some of these
            // may be the same, so we want to perform a diff to identify any items that don't
            // need to be removed (or just need their list order to be updated)
            collection.replace(datasource.items(), performDiff: true)
            setupDataSourceBinding()
        }
    }

    // This is the external, observable representation of the internal datasource.
    // When the data source mutates (or even if it is swapped), this will send valid ChangeSets
    public let collection: CollectionProperty<[ItemType]>

    public required init(datasource: AnyDataSource<ItemType>){ // , rebinding: RebindingType){

        self.datasource = datasource

        let existingItems = datasource.items()

        collection = CollectionProperty(existingItems)

        setupDataSourceBinding()
    }

    private func setupDataSourceBinding(){
        datasource.mutations()
            .bindTo(collection)
            .disposeIn(disposable)
    }

    deinit{
        disposable.dispose()
    }
}
