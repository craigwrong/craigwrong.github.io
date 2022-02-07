let postManualPayToTaprootDescriptors = Post("/post/2022-02-07-manual-pay-to-taproot-descriptors", "Manual Pay-To-Taproot Descriptors", "2022-02-07T12:00:00Z", .bitcoinCore) { """

[output descriptor](https://github.com/bitcoin/bips/blob/master/bip-0386.mediawiki)
[coming in version 23](https://github.com/bitcoin/bitcoin/pull/22364)

![Discussions App](DiscussionsApp.jpg)


```swift
import Foundation

struct NetworkSettings {

    enum Environments {
        static let production = NetworkSettings(
            discussionsURL: URL(string: "https://data.diegolavalle.com/discussion/6.json")!
        )

        static let testing = NetworkSettings(
            discussionsURL: URL(string: "http://localhost:8080/discussion/6.json")!
        )

        static let local = NetworkSettings(
            discussionsURL: Bundle.main.url(forResource: "discussion", withExtension: "json5")!
        )
    }

    let discussionsURL: URL
}
```


""" }
