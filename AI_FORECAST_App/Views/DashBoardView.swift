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
    
    let Num_Scanned: Int = 0;
    let LastScanDate: Date = Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 3, hour: 14, minute: 30))!
    let SizeData: Int = 0;
    
    var body: some View {
        
        VStack {
            
            Text("AI-ForCaST")
                .font(.title.bold())
                .foregroundColor(.blue.opacity(0.6))
                .padding()
                
            
            Button {
                authState = .scanPage
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
            
            
            VStack(spacing: 4) {
                Text("Trees Scanned")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("\(Num_Scanned)")
                    .font(.title.bold())
                    .foregroundColor(.green)
                
                Text("Last Scan")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(LastScanDate, style: .date)
                    .font(.headline)
            }
            .padding()
            .frame(width: 350, height: 100)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(20)

            
//            Button {
//                print("Log out")
//            } label: {
//                Text("Logout").font(.headline.bold())
//                    .frame(width: 100, height: 25)
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//                    .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
//            }
            
        }
        
    }
    
    func Scan_Tree() {
        
    }
}

#Preview {
    DashBoardView(authState: .constant(.Dashboard))
}
