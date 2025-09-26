#!/bin/bash

# Script to convert Swift Testing to XCTest
# Usage: ./convert_tests.sh

echo "Converting Swift Testing to XCTest..."

# Find all test files
find Tests -name "*.swift" -type f | while read file; do
    echo "Converting $file..."
    
    # Replace import Testing with import XCTest
    sed -i '' 's/import Testing/import XCTest/g' "$file"
    
    # Replace struct with class and XCTestCase
    sed -i '' 's/struct \([A-Za-z]*Tests\) {/class \1: XCTestCase {/g' "$file"
    
    # Remove @Test attributes
    sed -i '' 's/@Test([^)]*)//g' "$file"
    sed -i '' 's/@Test//g' "$file"
    
    # Replace @Test func with func test
    sed -i '' 's/@Test func \([a-zA-Z_][a-zA-Z0-9_]*\)(/func test\1(/g' "$file"
    
    # Replace #expect with XCTAssert
    sed -i '' 's/#expect(\([^)]*\))/XCTAssert(\1)/g' "$file"
    
    # Replace #expect with XCTAssertEqual for == comparisons
    sed -i '' 's/XCTAssert(\([^)]*\) == \([^)]*\))/XCTAssertEqual(\1, \2)/g' "$file"
    
    # Replace #expect with XCTAssertTrue for boolean checks
    sed -i '' 's/XCTAssert(\([^)]*\) == true)/XCTAssertTrue(\1)/g' "$file"
    sed -i '' 's/XCTAssert(\([^)]*\) == false)/XCTAssertFalse(\1)/g' "$file"
    
    # Replace #expect with XCTAssertGreaterThan for > comparisons
    sed -i '' 's/XCTAssert(\([^)]*\) > \([^)]*\))/XCTAssertGreaterThan(\1, \2)/g' "$file"
    
    # Replace #expect with XCTAssertLessThan for < comparisons
    sed -i '' 's/XCTAssert(\([^)]*\) < \([^)]*\))/XCTAssertLessThan(\1, \2)/g' "$file"
    
    echo "Converted $file"
done

echo "Conversion complete!"
