//
//  DashBoardView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 10/2/24.
//

import SwiftUI

struct DashBoardView: View {
    
    @Binding var authState: AuthState
    let Num_Scanned: Int = 0;
    let LastScanDate: Date = Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 3, hour: 14, minute: 30))!
    let SizeData: Int = 0;
    
    var body: some View {
        
        VStack {
            Text("I am Groot")
                .font(.title.bold())
                .foregroundColor(.brown)
                .padding()
                
            
            HStack {
                Button {
                    print("Scan tree")
                } label: {
                    Text("Scan Tree").font(.headline.bold())
                        .frame(width: 200, height: 255)
                        .background(Color(hex: "#228B22"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                }
                
                VStack {
                    Button {
                        print("View Inventory")
                    } label: {
                        Text("View Inventory").font(.headline.bold())
                            .frame(width: 150, height: 125)
                            .background(Color(hex: "#4682B4"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                    }
                    
                    Button {
                        print("Quick Tips and Instructions")
                    } label: {
                        Text("Quick Tips and Instructions").font(.headline.bold())
                            .frame(width: 150, height: 125)
                            .background(Color(hex: "#32CD32"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                        
                    }
                }
                
            }.padding()
            
            Spacer()
            
            Text("Number of Trees Scanned: \(Num_Scanned)").bold()
            Text("Date of Last Scan: \(LastScanDate)")
            
            Spacer()
            
            Button {
                print("Log out")
            } label: {
                Text("Logout").font(.headline.bold())
                    .frame(width: 100, height: 25)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
            }
            
        }
        
    }
    
    func Scan_Tree() {
        
    }
}

#Preview {
    DashBoardView()
}
