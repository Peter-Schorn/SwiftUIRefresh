SwiftUI-Refresh
===============

Maintainer: [@ldiqual](https://github.com/ldiqual)

Native Pull To Refresh in SwiftUI.

What is this?
-------------

SwiftUI-Refresh adds a native `UIRefreshControl` to a SwiftUI List view. It does this by introspecting the view hierarchy to find the relevant `UITableView`, then adding a refresh control to it.

Demo
----

<image src="docs/demo.gif" width="40%">

Install
-------

### SwiftPM

```
https://github.com/timbersoftware/SwiftUIRefresh.git
```

### Cocoapods

```
pod "SwiftUIRefresh"
```

Usage
-----

```
import SwiftUI
import SwiftUIRefresh

struct ContentView: View {
    
    @State private var isRefreshing = false
    var body: some View {
        List {
            Text("Item 1")
            Text("Item 2")
        }
        .pullToRefresh(isRefreshing: $isRefreshing) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.isRefreshing = false
            }
        }
    }
}
```

