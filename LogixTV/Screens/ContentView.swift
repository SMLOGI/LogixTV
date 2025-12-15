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
    case searchOption
    case searchItem(String)
    case menu(Int)
    case pageDot(Int)
    //case playButton
    case carouselItem(Int, Int)
    case mainContent
    case trapFocused
    case sideBanerTrappedFocused
    
    var description: String {
        switch self {
        case .searchOption:
            return "Search"
        case .searchItem(let item):
            return "Search(\(item))"
        case .menu(let index):
            return "Menu(\(index))"
        case .pageDot(let index):
            return "PageDot"
       // case .playButton:
          //  return "PlayButton"
        case .carouselItem(let group, let contentId):
            return "CarouselItem (\(group)): (\(contentId))"
        case .mainContent:
            return "MainContent"
        case .trapFocused:
            return "trapFocused"
        case .sideBanerTrappedFocused:
            return "sideTrappedFocused"
        }
    }
}

enum PlayerTriggerType {
    case home
    case miniPlayerLive
    case miniPlayerThumbnail
}

enum ActiveScreen: Identifiable, Equatable {
    
    case none
    case search
    case player(PlayerTriggerType)
    
    var id: String {
        switch self {
        case .none: return "none"
        case .search: return "search"
        case .player: return "player"
        }
    }
}
    
class GlobalNavigationState: ObservableObject {
    @Published var showDetail: Bool = false
    @Published var contentItem: CarouselContent?
    @Published var miniPlayerItem: MiniPlayerContent?
    @Published var miniPlayerItemIndex: Int = -1
    @Published var bannerIndex: Int = 0
    @Published var lastFocus: FocusTarget?
    @Published var activeScreen: ActiveScreen? = nil
    @Published var dummyList: [CarouselContent]?
    @Published var isShowMutiplayerView  = false
    @Published var isPiPMutiplayerView = false
    @Published var isGoLiveFocused = false
    
    @Published var dummyMiniPlayerContents: [MiniPlayerContent] = [
        MiniPlayerContent(
            id: 1,
            contentUrl: "https://logix-cms-content.s3.ap-south-1.amazonaws.com/content/transcoded/e7b93c57f8b89568d09f_hls/e7b93c57f8b89568d09f.m3u8",
            title: "Adventure Story",
            imageUrl: "https://logix-cms-content.s3.ap-south-1.amazonaws.com/content/actual/cwjN0C42Z3/images/1.jpg",
            description: "A fun and exciting mini adventure.",
            duration: 120
        ),
        MiniPlayerContent(
            id: 2,
            contentUrl: "https://logix-cms-content.s3.ap-south-1.amazonaws.com/content/transcoded/a758ef717ea30794c0c47eeahls/a758ef717ea30794c0c4.m3u8",
            title: "Learning Time",
            imageUrl: "https://logix-cms-content.s3.ap-south-1.amazonaws.com/content/actual/1wkJWVGNfj/images/2.jpg",
            description: "An engaging educational clip for kids.",
            duration: 150
        ),
        MiniPlayerContent(
            id: 3,
            contentUrl: "https://logix-cms-content.s3.ap-south-1.amazonaws.com/content/transcoded/133e62288e629f54990f76d6hls/133e62288e629f54990f.m3u8",
            title: "Fun With Friends",
            imageUrl: "https://logix-cms-content.s3.ap-south-1.amazonaws.com/content/actual/7ZFxIl7h81/images/3.jpg",
            description: "A joyful moment full of fun and laughter.",
            duration: 180
        )
    ]
}

// https://logix-cms-content.s3.ap-south-1.amazonaws.com/content/transcoded/e7b93c57f8b89568d09f_hls/e7b93c57f8b89568d09f.m3u8

struct ContentView: View {
    @State private var selectedIndex: Int = 0
    @State private var isSidebarExpanded: Bool = false
    @FocusState private var focusedField: FocusTarget?
    @StateObject private var viewModel = SideMenuViewModel()
    @StateObject private var configViewModel = ConfigViewModel()
    @State private var dynamicMenuItems: [MenuItem] = []
    @StateObject private var globalNavigationState = GlobalNavigationState()
    @State private var showVideoErrorAlert = false
    @State private var videoErrorMessage = ""
    @State private var showSplashScreen: Bool = true
    @State var isContentLoaded: Bool = false
    @State var isPresentingLogixPlayer: Bool = false
    @State private var showExitAlert = false

    init() {
        // Placeholder; replaced later in body where we have $focusedField
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            
            Color.black.opacity(1.0)
                .ignoresSafeArea(edges: .all)
            
            
            // Main Content Area using TabView
            ZStack {
                ForEach(Array(viewModel.menuList.enumerated()), id: \.offset) { index, menu in
                    let type = MenuTypeName(rawValue: menu.name) ?? .unknown
                    
                    Group {
                        switch type {
                        case .home:
                            HomeView(focusedItem: $focusedField, isContentLoaded: $isContentLoaded, focusTransitioning: .constant(true))
                                .onExitCommand { showExitAlert = true }
                        case .sports:
                            SportsView()
                        case .listen:
                            ListenView()
                        case .shows:
                            ShowsView()
                        case .watch:
                            WatchView()
                        default:
                            EmptyView()
                        }
                    }
                    .opacity(selectedIndex == index ? 1 : 0)           // only selected visible
                    .allowsHitTesting(selectedIndex == index)          // block focus for hidden ones
                }
            }
            .padding(.leading, 40.0)
            .padding(.top, 0)
            .focusSection()
            
            // Sidebar
            SideMenuView(
                isSidebarExpanded: $isSidebarExpanded,
                selectedIndex: $selectedIndex,
                focusedField: $focusedField, viewModel: viewModel,
            )
            .focusSection()
            // Movie → play directly
            .fullScreenCover(item: $globalNavigationState.activeScreen) { screen in
                switch screen {
                case .search:
                    SearchView(focusedField: $focusedField)
                case .player(let triggerType):
                    showPlayerView(with: triggerType)
                case .none:
                    EmptyView()
                }
                
            }
            .alert("Exit App?", isPresented: $showExitAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Exit", role: .destructive) {
                    exitApp()
                }
            } message: {
                Text("Are you sure you want to close the app?")
            }
            .alert(videoErrorMessage, isPresented: $showVideoErrorAlert) {
                Button("OK", role: .cancel) {}
            }
            
            // Series → go to detail screen
            /*.fullScreenCover(isPresented: $globalNavigationState.showDetails) {
             //SeriesDetailScreen(series: item)
             }*/
            
            
            if !isContentLoaded {
                Image("splashScreen")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                // Side Menu: This is added for fixing need double click of remote right button to jump banner from side menu
                    switch focusedField {
                    case .menu, .sideBanerTrappedFocused, .searchOption:
                        sideTrappedView
                            .padding(.leading, 400)
                    default:
                        EmptyView()
                }
            }
        }
        .environmentObject(globalNavigationState)
        .ignoresSafeArea()
        .task {
            await configViewModel.loadConfiguration()
            if let deviceName = configViewModel.deviceName, !deviceName.isEmpty {
                await viewModel.loadMenu(deviceName)
            }
        }
    }
    
    private func exitApp() {
        // Apple discourages forcibly quitting apps, but on tvOS it's often fine for exit flows
        // You can simulate exit by returning to root or performing cleanup
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        }
    }
    @ViewBuilder
    private func showPlayerView(with triggerType: PlayerTriggerType) -> some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            let mainItem = globalNavigationState.contentItem
            LogixMutilVideoPlayer(
                category: "ccategory",
                triggerType: triggerType,
                videoData: .constant(mainItem),
                miniplayerConetnt: .constant(nil),
                isPresentingLogixPlayer: $isPresentingLogixPlayer,
                focusedField: $focusedField
            )
        }
    }
    private var sideTrappedView: some View {
        Color.clear
            .frame(width: 50, height: 700)
            .focusable(true)
            .focused($focusedField, equals: .sideBanerTrappedFocused)
            .animation(.easeInOut(duration: 0.2), value: focusedField)
    }
    
    private func dismissPlayer() {
        isPresentingLogixPlayer = false
        globalNavigationState.activeScreen = nil
    }
}


struct ListenView: View { var body: some View { Color.gray.overlay(Text("Listen").foregroundColor(.white)) } }
struct SportsView: View { var body: some View { Color.gray.overlay(Text("Sports").foregroundColor(.white)) } }
struct WatchView: View { var body: some View { Color.gray.overlay(Text("Watch").foregroundColor(.white)) } }
struct ShowsView: View { var body: some View { Color.gray.overlay(Text("Shows").foregroundColor(.white)) } }




#Preview {
    ContentView()
}
