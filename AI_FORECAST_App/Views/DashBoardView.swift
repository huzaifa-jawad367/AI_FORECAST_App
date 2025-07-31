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
                            colors: [.blue, .green],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding()
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                
                Button {
                    authState = .ScanResultView
                } label: {
                    ZStack {
                        // Enhanced glassmorphism with vibrant gradient
                        RoundedRectangle(cornerRadius: 25)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.white.opacity(0.8), .clear],
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
                                            colors: [Color(hex: "#6b96db").opacity(0.3), Color(hex: "#4CAF50").opacity(0.2)],
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
                                        colors: [.blue, .green],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .padding(.trailing, 20)
                        }
                    }
                    .frame(width: 350, height: 170)
                }
                .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 8)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
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
                            //                        print("Album button tapped")
                            //
                            //                        authState = .ProjectsList
                            ProjectListView(authState: .constant(.ProjectsList))
                            
                        } label: {
                            VStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            Circle()
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [.white.opacity(0.8), .clear],
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
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [.white.opacity(0.8), .clear],
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
                                            colors: [.blue.opacity(0.25), .blue.opacity(0.15)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                        }
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                        // Accessibility
                        .accessibilityLabel("Album")
                        .accessibilityHint("Opens the list of scanned projects")
                        
                        NavigationLink(destination: SettingsView(authState: $authState).environmentObject(sessionManager)) {
                            VStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            Circle()
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [.white.opacity(0.8), .clear],
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
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [.white.opacity(0.8), .clear],
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
                                            colors: [.green.opacity(0.25), .green.opacity(0.15)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                        }
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
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
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            Circle()
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [.white.opacity(0.8), .clear],
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
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [.white.opacity(0.8), .clear],
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
                                            colors: [.red.opacity(0.25), .red.opacity(0.15)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                        }
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
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
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            Circle()
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [.white.opacity(0.8), .clear],
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
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [.white.opacity(0.8), .clear],
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
                                            colors: [.purple.opacity(0.25), .purple.opacity(0.15)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                        }
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
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
                        
                        //                    Text(userProfileId)
                        //                        .font(.caption.bold())
                        //                        .foregroundColor(.green)
                    }
                    
                }
                .padding()
                .frame(width: 350, height: 100)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        colors: [.white.opacity(0.8), .clear],
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
                                colors: [Color(hex: "#4CAF50").opacity(0.2), Color(hex: "#6b96db").opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                // Accessibility: group these two for VoiceOver
                .accessibilityElement(children: .combine)
                .accessibilityLabel(
                    "Trees Scanned: \(Num_Scanned). " +
                    "Number of Projects: \(Num_Projects)."
                )
                .accessibilityHint("Statistics about your scans and projects")
            }
            .background(Color(hex: "#F9FAFB"))
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
