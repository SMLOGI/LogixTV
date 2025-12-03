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

enum ActiveScreen: Identifiable, Equatable {
    case none
    case search
    case player
    
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
    @Published var bannerIndex: Int = 0
    @Published var lastFocus: FocusTarget?
    @Published var activeScreen: ActiveScreen? = nil
}

struct ContentView: View {
    @State private var selectedIndex: Int = 0
    @State private var isSidebarExpanded: Bool = false
    @FocusState private var focusedField: FocusTarget?
    @StateObject private var viewModel = SideMenuViewModel()
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
                case .player:
                    showPlayerView()
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
            await viewModel.loadMenu()
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
    private func showPlayerView() -> some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let contentItem = globalNavigationState.contentItem,
               let videoUrlString = contentItem.video?.first?.contentUrl,
               let videoUrl = URL(string: videoUrlString) {
                
                let videoData = VideoData(
                    type: "vod",
                    profile: "pradip",
                    drmEnabled: false,
                    licenceUrl: "",
                    contentUrl: videoUrl.absoluteString,
                    protocol: "",
                    encryptionType: "hls",
                    adInfo: nil,
                    qualityGroup: .none
                )

                LogixVideoPlayer(
                    category: "ccategory",
                    videoData: videoData,
                    isPresentingLogixPlayer: $isPresentingLogixPlayer,
                    mute: .constant(false),
                    showAds: .constant(true),
                    onDismiss: { }
                )
                
            } else {
                Color.clear
                    .onAppear {
                        videoErrorMessage = "Unable to play video. URL is invalid."
                        showVideoErrorAlert = true
                    }
            }
        }
    }
    private var sideTrappedView: some View {
        Color.red
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
