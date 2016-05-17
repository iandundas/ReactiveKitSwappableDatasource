# ReactiveKitSwappableDatasource

__Currently being developed - not ready for production use yet, documentation not ready yet.__

## Overview

An observable container that simplifies the changing of an underlying observable data source (e.g. from a Realm query resultset to an array), providing a diff and a common interface.

### The Data Source

	- wraps some third party database (e.g. array, FRC, Realm Results set) which actually fetches the data
  - is in charge of sort order and any inherent filtering/querying - though this (in theory) shouldn't be changed
	- handles auto-updating & produces change events, but otherwise can't be mutated externally.

### The Container

	- contains the Data Source and allows that data source to be dynamically swapped with any other data source
	- This calculates the diff necessary to produce a correct ChangeSet. So, externally a datasource replacement is no different to a regular mutation.

### Events:
	- First observe, should receive a single event: the current collection state. This is identifyable because insert, update and delete counts are all zero.


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
