//
//  RealmDataSource.swift
//  ReactiveKitSwappableDatasource
//
//  Created by Ian Dundas on 04/05/2016.
//  Copyright © 2016 IanDundas. All rights reserved.
//

import UIKit
import ReactiveKit
import RealmSwift

public class RealmDataSource<Item: Object where Item: Equatable>: DataSourceType {

    /* NB: It's important that the Realm collection is already sorted before it's passed to the RealmDataSource:

     > "Note that the order of Results is only guaranteed to stay consistent when the
     > query is sorted. For performance reasons, insertion order is not guaranteed to be preserved.
     > If you need to maintain order of insertion, some solutions are proposed here.
     */

    public func items() -> [Item] {
        return self.collection.filter {_ in return true}
    }


    // TODO this doesn't need to be retained here, right? If experiencing bugs, this could be the issue.
    public func mutations() -> Stream<CollectionChangeset<[Item]>> {
        return Stream<CollectionChangeset<[Item]>> { observer in

            let notificationToken = self.collection.addNotificationBlock {(changes: RealmCollectionChange) in

                switch changes {

                case .Initial(let initialCollection):

//                    let changeSet = CollectionChangeset.initial(initialCollection.filter{_ in return true})
//                    observer.next(changeSet)
                    break

                case .Update(let updatedCollection, let deletions, let insertions, let modifications):

                    let changeSet = CollectionChangeset(collection: updatedCollection.filter{_ in return true}, inserts: insertions, deletes: deletions, updates: modifications)
                    observer.next(changeSet)

                case .Error(let error):

                    // An error occurred while opening the Realm file on the background worker thread
                    fatalError("\(error)")
                    break
                }
            }

            return BlockDisposable{
                notificationToken.stop()
            }
        }
    }

    private let collection: AnyRealmCollection<Item>

    private let disposeBag = DisposeBag()

    public init<C: RealmCollectionType where C.Element == Item>(collection: C) {
        self.collection = AnyRealmCollection(collection)
    }
}
