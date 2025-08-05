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
                
                // Back Button
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
                    .accessibilityLabel("Back")
                    .accessibilityHint("Tap to return to the Dashboard")
                    
                    Spacer()
                }
                .padding(.top)
                
                // Main Header
                Text("Biomass Calculation Guide")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                    .accessibilityAddTraits(.isHeader)
                
                // Subheader
                Text("How Biomass is Calculated")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .accessibilityAddTraits(.isHeader)
                
                Text("The app calculates the biomass of trees using a scientific method known as allometric equations. These equations are developed by foresters and use key tree attributes such as height, diameter at breast height (DBH), and species classification. By inputting these values into an allometric equation, we can estimate the total biomass of the tree.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("The app calculates tree biomass using allometric equations, which use tree height, DBH, and species classification to estimate total biomass.")
                
                // Allometric Equations Section
                Text("Allometric Equations")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .accessibilityAddTraits(.isHeader)
                
                Text("Allometric equations are mathematical models used in forestry to estimate tree biomass based on measurable parameters. The equation typically follows the form:")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Allometric equations are models used to estimate tree biomass based on measurable parameters.")
                
                Text("Biomass = a × (DBH)^b × (Height)^c")
                    .font(.headline)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .accessibilityLabel("Biomass equals a times DBH raised to the b power times Height raised to the c power")
                
                Text("where 'a', 'b', and 'c' are species-specific coefficients determined through extensive research.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("The coefficients a, b, and c are specific to each species and determined through research.")
                
                Divider()
                
                // Measuring Tree Height Section
                Text("Measuring Tree Height")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .accessibilityAddTraits(.isHeader)
                
                VStack(alignment: .leading, spacing: 10) {
                    GuideStepView(stepNumber: "1", title: "Mark a Reference Point", description: "Stand near the tree and place a reference marker at the base to align measurements.")
                    GuideStepView(stepNumber: "2", title: "Mark the Bottom", description: "Move back approximately 4.0 meters and use the camera to mark the bottom of the tree.")
                    GuideStepView(stepNumber: "3", title: "Mark the Top", description: "Point the camera to the top of the tree and mark it to get the height calculation.")
                }
                
                Divider()
                
                // Measuring Diameter Section
                Text("Measuring Diameter at Breast Height (DBH)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .accessibilityAddTraits(.isHeader)
                
                Text("Currently, you need to manually input the diameter measurement. Use a measuring tape or caliper to measure the tree's diameter at breast height (1.3 meters or 4.5 feet above ground) and enter the value in centimeters.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Currently, manually input the diameter measurement using a measuring tape or caliper at 1.3 meters above ground and enter in centimeters.")
                
                Text("(Future versions of the app will include diameter at breast height measurement with AR capabilities)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
                    .accessibilityLabel("Future versions will include AR capabilities for diameter measurement")
                
                Divider()
                
                // Selecting Tree Species Section
                Text("Selecting Tree Species")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .accessibilityAddTraits(.isHeader)
                
                Text("Once the height and diameter are measured, you can select the tree species from a predefined list or use our AI classifier to automatically identify the species based on visual features.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("After measuring height and diameter, select the tree species from a list or use the AI classifier for automatic identification.")
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
        // Combine the step number, title, and description for accessibility
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Step \(stepNumber): \(title). \(description)")
    }
}

struct BiomassGuideView_Previews: PreviewProvider {
    static var previews: some View {
        BiomassGuideView(authState: .constant(.Guide))
    }
}

