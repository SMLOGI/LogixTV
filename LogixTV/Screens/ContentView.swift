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
enum FocusTarget: Hashable , Equatable  {
    case menu(Int)
    case pageDot
    case playButton
    case carouselItem(Int)
    case mainContent
    
    var description: String {
        switch self {
        case .menu(let index):
            return "Menu(\(index))"
        case .pageDot:
            return "PageDot"
        case .playButton:
            return "PlayButton"
        case .carouselItem(let index):
            return "CarouselItem(\(index))"
        case .mainContent:
            return "MainContent"
        }
    }
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
        let sportsView = AnyView(SportsView())
        let watchView = AnyView(WatchView())
        let showsView = AnyView(ShowsView())
        
        
        ZStack(alignment: .leading) {
            
            Color.black.opacity(1.0)
                .ignoresSafeArea(edges: .all)
            
            // Main Content Area using TabView
            TabView(selection: $selectedIndex) {
                ForEach(Array(viewModel.menuList.enumerated()), id: \.offset) { index, menu in
                    let type = MenuTypeName(rawValue: menu.name) ?? .unknown
                    
                    switch type {
                    case .home:
                        HomeView(focusedItem: $focusedField)
                            .tag(index) // must match selection binding
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black)
                    case .sports:
                        SportsView()
                            .tag(index) // must match selection binding
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black)
                    case .listen:
                        ListenView()
                            .tag(index) // must match selection binding
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black)
                    case .shows:
                        ShowsView()
                            .tag(index) // must match selection binding
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black)
                    case .watch:
                        WatchView()
                            .tag(index) // must match selection binding
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black)
                    default:
                        EmptyView()
                            .tag(index) // still needs a tag to keep indices in sync
                    }
                }
            }

            .tabViewStyle(.page(indexDisplayMode: .never))
            .padding(.leading, 40.0)
            .padding(.top, 0)
           // .focusSection()
            
            // Sidebar
            SideMenuView(
                isSidebarExpanded: $isSidebarExpanded,
                selectedIndex: $selectedIndex,
                focusedField: $focusedField, viewModel: viewModel,
            )
            .focusSection()
        }
        .ignoresSafeArea()
        .task {
            await viewModel.loadMenu()
            for menu in viewModel.menuList {
                let type = MenuTypeName(rawValue: menu.name) ?? .unknown
                
                let destination: AnyView
                switch type {
                case .home:
                    destination = AnyView(HomeView(focusedItem: $focusedField))
                    dynamicMenuItems.append(MenuItem(title: menu.name, view: destination))
                default:
                    EmptyView()
                }
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
