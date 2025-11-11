# Contributing to Zippy

Thank you for your interest in contributing to Zippy! This document provides guidelines and information for contributors.

## Development Setup

### Prerequisites

- macOS 13.0 or later
- Xcode 15.0 or later (for development)
- Swift 5.9 or later

### Building from Source

1. Clone the repository:

   ```bash
   git clone https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
   cd Zippy
   ```

2. Build the project:

   ```bash
   swift build
   ```

3. Run the application:

   ```bash
   swift run
   ```

4. Run tests:

   ```bash
   swift test
   ```

## Code Style

- Follow Swift standard naming conventions
- Use SwiftUI best practices
- Add documentation comments for public APIs
- Keep functions focused and single-purpose
- Use async/await for asynchronous operations

## Testing

- Add unit tests for new functionality
- Run the test suite before submitting PRs:

  ```bash
  swift test
  ```

## Submitting Changes

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes
4. Add tests if applicable
5. Ensure all tests pass
6. Commit your changes: `git commit -m "Add your descriptive commit message"`
7. Push to your fork: `git push origin feature/your-feature-name`
8. Create a Pull Request

## Reporting Issues

When reporting bugs, please include:

- macOS version
- Steps to reproduce
- Expected vs actual behavior
- Any relevant error messages

## Feature Requests

Feature requests are welcome! Please create an issue with:

- Clear description of the proposed feature
- Use case or problem it solves
- Any mockups or examples if applicable

## License

By contributing to Zippy, you agree that your contributions will be licensed under the MIT License.
