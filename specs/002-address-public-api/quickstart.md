# Quickstart Guide: Address Public API Documentation Warnings

## Overview
This quickstart guide provides step-by-step instructions for implementing comprehensive public API documentation in the ISP Snitch project.

## Prerequisites

### Required Tools
- **Swift 5.9+**: For Swift DocC support
- **SwiftLint**: For documentation rule enforcement
- **Git**: For version control integration
- **Node.js**: For GitHub Pages deployment (optional)

### System Requirements
- **macOS 12+**: For local development
- **Linux**: For CI/CD environments
- **Memory**: 4GB+ recommended
- **Disk**: 1GB+ free space

## Installation

### 1. Install Swift DocC
Swift DocC is included in Swift toolchains since November 2021.

```bash
# Verify Swift DocC availability
swift doc --version

# If not available, install Swift toolchain
brew install swift
```

### 2. Install SwiftLint
```bash
# Install SwiftLint
brew install swiftlint

# Verify installation
swiftlint version
```

### 3. Configure SwiftLint
Create or update `.swiftlint.yml`:

```yaml
# Enable documentation rules
opt_in_rules:
  - missing_docs
  - valid_docs

# Documentation rule configuration
missing_docs:
  included:
    - Sources
  excluded:
    - Tests
  public_only: true

valid_docs:
  included:
    - Sources
  excluded:
    - Tests
```

## Quick Setup

### 1. Validate Current Documentation
```bash
# Check current documentation coverage
swiftlint lint --strict

# Run quality check script
./Scripts/quality-check.sh
```

### 2. Generate Initial Documentation
```bash
# Generate documentation for all targets
swift doc generate --target ISPSnitchCore --output-path ./docs
swift doc generate --target ISPSnitchCLI --output-path ./docs
swift doc generate --target ISPSnitchWeb --output-path ./docs
```

### 3. Preview Documentation
```bash
# Start local preview server
swift doc preview --target ISPSnitchCore --port 8080

# Open in browser
open http://localhost:8080
```

## Basic Usage

### Documenting Public APIs

#### 1. Add Documentation Comments
For each public API, add comprehensive documentation:

```swift
/// Performs network connectivity tests for the specified target
///
/// This method executes a comprehensive connectivity test including ping,
/// HTTP, and DNS resolution tests against the specified target.
///
/// - Parameter target: The network target to test (IP address or hostname)
/// - Parameter timeout: Maximum time to wait for test completion (default: 10.0 seconds)
/// - Returns: A `TestResult` containing the test results and metrics
/// - Throws: `NetworkMonitorError.notRunning` if monitor is not started
/// - Throws: `NetworkMonitorError.invalidTarget` if target is invalid
///
/// Example:
/// ```swift
/// let result = try networkMonitor.executeTest(.ping, target: "8.8.8.8")
/// print("Test successful: \(result.success)")
/// ```
public func executeTest(_ testType: TestType, target: String) throws -> TestResult
```

#### 2. Document Parameters
```swift
/// - Parameter target: The network target to test (IP address or hostname)
/// - Parameter timeout: Maximum time to wait for test completion (default: 10.0 seconds)
```

#### 3. Document Return Values
```swift
/// - Returns: A `TestResult` containing the test results and metrics
```

#### 4. Document Errors
```swift
/// - Throws: `NetworkMonitorError.notRunning` if monitor is not started
/// - Throws: `NetworkMonitorError.invalidTarget` if target is invalid
```

#### 5. Add Usage Examples
```swift
/// Example:
/// ```swift
/// let result = try networkMonitor.executeTest(.ping, target: "8.8.8.8")
/// print("Test successful: \(result.success)")
/// ```
```

### Quality Validation

#### 1. Check Documentation Coverage
```bash
# Validate documentation coverage
swiftlint lint --strict

# Check specific rules
swiftlint lint --only missing_docs
swiftlint lint --only valid_docs
```

#### 2. Generate Quality Report
```bash
# Run comprehensive quality check
./Scripts/quality-check.sh

# Check documentation metrics
isp-snitch doc metrics --format table
```

#### 3. Fix Documentation Issues
```bash
# Automatically fix common issues
isp-snitch doc fix --dry-run

# Apply fixes
isp-snitch doc fix --interactive
```

## Advanced Configuration

### 1. Custom Documentation Standards
Create `DocumentationConfig.swift`:

```swift
struct DocumentationConfig {
    static let coverageThreshold = 85.0
    static let qualityThreshold = DocumentationQuality.good
    static let generationTargets = ["ISPSnitchCore", "ISPSnitchCLI", "ISPSnitchWeb"]
    static let outputPath = "./docs"
    static let hostingStrategy = HostingStrategy.both
}
```

### 2. CI/CD Integration
Add to `.github/workflows/documentation.yml`:

```yaml
name: Documentation
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  documentation:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Swift
        uses: swift-actions/setup-swift@v1
        with:
          swift-version: "5.9"
      
      - name: Validate Documentation
        run: |
          swiftlint lint --strict
          isp-snitch doc validate --coverage-threshold 85
      
      - name: Generate Documentation
        run: |
          isp-snitch doc generate --output-path ./docs
      
      - name: Deploy Documentation
        if: github.ref == 'refs/heads/main'
        run: |
          isp-snitch doc deploy --strategy github-pages
```

### 3. Quality Gates
Update `Package.swift`:

```swift
// Add documentation validation to build process
#if canImport(Foundation)
import Foundation

// Documentation validation
let documentationValidator = DocumentationValidator()
try documentationValidator.validate()
#endif
```

## Troubleshooting

### Common Issues

#### 1. Swift DocC Not Found
```bash
# Error: Swift DocC not found
# Solution: Install Swift toolchain
brew install swift

# Verify installation
swift doc --version
```

#### 2. Documentation Coverage Below Threshold
```bash
# Error: Coverage below 85%
# Solution: Add documentation to missing APIs
swiftlint lint --only missing_docs

# Fix missing documentation
isp-snitch doc fix --interactive
```

#### 3. Build Failures
```bash
# Error: Build fails on documentation warnings
# Solution: Fix documentation issues
swiftlint lint --strict

# Or temporarily disable strict mode
swiftlint lint --strict --disable missing_docs
```

#### 4. Generation Timeout
```bash
# Error: Documentation generation timeout
# Solution: Increase timeout or optimize generation
isp-snitch doc generate --timeout 60
```

### Performance Optimization

#### 1. Incremental Generation
```bash
# Generate only changed targets
isp-snitch doc generate --incremental

# Use cache for faster generation
isp-snitch doc generate --use-cache
```

#### 2. Parallel Generation
```bash
# Generate multiple targets in parallel
isp-snitch doc generate --parallel --targets ISPSnitchCore,ISPSnitchCLI
```

#### 3. Memory Optimization
```bash
# Limit memory usage
isp-snitch doc generate --max-memory 100MB

# Use streaming for large outputs
isp-snitch doc generate --stream
```

## Best Practices

### 1. Documentation Standards
- **Consistency**: Use consistent documentation format across all APIs
- **Completeness**: Document all parameters, return values, and errors
- **Examples**: Include usage examples for complex APIs
- **Thread Safety**: Document thread safety requirements

### 2. Quality Assurance
- **Regular Validation**: Run documentation validation regularly
- **Automated Checks**: Integrate validation into CI/CD pipeline
- **Quality Metrics**: Monitor documentation quality over time
- **Continuous Improvement**: Update documentation standards as needed

### 3. Maintenance
- **Regular Updates**: Keep documentation current with code changes
- **Version Control**: Track documentation changes in version control
- **Backup**: Create backups before major documentation changes
- **Testing**: Test documentation generation regularly

## Next Steps

### 1. Immediate Actions
- [ ] Configure SwiftLint documentation rules
- [ ] Add documentation to public APIs
- [ ] Set up documentation generation
- [ ] Integrate with quality check script

### 2. Short-term Goals
- [ ] Achieve 85% documentation coverage
- [ ] Set up automated generation
- [ ] Configure CI/CD integration
- [ ] Deploy documentation hosting

### 3. Long-term Objectives
- [ ] Maintain documentation quality
- [ ] Optimize generation performance
- [ ] Enhance developer experience
- [ ] Expand documentation features

## Support

### Getting Help
- **Documentation**: Check project documentation
- **Issues**: Report issues on GitHub
- **Community**: Join project discussions
- **Contributing**: Contribute to documentation improvements

### Resources
- **Swift DocC**: [Apple Documentation](https://developer.apple.com/documentation/docc)
- **SwiftLint**: [SwiftLint Rules](https://realm.github.io/SwiftLint/rule-directory.html)
- **ISP Snitch**: [Project Repository](https://github.com/isp-snitch/isp-snitch)

### Contact
- **GitHub Issues**: [Create Issue](https://github.com/isp-snitch/isp-snitch/issues)
- **Discussions**: [Project Discussions](https://github.com/isp-snitch/isp-snitch/discussions)
- **Email**: [Project Email](mailto:isp-snitch@example.com)
