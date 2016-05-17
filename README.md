# ReactiveKitSwappableDatasource

__Currently being developed - not ready for production use yet, documentation not ready yet.__

## Overview

A micro framework for when you need to swap a datasource on the fly. ReactiveKitSwappableDatasource provides an observable container which wraps any other observable container (e.g. Realm Result, a ReactiveKit `CollectionProperty`, etc) and provides Insert/Update/Delete notifications on the underlying dataset. When the datasource is swapped with another, it will provide on the same interface a diff of the changes.

The advantage of this is that the observer does not need to be aware that the underlying datasource has been changed. If an object is found in both the former and the latter datasource, the container will provide the updated index, rather than delete then insert the same object.

The Container exposes a ReactiveKit `CollectionProperty` as the interface for the above, this allows direct binding to a UITableView.

Currently implemented is a handle for a basic Array (`ManualDataSource`) and for a Realm Result set (`RealmDataSource`)

### Entities:

### The Data Source

- wraps some third party database provider (e.g. a basic array, a NSFetchedResultsController, a Realm [Results](https://realm.io/docs/swift/latest/api/Classes/Results.html) set) which actually fetches the data
- is in charge of sort order and any inherent filtering/querying - though this (in theory) shouldn't be changed
- handles auto-updating & produces change events, but otherwise can't be mutated externally.

### The Container

- contains the Data Source and allows that data source to be dynamically swapped with any other data source
- This calculates the diff necessary to produce a correct ChangeSet. So, externally a datasource replacement is no different to a regular mutation.

### Events:

- On first observe, observer should receive a single event: the current collection state. This is identifyable because insert, update and delete counts are all zero.


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

Tested with ReactiveKit 2.0.0beta5 (currently)
## Installation

ReactiveKitSwappableDatasource is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "ReactiveKitSwappableDatasource"
```

## Author

Ian Dundas, contact@iandundas.co.uk

## License

ReactiveKitSwappableDatasource is available under the MIT license. See the LICENSE file for more info.
