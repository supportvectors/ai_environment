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

[tool.hatch]
packages = "src"

[tool.pytest.ini_options]
testpaths = ["tests"]
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
echo "Moving hello.py to src/"
mv hello.py src/

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

    # Populate mkdocs.yml with the template
    cat > mkdocs.yml << EOF
site_name: SupportVectors $project_name
site_description: $project_description
site_author: SupportVectors
site_url: https://supportvectors.ai/$project_url
favicon: images/favicon.ico

# -----------------------------------------------------------------------------
# Theme configuration
# -----------------------------------------------------------------------------
theme:
  name: material
  logo: images/overlapping_logo.png

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
  - mknotebooks
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
uv add svlearn-bootcamp
echo "Adding the svlearn-bootcamp dependency"

echo "==============================================================="
echo "Building the project...."
echo "==============================================================="
uv build

echo "Finally, running hello to make sure all is well"
uv run src/hello.py

echo "************ SETUP COMPLETE ***********************************"

# Finally, activate the environments

exit



