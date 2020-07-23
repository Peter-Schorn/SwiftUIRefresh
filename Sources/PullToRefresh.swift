import SwiftUI
import Introspect

public enum ViewType {
    case scrollView, list
}

private struct PullToRefresh: UIViewRepresentable {
    
    @Binding var isRefreshing: Bool
    let onRefresh: () -> Void
    let viewType: ViewType
    
    public init(
        isRefreshing: Binding<Bool>,
        viewType: ViewType,
        onRefresh: @escaping () -> Void
    ) {
        self._isRefreshing = isRefreshing
        self.viewType = viewType
        self.onRefresh = onRefresh
    }
    
    public class Coordinator {
        let onRefresh: () -> Void
        let isRefreshing: Binding<Bool>
        
        init(
            onRefresh: @escaping () -> Void,
            isRefreshing: Binding<Bool>
        ) {
            self.onRefresh = onRefresh
            self.isRefreshing = isRefreshing
        }
        
        @objc
        func onValueChanged() {
            isRefreshing.wrappedValue = true
            onRefresh()
        }
    }
    
    public func makeUIView(context: UIViewRepresentableContext<PullToRefresh>) -> UIView {
        let view = UIView(frame: .zero)
        view.isHidden = true
        view.isUserInteractionEnabled = false
        return view
    }
    
    // MARK: - Table View -
    private func tableView(entry: UIView) -> UITableView? {
        
        // Search in ancestors
        if let tableView = Introspect.findAncestor(
            ofType: UITableView.self, from: entry
        ) {
            return tableView
        }

        guard let viewHost = Introspect.findViewHost(from: entry) else {
            return nil
        }

        // Search in siblings
        return Introspect.previousSibling(
            containing: UITableView.self, from: viewHost
        )
    }

    
    // MARK: - Scroll View -
    private func scrollView(entry: UIView) -> UIScrollView? {
        
        if let scrollView = Introspect.findAncestor(
            ofType: UIScrollView.self, from: entry
        ) {
        
            return scrollView
        }
        
        guard let viewHost = Introspect.findViewHost(from: entry) else {
            return nil
        }
        
        return Introspect.previousSibling(
            containing: UIScrollView.self, from: viewHost
        )
        
    }

    
    // MARK: - Update UI View
    public func updateUIView(
        _ uiView: UIView,
        context: UIViewRepresentableContext<PullToRefresh>
    ) {
        
        DispatchQueue.main.async  {
            
            guard let scrollableView = self.scrollView(entry: uiView) else {
                return
            }
            
            // if the refresh control has already been attached,
            // then update it based on the `isRefreshing` binding
            if let refreshControl = scrollableView.refreshControl {
                if self.isRefreshing {
                    refreshControl.beginRefreshing()
                } else {
                    refreshControl.endRefreshing()
                }
                return  // note the return
            }
            
            // else, create a new refresh control
            let refreshControl = UIRefreshControl()
            
            // add a delegate to watch for when the user scrolls
            refreshControl.addTarget(
                context.coordinator,
                action: #selector(Coordinator.onValueChanged),
                for: .valueChanged
            )
            
            // attach the refresh control to the scrollable view
            scrollableView.refreshControl = refreshControl
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(
            onRefresh: onRefresh, isRefreshing: $isRefreshing
        )
    }
}

extension View {
    
    /**
    Attaches a refresh control to the view.
    
    - Parameters:
      - isRefreshing: True if view is currently refreshing,
            else false.
      - viewType: Either `.scrollView` or `.list`.
      - onRefresh: A closure that gets called
            when the user pulls down to refresh the view.
            When this happens, `isRefreshing` gets set to true.
            You must set it back to false when new data
            has finished loading, which will dismiss
            the activity indicator.
    */
    public func pullToRefresh(
        isRefreshing: Binding<Bool>,
        viewType: ViewType,
        onRefresh: @escaping () -> Void
    ) -> some View {
        
        return overlay(
            PullToRefresh(
                isRefreshing: isRefreshing,
                viewType: viewType,
                onRefresh: onRefresh
            )
            .frame(width: 0, height: 0)
        )
    }
}
