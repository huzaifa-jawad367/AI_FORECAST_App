//
//  ScansViewModel.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 23/02/2025.
//

import Foundation
import Supabase
import SwiftUI

@MainActor
class ScansViewModel: ObservableObject {
    @Published var scans: [ScanRecord] = []
    
    // Offline database repository
    private let scanRepository = ScanRepository()
    
    // Keep original Supabase method unchanged
    func fetchScans(projectID: String) async {
        do {
            let response = try await client.database
                .from("scans")
                .select("""
                    id,
                    tree_height,
                    tree_diameter,
                    tree_species,
                    created_at,
                    projects(name),
                    users(full_name),
                    biomass_estimation,
                    latitude,
                    longitude
                """)
                .eq("project_id", value: projectID)
                .execute()
            
            
            
            // Decode the raw Data into an array of ScanRecord
            let records = try JSONDecoder().decode([ScanRecord].self, from: response.data)
            self.scans = records
        } catch {
            print("Error fetching scans: \(error.localizedDescription)")
        }

    }
    
    /// Fetch scans from local Core Data database for a specific project
    func fetchOfflineScans(projectID: String) async {
        do {
            // Fetch scans for the specific project from local database
            let localScans = try await scanRepository.fetchScans(for: projectID)
            
            // Convert ScanLocal to ScanRecord for UI compatibility
            let scanRecords = localScans.map { localScan in
                ScanRecord(
                    scan_id: localScan.id,
                    height: localScan.height,
                    diameter: localScan.diameter,
                    species: localScan.species,
                    scan_time: DateFormatter.iso8601.string(from: localScan.scanTime),
                    project_name: nil, // Would need to fetch project name separately if needed
                    user_name: nil, // Would need user lookup if needed
                    biomass_estimation: localScan.biomassEstimation.map { Float($0) },
                    latitude: localScan.coordinate.map { Float($0.latitude) }, // ✅ FIXED
                    longitude: localScan.coordinate.map { Float($0.longitude) } // ✅ FIXED
                )
            }
            
            self.scans = scanRecords
            print("✅ Fetched \(scans.count) scans from offline database for project: \(projectID)")
            
        } catch {
            print("❌ Error fetching offline scans: \(error.localizedDescription)")
            scans = []
        }
    }
    
    /// Fetch all scans from local database (not filtered by project)
    func fetchAllOfflineScans() async {
        do {
            let localScans = try await scanRepository.fetchAllScans()
            
            let scanRecords = localScans.map { localScan in
                ScanRecord(
                    scan_id: localScan.id,
                    height: localScan.height,
                    diameter: localScan.diameter,
                    species: localScan.species,
                    scan_time: DateFormatter.iso8601.string(from: localScan.scanTime),
                    project_name: nil,
                    user_name: nil,
                    biomass_estimation: localScan.biomassEstimation.map { Float($0) },
                    latitude: localScan.coordinate.map { Float($0.latitude) }, // ✅ FIXED
                    longitude: localScan.coordinate.map { Float($0.longitude) } // ✅ FIXED
                )
            }
            
            self.scans = scanRecords
            print("✅ Fetched \(scans.count) total scans from offline database")
            
        } catch {
            print("❌ Error fetching all offline scans: \(error.localizedDescription)")
            scans = []
        }
    }
    
    /// Search scans by species in local database
    func searchOfflineScans(species: String) async {
        do {
            let localScans = try await scanRepository.fetchScans(species: species)
            
            let scanRecords = localScans.map { localScan in
                ScanRecord(
                    scan_id: localScan.id,
                    height: localScan.height,
                    diameter: localScan.diameter,
                    species: localScan.species,
                    scan_time: DateFormatter.iso8601.string(from: localScan.scanTime),
                    project_name: nil,
                    user_name: nil,
                    biomass_estimation: localScan.biomassEstimation.map { Float($0) },
                    latitude: localScan.coordinate.map { Float($0.latitude) }, // ✅ FIXED
                    longitude: localScan.coordinate.map { Float($0.longitude) } // ✅ FIXED
                )
            }
            
            self.scans = scanRecords
            print("✅ Found \(scans.count) scans of species '\(species)' in offline database")
            
        } catch {
            print("❌ Error searching offline scans: \(error.localizedDescription)")
            scans = []
        }
    }
    
    /// Search scans by text (species name) in local database
    func searchOfflineScansText(text: String) async {
        do {
            let localScans = try await scanRepository.searchScans(text: text)
            
            let scanRecords = localScans.map { localScan in
                ScanRecord(
                    scan_id: localScan.id,
                    height: localScan.height,
                    diameter: localScan.diameter,
                    species: localScan.species,
                    scan_time: DateFormatter.iso8601.string(from: localScan.scanTime),
                    project_name: nil,
                    user_name: nil,
                    biomass_estimation: localScan.biomassEstimation.map { Float($0) },
                    latitude: localScan.coordinate.map { Float($0.latitude) }, // ✅ FIXED
                    longitude: localScan.coordinate.map { Float($0.longitude) } // ✅ FIXED
                )
            }
            
            self.scans = scanRecords
            print("✅ Found \(scans.count) scans matching '\(text)' in offline database")
            
        } catch {
            print("❌ Error searching offline scans by text: \(error.localizedDescription)")
            scans = []
        }
    }
    
    /// Get species distribution from local database
    func getOfflineSpeciesDistribution() async -> [String: Int] {
        do {
            let distribution = try await scanRepository.getSpeciesDistribution()
            print("✅ Retrieved species distribution from offline database")
            return distribution
        } catch {
            print("❌ Error getting species distribution: \(error.localizedDescription)")
            return [:]
        }
    }
    
    /// Get unsynced scans from local database
    func getOfflineUnsyncedScans() async -> [ScanRecord] {
        do {
            let localScans = try await scanRepository.fetchUnsyncedScans()
            
            let scanRecords = localScans.map { localScan in
                ScanRecord(
                    scan_id: localScan.id,
                    height: localScan.height,
                    diameter: localScan.diameter,
                    species: localScan.species,
                    scan_time: DateFormatter.iso8601.string(from: localScan.scanTime),
                    project_name: nil,
                    user_name: nil,
                    biomass_estimation: localScan.biomassEstimation.map { Float($0) },
                    latitude: localScan.coordinate.map { Float($0.latitude) }, // ✅ FIXED
                    longitude: localScan.coordinate.map { Float($0.longitude) } // ✅ FIXED
                )
            }
            
            print("✅ Found \(scanRecords.count) unsynced scans in offline database")
            return scanRecords
            
        } catch {
            print("❌ Error fetching unsynced scans: \(error.localizedDescription)")
            return []
        }
    }
}

// MARK: - DateFormatter Extension
private extension DateFormatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}