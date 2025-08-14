//
//  ContentView.swift
//  LogixTV
//
//  Created by Subodh  on 04/08/25.
//

import SwiftUI

struct MenuItem {
    let title: String
    let icon: String
    let view: AnyView
}
enum FocusTarget: Hashable {
    case menu(Int)
    case pageDot(Int)
    case carouselItem(UUID)
    case mainContent
}

struct ContentView: View {
    @State private var selectedIndex: Int = 0
    @State private var isSidebarExpanded: Bool = false
    @FocusState private var focusedField: FocusTarget?
    
    private var menuItems: [MenuItem]
    
    init() {
        // Placeholder; replaced later in body where we have $focusedField
        self.menuItems = []
    }
    
    var body: some View {
        let dynamicMenuItems: [MenuItem] = [
            MenuItem(title: "Home", icon: "house", view: AnyView(HomeView(focusedItem: $focusedField))),
            MenuItem(title: "Listen", icon: "headphones", view: AnyView(ListenView())),
            MenuItem(title: "Sports", icon: "sportscourt", view: AnyView(SportsView())),
            MenuItem(title: "Watch", icon: "play.tv", view: AnyView(WatchView())),
            MenuItem(title: "Shows", icon: "tv", view: AnyView(ShowsView()))
        ]
        
        ZStack(alignment: .leading) {
            // Main Content Area using TabView
            TabView(selection: $selectedIndex) {
                ForEach(dynamicMenuItems.indices, id: \.self) { index in
                    dynamicMenuItems[index].view
                        .tag(index)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.darkGray))
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Sidebar
            SideMenuView(
                isSidebarExpanded: $isSidebarExpanded,
                selectedIndex: $selectedIndex,
                focusedField: $focusedField,
                menuItems: dynamicMenuItems
            )
            .ignoresSafeArea()
            .frame(width: 250)
            .onChange(of: focusedField) { newFocus in
                withAnimation {
                    switch newFocus {
                    case .menu:
                        isSidebarExpanded = true
                    default:
                        isSidebarExpanded = false
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}


struct ListenView: View { var body: some View { Color.blue.overlay(Text("Listen").foregroundColor(.white)) } }
struct SportsView: View { var body: some View { Color.green.overlay(Text("Sports").foregroundColor(.white)) } }
struct WatchView: View { var body: some View { Color.orange.overlay(Text("Watch").foregroundColor(.white)) } }
struct ShowsView: View { var body: some View { Color.purple.overlay(Text("Shows").foregroundColor(.white)) } }




#Preview {
    ContentView()
}
