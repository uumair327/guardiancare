# Contributing to GuardianCare

Thank you for your interest in contributing to GuardianCare! This document provides guidelines and instructions for contributing.

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for everyone.

## Getting Started

### Prerequisites

- Flutter SDK (>=3.4.0 <4.0.0)
- Dart SDK
- Firebase account (for backend features)
- Android Studio / VS Code with Flutter extensions

### Setup

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/guardiancare.git
   cd guardiancare
   ```
3. Add upstream remote:
   ```bash
   git remote add upstream https://github.com/uumair327/guardiancare.git
   ```
4. Install dependencies:
   ```bash
   flutter pub get
   ```
5. Configure Firebase (see README.md for details)

## Development Workflow

### Branch Naming

- `feature/` - New features (e.g., `feature/add-notifications`)
- `fix/` - Bug fixes (e.g., `fix/login-crash`)
- `docs/` - Documentation updates
- `refactor/` - Code refactoring

### Making Changes

1. Create a branch from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
2. Make your changes following the architecture guidelines
3. Run tests and linting:
   ```bash
   flutter analyze
   flutter test
   ```
4. Commit with clear messages:
   ```bash
   git commit -m "feat: add notification service"
   ```

### Commit Message Format

Use conventional commits:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `refactor:` - Code refactoring
- `test:` - Adding tests
- `chore:` - Maintenance tasks

## Architecture Guidelines

This project follows Clean Architecture. When adding features:

### Layer Structure

```
lib/features/your_feature/
├── domain/
│   ├── entities/       # Business objects
│   ├── repositories/   # Abstract repository interfaces
│   └── usecases/       # Business logic
├── data/
│   ├── models/         # Data transfer objects
│   ├── datasources/    # Remote/local data sources
│   └── repositories/   # Repository implementations
└── presentation/
    ├── bloc/           # State management
    ├── pages/          # Screen widgets
    └── widgets/        # Reusable UI components
```

### Key Principles

- Dependencies point inward (presentation → domain ← data)
- Domain layer has no external dependencies
- Use dependency injection via `get_it`
- Handle errors with `Either<Failure, Success>` from `dartz`

## Pull Request Process

1. Update documentation if needed
2. Ensure all tests pass
3. Update the README.md if you've added features
4. Request review from maintainers
5. Address review feedback

### PR Checklist

- [ ] Code follows project architecture
- [ ] Tests added/updated
- [ ] No linting errors (`flutter analyze`)
- [ ] Documentation updated
- [ ] Commit messages follow convention

## Testing

### Running Tests

```bash
# All tests
flutter test

# Specific test file
flutter test test/path/to/test.dart

# With coverage
flutter test --coverage
```

### Writing Tests

- Unit tests for use cases and repositories
- Widget tests for UI components
- BLoC tests for state management

## Questions?

- Check existing issues and discussions
- Open a new issue for bugs or feature requests
- Tag maintainers for urgent matters

Thank you for contributing!
