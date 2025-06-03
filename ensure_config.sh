#!/bin/bash

#-------------------------------------------------------------------------------------------
echo "Starting by first ensuring that a virtual environment exists"
uv sync --upgrade
source .venv/bin/activate


TARGET_DIR="${1:-.}"  # Use current directory if no argument is provided.

if [[ ! -f "$TARGET_DIR/config.yaml" ]]; then
    cat > "$TARGET_DIR/config.yaml" << 'EOF'
#-------------------------------------------------------------------------------------------
#  Copyright (c) 2016-2025.  SupportVectors AI Lab
#
#  This code is part of the training material, and therefore part of the intellectual property.
#  It may not be reused or shared without the explicit, written permission of SupportVectors.
#
#  Use is limited to the duration and purpose of the training at SupportVectors.
#
#  Author: SupportVectors AI Training
#-------------------------------------------------------------------------------------------

cohort: Spring 2025

EOF
    echo "config.yaml created in $TARGET_DIR."
else
    echo "config.yaml already exists in $TARGET_DIR."
fi

#--------------------------------------------------------------------------------------------
# Update the project to recognize:
# ./src      dir as the root of svlearn modules
# ./tests    dir as the root of test cases

if ! grep -q "\[tool.hatch\]" pyproject.toml || ! grep -q "\[tool.pytest.ini_options\]" pyproject.toml; then
    cat >> pyproject.toml << 'EOF'

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.pytest.ini_options]
testpaths = ["tests"]

# If you also build sdists and want data included:
[tool.hatch.build.targets.sdist]
include = [
    "/src",
    "/tests",
    # ... other includes like README, pyproject.toml, etc.
]
EOF
    for dir in src tests ; do
	if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            echo "Directory '$dir' created."
	else
            echo "Directory '$dir' already exists."
	fi
    done
    echo "Correct src/ and tests/ configurations added to pyproject.toml."
else
    echo "Correct src/ and tests/ configurations already exist in pyproject.toml."
fi

#------------------------------------------------------------------------------------------
# Ensure that the .env file exists, and has the
# correct environment variables declared.
#
# Get the absolute path of the current directory
current_dir=$(pwd)

# Check if the .env file exists
if [[ ! -f .env ]]; then
    # Create the .env file with the desired statement
    cat > .env << EOF
#-------------------------------------------------------------------------------------------
#  Copyright (c) 2016-2025.  SupportVectors AI Lab
#
#  This code is part of the training material, and therefore part of the intellectual property.
#  It may not be reused or shared without the explicit, written permission of SupportVectors.
#
#  Use is limited to the duration and purpose of the training at SupportVectors.
#
#  Author: SupportVectors AI Training
#-------------------------------------------------------------------------------------------

#
# Since most our projects will need the configuration
# utility, this fixes the directory where to find them.
#
export BOOTCAMP_ROOT_DIR="$current_dir"

#
# Precaution, needed for some IDEs
# to recognize that the main svlearn library code
# is in the src/ sub-directory
#
export PYTHONPATH="$current_dir/src"
EOF

    echo ".env file created with BOOTCAMP_ROOT_DIR set to $current_dir"
else
    echo ".env file already exists. No changes made."
fi


#-----------------------------------------------------------------------------------------
# Download and create the docs folder, for mkdocs later.
tar -xvzf docs.tgz

#-----------------------------------------------------------------------------------------


# Prompt user for project details
    read -p "Enter the python module name (e.g. svlearn_something): " module_name

# Ensure required directories and files exist
directories=("docs" "docs/notebooks" "src/$module_name")
files=("docs/index.md" "src/$module_name/__init__.py")

# Create missing directories
for dir in "${directories[@]}"; do
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        echo "Directory '$dir' created."
    else
        echo "Directory '$dir' already exists."
    fi
done

# Create missing files
for file in "${files[@]}"; do
    if [[ ! -f "$file" ]]; then
        touch "$file"
        echo "File '$file' created."
    else
        echo "File '$file' already exists."
    fi
done

#-----------------------------------------------------------------------------------------
# Add hatch build targets wheel section to pyproject.toml
echo "Adding hatch build targets wheel section to pyproject.toml..."

# Check if the wheel section already exists
if ! grep -q "\[tool.hatch.build.targets.wheel\]" pyproject.toml; then
    cat >> pyproject.toml << EOF

[tool.hatch.build.targets.wheel]
packages = ["src/$module_name"]
EOF
    echo "Hatch build targets wheel section added to pyproject.toml."
else
    echo "Hatch build targets wheel section already exists in pyproject.toml."
fi

#-----------------------------------------------------------------------------------------
#Now populate the __init__.py with the proper configuration initialization
#
echo "Populating the __init__.py with the proper configuration initialization"

init_file="src/$module_name/__init__.py"

# Define the content
content="#  -------------------------------------------------------------------------------------------------
#   Copyright (c) 2016-2025.  SupportVectors AI Lab
#   This code is part of the training material and, therefore, part of the intellectual property.
#   It may not be reused or shared without the explicit, written permission of SupportVectors.
#
#   Use is limited to the duration and purpose of the training at SupportVectors.
#
#   Author: SupportVectors AI Training Team
#  -------------------------------------------------------------------------------------------------
from svlearn.config.configuration import ConfigurationMixin

from dotenv import load_dotenv
load_dotenv()

config = ConfigurationMixin().load_config()"

# Check if the content is already present in the file
if ! grep -q "from svlearn.config.configuration import ConfigurationMixin" "$init_file"; then
    # Append the content to the file
    echo "$content" >> "$init_file"
    echo "Content appended to $init_file."
else
    echo "Content already exists in $init_file. No changes made."
fi

#-----------------------------------------------------------------------------------------
echo "Creating environment test file..."

# Create a test file to verify the setup
cat > src/test_setup.py << EOF
#!/usr/bin/env python3
"""
Test script to verify that the environment and configuration are set up correctly.
"""

import sys
import os
from pathlib import Path

def main():
    print("🚀 SupportVectors Environment Setup Test")
    print("=" * 50)
    
    # Test Python version
    print(f"✅ Python version: {sys.version}")
    
    # Test current working directory
    print(f"✅ Working directory: {os.getcwd()}")
    
    # Test PYTHONPATH
    pythonpath = os.environ.get('PYTHONPATH', 'Not set')
    print(f"✅ PYTHONPATH: {pythonpath}")
    
    # Test that we can import our module
    try:
        # Dynamic import based on the module structure
        src_path = Path('src')
        if src_path.exists():
            module_dirs = [d for d in src_path.iterdir() if d.is_dir() and not d.name.startswith('.')]
            if module_dirs:
                module_name = module_dirs[0].name
                print(f"✅ Found module: {module_name}")
                
                # Try to import the module
                sys.path.insert(0, str(src_path))
                try:
                    module = __import__(module_name)
                    print(f"✅ Successfully imported {module_name}")
                    
                    # Try to access the config if it exists
                    if hasattr(module, 'config'):
                        print("✅ Configuration object found and accessible")
                    else:
                        print("ℹ️  Configuration object not yet accessible (this is normal)")
                        
                except ImportError as e:
                    print(f"⚠️  Could not import {module_name}: {e}")
                    print("   This might be normal if dependencies aren't fully installed yet")
            else:
                print("ℹ️  No module directories found in src/")
        else:
            print("⚠️  src/ directory not found")
    
    except Exception as e:
        print(f"⚠️  Error during module test: {e}")
    
    print("=" * 50)
    print("🎉 Hello World! Environment setup test completed!")
    print("🎯 Your SupportVectors project environment is ready to use!")

if __name__ == "__main__":
    main()
EOF

echo "Environment test file created at src/test_setup.py"

#--------------------------------------------------------------------------------------

echo "------------------------------------"
echo "Checkin the situation with mkdocs..."
echo "------------------------------------"


# Check if mkdocs.yml exists
if [[ ! -f "mkdocs.yml" ]]; then
    echo "mkdocs.yml does not exist. Creating it."

    # Prompt user for project details
    read -p "Enter the project name: " project_name
    read -p "Enter the project description: " project_description
    read -p "Enter the project URL: " project_url

    #-----------------------------------------------------------------------------------------
    # Update pyproject.toml with project description
    echo "Adding project description to pyproject.toml..."
    
    # Check if [project] section exists, if not create it
    if ! grep -q "\[project\]" pyproject.toml; then
        cat >> pyproject.toml << EOF

[project]
description = "$project_description"
EOF
        echo "Project section with description added to pyproject.toml."
    elif ! grep -q "description = " pyproject.toml; then
        # Add description to existing [project] section
        sed -i '' '/\[project\]/a\
description = "'"$project_description"'"
' pyproject.toml
        echo "Description added to existing project section in pyproject.toml."
    else
        echo "Description already exists in pyproject.toml."
    fi
    
    #-----------------------------------------------------------------------------------------
    # Append project description to docs/index.md
    echo "Adding project description to docs/index.md..."
    
    if [[ -f "docs/index.md" ]]; then
        # Check if description is already in the file
        if ! grep -q "$project_description" docs/index.md; then
            cat >> docs/index.md << EOF

$project_description
EOF
            echo "Project description appended to docs/index.md."
        else
            echo "Project description already exists in docs/index.md."
        fi
    else
        echo "docs/index.md does not exist, skipping description addition."
    fi

    # Populate mkdocs.yml with the template
    cat > mkdocs.yml << EOF
site_name: SupportVectors $project_name
site_description: $project_description
site_author: SupportVectors
site_url: https://supportvectors.ai/$project_url

# -----------------------------------------------------------------------------
# Theme configuration
# -----------------------------------------------------------------------------
theme:
  name: material
  logo: images/overlapping_logo.png
  favicon: images/favicon.ico

  palette:
    # Palette toggle for light mode
    - scheme: default
      primary: 'light blue'
      accent: 'gray'
      toggle:
        icon: material/brightness-7
        name: Switch to dark mode

    # Palette toggle for dark mode
    - scheme: slate
      toggle:
        icon: material/brightness-4
        name: Switch to light mode

  font:
    text: 'Lora'
    code: 'Roboto Mono'
    code_title: 'Roboto Mono'
    code_block: 'Roboto Mono'
    code_font_size: 0.9rem
    heading: 'Merriweather'
    heading_weight: 300
    heading_line_height: 1.5

# -----------------------------------------------------------------------------
# Plugins configuration
# -----------------------------------------------------------------------------

plugins:
  - search
  - mknotebooks:
      # Configure mknotebooks to avoid template deprecation warnings
      enable_default_jupyter_cell_styling: true
      execute: false
  - mkdocstrings:
      handlers:
        python:
          rendering:
            show_source: true
  - awesome-pages
  - mermaid2
  - include-markdown:
      comments: false #This stops the include-markdown plugin comments from being displayed

markdown_extensions:
  - admonition
  - toc:
      permalink: true
  - pymdownx.superfences
  - pymdownx.details
  - pymdownx.arithmatex:
      generic: true
  - pymdownx.superfences:
      # make exceptions to highlighting of code:
      custom_fences:
        - name: mermaid
          class: mermaid
          format: !!python/name:mermaid2.fence_mermaid

extra_css:
  - stylesheets/supportvectors.css

extra_javascript:
  - javascripts/mathjax.js
  #- https://polyfill.io/v3/polyfill.min.js?features=es6
  - https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js
extra:
  PYTHONPATH: src

EOF

    echo "mkdocs.yml created."
else
    echo "mkdocs.yml already exists."
fi

#-----------------------------------------------------------------------------------------

source .env
echo ".env sourced"
uv add svlearn-core
echo "Adding the svlearn-core dependency"
uv add torch datasets
echo "Adding PyTorch and datasets to the project"
uv add matplotlib
echo "Adding matplotlib to the project"
uv add pandas
echo "Adding pandas to the project"
uv add scikit-learn
echo "Adding scikit-learn to the project"
echo "==============================================================="
echo "Building the project...."
echo "==============================================================="
uv build

echo "Running environment setup test to verify everything is working..."
uv run src/test_setup.py

echo "************ SETUP COMPLETE ***********************************"

# Finally, activate the environments

exit



