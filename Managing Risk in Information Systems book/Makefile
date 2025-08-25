####################################################################################################
# Configuration
####################################################################################################

# Build configuration

BUILD = build
MAKEFILE = Makefile
OUTPUT_FILENAME = book
VERSION = 1.0.0
METADATA = metadata.yml
CHAPTERS = book-source/*.md

# Generate a list of all source files
ALL_SOURCES = $(shell find source -name "*.md" -type f)
CHAPTER_FILES = $(filter source/chapter%/100-chapter.md,$(ALL_SOURCES))
TOC = --toc
METADATA_ARGS = --metadata-file $(METADATA)
IMAGES = $(shell find images -type f)
TEMPLATES = $(shell find templates/ -type f)
COVER_IMAGE = images/cover.jpg
MATH_FORMULAS = --webtex

# Chapters content
CONTENT = find source -name "*.md" -type f -print0 | sort -z | xargs -0 cat
# Alternative with better handling of chapter breaks:
# CONTENT = find source -name "*.md" -type f -print0 | sort -z | xargs -0 awk 'FNR==1{if(NR!=1)print "\n\n"}{print}'
CONTENT_FILTERS = tee # Use this to add sed filters or other piped commands

# Debugging

# DEBUG_ARGS = --verbose

# Pandoc filtes - uncomment the following variable to enable cross references filter. For more
# information, check the "Cross references" section on the README.md file.

#FILTER_ARGS = --lua-filter pagebreak.lua

# Combined arguments

ARGS = $(TOC) $(MATH_FORMULAS) $(METADATA_ARGS) $(FILTER_ARGS) $(DEBUG_ARGS) -f markdown
	
PANDOC_COMMAND = pandoc

# Per-format options

DOCX_ARGS = --standalone --reference-doc templates/docx.docx --template templates/word.openxml
EPUB_ARGS = --template templates/epub.html --epub-cover-image $(COVER_IMAGE)
HTML_ARGS = --template templates/html.html --standalone --to html5
PDF_ARGS = --template templates/pdf.latex --pdf-engine xelatex

# Per-format file dependencies

BASE_DEPENDENCIES = $(MAKEFILE) $(CHAPTERS) $(METADATA) $(IMAGES) $(TEMPLATES)
DOCX_DEPENDENCIES = $(BASE_DEPENDENCIES) $(ALL_SOURCES)
EPUB_DEPENDENCIES = $(BASE_DEPENDENCIES) $(ALL_SOURCES)
HTML_DEPENDENCIES = $(BASE_DEPENDENCIES) $(ALL_SOURCES)
PDF_DEPENDENCIES = $(BASE_DEPENDENCIES) $(ALL_SOURCES)
CC_DEPENDENCIES = $(BASE_DEPENDENCIES) $(ALL_SOURCES) md-to-cc.sh

# Detected Operating System

OS = $(shell sh -c 'uname -s 2>/dev/null || echo Unknown')

# OS specific commands

ifeq ($(OS),Darwin) # Mac OS X
	COPY_CMD = cp -P
else # Linux
	COPY_CMD = cp --parent
endif


MKDIR_CMD = mkdir -p
RMDIR_CMD = rm -r
ECHO_BUILDING = @echo "building $@..."
ECHO_BUILT = @echo "$@ was built\n"

####################################################################################################
# Basic actions
####################################################################################################

.PHONY: all book clean epub html pdf docx cc help clean-pdf clean-html clean-epub clean-docx clean-cc clean-all debug-vars version

all:	book

book:	epub html pdf docx cc

clean:
	$(RMDIR_CMD) $(BUILD)

clean-pdf:
	rm -f $(BUILD)/pdf/$(OUTPUT_FILENAME).pdf

clean-html:
	rm -f $(BUILD)/html/$(OUTPUT_FILENAME).html
	rm -rf $(BUILD)/html/images

clean-epub:
	rm -f $(BUILD)/epub/$(OUTPUT_FILENAME).epub

clean-docx:
	rm -f $(BUILD)/docx/$(OUTPUT_FILENAME).docx

clean-cc:
	rm -f $(BUILD)/cc/$(OUTPUT_FILENAME).imscc
	rm -f $(BUILD)/cc/$(OUTPUT_FILENAME).md

clean-all: clean-pdf clean-html clean-epub clean-docx clean-cc

debug-vars:
	@echo "BUILD = $(BUILD)"
	@echo "CHAPTERS = $(CHAPTERS)"
	@echo "ALL_SOURCES = $(ALL_SOURCES)"
	@echo "IMAGES = $(IMAGES)"
	@echo "TEMPLATES = $(TEMPLATES)"

version:
	@echo "Book Build System v$(VERSION)"

help:
	@echo "Book Build System"
	@echo "================="
	@echo "make all       - Build all formats"
	@echo "make epub      - Build EPUB format"
	@echo "make html      - Build HTML format"
	@echo "make pdf       - Build PDF format"
	@echo "make docx      - Build DOCX format"
	@echo "make cc        - Build Common Cartridge format"
	@echo "make clean     - Remove build directory"
	@echo "make clean-pdf - Remove only PDF builds"
	@echo "make clean-html - Remove only HTML builds"
	@echo "make clean-epub - Remove only EPUB builds"
	@echo "make clean-docx - Remove only DOCX builds"
	@echo "make clean-cc   - Remove only CC builds"
	@echo "make clean-all  - Remove all builds"
	@echo "make debug-vars - Display debug information"
	@echo "make version    - Display version information"

####################################################################################################
# File builders
####################################################################################################

epub:	$(BUILD)/epub/$(OUTPUT_FILENAME).epub

html:	$(BUILD)/html/$(OUTPUT_FILENAME).html

pdf:	$(BUILD)/pdf/$(OUTPUT_FILENAME).pdf

docx:	$(BUILD)/docx/$(OUTPUT_FILENAME).docx

cc:	$(BUILD)/cc/$(OUTPUT_FILENAME).imscc

$(BUILD)/epub/$(OUTPUT_FILENAME).epub:	$(EPUB_DEPENDENCIES)
	$(ECHO_BUILDING)
	@$(MKDIR_CMD) $(BUILD)/epub || (echo "Failed to create directory" && exit 1)
	$(CONTENT) | $(CONTENT_FILTERS) | $(PANDOC_COMMAND) $(ARGS) $(EPUB_ARGS) -o $@ || (echo "Failed to build EPUB" && exit 1)
	$(ECHO_BUILT)

$(BUILD)/html/$(OUTPUT_FILENAME).html:	$(HTML_DEPENDENCIES)
	$(ECHO_BUILDING)
	@$(MKDIR_CMD) $(BUILD)/html || (echo "Failed to create directory" && exit 1)
	$(CONTENT) | $(CONTENT_FILTERS) | $(PANDOC_COMMAND) $(ARGS) $(HTML_ARGS) -o $@ || (echo "Failed to build HTML" && exit 1)
	$(COPY_CMD) $(IMAGES) $(BUILD)/html/ 2>/dev/null || true
	$(ECHO_BUILT)

$(BUILD)/pdf/$(OUTPUT_FILENAME).pdf:	$(PDF_DEPENDENCIES)
	$(ECHO_BUILDING)
	@$(MKDIR_CMD) $(BUILD)/pdf || (echo "Failed to create directory" && exit 1)
	$(CONTENT) | $(CONTENT_FILTERS) | $(PANDOC_COMMAND) $(ARGS) $(PDF_ARGS) -o $@ || (echo "Failed to build PDF" && exit 1)
	$(ECHO_BUILT)

$(BUILD)/docx/$(OUTPUT_FILENAME).docx:	$(DOCX_DEPENDENCIES)
	$(ECHO_BUILDING)
	@$(MKDIR_CMD) $(BUILD)/docx || (echo "Failed to create directory" && exit 1)
	$(CONTENT) | $(CONTENT_FILTERS) | $(PANDOC_COMMAND) $(ARGS) $(DOCX_ARGS) -o $@ || (echo "Failed to build DOCX" && exit 1)
	$(ECHO_BUILT)

$(BUILD)/cc/$(OUTPUT_FILENAME).imscc:	$(CC_DEPENDENCIES)
	$(ECHO_BUILDING)
	@$(MKDIR_CMD) $(BUILD)/cc || (echo "Failed to create directory" && exit 1)
	$(CONTENT) | $(CONTENT_FILTERS) > $(BUILD)/cc/$(OUTPUT_FILENAME).md || (echo "Failed to create CC markdown file" && exit 1)
	./md-to-cc.sh $(BUILD)/cc/$(OUTPUT_FILENAME).md $@ || (echo "Failed to build CC format" && exit 1)
	@if [ -d images ]; then $(COPY_CMD) $(IMAGES) $(BUILD)/cc/ 2>/dev/null || true; fi
	$(ECHO_BUILT)