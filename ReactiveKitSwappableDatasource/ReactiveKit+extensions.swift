//
//  ReactiveKit+extensions.swift
//  ReactiveKitSwappableDatasource
//
//  Created by Ian Dundas on 05/06/2016.
//  Copyright © 2016 IanDundas. All rights reserved.
//

import ReactiveKit

public extension CollectionChangeset{
    var isInitialEvent: Bool{
        return inserts.count == 0 && updates.count == 0 && deletes.count == 0
    }
}
