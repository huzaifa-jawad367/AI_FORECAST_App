# Offline Database Module

A production-ready Core Data stack for local-first tree scanning data management in AI_FORECAST_App.

## Overview

This module provides a complete offline database solution with clean domain models, repositories, and comprehensive testing. It supports local CRUD operations for scans and projects with soft-delete functionality and sync tracking.

## Architecture

```
Offline/
├── PersistenceController.swift     # Core Data stack management
├── Models/
│   ├── ScanLocal.swift            # Domain model for tree scans
│   ├── ProjectLocal.swift         # Domain model for projects
│   └── TreeCoordinate.swift       # Value type for GPS coordinates
├── CoreData/
│   ├── ScanEntity+Mapping.swift   # Core Data entity mappings for scans
│   └── ProjectEntity+Mapping.swift # Core Data entity mappings for projects
└── Repositories/
    ├── ScanRepository.swift       # Repository pattern for scan operations
    └── ProjectRepository.swift    # Repository pattern for project operations

AI_FORECAST_AppTests/
└── PersistenceTests.swift         # Comprehensive unit tests
```

## Core Data Model

**Biomass.xcdatamodeld** contains two entities:

### ScanEntity
- `scanId` (String, required, unique)
- `height` (Double, required)
- `diameter` (Double, required)
- `species` (String, required)
- `scanTime` (Date, required)
- `projectId` (String, optional)
- `userId` (String, optional)
- `latitude` (Double, optional)
- `longitude` (Double, optional)
- `biomassEstimation` (Double, optional)
- `createdAt` (Date, required)
- `updatedAt` (Date, required)
- `deletedAt` (Date, optional) - for soft delete
- `synced` (Bool, required) - sync status flag

### ProjectEntity
- `projectId` (String, required, unique)
- `projectName` (String, required)
- `projectDescription` (String, optional)
- `creatorName` (String, optional)
- `createdAt` (Date, required)
- `updatedAt` (Date, required)
- `deletedAt` (Date, optional) - for soft delete
- `synced` (Bool, required) - sync status flag

## Key Features

### 1. Swift 6 Compatibility
- Full actor isolation support
- `@MainActor` annotations for UI thread safety
- No escaping closure lifetime issues

### 2. Local-First Design
- Offline-capable CRUD operations
- Soft delete with `deletedAt` timestamps
- Sync status tracking with `synced` flag

### 3. Clean Architecture
- Domain models separate from Core Data entities
- Repository pattern for data access
- Comprehensive error handling

### 4. Type Safety
- Strong typing with domain models
- Coordinate validation with `TreeCoordinate`
- Input validation for all models

## Usage Examples

### Setup

```swift
// Initialize persistence controller (singleton)
let persistenceController = PersistenceController.shared

// Initialize repositories
let scanRepository = ScanRepository(persistenceController: persistenceController)
let projectRepository = ProjectRepository(persistenceController: persistenceController)
```

### Working with Projects

```swift
// Create a new project
let project = ProjectLocal(
    name: "Forest Survey 2024",
    description: "Annual biodiversity assessment",
    creatorName: "John Doe"
)

try await projectRepository.create(project)

// Fetch all projects
let projects = try await projectRepository.fetchAllProjects()

// Update a project
let updated = project.updated(name: "Updated Forest Survey 2024")
try await projectRepository.update(updated)

// Soft delete
try await projectRepository.delete(id: project.id)

// Search projects
let results = try await projectRepository.searchProjects(text: "Forest")
```

### Working with Scans

```swift
// Create a new scan
let coordinate = TreeCoordinate(latitude: 37.7749, longitude: -122.4194)
let scan = ScanLocal(
    height: 15.5,
    diameter: 0.8,
    species: "Oak",
    projectId: project.id,
    coordinate: coordinate,
    biomassEstimation: 250.0
)

try await scanRepository.create(scan)

// Fetch scans for a project
let projectScans = try await scanRepository.fetchScans(for: project.id)

// Search by species
let oakScans = try await scanRepository.fetchScans(species: "Oak")

// Update scan
let updated = scan.updated(height: 16.0)
try await scanRepository.update(updated)
```

### Sync Operations

```swift
// Get unsynced items
let unsyncedProjects = try await projectRepository.fetchUnsyncedProjects()
let unsyncedScans = try await scanRepository.fetchUnsyncedScans()

// Mark as synced after successful upload
try await projectRepository.markAsSynced(ids: [project.id])
try await scanRepository.markAsSynced(ids: [scan.id])
```

### Batch Operations

```swift
// Create multiple projects
let projects = [
    ProjectLocal(name: "Project 1"),
    ProjectLocal(name: "Project 2"),
    ProjectLocal(name: "Project 3")
]
try await projectRepository.createBatch(projects)

// Create multiple scans
let scans = [
    ScanLocal(height: 15.5, diameter: 0.8, species: "Oak"),
    ScanLocal(height: 12.0, diameter: 0.6, species: "Pine")
]
try await scanRepository.createBatch(scans)
```

### Statistics and Analytics

```swift
// Get project statistics
let stats = try await projectRepository.getProjectStatistics(id: project.id)
print("Total scans: \(stats.totalScans)")
print("Most common species: \(stats.mostCommonSpecies ?? "None")")
print("Average height: \(stats.averageHeight ?? 0)")

// Get species distribution
let distribution = try await scanRepository.getSpeciesDistribution()
print("Oak trees: \(distribution["Oak"] ?? 0)")
```

## SwiftUI Integration

### ObservableObject Support

Both repositories are `@MainActor` classes that conform to `ObservableObject`:

```swift
struct ProjectListView: View {
    @StateObject private var projectRepository = ProjectRepository()
    
    var body: some View {
        List(projectRepository.projects) { project in
            ProjectRowView(project: project)
        }
        .task {
            try? await projectRepository.fetchAllProjects()
        }
    }
}
```

### Error Handling

```swift
struct ScanListView: View {
    @StateObject private var scanRepository = ScanRepository()
    
    var body: some View {
        Group {
            if scanRepository.isLoading {
                ProgressView("Loading scans...")
            } else if let error = scanRepository.error {
                ErrorView(error: error)
            } else {
                List(scanRepository.scans) { scan in
                    ScanRowView(scan: scan)
                }
            }
        }
        .task {
            try? await scanRepository.fetchAllScans()
        }
    }
}
```

## Testing

Comprehensive unit tests cover:

- Core Data stack initialization and configuration
- CRUD operations for both entities
- Soft delete functionality
- Sync status management
- Batch operations
- Search and filtering
- Statistics calculations
- Error handling
- Performance with large datasets

Run tests:
```bash
xcodebuild test -scheme AI_FORECAST_App -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Migration from Existing DTOs

The module includes mapping extensions to convert between Core Data entities and existing Supabase DTOs:

```swift
// Convert to network DTOs
let scanRecord = scanEntity.toScanRecord()
let scanRecordWrite = scanEntity.toScanRecordWrite()

let projectRecord = projectEntity.toProjectRecord()
let projectRecordWrite = projectEntity.toProjectRecordWrite()
```

## Performance Considerations

- Uses background contexts for database operations
- Batch operations for multiple inserts/updates
- Optimized fetch requests with predicates and sorting
- In-memory stores for testing to avoid file I/O

## Future Enhancements

The module is designed to support future sync functionality:

1. **Outbox Pattern**: Queue local changes for sync
2. **Conflict Resolution**: Handle merge conflicts during sync
3. **Change Tracking**: Monitor entity changes for incremental sync
4. **Background Sync**: Automatic sync when network is available

## Error Handling

All operations use the `PersistenceError` enum for consistent error handling:

```swift
enum PersistenceError: LocalizedError {
    case saveFailure(Error)
    case fetchFailure(Error)
    case entityNotFound
    case invalidData
}
```

## Dependencies

- CoreData (iOS 17+)
- SwiftUI (iOS 17+)
- Combine (for ObservableObject support)
- CoreLocation (for coordinate handling)

## Installation

The module is self-contained within the `Offline/` folder. Simply:

1. Add the `Biomass.xcdatamodeld` to your Xcode project
2. Import the `Offline/` folder into your project
3. Initialize `PersistenceController.shared` in your App delegate
4. Use repositories in your SwiftUI views

That's it! You now have a production-ready offline database for your tree scanning app.
