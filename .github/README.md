# GitHub Actions Workflows

This directory contains comprehensive GitHub Actions workflows for the ISP Snitch project, providing automated CI/CD, testing, security scanning, and release management.

## Workflows Overview

### 🔄 CI/CD Pipeline (`ci.yml`)
**Triggers:** Push to main/develop, Pull requests, Releases
**Purpose:** Main continuous integration and deployment pipeline

**Features:**
- Automated testing on macOS with Swift 6.0
- Build and package creation
- Homebrew formula updates
- Release creation with assets
- Security scanning with Trivy
- Performance testing

### 🍺 Homebrew Management (`homebrew.yml`)
**Triggers:** Changes to Formula/isp-snitch.rb, Manual dispatch
**Purpose:** Automated Homebrew formula updates and validation

**Features:**
- SHA256 hash updates
- Formula syntax validation
- Installation testing
- Package structure validation
- Service script testing

### 🚀 Release Automation (`release.yml`)
**Triggers:** Tag pushes (v*), Manual dispatch
**Purpose:** Automated release creation and distribution

**Features:**
- Automated release creation
- Asset upload (package, formula)
- Release notes generation
- Formula SHA256 updates
- Notification system

### 🔍 Code Quality (`quality.yml`)
**Triggers:** Push to main/develop, Pull requests
**Purpose:** Code quality, security, and performance validation

**Features:**
- SwiftLint code analysis
- Security vulnerability scanning
- Performance testing
- Memory usage validation
- Documentation checks

### 🧪 Matrix Testing (`matrix-test.yml`)
**Triggers:** Push to main/develop, Pull requests
**Purpose:** Multi-platform compatibility testing

**Features:**
- Testing on macOS 13/14
- Swift 6.0/6.1 compatibility
- Integration testing
- Service installation testing
- Package creation testing

### 🤖 Dependabot (`dependabot.yml`)
**Triggers:** Dependabot pull requests
**Purpose:** Automated dependency updates

**Features:**
- Auto-merge approved dependency updates
- Swift package updates
- GitHub Actions updates

## Workflow Triggers

| Workflow | Push | PR | Release | Manual |
|----------|------|----|---------| -------|
| ci.yml | ✅ | ✅ | ✅ | ❌ |
| homebrew.yml | ✅ | ❌ | ❌ | ✅ |
| release.yml | ❌ | ❌ | ✅ | ✅ |
| quality.yml | ✅ | ✅ | ❌ | ❌ |
| matrix-test.yml | ✅ | ✅ | ❌ | ❌ |
| dependabot.yml | ❌ | ✅ | ❌ | ❌ |

## Environment Variables

The workflows use the following environment variables:

- `SWIFT_VERSION`: Swift version for builds (default: "6.0")
- `MACOS_VERSION`: macOS version for testing (default: "14")
- `GITHUB_TOKEN`: Automatically provided for GitHub API access

## Secrets Required

The following secrets should be configured in the repository:

- `GITHUB_TOKEN`: Automatically provided by GitHub
- No additional secrets required for basic functionality

## Workflow Features

### 🔧 Build and Test
- Swift package resolution and caching
- Multi-platform testing (macOS 13/14)
- Swift version compatibility (6.0/6.1)
- Comprehensive test suite execution
- Performance and memory usage validation

### 📦 Package Management
- Automated package creation
- SHA256 hash calculation and validation
- Homebrew formula updates
- Release asset management
- Installation testing

### 🔒 Security
- Trivy vulnerability scanning
- CodeQL security analysis
- Secret detection
- Dependency security checks

### 📊 Quality Assurance
- SwiftLint code analysis
- Code formatting checks
- Documentation validation
- Performance benchmarking
- Memory usage monitoring

### 🚀 Release Management
- Automated release creation
- Asset upload and management
- Release notes generation
- Formula updates
- Notification system

## Usage

### Manual Workflow Execution

To manually trigger workflows:

```bash
# Trigger Homebrew formula update
gh workflow run homebrew.yml

# Trigger release creation
gh workflow run release.yml -f version=v1.0.0
```

### Workflow Status

Check workflow status:

```bash
# List all workflows
gh run list

# View specific workflow
gh run view <run-id>

# Download workflow logs
gh run download <run-id>
```

### Dependencies

The workflows automatically handle:

- Swift package dependencies
- Homebrew dependencies (sqlite, speedtest-cli, curl, bind)
- GitHub Actions dependencies
- Security scanning tools (Trivy, CodeQL)

## Troubleshooting

### Common Issues

1. **Swift Version Compatibility**
   - Ensure Swift 6.0+ is available
   - Check macOS version compatibility

2. **Homebrew Formula Issues**
   - Verify SHA256 hash calculation
   - Check formula syntax
   - Validate package structure

3. **Security Scan Failures**
   - Review Trivy scan results
   - Check for false positives
   - Update dependencies if needed

4. **Performance Test Failures**
   - Check memory usage limits
   - Verify CPU usage thresholds
   - Review test configuration

### Debugging

Enable debug logging:

```yaml
env:
  ACTIONS_STEP_DEBUG: true
  ACTIONS_RUNNER_DEBUG: true
```

## Contributing

When adding new workflows:

1. Follow the existing naming convention
2. Include comprehensive documentation
3. Add appropriate triggers and conditions
4. Test workflows thoroughly
5. Update this README

## Support

For workflow issues:

1. Check the Actions tab in GitHub
2. Review workflow logs
3. Verify environment setup
4. Check dependency versions
5. Open an issue if needed
