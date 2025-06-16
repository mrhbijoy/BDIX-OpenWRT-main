#!/bin/bash

echo "=== BDIX Controller Syntax Validation ==="

# Check if lua is available
if ! command -v lua &> /dev/null; then
    echo "WARNING: lua command not found, cannot validate syntax"
    echo "Please test manually on router"
    exit 1
fi

# Test syntax of the controller file
echo "Testing bdix-controller-simple.lua syntax..."
lua -c "bdix-controller-simple.lua" 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Syntax is valid"
else
    echo "✗ Syntax errors found"
    exit 1
fi

echo "=== Validation Complete ==="
