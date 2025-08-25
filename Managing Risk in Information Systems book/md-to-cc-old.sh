#!/bin/bash
# Markdown to Common Cartridge Converter for D2L Brightspace
# For Debian 12 systems
# This script converts a markdown file into a Common Cartridge package

# Exit on error
set -e

# Default configuration
INPUT_FILE="content.md"
OUTPUT_DIR="build/brightspace-package"
COURSE_TITLE="Your Course Title"
COURSE_DESCRIPTION="Your course description here"
TMP_DIR="" # Will be set in main()

# Read metadata from YAML file if it exists
if [ -f "metadata.yml" ]; then
  echo "Found metadata.yml file, reading course information..."
  
  # Check if yq is installed
  if ! command -v yq &> /dev/null; then
    echo "ERROR: yq is required but not installed. Please run the install-dependencies.sh script first."
    exit 1
  fi
  
  # Extract course title and description from metadata.yml
  if TITLE=$(yq e '.title' metadata.yml | head -n1 2>/dev/null) && [ "$TITLE" != "null" ]; then
    COURSE_TITLE="$TITLE"
    echo "Found course title: $COURSE_TITLE"
  fi
  
  if ABSTRACT=$(yq e '.abstract' metadata.yml 2>/dev/null) && [ "$ABSTRACT" != "null" ]; then
    # Remove pipe character and any leading/trailing whitespace
    COURSE_DESCRIPTION=$(echo "$ABSTRACT" | sed 's/^|//;s/^[[:space:]]*//;s/[[:space:]]*$//')
    echo "Found course description from abstract"
  fi
fi

# Set output package name based on course title
OUTPUT_PACKAGE="$COURSE_TITLE.imscc"

# Check required dependencies
check_dependencies() {
  echo "Checking dependencies..."
  
  local missing_deps=()
  
  # List of required tools
  local required_tools=("pandoc" "zip" "xmlstarlet" "uuidgen" "yq")
  
  # Check each tool
  for tool in "${required_tools[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
      missing_deps+=("$tool")
    fi
  done
  
  # If there are missing dependencies, exit with error
  if [ ${#missing_deps[@]} -gt 0 ]; then
    echo "ERROR: The following required tools are missing:"
    for dep in "${missing_deps[@]}"; do
      echo "  - $dep"
    done
    echo "Please run the install-dependencies.sh script first."
    exit 1
  fi
  
  echo "All dependencies are installed."
}

# Create a UUID (without hyphens)
create_uuid() {
  uuidgen | tr -d '-'
}

# Create output directory
create_directories() {
  echo "Creating output directory: $OUTPUT_DIR"
  mkdir -p "$OUTPUT_DIR"
}

# Combine markdown files from source directory
combine_source_files() {
  local combined_file="$TMP_DIR/combined.md"
  
  if [ -d "source" ] && [ -n "$(ls -A source/*.md 2>/dev/null)" ]; then
    echo "Found markdown files in source directory. Combining them..."
    
    # Create combined.md file
    touch "$combined_file"
    
    # Get all .md files in the source directory, sort them numerically
    find "source" -name "*.md" -print0 | sort -z | while IFS= read -r -d $'\0' source_file; do
      echo "Adding \"$source_file\" to combined file"
      cat "$source_file" >> "$combined_file"
      # Add a newline between files to ensure proper separation
      echo -e "\n\n" >> "$combined_file"
    done
    
    echo "Created combined markdown file at $combined_file"
    INPUT_FILE="$combined_file"
  fi
}

# Split the combined markdown file into sections
split_into_sections() {
  echo "Splitting markdown into sections..."
  
  # Split the file on H1 headings (# )
  csplit --prefix="$TMP_DIR/section_" --suffix-format="%03d.md" "$INPUT_FILE" '/^# /' '{*}' > /dev/null 2>&1 || true
  
  # Get the list of section files
  local section_files
  section_files=$(find "$TMP_DIR" -name "section_*.md" | sort)
  
  if [ -z "$section_files" ]; then
    echo "Warning: No sections found. Using the entire file as one section."
    cp "$INPUT_FILE" "$TMP_DIR/section_000.md"
    section_files="$TMP_DIR/section_000.md"
  fi
  
  echo "Found $(echo "$section_files" | wc -l) sections"
  return 0
}

# Convert markdown sections to HTML
convert_sections_to_html() {
  echo "Converting sections to HTML..."
  
  # Create an array to store section titles
  declare -a SECTION_TITLES
  declare -a SECTION_FILES
  
  # Counter for content files
  local counter=1
  
  # Process each section
  for section_file in "$TMP_DIR"/section_*.md; do
    # Extract the section title from the first line (if it starts with #)
    local title
    title=$(head -n 1 "$section_file" | sed -n 's/^#\+ \(.*\)/\1/p')
    
    # If no title found (e.g., content before first heading), use default
    if [ -z "$title" ]; then
      title="Section $counter"
    fi
    
    # Create HTML file from markdown section
    echo "Converting section: $title"
    local output_file="$OUTPUT_DIR/content_${counter}.html"
    
    # Convert markdown to HTML using pandoc
    pandoc -f markdown -t html "$section_file" -o "$output_file" \
      --standalone \
      --metadata title="$title" \
      --css="styles.css"
    
    # Add to section arrays
    SECTION_TITLES+=("$title")
    SECTION_FILES+=("content_${counter}.html")
    
    # Increment counter
    counter=$((counter + 1))
  done
  
  # Create CSS file with basic styling
  cat > "${OUTPUT_DIR}/styles.css" << EOF
body {
  font-family: Arial, sans-serif;
  line-height: 1.6;
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
}
pre {
  background-color: #f5f5f5;
  padding: 15px;
  border-radius: 5px;
  overflow-x: auto;
}
code {
  background-color: #f5f5f5;
  padding: 2px 4px;
  border-radius: 3px;
}
img {
  max-width: 100%;
  height: auto;
}
table {
  border-collapse: collapse;
  width: 100%;
}
th, td {
  border: 1px solid #ddd;
  padding: 8px;
}
th {
  background-color: #f2f2f2;
}
EOF
}

# Create manifest file
create_manifest() {
  echo "Creating manifest file..."
  
  # Generate UUIDs
  local manifest_id="manifest_$(create_uuid)"
  local organization_id="organization_$(create_uuid)"
  
  # Start creating manifest XML
  cat > "${OUTPUT_DIR}/imsmanifest.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<manifest identifier="${manifest_id}" xmlns="http://www.imsglobal.org/xsd/imsccv1p1/imscp_v1p1" 
  xmlns:lom="http://ltsc.ieee.org/xsd/imsccv1p1/LOM/resource" 
  xmlns:lomimscc="http://ltsc.ieee.org/xsd/imsccv1p1/LOM/manifest" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  xsi:schemaLocation="http://www.imsglobal.org/xsd/imsccv1p1/imscp_v1p1 http://www.imsglobal.org/xsd/imscp_v1p1.xsd http://ltsc.ieee.org/xsd/imsccv1p1/LOM/resource http://www.imsglobal.org/xsd/imsccv1p1/LOM/resource.xsd http://ltsc.ieee.org/xsd/imsccv1p1/LOM/manifest http://www.imsglobal.org/xsd/imsccv1p1/LOM/manifest.xsd">
  <metadata>
    <schema>IMS Common Cartridge</schema>
    <schemaversion>1.1.0</schemaversion>
    <lomimscc:lom>
      <lomimscc:general>
        <lomimscc:title>
          <lomimscc:string>${COURSE_TITLE}</lomimscc:string>
        </lomimscc:title>
        <lomimscc:description>
          <lomimscc:string>${COURSE_DESCRIPTION}</lomimscc:string>
        </lomimscc:description>
      </lomimscc:general>
    </lomimscc:lom>
  </metadata>
  <organizations>
    <organization identifier="${organization_id}" structure="rooted-hierarchy">
      <item identifier="root">
        <title>${COURSE_TITLE}</title>
EOF
  
  # Find all content HTML files
  local content_files
  local resources_xml=""
  
  # Look for content files in the output directory
  content_files=$(find "$OUTPUT_DIR" -name "content_*.html" | sort)
  
  # Add each section as an item and create resources
  local counter=1
  for content_file in $content_files; do
    local filename=$(basename "$content_file")
    local resource_id="resource_$(create_uuid)"
    local title
    
    # Try to extract title from HTML file
    title=$(grep -m 1 "<title>" "$content_file" | sed 's/<title>\(.*\)<\/title>/\1/' || echo "Section $counter")
    
    # Add item to manifest
    cat >> "${OUTPUT_DIR}/imsmanifest.xml" << EOF
        <item identifier="item_${counter}" identifierref="${resource_id}">
          <title>${title}</title>
        </item>
EOF
    
    # Build resource XML entry
    resources_xml+="    <resource identifier=\"${resource_id}\" type=\"webcontent\" href=\"${filename}\">\n"
    resources_xml+="      <file href=\"${filename}\"/>\n"
    resources_xml+="      <file href=\"styles.css\"/>\n"
    resources_xml+="    </resource>\n"
    
    counter=$((counter + 1))
  done
  
  # Close organization section
  cat >> "${OUTPUT_DIR}/imsmanifest.xml" << EOF
      </item>
    </organization>
  </organizations>
  <resources>
EOF
  
  # Add resources section
  echo -e "$resources_xml" >> "${OUTPUT_DIR}/imsmanifest.xml"
  
  # Close resources section
  cat >> "${OUTPUT_DIR}/imsmanifest.xml" << EOF
  </resources>
</manifest>
EOF

  echo "Manifest file created."
}

# Create Common Cartridge package
create_package() {
  echo "Creating Common Cartridge package..."
  
  # Navigate to the output directory
  cd "$OUTPUT_DIR"
  
  # Create zip file (Common Cartridge package)
  zip -r "../$OUTPUT_PACKAGE" * >/dev/null 2>&1
  
  # Return to original directory
  cd ..
  
  echo "Package created: $OUTPUT_PACKAGE"
}

# Main execution
main() {
  echo "Starting Markdown to Common Cartridge converter..."
  
  # Check dependencies
  check_dependencies
  
  # Create temporary directory
  TMP_DIR=$(mktemp -d)
  
  # Create output directory
  create_directories
  
  # Combine source files if needed
  combine_source_files
  
  # Split content into sections
  split_into_sections
  
  # Convert sections to HTML
  convert_sections_to_html
  
  # Create manifest file
  create_manifest
  
  # Create package
  create_package
  
  # Clean up temporary files
  rm -rf "$TMP_DIR"
  
  echo "Conversion completed successfully."
  echo "The file $OUTPUT_PACKAGE is ready to be imported into D2L Brightspace."
}

# Run the main function
main
