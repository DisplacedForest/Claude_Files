# Development Guide for Claude - Swift + Core Data Stack

## 🎯 Core Philosophy

**TEST-DRIVEN DEVELOPMENT IS NON-NEGOTIABLE.** Every single line of production code must be written in response to a failing test. No exceptions. This is not a suggestion or a preference - it is the fundamental practice that enables all other principles in this document.

### Quick Reference
- **Write tests first** (TDD - Red, Green, Refactor)
- **Test behavior, not implementation**
- **No force unwrapping** without safety checks
- **Immutable value types**
- **Small, focused types**
- **Swift strict concurrency**
- **100% behavior coverage** (not just line coverage)
- **Model-first development** with Core Data

## ⚡ Tech Stack Configuration

```yaml
# PROJECT SPECIFIC - Swift + Core Data Stack
Platform: iOS/macOS/iPadOS/watchOS
Language: Swift 5.9+
UI Framework: SwiftUI
Testing: XCTest + Quick/Nimble (optional)
Database: Core Data
Cloud Sync: CloudKit (optional)
State Management: Combine + @Published/@State
Dependency Management: Swift Package Manager (SPM)
Minimum iOS Version: iOS 16.0+
Architecture: MVVM + Repository Pattern

Core Technologies:
  - Swift 5.9+ with strict concurrency
  - SwiftUI (declarative UI)
  - Core Data (local persistence)
  - Combine framework (reactive programming)
  - async/await (structured concurrency)
  - Swift Concurrency (@MainActor, actors)

Architecture:
  - MVVM with Combine
  - Repository pattern for data access
  - Coordinator pattern for navigation
  - Dependency injection container
  - Clean Architecture principles

Optional Features:
  - CloudKit sync (Core Data + CloudKit)
  - WidgetKit (home screen widgets)
  - Push notifications (APNS)
  - In-app purchases (StoreKit)
  - SharePlay (GroupActivities)
  - App Clips
  - SiriKit (voice shortcuts)
```

## 📁 Repository Structure

```
/
├── YourApp/                    # Main app target
│   ├── Models/                # Data models & Core Data
│   │   ├── CoreData/          # .xcdatamodeld & NSManagedObject subclasses
│   │   │   ├── YourApp.xcdatamodeld
│   │   │   ├── User+CoreDataClass.swift
│   │   │   └── User+CoreDataProperties.swift
│   │   ├── DTOs/              # Data transfer objects
│   │   └── Domain/            # Domain models (value types)
│   ├── Views/                 # SwiftUI views
│   │   ├── Screens/           # Full screen views
│   │   ├── Components/        # Reusable UI components
│   │   └── Modifiers/         # Custom view modifiers
│   ├── ViewModels/            # ViewModels (ObservableObject)
│   ├── Services/              # Business logic & data services
│   │   ├── Network/           # API clients & networking
│   │   ├── Storage/           # Core Data stack & repositories
│   │   └── CloudKit/          # CloudKit sync (if used)
│   ├── Extensions/            # Swift extensions
│   ├── Utilities/             # Helper functions & utilities
│   ├── Resources/             # Assets, Localizations
│   │   ├── Assets.xcassets
│   │   └── Localizable.strings
│   └── App/                   # App entry point & configuration
│       ├── YourAppApp.swift   # App entry point
│       └── ContentView.swift  # Root view
├── YourAppTests/              # Unit tests
│   ├── Models/                # Model tests
│   ├── ViewModels/            # ViewModel tests
│   ├── Services/              # Service tests
│   └── Mocks/                 # Mock objects & test data
├── YourAppUITests/            # UI tests
├── YourAppWidget/             # Widget extension (if applicable)
├── Shared/                    # Code shared between targets
│   ├── Models/                # Shared models
│   └── Extensions/            # Shared extensions
├── docs/                      # Documentation
│   ├── features/              # Feature specs and planning
│   ├── architecture/          # Architecture decisions
│   └── coredata/              # Core Data documentation
├── .claude/                   # AI assistant configuration
│   └── commands/              # Custom AI commands
└── YourApp.xcodeproj          # Xcode project file
```

## 🗄️ Core Data Documentation (CRITICAL FOR AI)

### Overview Documentation Structure

```markdown
# docs/coredata/00_coredata_overview.md

## Architecture Philosophy
[Domain-driven design with Core Data as persistence layer]

## Database Technology
- Platform: Core Data (SQLite backend)
- Framework: NSPersistentContainer with NSPersistentCloudKitContainer (if CloudKit)
- Concurrency: NSManagedObjectContext with proper queue confinement
- Sync: CloudKit integration (optional)
- Migration: Lightweight migrations preferred, mapping models for complex changes
- Relationships: Proper inverse relationships and cascade rules

## Schema Organization Strategy
### Domain Boundaries
Core Domain       → [Primary entities and purpose]
Supporting Domain → [Secondary features]
Analytics Domain  → [Tracking and metrics]

### Entity Naming Conventions
- Use singular nouns: User, Project, Task (not Users, Projects, Tasks)
- Use clear, descriptive names
- Avoid technical prefixes like CD or Data
- Relationships should be clear: user.projects, project.tasks

## Critical Relationships Map
[Visual or text representation of core entity relationships]

## Query Performance Guidelines
### Hot Paths (Optimize First)
- Use NSFetchRequest with predicates and sort descriptors
- Implement proper indexing with compound attributes
- Use batch operations for bulk changes
- Implement proper faulting strategies

## Business Context
[What kind of application this supports, tiers, key features]
```

### Core Data Entity Documentation

```markdown
# docs/coredata/01_user_domain.md

> **Domain**: User Management
> **Primary Entities**: User, UserProfile, UserPreferences
> **CloudKit**: Enabled with proper record zones

## Business Context
Handles user authentication, profile management, and user-specific settings.

---

## Entity Definitions

### User
**Central user entity with authentication and basic info**

| Attribute | Type | Optional | Default | CloudKit | Description |
|-----------|------|----------|---------|----------|-------------|
| id | UUID | NO | UUID() | YES | Primary identifier |
| email | String | NO | - | YES | User's email address |
| displayName | String | YES | - | YES | User's display name |
| createdAt | Date | NO | Date() | YES | Account creation date |
| lastLoginAt | Date | YES | - | NO | Last login timestamp |
| isActive | Boolean | NO | true | YES | Account active status |

**Business Rules:**
- Email must be unique across all users
- DisplayName can be changed by user
- CreatedAt is immutable after creation
- LastLoginAt updated on each successful login

### UserProfile
**Extended user information and preferences**

| Attribute | Type | Optional | Default | CloudKit | Description |
|-----------|------|----------|---------|----------|-------------|
| id | UUID | NO | UUID() | YES | Primary identifier |
| firstName | String | YES | - | YES | User's first name |
| lastName | String | YES | - | YES | User's last name |
| bio | String | YES | - | YES | User biography |
| avatarData | Data | YES | - | NO | Profile image data |
| user | User | NO | - | YES | Relationship to User |

---

## Relationships

| From Entity | Relationship | To Entity | Type | Delete Rule |
|-------------|--------------|-----------|------|-------------|
| User | profile | UserProfile | One-to-One | Cascade |
| User | projects | Project | One-to-Many | Cascade |
| UserProfile | user | User | One-to-One | Nullify |

---

## Common Fetch Patterns

### Fetch User with Profile
```swift
let request: NSFetchRequest<User> = User.fetchRequest()
request.predicate = NSPredicate(format: "email == %@", email)
request.relationshipKeyPathsForPrefetching = ["profile"]
request.fetchLimit = 1

return try container.viewContext.fetch(request).first
```

### Fetch Active Users
```swift
let request: NSFetchRequest<User> = User.fetchRequest()
request.predicate = NSPredicate(format: "isActive == YES")
request.sortDescriptors = [NSSortDescriptor(key: "displayName", ascending: true)]

return try container.viewContext.fetch(request)
```

---

## Performance Considerations

### Indexes
- `User.email` - Unique index for login lookups
- `User.isActive` - Index for filtering active users
- `User.createdAt` - Index for sorting by registration date

### CloudKit Considerations
- User entity syncs to private database
- Large avatarData stored locally only
- Email field indexed in CloudKit for queries
```

### Core Data Migration Convention

```
/YourApp/Models/CoreData/
├── YourApp.xcdatamodeld/
│   ├── YourApp.xcdatamodel          # Version 1 (original)
│   ├── YourApp 2.xcdatamodel        # Version 2
│   ├── YourApp 3.xcdatamodel        # Version 3
│   └── .xccurrentversion            # Current version marker
├── Migrations/
│   ├── V1toV2.xcmappingmodel        # Migration from v1 to v2
│   └── V2toV3.xcmappingmodel        # Migration from v2 to v3
└── NSManagedObject Subclasses/
    ├── User+CoreDataClass.swift
    ├── User+CoreDataProperties.swift
    ├── Project+CoreDataClass.swift
    └── Project+CoreDataProperties.swift
```

**Migration Best Practices:**
- Use lightweight migrations when possible (automatic inference)
- Create mapping models for complex schema changes
- Test migrations with realistic data sets
- Keep old model versions for backward compatibility
- Document all breaking changes in migration notes
- Version model files sequentially: Model, Model 2, Model 3, etc.

### Core Data Stack Patterns

```swift
// Persistence Controller (Singleton with dependency injection support)
class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    // For testing with in-memory store
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        
        // Add sample data for previews
        let sampleUser = User(context: context)
        sampleUser.id = UUID()
        sampleUser.email = "john@example.com"
        sampleUser.displayName = "John Doe"
        sampleUser.createdAt = Date()
        
        try? context.save()
        return controller
    }()
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "YourApp")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Enable CloudKit if needed
        #if !DEBUG
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, 
                                                               forKey: NSPersistentHistoryTrackingKey)
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, 
                                                               forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        #endif
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // In production, handle this error appropriately
                fatalError("Core Data failed to load: \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Core Data save error: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

// Repository Pattern for Data Access
protocol UserRepositoryProtocol {
    func fetchUser(by id: UUID) async throws -> User?
    func fetchUser(by email: String) async throws -> User?
    func createUser(email: String, displayName: String) async throws -> User
    func updateUser(_ user: User) async throws
    func deleteUser(_ user: User) async throws
}

class CoreDataUserRepository: UserRepositoryProtocol {
    private let container: NSPersistentContainer
    
    init(container: NSPersistentContainer) {
        self.container = container
    }
    
    func fetchUser(by id: UUID) async throws -> User? {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        return try await container.viewContext.perform {
            try self.container.viewContext.fetch(request).first
        }
    }
    
    func fetchUser(by email: String) async throws -> User? {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", email)
        request.fetchLimit = 1
        
        return try await container.viewContext.perform {
            try self.container.viewContext.fetch(request).first
        }
    }
    
    func createUser(email: String, displayName: String) async throws -> User {
        return try await container.viewContext.perform {
            let user = User(context: self.container.viewContext)
            user.id = UUID()
            user.email = email
            user.displayName = displayName
            user.createdAt = Date()
            user.isActive = true
            
            try self.container.viewContext.save()
            return user
        }
    }
    
    func updateUser(_ user: User) async throws {
        try await container.viewContext.perform {
            try self.container.viewContext.save()
        }
    }
    
    func deleteUser(_ user: User) async throws {
        try await container.viewContext.perform {
            self.container.viewContext.delete(user)
            try self.container.viewContext.save()
        }
    }
}
```

## 🔄 Development Workflow

### Test-Driven Development Cycle

```swift
// Step 1: RED - Write a failing test
class PaymentProcessingTests: XCTestCase {
    var container: NSPersistentContainer!
    var repository: PaymentRepository!
    
    override func setUp() {
        super.setUp()
        container = PersistenceController(inMemory: true).container
        repository = CoreDataPaymentRepository(container: container)
    }
    
    func testProcessesValidPayment() async throws {
        // Given
        let payment = try await createTestPayment(amount: 100.00)
        let processor = PaymentProcessor(repository: repository)
        
        // When
        let result = try await processor.process(payment)
        
        // Then
        XCTAssertTrue(result.isSuccess)
        XCTAssertEqual(result.payment?.status, .processed)
    }
    
    private func createTestPayment(amount: Decimal) async throws -> Payment {
        return try await container.viewContext.perform {
            let payment = Payment(context: self.container.viewContext)
            payment.id = UUID()
            payment.amount = amount as NSDecimalNumber
            payment.status = PaymentStatus.pending.rawValue
            payment.createdAt = Date()
            
            try self.container.viewContext.save()
            return payment
        }
    }
}

// Step 2: GREEN - Minimal implementation
class PaymentProcessor {
    private let repository: PaymentRepositoryProtocol
    
    init(repository: PaymentRepositoryProtocol) {
        self.repository = repository
    }
    
    func process(_ payment: Payment) async throws -> PaymentResult {
        guard payment.amount.doubleValue > 0 else {
            return PaymentResult.failure(PaymentError.invalidAmount)
        }
        
        payment.status = PaymentStatus.processed.rawValue
        payment.processedAt = Date()
        
        try await repository.updatePayment(payment)
        
        return PaymentResult.success(payment)
    }
}

// Step 3: REFACTOR - Assess improvements
// Extract result types, add proper error handling, etc.
```

### Feature Development Process

1. **Plan**: Define feature requirements and acceptance criteria
2. **Test**: Write failing tests for each acceptance criterion
3. **Implement**: Write minimal code to pass tests
4. **Refactor**: Assess and improve code quality
5. **Document**: Update relevant documentation
6. **Commit**: Use conventional commits (NO AI signatures)

### Commit Standards

```bash
# ✅ Good commits
git commit -m "feat: add payment processing service"
git commit -m "fix: correct Core Data relationship mapping"
git commit -m "refactor: extract user validation logic"
git commit -m "test: add edge cases for payment flow"

# ❌ Never include
# - "Generated with Claude"
# - "AI-assisted"
# - Any mention of AI/Claude
```

## 📐 Architecture Principles

### Model-First Development

```swift
// 1. Define Core Data entity in .xcdatamodeld using Xcode Data Model Editor
// 2. Generate NSManagedObject subclass (or use @objc(EntityName) class)
// 3. Extend with domain logic and computed properties

import CoreData
import Foundation

// Core Data generated class
@objc(Payment)
public class Payment: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var amount: NSDecimalNumber
    @NSManaged public var currency: String
    @NSManaged public var status: String
    @NSManaged public var createdAt: Date
    @NSManaged public var processedAt: Date?
    @NSManaged public var user: User
}

// Domain extensions
extension Payment {
    enum Status: String, CaseIterable {
        case pending = "pending"
        case processing = "processing"
        case completed = "completed"
        case failed = "failed"
        case refunded = "refunded"
    }
    
    enum Currency: String, CaseIterable {
        case usd = "USD"
        case eur = "EUR"
        case gbp = "GBP"
    }
    
    var statusEnum: Status? {
        get { Status(rawValue: status) }
        set { status = newValue?.rawValue ?? "" }
    }
    
    var currencyEnum: Currency? {
        get { Currency(rawValue: currency) }
        set { currency = newValue?.rawValue ?? "" }
    }
    
    var isProcessable: Bool {
        statusEnum == .pending && amount.doubleValue > 0
    }
    
    static func fetchRequest() -> NSFetchRequest<Payment> {
        return NSFetchRequest<Payment>(entityName: "Payment")
    }
}

// Validation and business logic
extension Payment {
    enum ValidationError: Error, LocalizedError {
        case invalidAmount
        case invalidCurrency
        case invalidStatus
        
        var errorDescription: String? {
            switch self {
            case .invalidAmount:
                return "Payment amount must be greater than zero"
            case .invalidCurrency:
                return "Invalid currency code"
            case .invalidStatus:
                return "Invalid payment status"
            }
        }
    }
    
    func validate() throws {
        guard amount.doubleValue > 0 else {
            throw ValidationError.invalidAmount
        }
        
        guard Currency(rawValue: currency) != nil else {
            throw ValidationError.invalidCurrency
        }
        
        guard Status(rawValue: status) != nil else {
            throw ValidationError.invalidStatus
        }
    }
}

// Convenience initializers
extension Payment {
    static func create(in context: NSManagedObjectContext,
                      amount: Decimal,
                      currency: Currency,
                      user: User) -> Payment {
        let payment = Payment(context: context)
        payment.id = UUID()
        payment.amount = NSDecimalNumber(decimal: amount)
        payment.currency = currency.rawValue
        payment.status = Status.pending.rawValue
        payment.createdAt = Date()
        payment.user = user
        return payment
    }
}
```

### Value Types and Domain Models

```swift
// ✅ Good: Immutable value types for domain logic
struct PaymentRequest {
    let amount: Decimal
    let currency: Payment.Currency
    let userId: UUID
    let description: String?
    
    func validate() throws {
        guard amount > 0 else {
            throw PaymentValidationError.invalidAmount
        }
        // Additional validation logic
    }
}

struct PaymentResult {
    let isSuccess: Bool
    let payment: Payment?
    let error: Error?
    
    static func success(_ payment: Payment) -> PaymentResult {
        PaymentResult(isSuccess: true, payment: payment, error: nil)
    }
    
    static func failure(_ error: Error) -> PaymentResult {
        PaymentResult(isSuccess: false, payment: nil, error: error)
    }
}

// ✅ Good: Protocol-oriented design
protocol PaymentProcessorProtocol {
    func process(_ request: PaymentRequest) async throws -> PaymentResult
}

class PaymentProcessor: PaymentProcessorProtocol {
    private let repository: PaymentRepositoryProtocol
    private let gateway: PaymentGatewayProtocol
    
    init(repository: PaymentRepositoryProtocol, gateway: PaymentGatewayProtocol) {
        self.repository = repository
        self.gateway = gateway
    }
    
    func process(_ request: PaymentRequest) async throws -> PaymentResult {
        try request.validate()
        
        let user = try await repository.fetchUser(by: request.userId)
        guard let user = user else {
            throw PaymentError.userNotFound
        }
        
        let payment = Payment.create(
            in: repository.context,
            amount: request.amount,
            currency: request.currency,
            user: user
        )
        
        do {
            try await gateway.charge(payment)
            payment.statusEnum = .completed
            payment.processedAt = Date()
            try await repository.save()
            
            return PaymentResult.success(payment)
        } catch {
            payment.statusEnum = .failed
            try await repository.save()
            throw error
        }
    }
}

// ❌ Avoid: Mutable reference types for simple data
class PaymentData {  // Don't do this for simple data containers
    var amount: Decimal
    var currency: String
    // ... mutable properties
}
```

### Dependency Injection Pattern

```swift
// Dependency container
class AppContainer {
    lazy var persistenceController = PersistenceController.shared
    
    lazy var userRepository: UserRepositoryProtocol = CoreDataUserRepository(
        container: persistenceController.container
    )
    
    lazy var paymentRepository: PaymentRepositoryProtocol = CoreDataPaymentRepository(
        container: persistenceController.container
    )
    
    lazy var paymentGateway: PaymentGatewayProtocol = StripePaymentGateway()
    
    lazy var paymentProcessor: PaymentProcessorProtocol = PaymentProcessor(
        repository: paymentRepository,
        gateway: paymentGateway
    )
}

// Usage in SwiftUI
@main
struct YourApp: App {
    let container = AppContainer()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, container.persistenceController.container.viewContext)
                .environmentObject(container)
        }
    }
}

// ViewModel with dependency injection
class PaymentViewModel: ObservableObject {
    @Published var isProcessing = false
    @Published var errorMessage: String?
    
    private let paymentProcessor: PaymentProcessorProtocol
    
    init(paymentProcessor: PaymentProcessorProtocol) {
        self.paymentProcessor = paymentProcessor
    }
    
    @MainActor
    func processPayment(_ request: PaymentRequest) async {
        isProcessing = true
        errorMessage = nil
        
        do {
            let result = try await paymentProcessor.process(request)
            if !result.isSuccess {
                errorMessage = result.error?.localizedDescription
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isProcessing = false
    }
}
```

## 🧪 Testing Guidelines

### Behavior-Driven Testing

```swift
// ✅ Test behavior through public API
class PaymentProcessorTests: XCTestCase {
    var container: NSPersistentContainer!
    var processor: PaymentProcessor!
    var mockGateway: MockPaymentGateway!
    
    override func setUp() {
        super.setUp()
        container = PersistenceController(inMemory: true).container
        mockGateway = MockPaymentGateway()
        
        let repository = CoreDataPaymentRepository(container: container)
        processor = PaymentProcessor(repository: repository, gateway: mockGateway)
    }
    
    func testProcessesValidPaymentSuccessfully() async throws {
        // Given
        let user = createTestUser()
        let request = PaymentRequest(
            amount: 100.00,
            currency: .usd,
            userId: user.id,
            description: "Test payment"
        )
        mockGateway.shouldSucceed = true
        
        // When
        let result = try await processor.process(request)
        
        // Then
        XCTAssertTrue(result.isSuccess)
        XCTAssertEqual(result.payment?.statusEnum, .completed)
        XCTAssertNotNil(result.payment?.processedAt)
    }
    
    func testHandlesGatewayFailure() async throws {
        // Given
        let user = createTestUser()
        let request = PaymentRequest(
            amount: 100.00,
            currency: .usd,
            userId: user.id,
            description: "Test payment"
        )
        mockGateway.shouldSucceed = false
        
        // When/Then
        do {
            _ = try await processor.process(request)
            XCTFail("Expected payment to fail")
        } catch {
            // Verify payment status was updated to failed
            let payments = try fetchPayments()
            XCTAssertEqual(payments.first?.statusEnum, .failed)
        }
    }
    
    private func createTestUser() -> User {
        let context = container.viewContext
        let user = User(context: context)
        user.id = UUID()
        user.email = "test@example.com"
        user.displayName = "Test User"
        user.createdAt = Date()
        
        try! context.save()
        return user
    }
    
    private func fetchPayments() throws -> [Payment] {
        let request: NSFetchRequest<Payment> = Payment.fetchRequest()
        return try container.viewContext.fetch(request)
    }
}

// Mock for testing
class MockPaymentGateway: PaymentGatewayProtocol {
    var shouldSucceed = true
    var capturedPayments: [Payment] = []
    
    func charge(_ payment: Payment) async throws {
        capturedPayments.append(payment)
        
        if !shouldSucceed {
            throw PaymentGatewayError.chargeDeclined
        }
    }
}

// ❌ Don't test Core Data implementation details
func testCoreDataSaveOperation() {
    // This tests implementation, not behavior - avoid this
}
```

### Test Data Factories

```swift
// Test helpers with builder pattern
class TestDataFactory {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    @discardableResult
    func createUser(
        email: String = "test@example.com",
        displayName: String = "Test User",
        isActive: Bool = true
    ) -> User {
        let user = User(context: context)
        user.id = UUID()
        user.email = email
        user.displayName = displayName
        user.isActive = isActive
        user.createdAt = Date()
        
        try! context.save()
        return user
    }
    
    @discardableResult
    func createPayment(
        amount: Decimal = 100.00,
        currency: Payment.Currency = .usd,
        status: Payment.Status = .pending,
        user: User? = nil
    ) -> Payment {
        let paymentUser = user ?? createUser()
        
        let payment = Payment.create(
            in: context,
            amount: amount,
            currency: currency,
            user: paymentUser
        )
        payment.statusEnum = status
        
        try! context.save()
        return payment
    }
}

// Usage in tests
class PaymentTests: XCTestCase {
    var container: NSPersistentContainer!
    var factory: TestDataFactory!
    
    override func setUp() {
        super.setUp()
        container = PersistenceController(inMemory: true).container
        factory = TestDataFactory(context: container.viewContext)
    }
    
    func testPaymentValidation() throws {
        // Given
        let payment = factory.createPayment(amount: -10.00)
        
        // When/Then
        XCTAssertThrowsError(try payment.validate()) { error in
            XCTAssertTrue(error is Payment.ValidationError)
        }
    }
}
```

## 🔧 Swift Compiler Configuration

### Build Settings (Xcode)

```yaml
# Swift Compiler - Warnings
SWIFT_TREAT_WARNINGS_AS_ERRORS: YES
GCC_WARN_UNUSED_VARIABLE: YES
GCC_WARN_UNUSED_FUNCTION: YES
CLANG_WARN_DOCUMENTATION_COMMENTS: YES

# Swift Compiler - Code Generation
SWIFT_OPTIMIZATION_LEVEL: -Onone (Debug) / -O (Release)
SWIFT_COMPILATION_MODE: wholemodule (Release)

# Strict Concurrency Checking
SWIFT_STRICT_CONCURRENCY: complete

# Other Important Settings
ENABLE_TESTABILITY: YES (Debug only)
SWIFT_VERSION: 5.9
```

### Swift Guidelines

- **Force unwrapping (`!`)** - Only in provably safe cases (IBOutlets, test data)
- **Implicitly unwrapped optionals** - Avoid except for lifecycle requirements
- **Force casts (`as!`)** - Use `as?` with proper error handling instead
- **Protocol-oriented design** - Prefer protocols over inheritance
- **Value types** - Prefer structs over classes when possible
- **Structured concurrency** - Use async/await over completion handlers

```swift
// ✅ Good: Type-safe identifiers
struct UserID: Hashable, Codable, RawRepresentable {
    let rawValue: UUID
    
    init(rawValue: UUID) {
        self.rawValue = rawValue
    }
    
    init() {
        self.rawValue = UUID()
    }
}

struct PaymentAmount: Hashable, Comparable {
    let value: Decimal
    let currency: Payment.Currency
    
    init?(_ value: Decimal, currency: Payment.Currency) {
        guard value > 0 else { return nil }
        self.value = value
        self.currency = currency
    }
    
    static func < (lhs: PaymentAmount, rhs: PaymentAmount) -> Bool {
        guard lhs.currency == rhs.currency else {
            fatalError("Cannot compare amounts with different currencies")
        }
        return lhs.value < rhs.value
    }
}

// ✅ Good: Error handling with Result type
func fetchUser(id: UserID) async -> Result<User, UserError> {
    do {
        let user = try await userRepository.fetchUser(by: id.rawValue)
        guard let user = user else {
            return .failure(.userNotFound)
        }
        return .success(user)
    } catch {
        return .failure(.repositoryError(error))
    }
}

// ✅ Good: Actor for thread-safe state management
actor PaymentCache {
    private var cachedPayments: [UUID: Payment] = [:]
    
    func store(_ payment: Payment) {
        cachedPayments[payment.id] = payment
    }
    
    func retrieve(id: UUID) -> Payment? {
        return cachedPayments[id]
    }
    
    func clear() {
        cachedPayments.removeAll()
    }
}
```

## 🤖 AI Assistant Collaboration

### Session Management

```markdown
## Starting a Session
1. Use TodoRead to check current tasks
2. Review recent commits for context
3. Verify working directory state
4. Ask about session goals

## During Development
- Work on one task at a time
- Mark todos as in_progress before starting
- Run tests after each implementation (⌘U in Xcode)
- Commit working code before refactoring
- Update todos in real-time
```

### AI Safety Guidelines

```markdown
✅ AI CAN safely:
- Implement value types and domain models
- Write tests for defined behaviors
- Refactor with passing tests
- Update documentation
- Create Core Data entity extensions

⚠️ AI SHOULD confirm before:
- Modifying Core Data schema (.xcdatamodeld)
- Changing authentication/authorization
- Updating critical business logic
- Adding new dependencies via SPM
- Modifying Xcode project settings

❌ AI MUST NOT:
- Store secrets in code
- Modify .xcodeproj files directly
- Force unwrap without safety checks
- Push to remote repositories
- Make architectural decisions alone
- Create files unless necessary
```

### Code Boundaries for AI

```swift
// Use clear section markers for complex implementations
class PaymentProcessor {
    func process(_ request: PaymentRequest) async throws -> PaymentResult {
        // === VALIDATION SECTION START ===
        try request.validate()
        let user = try await validateUser(request.userId)
        // === VALIDATION SECTION END ===
        
        // === PAYMENT CREATION SECTION START ===
        let payment = try await createPayment(from: request, user: user)
        // === PAYMENT CREATION SECTION END ===
        
        // === GATEWAY PROCESSING SECTION START ===
        let gatewayResult = try await processWithGateway(payment)
        // === GATEWAY PROCESSING SECTION END ===
        
        // === RESULT HANDLING SECTION START ===
        return try await handleGatewayResult(gatewayResult, payment: payment)
        // === RESULT HANDLING SECTION END ===
    }
    
    private func validateUser(_ userId: UUID) async throws -> User {
        // Implementation here
    }
    
    private func createPayment(from request: PaymentRequest, user: User) async throws -> Payment {
        // Implementation here
    }
    
    private func processWithGateway(_ payment: Payment) async throws -> GatewayResult {
        // Implementation here
    }
    
    private func handleGatewayResult(_ result: GatewayResult, payment: Payment) async throws -> PaymentResult {
        // Implementation here
    }
}
```

## 🚀 Development Practices

### Code Style

1. **Self-documenting code** - No comments unless explaining complex algorithms
2. **Early returns** - Use guard statements to reduce nesting
3. **Small types** - Single responsibility principle
4. **Descriptive names** - Variables and functions should explain themselves

### Error Handling

```swift
// Custom error types for domain-specific errors
enum PaymentError: Error, LocalizedError {
    case insufficientFunds
    case invalidCard
    case networkError(underlying: Error)
    case userNotFound
    case invalidAmount
    
    var errorDescription: String? {
        switch self {
        case .insufficientFunds:
            return "Insufficient funds for this transaction"
        case .invalidCard:
            return "The payment card is invalid"
        case .networkError(let underlying):
            return "Network error: \(underlying.localizedDescription)"
        case .userNotFound:
            return "User not found"
        case .invalidAmount:
            return "Payment amount must be greater than zero"
        }
    }
}

// Structured error handling with async/await
func processPayment(_ request: PaymentRequest) async throws -> PaymentResult {
    do {
        try request.validate()
        
        guard let user = try await userRepository.fetchUser(by: request.userId) else {
            throw PaymentError.userNotFound
        }
        
        let payment = try await createAndSavePayment(request, user: user)
        try await chargePayment(payment)
        
        return PaymentResult.success(payment)
        
    } catch let error as PaymentError {
        // Handle domain-specific errors
        throw error
    } catch {
        // Handle unexpected errors
        throw PaymentError.networkError(underlying: error)
    }
}

// Result type for operations that can fail predictably
func fetchPaymentHistory(for user: User) async -> Result<[Payment], PaymentError> {
    do {
        let payments = try await paymentRepository.fetchPayments(for: user)
        return .success(payments)
    } catch {
        return .failure(.networkError(underlying: error))
    }
}

// Safe unwrapping patterns
extension Optional {
    func orThrow(_ error: Error) throws -> Wrapped {
        guard let value = self else { throw error }
        return value
    }
}

// Usage:
let user = try optionalUser.orThrow(PaymentError.userNotFound)
```

### Refactoring Checklist

Before marking refactoring complete:
- [ ] Code improves readability (if not, don't refactor)
- [ ] All tests pass without modification (⌘U in Xcode)
- [ ] No new public APIs added
- [ ] Swift compiler warnings resolved
- [ ] Code follows Swift API design guidelines
- [ ] Committed separately from features

## ⚠️ Critical Instructions

### NEVER
- Force unwrap without safety checks (`!` operator)
- Use `as!` force casts when `as?` would work
- Create files unless absolutely necessary
- Write production code without a failing test first
- Include AI/Claude mentions in commits
- Modify .xcodeproj files directly
- Use synchronous Core Data operations on main thread
- Create documentation unless requested
- Use `try!` except in test code or provably safe cases

### ALWAYS
- Write tests first (TDD)
- Handle optionals safely with guard, if let, or nil coalescing
- Use value types (structs) when possible
- Prefer protocols over inheritance
- Run tests after implementation (⌘U in Xcode)
- Use @MainActor for UI updates
- Follow Swift API design guidelines
- Keep functions pure when possible
- Use structured concurrency (async/await)
- Use proper Core Data queue confinement
- Validate Core Data entities before saving

## 📋 Custom Commands

### /audit
Performs comprehensive codebase analysis across:
- Code quality and duplication
- Security vulnerabilities
- Core Data model optimization
- Documentation gaps
- Dependency issues

### /plan [feature-name]
Creates detailed feature specification including:
- User stories and acceptance criteria
- Technical approach
- Core Data schema changes
- UI/UX considerations
- Testing strategy

### /add-feature [feature-name]
Adds feature to planning queue with strategic questions for consideration

## 📚 Resources

- [Swift Programming Language Guide](https://docs.swift.org/swift-book/)
- [Core Data Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- [XCTest Documentation](https://developer.apple.com/documentation/xctest)
- [Combine Framework](https://developer.apple.com/documentation/combine)
- [CloudKit Documentation](https://developer.apple.com/documentation/cloudkit)
- Project-specific ADRs in `/docs/ADRs/`

---

**Remember**: The key is writing clean, testable, type-safe code that evolves through small, safe increments. Every change should be driven by a test that describes the desired behavior. When in doubt, favor Swift conventions, type safety, and immutability over cleverness.