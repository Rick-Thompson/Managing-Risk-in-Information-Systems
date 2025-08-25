#!/bin/bash
# Clean Markdown to Common Cartridge Converter

INPUT_FILE="$1"
OUTPUT_PACKAGE="$2"
OUTPUT_DIR="$(dirname "$OUTPUT_PACKAGE")/brightspace-package"

echo "Starting conversion..."
echo "Input: $INPUT_FILE"
echo "Output: $OUTPUT_PACKAGE"
echo "Working dir: $OUTPUT_DIR"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "ERROR: Input file not found: $INPUT_FILE"
    exit 1
fi

echo "Input file found, size: $(wc -c < "$INPUT_FILE") bytes"

# Create output directory
mkdir -p "$OUTPUT_DIR"
echo "Created output directory: $OUTPUT_DIR"

# Create temporary directory
TMP_DIR=$(mktemp -d)
echo "Created temp directory: $TMP_DIR"

# Read metadata if available
COURSE_TITLE="Your Course"
COURSE_DESCRIPTION="Course Description"

if [ -f "metadata.yml" ]; then
    echo "Reading metadata..."
    if command -v yq >/dev/null 2>&1; then
        TITLE=$(yq e '.title' metadata.yml 2>/dev/null || echo "")
        if [ -n "$TITLE" ] && [ "$TITLE" != "null" ]; then
            COURSE_TITLE="$TITLE"
            echo "Course title: $COURSE_TITLE"
        fi
    fi
fi

# Split content by chapters (##)
echo "Splitting content by chapters..."
awk '
BEGIN {
    file_num = 1
    current_file = ""
}
/^## / {
    if (current_file != "") close(current_file)
    current_file = "'"$TMP_DIR"'/chapter_" sprintf("%03d", file_num) ".md"
    print "# " substr($0, 4) > current_file
    file_num++
    next
}
{
    if (current_file != "") print $0 >> current_file
}
' "$INPUT_FILE"

# Count chapters created
CHAPTER_COUNT=$(find "$TMP_DIR" -name "chapter_*.md" | wc -l)
echo "Created $CHAPTER_COUNT chapters"

if [ "$CHAPTER_COUNT" -eq 0 ]; then
    echo "No chapters found, creating single chapter"
    cp "$INPUT_FILE" "$TMP_DIR/chapter_001.md"
    CHAPTER_COUNT=1
fi

# Convert chapters to HTML
echo "Converting chapters to HTML..."
counter=1
for chapter_file in "$TMP_DIR"/chapter_*.md; do
    if [ -f "$chapter_file" ]; then
        title=$(head -n1 "$chapter_file" | sed 's/^# //')
        html_file="$OUTPUT_DIR/chapter_${counter}.html"
        echo "Converting: $title"

        if command -v pandoc >/dev/null 2>&1; then
            pandoc -f markdown -t html "$chapter_file" -o "$html_file" \
                --standalone --metadata title="$title"
        else
            echo "ERROR: pandoc not found"
            exit 1
        fi
        counter=$((counter + 1))
    fi
done

# Create CSS
echo "Creating CSS..."
cat > "$OUTPUT_DIR/styles.css" << 'EOF'
body { font-family: Arial, sans-serif; line-height: 1.6; max-width: 800px; margin: 0 auto; padding: 20px; }
h1, h2, h3 { color: #333; }
pre { background: #f5f5f5; padding: 10px; border-radius: 5px; }
code { background: #f5f5f5; padding: 2px 4px; border-radius: 3px; }
EOF

# Create manifest
echo "Creating manifest..."
MANIFEST_ID="manifest_$(uuidgen | tr -d '-')"
ORG_ID="org_$(uuidgen | tr -d '-')"

cat > "$OUTPUT_DIR/imsmanifest.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<manifest identifier="$MANIFEST_ID" xmlns="http://www.imsglobal.org/xsd/imsccv1p1/imscp_v1p1">
  <metadata>
    <schema>IMS Common Cartridge</schema>
    <schemaversion>1.1.0</schemaversion>
  </metadata>
  <organizations>
    <organization identifier="$ORG_ID">
      <item identifier="root">
        <title>$COURSE_TITLE</title>
EOF

# Add chapters to manifest
counter=1
for html_file in "$OUTPUT_DIR"/chapter_*.html; do
    if [ -f "$html_file" ]; then
        filename=$(basename "$html_file")
        resource_id="resource_$(uuidgen | tr -d '-')"
        title=$(grep -m1 '<title>' "$html_file" | sed 's/<title>\(.*\)<\/title>/\1/' | sed 's/^[[:space:]]*//')

        cat >> "$OUTPUT_DIR/imsmanifest.xml" << EOF
        <item identifier="item_$counter" identifierref="$resource_id">
          <title>$title</title>
        </item>
EOF
        counter=$((counter + 1))
    fi
done

cat >> "$OUTPUT_DIR/imsmanifest.xml" << 'EOF'
      </item>
    </organization>
  </organizations>
  <resources>
EOF

# Add resources to manifest
counter=1
for html_file in "$OUTPUT_DIR"/chapter_*.html; do
    if [ -f "$html_file" ]; then
        filename=$(basename "$html_file")
        resource_id="resource_$(uuidgen | tr -d '-')"

        cat >> "$OUTPUT_DIR/imsmanifest.xml" << EOF
    <resource identifier="$resource_id" type="webcontent" href="$filename">
      <file href="$filename"/>
      <file href="styles.css"/>
    </resource>
EOF
        counter=$((counter + 1))
    fi
done

cat >> "$OUTPUT_DIR/imsmanifest.xml" << 'EOF'
  </resources>
</manifest>
EOF

# Create package
echo "Creating Common Cartridge package..."
cd "$OUTPUT_DIR"
if command -v zip >/dev/null 2>&1; then
    zip -r "../$(basename "$OUTPUT_PACKAGE")" * >/dev/null
    cd - >/dev/null

    # Check if we need to move the file
    SOURCE_FILE="$(dirname "$OUTPUT_DIR")/$(basename "$OUTPUT_PACKAGE")"
    if [ "$SOURCE_FILE" != "$OUTPUT_PACKAGE" ]; then
        if mv "$SOURCE_FILE" "$OUTPUT_PACKAGE"; then
            echo "Package moved to: $OUTPUT_PACKAGE"
        else
            echo "ERROR: Failed to move package from $SOURCE_FILE to $OUTPUT_PACKAGE"
            exit 1
        fi
    else
        echo "Package created at: $OUTPUT_PACKAGE"
    fi

    if [ -f "$OUTPUT_PACKAGE" ]; then
        ls -la "$OUTPUT_PACKAGE"
        echo "SUCCESS: Common Cartridge package created!"
    else
        echo "ERROR: Package file not found at expected location"
        exit 1
    fi
else
    echo "ERROR: zip command not found"
    exit 1
fi

# Cleanup
rm -rf "$TMP_DIR"
echo "Conversion completed successfully!"
echo "Created $CHAPTER_COUNT chapters in Common Cartridge format"
