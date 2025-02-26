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
        
        VStack {
            
            Text("AI-ForCaST")
                .font(.title.bold())
                .foregroundColor(.blue.opacity(0.6))
                .padding()
                
            
            Button {
                authState = .ProjectsList
            } label: {
                ZStack {
                    Color(hex: "#6b96db")
                        .cornerRadius(20)
                    
                    HStack {
                        Image("AIForCaST")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 180, height: 180)
                            .padding(.leading, 20)
                        
                        Spacer()
                        
                        Text("AI-ForCaST")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .padding(.trailing, 20)
                    }
                }
                .frame(width: 350, height: 170)
                .opacity(0.8)
            }

            
            Text("Quick Access")
                .font(.title2.bold())

            
            HStack {
                
                VStack {
                    Button {
                        print("Album button tapped")
                        
                        authState = .ScansList
                        
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "photo.on.rectangle.angled") // Replace with your custom icon if needed
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.blue)
                            }
                            
                            Text("Album")
                                .font(.headline)
                                .foregroundColor(.black)
                        }
                        .frame(width: 175, height: 150)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(20)
                    }

                    Button {
                        print("Settings Button Tapped")
                        
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "gearshape.fill") // Replace with your custom icon if needed
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.green)
                            }
                            
                            Text("Settings")
                                .font(.headline)
                                .foregroundColor(.black)
                        }
                        .frame(width: 175, height: 150)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(20)
                    }
                    
                }
                
                VStack {
                    Button {
                        print("Capture Scan")
                        
                        authState = .scanPage
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "camera.fill") // Replace with your custom icon if needed
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.red)
                            }
                            
                            Text("Camera")
                                .font(.headline)
                                .foregroundColor(.black)
                        }
                        .frame(width: 175, height: 150)
                        .background(Color.red.opacity(0.2))
                        .cornerRadius(20)
                    }
                    
                    Button {
                        print("Album button tapped")
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "questionmark.circle") // Replace with your custom icon if needed
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.purple)
                            }
                            
                            Text("Guide / Help")
                                .font(.headline)
                                .foregroundColor(.black)
                        }
                        .frame(width: 175, height: 150)
                        .background(Color.purple.opacity(0.2))
                        .cornerRadius(20)
                    }
                    
                }
                
            }.padding()
            
            
            HStack(spacing: 4) {
                VStack {
                    Text("Trees Scanned")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("\(Num_Scanned)")
                        .font(.title.bold())
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                VStack {
                    Text("Number of Projects")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("\(Num_Projects)")
                        .font(.title.bold())
                        .foregroundColor(.green)
                }
                
            }
            .padding()
            .frame(width: 350, height: 100)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(20)
        }
        .task {
            await loadCounts(tables: "scans")
            await loadCounts(tables: "projects")
        }
        
    }
    
    func Scan_Tree() {
        
    }
}

#Preview {
    DashBoardView(authState: .constant(.Dashboard))
}
