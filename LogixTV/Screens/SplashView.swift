//
//  SplashView.swift
//  LogixTV
//
//  Created by Pradeep  Vijay Deore on 22/09/25.
//

import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.5
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            Image("splashScreen")
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
    }
}

#Preview {
    SplashView()
}
