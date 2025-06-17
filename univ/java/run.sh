#!/usr/bin/env bash

_file="$1"
cd "$(dirname "$0")" || exit 1
set -euo pipefail

javac -d . "$_file" || {
    echo "Compilation failed"
    exit 1
}

# Extract package name from the java file
package_name=$(grep "^package " "$_file" | sed 's/^package //; s/;//')

# Extract class name from the java file
class_name=$(grep "public class " "$_file" | head -n 1 | awk '{print $3}' | tr -d '{')

if [ -n "$package_name" ]; then
    java -cp . "$package_name.$class_name"
else
    java -cp . "$class_name"
fi || {
    echo "Execution failed"
    exit 1
}
