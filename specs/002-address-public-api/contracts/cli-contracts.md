# CLI Contracts: Address Public API Documentation Warnings

## Overview
This document defines the CLI interface contracts for the documentation system, ensuring consistent command-line interactions for documentation management.

## Command Structure

### Documentation Commands
All documentation-related commands follow the pattern:
```bash
isp-snitch doc [subcommand] [options]
```

## Core Commands

### `isp-snitch doc validate`
Validates documentation coverage and quality.

**Usage:**
```bash
isp-snitch doc validate [options]
```

**Options:**
- `--coverage-threshold <percentage>`: Minimum coverage percentage (default: 85)
- `--quality-threshold <level>`: Minimum quality level (default: good)
- `--output <format>`: Output format (json, text, table)
- `--verbose`: Enable verbose output
- `--fail-fast`: Stop on first violation

**Output:**
```json
{
  "passed": true,
  "coverage": 87.5,
  "qualityScore": 92,
  "violations": [],
  "recommendations": []
}
```

**Exit Codes:**
- `0`: Validation passed
- `1`: Validation failed
- `2`: Configuration error

### `isp-snitch doc generate`
Generates comprehensive API documentation.

**Usage:**
```bash
isp-snitch doc generate [options]
```

**Options:**
- `--target <target>`: Specific target to document (default: all)
- `--output-path <path>`: Output directory (default: ./docs)
- `--format <format>`: Output format (html, markdown)
- `--include-examples`: Include code examples
- `--include-diagrams`: Include architecture diagrams
- `--hosting <strategy>`: Hosting strategy (local, github-pages, both)

**Output:**
```
Documentation generated successfully:
- Target: ISPSnitchCore
- Output: ./docs
- Format: HTML
- Files: 15
- Size: 2.3MB
- Time: 3.2s
```

**Exit Codes:**
- `0`: Generation successful
- `1`: Generation failed
- `2`: Target not found

### `isp-snitch doc preview`
Previews documentation locally.

**Usage:**
```bash
isp-snitch doc preview [options]
```

**Options:**
- `--target <target>`: Target to preview (default: ISPSnitchCore)
- `--port <port>`: Local server port (default: 8080)
- `--host <host>`: Local server host (default: localhost)
- `--open`: Open in browser automatically

**Output:**
```
Starting documentation preview server...
- URL: http://localhost:8080
- Target: ISPSnitchCore
- Status: Running
```

**Exit Codes:**
- `0`: Server started successfully
- `1`: Server failed to start
- `2`: Port already in use

### `isp-snitch doc metrics`
Shows documentation metrics and statistics.

**Usage:**
```bash
isp-snitch doc metrics [options]
```

**Options:**
- `--format <format>`: Output format (json, text, table)
- `--detailed`: Show detailed breakdown
- `--history`: Show historical metrics
- `--export <file>`: Export metrics to file

**Output:**
```
Documentation Metrics:
- Total APIs: 293
- Documented APIs: 249
- Coverage: 85.0%
- Quality Score: 87
- Last Updated: 2025-01-27 14:30:00
- Generation Time: 2.1s
```

**Exit Codes:**
- `0`: Metrics retrieved successfully
- `1`: Metrics unavailable
- `2`: Export failed

## Quality Gate Commands

### `isp-snitch doc check`
Runs comprehensive documentation quality checks.

**Usage:**
```bash
isp-snitch doc check [options]
```

**Options:**
- `--strict`: Enable strict mode (fail on warnings)
- `--include-tests`: Include test files in validation
- `--exclude-pattern <pattern>`: Exclude files matching pattern
- `--report <file>`: Generate detailed report

**Output:**
```
Documentation Quality Check:
✓ Coverage: 85.0% (≥ 85.0%)
✓ Quality: Good (≥ Good)
✓ Examples: 92% (≥ 80%)
✓ Parameters: 98% (≥ 95%)
✓ Return Values: 96% (≥ 95%)
✓ Error Documentation: 89% (≥ 85%)

Overall: PASSED
```

**Exit Codes:**
- `0`: All checks passed
- `1`: Some checks failed
- `2`: Configuration error

### `isp-snitch doc fix`
Automatically fixes common documentation issues.

**Usage:**
```bash
isp-snitch doc fix [options]
```

**Options:**
- `--dry-run`: Show what would be fixed without making changes
- `--interactive`: Prompt before making changes
- `--backup`: Create backup before fixing
- `--pattern <pattern>`: Only fix files matching pattern

**Output:**
```
Documentation Fixes:
- Fixed 12 missing parameter documentation
- Fixed 8 missing return value documentation
- Fixed 5 missing error documentation
- Added 3 missing examples
- Updated 2 outdated documentation

Total: 30 fixes applied
```

**Exit Codes:**
- `0`: Fixes applied successfully
- `1`: Some fixes failed
- `2`: No fixes needed

## Configuration Commands

### `isp-snitch doc config`
Manages documentation configuration.

**Usage:**
```bash
isp-snitch doc config [subcommand] [options]
```

**Subcommands:**
- `show`: Show current configuration
- `set <key> <value>`: Set configuration value
- `reset`: Reset to default configuration
- `validate`: Validate configuration

**Options:**
- `--global`: Use global configuration
- `--local`: Use local configuration
- `--file <file>`: Use specific configuration file

**Output:**
```
Documentation Configuration:
- Coverage Threshold: 85%
- Quality Threshold: Good
- Generation Targets: [ISPSnitchCore, ISPSnitchCLI, ISPSnitchWeb]
- Output Path: ./docs
- Hosting Strategy: Both
- Update Frequency: Every Commit
```

**Exit Codes:**
- `0`: Configuration valid
- `1`: Configuration invalid
- `2`: File not found

## Integration Commands

### `isp-snitch doc ci`
CI/CD integration commands.

**Usage:**
```bash
isp-snitch doc ci [subcommand] [options]
```

**Subcommands:**
- `validate`: Run validation for CI
- `generate`: Generate documentation for CI
- `deploy`: Deploy documentation
- `status`: Check CI status

**Options:**
- `--fail-fast`: Stop on first error
- `--timeout <seconds>`: Set timeout for operations
- `--retry <count>`: Retry failed operations
- `--verbose`: Enable verbose output

**Output:**
```
CI Documentation Pipeline:
✓ Validation: PASSED
✓ Generation: SUCCESS
✓ Deployment: SUCCESS
✓ Status: HEALTHY

Total Time: 45.2s
```

**Exit Codes:**
- `0`: All operations successful
- `1`: Some operations failed
- `2`: CI configuration error

## Error Handling

### Common Error Scenarios

#### Validation Failures
```bash
$ isp-snitch doc validate
Error: Documentation coverage below threshold
- Current: 82.5%
- Required: 85.0%
- Missing: 7 APIs
```

#### Generation Failures
```bash
$ isp-snitch doc generate
Error: Documentation generation failed
- Target: ISPSnitchCore
- Error: Swift DocC not found
- Suggestion: Install Swift DocC or use --no-docc
```

#### Configuration Errors
```bash
$ isp-snitch doc config set coverage-threshold 90
Error: Invalid configuration value
- Key: coverage-threshold
- Value: 90
- Valid Range: 0-100
- Suggestion: Use percentage value (e.g., 0.9)
```

### Error Recovery

#### Automatic Recovery
- **Retry Logic**: Automatic retry for transient failures
- **Fallback Options**: Graceful degradation when tools unavailable
- **Cache Management**: Clear cache on persistent failures

#### Manual Recovery
- **Reset Commands**: Reset configuration to defaults
- **Backup Restoration**: Restore from backup files
- **Diagnostic Commands**: Detailed error information

## Performance Considerations

### Response Time Targets
- **Validation**: < 5 seconds
- **Generation**: < 30 seconds
- **Preview**: < 2 seconds
- **Metrics**: < 1 second

### Resource Usage
- **Memory**: < 100MB for generation
- **CPU**: < 50% during generation
- **Disk**: < 10MB for output
- **Network**: Minimal (local operations only)

## Security Considerations

### Input Validation
- **Path Sanitization**: Prevent directory traversal
- **Parameter Validation**: Validate all input parameters
- **File Permissions**: Respect file system permissions
- **Resource Limits**: Prevent resource exhaustion

### Output Security
- **Content Filtering**: Sanitize generated content
- **Access Control**: Respect file permissions
- **Audit Logging**: Log all operations
- **Error Disclosure**: Limit error information exposure

## Compliance

### ISP Snitch Constitution Alignment
- **Minimal Resource Footprint**: Efficient resource usage
- **Public Project Transparency**: Open source and auditable
- **Data Privacy and Security**: Local processing only
- **Modern Swift Architecture**: Swift-based implementation

### Quality Standards
- **Documentation Coverage**: Minimum 85%
- **Quality Threshold**: Good or better
- **Performance**: Reasonable generation time
- **Reliability**: Consistent operation
