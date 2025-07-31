//
//
//  DashBoardView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 10/2/24.
//

import SwiftUI

struct DashBoardView: View {
    
    @Binding var authState: AuthState
    @State private var showMenu = false
    
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject var sessionManager: SessionManager
    
    @State private var userProfileId: String = ""
    
    @State private var Num_Scanned: Int = 0
    @State private var Num_Projects: Int = 0

    let SizeData: Int = 0;
    
    // Environment for color scheme detection
    @Environment(\.colorScheme) var colorScheme
    
    // Dynamic color helpers
    var cardBackground: Color {
        colorScheme == .dark
            ? Color(.secondarySystemBackground)
            : Color(.systemBackground)
    }
    
    var elevatedCardBackground: Color {
        colorScheme == .dark
            ? Color(.secondarySystemBackground).opacity(1.1)
            : Color(.systemBackground)
    }
    
    var gradientColors: [Color] {
        colorScheme == .dark
            ? [Color.blue.opacity(0.7), Color.green.opacity(0.7)]
            : [Color.blue, Color.green]
    }
    
    var cardAccentGradient: [Color] {
        colorScheme == .dark
            ? [Color.blue.opacity(0.2), Color.green.opacity(0.15)]
            : [Color.blue.opacity(0.3), Color.green.opacity(0.2)]
    }
    
    var shadowColor: Color {
        colorScheme == .dark
            ? Color.clear
            : Color.black.opacity(0.1)
    }
    
    var lightShadowColor: Color {
        colorScheme == .dark
            ? Color.clear
            : Color.black.opacity(0.05)
    }
    
    func loadCounts(tables: String) async {
        
        do {

            let response = try await client.database
                .from(tables)
                .select("*", head: true, count: .exact)
                .execute()
            
            // response.count is an Int? containing the number of rows
            let treeCount = response.count ?? 0
            if (tables == "projects") {
                Num_Projects = treeCount
            } else if (tables == "scans") {
                Num_Scanned = treeCount
            }
                
        } catch {
            print("Error fetching tree count: \(error.localizedDescription)")
        }
    }

    
    var body: some View {
        
        NavigationView {
            
            VStack {
                
                Text("AI-ForCaST")
                    .font(.largeTitle.bold())
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding()
                    .shadow(color: shadowColor, radius: 10, x: 0, y: 5)
                
                
                Button {
                    authState = .ScanResultView
                } label: {
                    ZStack {
                        // Enhanced glassmorphism with dynamic colors
                        RoundedRectangle(cornerRadius: 25)
                            .fill(colorScheme == .dark ? .thinMaterial : .ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.primary.opacity(0.3), Color.clear],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(
                                        LinearGradient(
                                            colors: cardAccentGradient,
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                        
                        HStack {
                            Image("AIForCaST")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 180, height: 180)
                                .padding(.leading, 20)
                            
                            Spacer()
                            
                            Text("AI-ForCaST")
                                .font(.title2.bold())
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: gradientColors,
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .padding(.trailing, 20)
                        }
                    }
                    .frame(width: 350, height: 170)
                }
                .shadow(color: shadowColor, radius: 15, x: 0, y: 8)
                .shadow(color: lightShadowColor, radius: 5, x: 0, y: 2)
                // Accessibility
                .accessibilityLabel("AI-ForCaST button")
                .accessibilityHint("Tap to open the AI-ForCaST Projects list")
                .accessibilityAddTraits(.isButton)
                
                
                Text("Quick Access")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    // Accessibility
                    .accessibilityLabel("Quick Access")
                    .accessibilityHint("A section providing quick shortcuts")
                
                
                HStack {
                    
                    VStack {
                        
                        NavigationLink {
                            ProjectListView(authState: .constant(.ProjectsList))
                            
                        } label: {
                            VStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(colorScheme == .dark ? .thinMaterial : .ultraThinMaterial)
                                        .overlay(
                                            Circle()
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [Color.primary.opacity(0.3), Color.clear],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1
                                                )
                                        )
                                        .frame(width: 60, height: 60)
                                    
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.blue)
                                }
                                
                                Text("Album")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            .frame(width: 175, height: 150)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(colorScheme == .dark ? .thinMaterial : .ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color.primary.opacity(0.3), Color.clear],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1.5
                                            )
                                    )
                            )
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.blue.opacity(colorScheme == .dark ? 0.15 : 0.25), Color.blue.opacity(colorScheme == .dark ? 0.1 : 0.15)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                        }
                        .shadow(color: shadowColor, radius: 10, x: 0, y: 5)
                        .shadow(color: lightShadowColor, radius: 3, x: 0, y: 2)
                        // Accessibility
                        .accessibilityLabel("Album")
                        .accessibilityHint("Opens the list of scanned projects")
                        
                        NavigationLink(destination: SettingsView(authState: $authState).environmentObject(sessionManager)) {
                            VStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(colorScheme == .dark ? .thinMaterial : .ultraThinMaterial)
                                        .overlay(
                                            Circle()
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [Color.primary.opacity(0.3), Color.clear],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1
                                                )
                                        )
                                        .frame(width: 60, height: 60)
                                    
                                    Image(systemName: "gearshape.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.green)
                                }
                                
                                Text("Settings")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            .frame(width: 175, height: 150)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(colorScheme == .dark ? .thinMaterial : .ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color.primary.opacity(0.3), Color.clear],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1.5
                                            )
                                    )
                            )
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.green.opacity(colorScheme == .dark ? 0.15 : 0.25), Color.green.opacity(colorScheme == .dark ? 0.1 : 0.15)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                        }
                        .shadow(color: shadowColor, radius: 10, x: 0, y: 5)
                        .shadow(color: lightShadowColor, radius: 3, x: 0, y: 2)
                        .accessibilityLabel("Settings")
                        .accessibilityHint("Tap to view or change settings")
                        .accessibilityAddTraits(.isButton)
                        
                    }
                    
                    VStack {
                        Button {
                            print("Capture Scan")
                            
                            authState = .scanPage
                        } label: {
                            VStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(colorScheme == .dark ? .thinMaterial : .ultraThinMaterial)
                                        .overlay(
                                            Circle()
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [Color.primary.opacity(0.3), Color.clear],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1
                                                )
                                        )
                                        .frame(width: 60, height: 60)
                                    
                                    Image(systemName: "camera.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.red)
                                }
                                
                                Text("Camera")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            .frame(width: 175, height: 150)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(colorScheme == .dark ? .thinMaterial : .ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color.primary.opacity(0.3), Color.clear],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1.5
                                            )
                                    )
                            )
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.red.opacity(colorScheme == .dark ? 0.15 : 0.25), Color.red.opacity(colorScheme == .dark ? 0.1 : 0.15)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                        }
                        .shadow(color: shadowColor, radius: 10, x: 0, y: 5)
                        .shadow(color: lightShadowColor, radius: 3, x: 0, y: 2)
                        // Accessibility
                        .accessibilityLabel("Camera")
                        .accessibilityHint("Tap to capture a new tree scan")
                        .accessibilityAddTraits(.isButton)
                        
                        Button {
                            print("Guide Button Tapped")
                            
                            authState = .Guide
                        } label: {
                            VStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(colorScheme == .dark ? .thinMaterial : .ultraThinMaterial)
                                        .overlay(
                                            Circle()
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [Color.primary.opacity(0.3), Color.clear],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1
                                                )
                                        )
                                        .frame(width: 60, height: 60)
                                    
                                    Image(systemName: "questionmark.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.purple)
                                }
                                
                                Text("Guide / Help")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            .frame(width: 175, height: 150)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(colorScheme == .dark ? .thinMaterial : .ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color.primary.opacity(0.3), Color.clear],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1.5
                                            )
                                    )
                            )
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.purple.opacity(colorScheme == .dark ? 0.15 : 0.25), Color.purple.opacity(colorScheme == .dark ? 0.1 : 0.15)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                        }
                        .shadow(color: shadowColor, radius: 10, x: 0, y: 5)
                        .shadow(color: lightShadowColor, radius: 3, x: 0, y: 2)
                        // Accessibility
                        .accessibilityLabel("Guide or Help")
                        .accessibilityHint("Tap to read instructions or get help")
                        .accessibilityAddTraits(.isButton)
                        
                    }
                    
                }.padding()
                
                
                HStack(spacing: 4) {
                    VStack {
                        Text("Trees Scanned")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(Num_Scanned)")
                            .font(.title.bold())
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("Number of Projects")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(Num_Projects)")
                            .font(.title.bold())
                            .foregroundColor(.green)
                    }
                    
                }
                .padding()
                .frame(width: 350, height: 100)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(colorScheme == .dark ? .thinMaterial : .ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.primary.opacity(0.3), Color.clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                )
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: cardAccentGradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: shadowColor, radius: 10, x: 0, y: 5)
                .shadow(color: lightShadowColor, radius: 3, x: 0, y: 2)
                // Accessibility: group these two for VoiceOver
                .accessibilityElement(children: .combine)
                .accessibilityLabel(
                    "Trees Scanned: \(Num_Scanned). " +
                    "Number of Projects: \(Num_Projects)."
                )
                .accessibilityHint("Statistics about your scans and projects")
            }
            .background(Color(.systemBackground))
            .task {
                await loadCounts(tables: "scans")
                await loadCounts(tables: "projects")
            }
        }
        
    }
    
    func loadUserProfileId() async throws -> String {
        guard let supabaseUser = sessionManager.user else {
            viewModel.isSignedIn = false
            return "guard session"
        }
        
        do {
            // fetch the user instance
            let profile = try await viewModel.fetchUserProfile(userID: supabaseUser.id.uuidString)
            viewModel.currentUser = profile
            viewModel.isSignedIn = true
            
            return "\(supabaseUser.id.uuidString)"
        } catch {
            print("Error fetch profile: \(error)")
            viewModel.isSignedIn = false
            return "Error: \(error.localizedDescription)"
        }
    }
}

#Preview {
    DashBoardView(authState: .constant(.Dashboard))
        .environmentObject(SessionManager())
}
