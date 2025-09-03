//
//  ContentView.swift
//  LogixTV
//
//  Created by Subodh  on 04/08/25.
//


import SwiftUI

enum MenuTypeName: String {
    case home, listen, watch, sports, shows, unknown
}

struct MenuItem {
    let title: String
    let view: AnyView
}
enum FocusTarget: Hashable {
    case menu(Int)
    case pageDot(Int)
    case playButton
    case carouselItem(Int)
    case mainContent
}

struct ContentView: View {
    @State private var selectedIndex: Int = 0
    @State private var isSidebarExpanded: Bool = false
    @FocusState private var focusedField: FocusTarget?
    @StateObject private var viewModel = SideMenuViewModel()
    @State private var dynamicMenuItems: [MenuItem] = []
    init() {
        // Placeholder; replaced later in body where we have $focusedField
    }
    
    var body: some View {
        let homeView = AnyView(HomeView(focusedItem: $focusedField))
        let listenView = AnyView(ListenView())
        let sportsView = AnyView(SportsView())
        let watchView = AnyView(WatchView())
        let showsView = AnyView(ShowsView())
        
        
        ZStack(alignment: .leading) {
            // Main Content Area using TabView
            TabView(selection: $selectedIndex) {
                ForEach(dynamicMenuItems.indices, id: \.self) { index in
                    dynamicMenuItems[index].view
                        .tag(index)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.black))
                        .focused($focusedField, equals: .mainContent)
                        .focusSection()
                        .onMoveCommand { dir in
                            if dir == .left {
                                // go back to sidebar
                                focusedField = .menu(selectedIndex)
                            }
                        }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Sidebar
            SideMenuView(
                isSidebarExpanded: $isSidebarExpanded,
                selectedIndex: $selectedIndex,
                focusedField: $focusedField, viewModel: viewModel,
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
        .task {
            await viewModel.loadMenu()
            for menu in viewModel.menuList {
                let type = MenuTypeName(rawValue: menu.name) ?? .unknown
                
                let destination: AnyView
                switch type {
                case .home:
                    destination = homeView
                case .listen:
                    destination = listenView
                case .watch:
                    destination = watchView
                case .sports:
                    destination = sportsView
                case .shows, .unknown:
                    destination = showsView
                }
                dynamicMenuItems.append(MenuItem(title: menu.name, view: destination))
            }
        }
    }
}


struct ListenView: View { var body: some View { Color.blue.overlay(Text("Listen").foregroundColor(.white)) } }
struct SportsView: View { var body: some View { Color.green.overlay(Text("Sports").foregroundColor(.white)) } }
struct WatchView: View { var body: some View { Color.orange.overlay(Text("Watch").foregroundColor(.white)) } }
struct ShowsView: View { var body: some View { Color.purple.overlay(Text("Shows").foregroundColor(.white)) } }




#Preview {
    ContentView()
}
