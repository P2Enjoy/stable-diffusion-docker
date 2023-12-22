#!/bin/bash

# Check if at least one file is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <requirements_file1> [<requirements_file2> ...]"
    exit 1
fi

# Declare an associative array to hold package versions and their sources
declare -A pkg_versions

# Function to parse requirements file
parse_requirements() {
    local file=$1
    while IFS= read -r line; do
        # Extract package and version
        if [[ $line =~ ^([a-zA-Z0-9_-]+)([=\>\<]=[0-9a-zA-Z.+-]+)$ ]]; then
            local pkg=${BASH_REMATCH[1]}
            local ver=${BASH_REMATCH[2]}
            # Add to associative array
            pkg_versions["$pkg"]+="${ver}¬${file}|"
        fi
    done < "$file"
}

# Parse each file
for file in "$@"; do
    if [ -f "$file" ]; then
        parse_requirements "$file"
    else
        echo "File not found: $file"
    fi
done

# Function to compare versions
compare_versions() {
    local pkg=$1
    local versions_string=${pkg_versions[$pkg]}
    IFS='|' read -ra versions <<< "$versions_string"
    local -A unique_versions

    for version_info in "${versions[@]}"; do
        local version=${version_info%%¬*}
        local file=${version_info##*¬}
        unique_versions["$version"]+="$file|"
    done

    if [ ${#unique_versions[@]} -gt 1 ]; then
        echo "Inconsistency found for $pkg:"
        for ver in "${!unique_versions[@]}"; do
            echo "  - Version: $ver in files:"
            IFS='|' read -ra files <<< "${unique_versions[$ver]}"
            for file in "${files[@]}"; do
                echo "    - $file"
            done
        done
    fi
}

# Compare versions for each package
for pkg in "${!pkg_versions[@]}"; do
    compare_versions "$pkg"
done

