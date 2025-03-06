//
//  GuideView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 06/03/2025.
//

import SwiftUI

struct BiomassGuideView: View {
    
    @Binding var authState: AuthState
    
    var body: some View {
        
        ScrollView {
            
            VStack(alignment: .leading, spacing: 20) {
                
                HStack {
                    Button(action: {
                        authState = .Dashboard
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.headline)
                            Text("Back")
                                .font(.body)
                        }
                        .foregroundColor(.blue)
                    }
                    Spacer()
                }
                .padding(.top)
                
                Text("Biomass Calculation Guide")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("How Biomass is Calculated")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("The app calculates the biomass of trees using a scientific method known as allometric equations. These equations are developed by foresters and use key tree attributes such as height, diameter at breast height (DBH), and species classification. By inputting these values into an allometric equation, we can estimate the total biomass of the tree.")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Text("Allometric Equations")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Allometric equations are mathematical models used in forestry to estimate tree biomass based on measurable parameters. The equation typically follows the form:")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Text("Biomass = a × (DBH)^b × (Height)^c")
                    .font(.headline)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                
                Text("where 'a', 'b', and 'c' are species-specific coefficients determined through extensive research.")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Divider()
                
                // Measuring Tree Height
                Text("Measuring Tree Height")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 10) {
                    GuideStepView(stepNumber: "1", title: "Mark a Reference Point", description: "Stand near the tree and place a reference marker at the base to align measurements.")
                    GuideStepView(stepNumber: "2", title: "Mark the Bottom", description: "Move back and use the camera to mark the bottom of the tree.")
                    GuideStepView(stepNumber: "3", title: "Mark the Top", description: "Point the camera to the top of the tree and mark it to get the height calculation.")
                }
                
                Divider()
                
                // Measuring Diameter
                Text("Measuring Diameter at Breast Height (DBH)")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 10) {
                    GuideStepView(stepNumber: "1", title: "Position Yourself", description: "Stand near the tree and align your camera at 1.3 meters (4.5 feet) above ground.")
                    GuideStepView(stepNumber: "2", title: "Mark Both Sides", description: "Move back and mark both edges of the tree trunk to measure its diameter.")
                }
                
                Divider()
                
                // Selecting Tree Species
                Text("Selecting Tree Species")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Once the height and diameter are measured, you can select the tree species from a predefined list or use our AI classifier to automatically identify the species based on visual features.")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}

struct GuideStepView: View {
    let stepNumber: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(stepNumber)
                .font(.headline)
                .frame(width: 30, height: 30)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Circle())
                .padding(.trailing, 10)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct BiomassGuideView_Previews: PreviewProvider {
    static var previews: some View {
        BiomassGuideView(authState: .constant(.Guide))
    }
}

