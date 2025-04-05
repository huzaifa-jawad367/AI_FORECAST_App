//
//  NavBarView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 15/03/2025.
//


import SwiftUI

struct MainTabView: View {
    
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // ALBUM TAB
            AlbumView()
                .tabItem {
                    Label("Album", systemImage: "photo.on.rectangle.angled")
                }
                .tag(0)
            
            // SETTINGS TAB
            SettingsView(authState: .constant(.Settings))
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(1)
            
            // CAMERA TAB
            CameraView()
                .tabItem {
                    Label("Camera", systemImage: "camera.fill")
                }
                .tag(2)
            
            // GUIDE / HELP TAB
            GuideView()
                .tabItem {
                    Label("Guide/Help", systemImage: "questionmark.circle")
                }
                .tag(3)
            
            // DASHBOARD TAB
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(4)
        }
    }
}

// MARK: - Example Destination Views

struct AlbumView: View {
    var body: some View {
        NavigationView {
            Text("Album Page Content")
                .navigationTitle("Album")
        }
    }
}



struct GuideView: View {
    var body: some View {
        NavigationView {
            Text("Guide / Help Page Content")
                .navigationTitle("Guide")
        }
    }
}

struct DashboardView: View {
    var body: some View {
        NavigationView {
            Text("Dashboard Page Content")
                .navigationTitle("Dashboard")
        }
    }
}

// MARK: - PREVIEW

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
