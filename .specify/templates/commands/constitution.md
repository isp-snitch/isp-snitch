# Constitution Command

## Description
Create or update the project constitution from interactive or provided principle inputs, ensuring all dependent templates stay in sync.

## Usage
```bash
/constitution [ARGUMENTS]
```

## Parameters
- `ARGUMENTS` (optional): Direct input for constitution principles or amendments

## Process Flow

### 1. Load Existing Constitution
- Read `.specify/memory/constitution.md`
- Identify placeholder tokens `[ALL_CAPS_IDENTIFIER]`
- Determine required vs. optional principles

### 2. Collect/Derive Values
- Use user input if provided
- Infer from existing repository context
- Set governance dates (ratification, last amended)
- Increment version according to semantic versioning

### 3. Draft Updated Constitution
- Replace all placeholders with concrete text
- Preserve heading hierarchy
- Ensure principles are declarative and testable
- Include explicit rationale for each principle

### 4. Consistency Propagation
- Update `.specify/templates/plan-template.md`
- Update `.specify/templates/spec-template.md`
- Update `.specify/templates/tasks-template.md`
- Update all command files in `.specify/templates/commands/`
- Update runtime guidance documents

### 5. Generate Sync Impact Report
- Document version changes
- List modified principles
- Note added/removed sections
- Flag templates requiring updates
- Include follow-up TODOs

### 6. Validation
- No unexplained bracket tokens
- Version matches report
- Dates in ISO format (YYYY-MM-DD)
- Principles are testable and specific

### 7. Write Constitution
- Overwrite `.specify/memory/constitution.md`
- Include sync impact report as HTML comment

### 8. Output Summary
- New version and bump rationale
- Files flagged for manual follow-up
- Suggested commit message

## Version Bump Rules
- **MAJOR (X.0.0):** Backward incompatible principle changes
- **MINOR (X.Y.0):** New principles or expanded guidance
- **PATCH (X.Y.Z):** Clarifications or typo fixes

## Constitution Principles (ISP Snitch)
1. **Minimal Resource Footprint** - Low CPU, memory, network usage
2. **Accurate Connectivity Reporting** - Scientific measurement methodology
3. **Modern Swift Architecture** - Swift-based implementation with concurrency
4. **Homebrew Integration** - Package management through Homebrew
5. **Multi-Access Interface** - CLI and web interfaces
6. **Automatic Startup Integration** - macOS service integration
7. **Public Project Transparency** - Open source with comprehensive documentation
8. **Data Privacy and Security** - Local data handling with encryption

## Template Dependencies
- `plan-template.md` - Project planning alignment
- `spec-template.md` - Technical specification alignment
- `tasks-template.md` - Task categorization alignment
- `commands/*.md` - Command documentation alignment

## Error Handling
- Missing ratification date: Insert `TODO(<FIELD_NAME>): explanation`
- Ambiguous version bump: Propose reasoning before finalizing
- Template conflicts: Flag for manual resolution
- Validation failures: Report specific issues

## Output Format
- Markdown with proper heading hierarchy
- Single blank lines between sections
- No trailing whitespace
- Lines wrapped for readability (<100 chars)
- HTML comments for metadata

## Examples

### Initial Constitution Creation
```bash
/constitution "ISP Snitch is a lightweight ISP service monitor..."
```

### Principle Amendment
```bash
/constitution "Update Principle 1 to include battery usage monitoring"
```

### Version Bump
```bash
/constitution "Add new principle for mobile app support"
```

## Compliance
This command MUST align with all constitution principles:
- **Minimal Resource Footprint:** Command execution should be efficient
- **Accurate Connectivity Reporting:** N/A (documentation command)
- **Modern Swift Architecture:** N/A (documentation command)
- **Homebrew Integration:** N/A (documentation command)
- **Multi-Access Interface:** N/A (documentation command)
- **Automatic Startup Integration:** N/A (documentation command)
- **Public Project Transparency:** Command output is transparent and documented
- **Data Privacy and Security:** Command operates on local files only
