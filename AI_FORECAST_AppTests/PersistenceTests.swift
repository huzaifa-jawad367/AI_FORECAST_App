//
//  PersistenceTests.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 27/08/2025.
//

import XCTest
import CoreData
@testable import AI_FORECAST_App

@MainActor
final class PersistenceTests: XCTestCase {
    
    var persistenceController: PersistenceController!
    var scanRepository: ScanRepository!
    var projectRepository: ProjectRepository!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Use in-memory store for testing
        persistenceController = PersistenceController(inMemory: true)
        scanRepository = ScanRepository(persistenceController: persistenceController)
        projectRepository = ProjectRepository(persistenceController: persistenceController)
    }
    
    override func tearDown() async throws {
        persistenceController = nil
        scanRepository = nil
        projectRepository = nil
        
        try await super.tearDown()
    }
    
    // MARK: - PersistenceController Tests
    
    func testPersistenceControllerInitialization() {
        XCTAssertNotNil(persistenceController)
        XCTAssertNotNil(persistenceController.container)
        XCTAssertEqual(persistenceController.container.name, "Biomass")
    }
    
    func testInMemoryStoreConfiguration() {
        let inMemoryController = PersistenceController(inMemory: true)
        let storeDescription = inMemoryController.container.persistentStoreDescriptions.first
        XCTAssertEqual(storeDescription?.url?.path, "/dev/null")
    }
    
    func testSaveContext() {
        // Create an entity to trigger changes
        let context = persistenceController.container.viewContext
        let project = ProjectEntity(context: context)
        project.projectId = "test-project"
        project.projectName = "Test Project"
        project.createdAt = Date()
        project.updatedAt = Date()
        project.synced = false
        
        // Save should not throw
        XCTAssertNoThrow(persistenceController.save())
    }
    
    func testIsEmpty() async {
        let isEmpty = await persistenceController.isEmpty()
        XCTAssertTrue(isEmpty)
        
        // Add some data
        let project = ProjectLocal(name: "Test Project")
        try! await projectRepository.create(project)
        
        let isEmptyAfterAdd = await persistenceController.isEmpty()
        XCTAssertFalse(isEmptyAfterAdd)
    }
    
    func testDeleteAllData() async throws {
        // Add some data first
        let project = ProjectLocal(name: "Test Project")
        try await projectRepository.create(project)
        
        let scan = ScanLocal(height: 10.0, diameter: 0.5, species: "Oak", projectId: project.id)
        try await scanRepository.create(scan)
        
        // Verify data exists
        let projectCount = try await projectRepository.getTotalProjectCount()
        let scanCount = try await scanRepository.getTotalScanCount()
        XCTAssertEqual(projectCount, 1)
        XCTAssertEqual(scanCount, 1)
        
        // Delete all data
        try await persistenceController.deleteAllData()
        
        // Verify data is gone
        let projectCountAfter = try await projectRepository.getTotalProjectCount()
        let scanCountAfter = try await scanRepository.getTotalScanCount()
        XCTAssertEqual(projectCountAfter, 0)
        XCTAssertEqual(scanCountAfter, 0)
    }
    
    // MARK: - TreeCoordinate Tests
    
    func testTreeCoordinateInitialization() {
        let coord = TreeCoordinate(latitude: 37.7749, longitude: -122.4194)
        XCTAssertEqual(coord.latitude, 37.7749)
        XCTAssertEqual(coord.longitude, -122.4194)
    }
    
    func testTreeCoordinateValidation() {
        let validCoord = TreeCoordinate(latitude: 37.7749, longitude: -122.4194)
        XCTAssertTrue(validCoord.isValid)
        
        let invalidLat = TreeCoordinate(latitude: 91.0, longitude: -122.4194)
        XCTAssertFalse(invalidLat.isValid)
        
        let invalidLon = TreeCoordinate(latitude: 37.7749, longitude: 181.0)
        XCTAssertFalse(invalidLon.isValid)
    }
    
    func testTreeCoordinateDistance() {
        let coord1 = TreeCoordinate(latitude: 37.7749, longitude: -122.4194) // San Francisco
        let coord2 = TreeCoordinate(latitude: 34.0522, longitude: -118.2437) // Los Angeles
        
        let distance = coord1.distance(to: coord2)
        XCTAssertGreaterThan(distance, 0)
        XCTAssertLessThan(distance, 1000000) // Less than 1000km (reasonable for SF to LA)
    }
    
    func testTreeCoordinateDisplayString() {
        let coord = TreeCoordinate(latitude: 37.774900, longitude: -122.419400)
        XCTAssertEqual(coord.displayString, "37.774900, -122.419400")
    }
    
    // MARK: - Domain Model Tests
    
    func testScanLocalInitialization() {
        let scan = ScanLocal(
            height: 15.5,
            diameter: 0.8,
            species: "Oak",
            coordinate: TreeCoordinate(latitude: 37.7749, longitude: -122.4194),
            biomassEstimation: 250.0
        )
        
        XCTAssertEqual(scan.height, 15.5)
        XCTAssertEqual(scan.diameter, 0.8)
        XCTAssertEqual(scan.species, "Oak")
        XCTAssertNotNil(scan.coordinate)
        XCTAssertEqual(scan.biomassEstimation, 250.0)
        XCTAssertFalse(scan.synced)
        XCTAssertNil(scan.deletedAt)
    }
    
    func testScanLocalUpdated() {
        let original = ScanLocal(height: 15.5, diameter: 0.8, species: "Oak")
        let updated = original.updated(height: 16.0, species: "Pine")
        
        XCTAssertEqual(updated.height, 16.0)
        XCTAssertEqual(updated.species, "Pine")
        XCTAssertEqual(updated.diameter, 0.8) // Unchanged
        XCTAssertEqual(updated.id, original.id) // Same ID
        XCTAssertNotEqual(updated.updatedAt, original.updatedAt) // Updated timestamp
    }
    
    func testScanLocalValidation() {
        let validScan = ScanLocal(height: 15.5, diameter: 0.8, species: "Oak")
        XCTAssertTrue(validScan.isValid)
        XCTAssertTrue(validScan.validationErrors.isEmpty)
        
        let invalidScan = ScanLocal(height: -1, diameter: 0, species: "")
        XCTAssertFalse(invalidScan.isValid)
        XCTAssertFalse(invalidScan.validationErrors.isEmpty)
    }
    
    func testScanLocalEstimatedVolume() {
        let scan = ScanLocal(height: 10.0, diameter: 1.0, species: "Oak")
        let expectedVolume = Double.pi * 0.5 * 0.5 * 10.0 // π * r² * h
        XCTAssertEqual(scan.estimatedVolume, expectedVolume, accuracy: 0.001)
    }
    
    func testProjectLocalInitialization() {
        let project = ProjectLocal(
            name: "Forest Survey 2024",
            description: "Annual forest survey project",
            creatorName: "John Doe"
        )
        
        XCTAssertEqual(project.name, "Forest Survey 2024")
        XCTAssertEqual(project.description, "Annual forest survey project")
        XCTAssertEqual(project.creatorName, "John Doe")
        XCTAssertFalse(project.synced)
        XCTAssertNil(project.deletedAt)
    }
    
    func testProjectLocalValidation() {
        let validProject = ProjectLocal(name: "Valid Project")
        XCTAssertTrue(validProject.isValid)
        XCTAssertTrue(validProject.validationErrors.isEmpty)
        
        let invalidProject = ProjectLocal(name: "")
        XCTAssertFalse(invalidProject.isValid)
        XCTAssertFalse(invalidProject.validationErrors.isEmpty)
    }
    
    // MARK: - Repository Tests - Projects
    
    func testProjectRepositoryCreate() async throws {
        let project = ProjectLocal(name: "Test Project", description: "A test project")
        
        try await projectRepository.create(project)
        
        let projects = try await projectRepository.fetchAllProjects()
        XCTAssertEqual(projects.count, 1)
        XCTAssertEqual(projects.first?.name, "Test Project")
    }
    
    func testProjectRepositoryFetch() async throws {
        let project1 = ProjectLocal(name: "Project 1")
        let project2 = ProjectLocal(name: "Project 2")
        
        try await projectRepository.create(project1)
        try await projectRepository.create(project2)
        
        let projects = try await projectRepository.fetchAllProjects()
        XCTAssertEqual(projects.count, 2)
        
        let fetchedProject = try await projectRepository.fetchProject(id: project1.id)
        XCTAssertNotNil(fetchedProject)
        XCTAssertEqual(fetchedProject?.name, "Project 1")
    }
    
    func testProjectRepositoryUpdate() async throws {
        let project = ProjectLocal(name: "Original Name")
        try await projectRepository.create(project)
        
        let updatedProject = project.updated(name: "Updated Name")
        try await projectRepository.update(updatedProject)
        
        let fetchedProject = try await projectRepository.fetchProject(id: project.id)
        XCTAssertEqual(fetchedProject?.name, "Updated Name")
    }
    
    func testProjectRepositorySoftDelete() async throws {
        let project = ProjectLocal(name: "Test Project")
        try await projectRepository.create(project)
        
        try await projectRepository.delete(id: project.id)
        
        let projects = try await projectRepository.fetchAllProjects()
        XCTAssertEqual(projects.count, 0) // Should not appear in active projects
        
        let deletedProject = try await projectRepository.fetchProject(id: project.id)
        XCTAssertNotNil(deletedProject?.deletedAt) // Should have deletion timestamp
    }
    
    func testProjectRepositorySearch() async throws {
        let project1 = ProjectLocal(name: "Forest Survey", description: "Oak trees")
        let project2 = ProjectLocal(name: "Urban Study", description: "Pine trees")
        
        try await projectRepository.create(project1)
        try await projectRepository.create(project2)
        
        let forestResults = try await projectRepository.searchProjects(text: "Forest")
        XCTAssertEqual(forestResults.count, 1)
        XCTAssertEqual(forestResults.first?.name, "Forest Survey")
        
        let treeResults = try await projectRepository.searchProjects(text: "trees")
        XCTAssertEqual(treeResults.count, 2) // Both have "trees" in description
    }
    
    // MARK: - Repository Tests - Scans
    
    func testScanRepositoryCreate() async throws {
        let scan = ScanLocal(height: 15.5, diameter: 0.8, species: "Oak")
        
        try await scanRepository.create(scan)
        
        let scans = try await scanRepository.fetchAllScans()
        XCTAssertEqual(scans.count, 1)
        XCTAssertEqual(scans.first?.species, "Oak")
    }
    
    func testScanRepositoryFetch() async throws {
        let project = ProjectLocal(name: "Test Project")
        try await projectRepository.create(project)
        
        let scan1 = ScanLocal(height: 15.5, diameter: 0.8, species: "Oak", projectId: project.id)
        let scan2 = ScanLocal(height: 12.0, diameter: 0.6, species: "Pine", projectId: project.id)
        
        try await scanRepository.create(scan1)
        try await scanRepository.create(scan2)
        
        let allScans = try await scanRepository.fetchAllScans()
        XCTAssertEqual(allScans.count, 2)
        
        let projectScans = try await scanRepository.fetchScans(for: project.id)
        XCTAssertEqual(projectScans.count, 2)
        
        let fetchedScan = try await scanRepository.fetchScan(id: scan1.id)
        XCTAssertNotNil(fetchedScan)
        XCTAssertEqual(fetchedScan?.species, "Oak")
    }
    
    func testScanRepositoryUpdate() async throws {
        let scan = ScanLocal(height: 15.5, diameter: 0.8, species: "Oak")
        try await scanRepository.create(scan)
        
        let updatedScan = scan.updated(height: 16.0, species: "Pine")
        try await scanRepository.update(updatedScan)
        
        let fetchedScan = try await scanRepository.fetchScan(id: scan.id)
        XCTAssertEqual(fetchedScan?.height, 16.0)
        XCTAssertEqual(fetchedScan?.species, "Pine")
    }
    
    func testScanRepositorySoftDelete() async throws {
        let scan = ScanLocal(height: 15.5, diameter: 0.8, species: "Oak")
        try await scanRepository.create(scan)
        
        try await scanRepository.delete(id: scan.id)
        
        let scans = try await scanRepository.fetchAllScans()
        XCTAssertEqual(scans.count, 0) // Should not appear in active scans
        
        let deletedScan = try await scanRepository.fetchScan(id: scan.id)
        XCTAssertNotNil(deletedScan?.deletedAt) // Should have deletion timestamp
    }
    
    func testScanRepositorySpeciesSearch() async throws {
        let oakScan = ScanLocal(height: 15.5, diameter: 0.8, species: "Oak")
        let pineScan = ScanLocal(height: 12.0, diameter: 0.6, species: "Pine")
        
        try await scanRepository.create(oakScan)
        try await scanRepository.create(pineScan)
        
        let oakScans = try await scanRepository.fetchScans(species: "Oak")
        XCTAssertEqual(oakScans.count, 1)
        XCTAssertEqual(oakScans.first?.species, "Oak")
    }
    
    func testScanRepositorySync() async throws {
        let scan1 = ScanLocal(height: 15.5, diameter: 0.8, species: "Oak")
        let scan2 = ScanLocal(height: 12.0, diameter: 0.6, species: "Pine")
        
        try await scanRepository.create(scan1)
        try await scanRepository.create(scan2)
        
        let unsyncedScans = try await scanRepository.fetchUnsyncedScans()
        XCTAssertEqual(unsyncedScans.count, 2)
        
        try await scanRepository.markAsSynced(ids: [scan1.id])
        
        let unsyncedAfter = try await scanRepository.fetchUnsyncedScans()
        XCTAssertEqual(unsyncedAfter.count, 1)
        XCTAssertEqual(unsyncedAfter.first?.id, scan2.id)
    }
    
    // MARK: - Batch Operations Tests
    
    func testProjectBatchOperations() async throws {
        let projects = [
            ProjectLocal(name: "Project 1"),
            ProjectLocal(name: "Project 2"),
            ProjectLocal(name: "Project 3")
        ]
        
        try await projectRepository.createBatch(projects)
        
        let allProjects = try await projectRepository.fetchAllProjects()
        XCTAssertEqual(allProjects.count, 3)
        
        let updatedProjects = projects.map { $0.updated(name: $0.name + " Updated") }
        try await projectRepository.updateBatch(updatedProjects)
        
        let updatedAll = try await projectRepository.fetchAllProjects()
        XCTAssertTrue(updatedAll.allSatisfy { $0.name.contains("Updated") })
    }
    
    func testScanBatchOperations() async throws {
        let scans = [
            ScanLocal(height: 15.5, diameter: 0.8, species: "Oak"),
            ScanLocal(height: 12.0, diameter: 0.6, species: "Pine"),
            ScanLocal(height: 18.0, diameter: 1.0, species: "Maple")
        ]
        
        try await scanRepository.createBatch(scans)
        
        let allScans = try await scanRepository.fetchAllScans()
        XCTAssertEqual(allScans.count, 3)
        
        let updatedScans = scans.map { $0.updated(height: $0.height + 1.0) }
        try await scanRepository.updateBatch(updatedScans)
        
        let updatedAll = try await scanRepository.fetchAllScans()
        for (index, scan) in updatedAll.enumerated() {
            XCTAssertEqual(scan.height, scans[index].height + 1.0)
        }
    }
    
    // MARK: - Statistics Tests
    
    func testProjectStatistics() async throws {
        let project = ProjectLocal(name: "Test Project")
        try await projectRepository.create(project)
        
        let scans = [
            ScanLocal(height: 15.5, diameter: 0.8, species: "Oak", projectId: project.id, biomassEstimation: 100.0),
            ScanLocal(height: 12.0, diameter: 0.6, species: "Pine", projectId: project.id, biomassEstimation: 80.0),
            ScanLocal(height: 18.0, diameter: 1.0, species: "Oak", projectId: project.id, biomassEstimation: 120.0)
        ]
        
        try await scanRepository.createBatch(scans)
        
        let stats = try await projectRepository.getProjectStatistics(id: project.id)
        XCTAssertEqual(stats.totalScans, 3)
        XCTAssertEqual(stats.activeScanCount, 3)
        XCTAssertEqual(stats.mostCommonSpecies, "Oak")
        XCTAssertEqual(stats.averageHeight, 15.166666666666666, accuracy: 0.001)
        XCTAssertEqual(stats.totalBiomass, 300.0)
    }
    
    func testSpeciesDistribution() async throws {
        let scans = [
            ScanLocal(height: 15.5, diameter: 0.8, species: "Oak"),
            ScanLocal(height: 12.0, diameter: 0.6, species: "Pine"),
            ScanLocal(height: 18.0, diameter: 1.0, species: "Oak"),
            ScanLocal(height: 14.0, diameter: 0.7, species: "Maple")
        ]
        
        try await scanRepository.createBatch(scans)
        
        let distribution = try await scanRepository.getSpeciesDistribution()
        XCTAssertEqual(distribution["Oak"], 2)
        XCTAssertEqual(distribution["Pine"], 1)
        XCTAssertEqual(distribution["Maple"], 1)
    }
    
    // MARK: - Error Handling Tests
    
    func testRepositoryErrorHandling() async {
        // Test fetching non-existent scan
        let nonExistentScan = try? await scanRepository.fetchScan(id: "non-existent-id")
        XCTAssertNil(nonExistentScan)
        
        // Test fetching non-existent project
        let nonExistentProject = try? await projectRepository.fetchProject(id: "non-existent-id")
        XCTAssertNil(nonExistentProject)
        
        // Test updating non-existent entities
        let fakeScan = ScanLocal(id: "fake-id", height: 10, diameter: 0.5, species: "Test")
        let fakeProject = ProjectLocal(id: "fake-id", name: "Fake Project")
        
        do {
            try await scanRepository.update(fakeScan)
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertTrue(error is PersistenceError)
        }
        
        do {
            try await projectRepository.update(fakeProject)
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertTrue(error is PersistenceError)
        }
    }
    
    // MARK: - Performance Tests
    
    func testLargeDatasetPerformance() async throws {
        let startTime = Date()
        
        // Create 100 projects and 1000 scans
        var projects: [ProjectLocal] = []
        var scans: [ScanLocal] = []
        
        for i in 0..<100 {
            let project = ProjectLocal(name: "Project \(i)")
            projects.append(project)
            
            for j in 0..<10 {
                let scan = ScanLocal(
                    height: Double.random(in: 5...25),
                    diameter: Double.random(in: 0.1...1.5),
                    species: ["Oak", "Pine", "Maple", "Birch"].randomElement()!,
                    projectId: project.id
                )
                scans.append(scan)
            }
        }
        
        try await projectRepository.createBatch(projects)
        try await scanRepository.createBatch(scans)
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // Should complete within reasonable time (adjust based on your requirements)
        XCTAssertLessThan(duration, 10.0, "Large dataset creation took too long")
        
        let fetchedProjects = try await projectRepository.fetchAllProjects()
        let fetchedScans = try await scanRepository.fetchAllScans()
        
        XCTAssertEqual(fetchedProjects.count, 100)
        XCTAssertEqual(fetchedScans.count, 1000)
    }
}
