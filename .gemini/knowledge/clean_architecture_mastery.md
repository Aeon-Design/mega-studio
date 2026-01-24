# Clean Architecture Mastery Grimoire 🏛️

> **Domain:** Software Engineering, Dependency Management, Scalability.
> **Goal:** Build code that survives user and developer turnover.

## 🧱 Layered Architecture
- **Domain Layer:** Pure Dart. Entity and Use Case definitions. No dependencies on UI or External APIs.
- **Data Layer:** Repository implementations, Data Sources (Remote/Local), and Mappers (DTO to Entity).
- **Presentation Layer:** Widgets, ViewModels (StateNotifier/Riverpod), and UI Logic.

## 🧬 Dependency Inversion (DI)
- **Principle:** High-level modules should not depend on low-level modules. Both should depend on abstractions.
- **Implementation:** Use interfaces (abstract classes) for repositories and inject them via Riverpod.

## 🧪 Testability
- **Mocking:** Every repository and service MUST have a mockable interface for testing.
- **Unit Tests:** Mandatory for all Use Cases and Mappers.
- **Widget Tests:** Mandatory for all core UI components.

## 🧹 Clean Code Mandates
- **SRP:** Single Responsibility Principle. A class should have only one reason to change.
- **Dry vs Moist:** Don't Repeat Yourself, but Avoid Premature Abstraction.
- **Naming:** Use "SearchIntent", "UserRepository", "AuthService" - names must describe the *role*.
