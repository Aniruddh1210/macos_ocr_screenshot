#!/usr/bin/make -f

SWIFTC?=swiftc
ROOT_DIR:=$(shell pwd)
BIN_DIR:=$(ROOT_DIR)/bin
VISION_SRC=$(ROOT_DIR)/tools/vision_ocr/main.swift
VISION_BIN=$(BIN_DIR)/vision_ocr
APP_SRC=$(ROOT_DIR)/OCRScreenshot/OCRScreenshot.swift
APP_BIN=$(ROOT_DIR)/OCRScreenshot/OCRScreenshot
LENS_SRC=$(ROOT_DIR)/OCRSelect/OCRSelect.swift
LENS_BIN=$(ROOT_DIR)/OCRSelect/OCRSelect
LENS_APP=$(ROOT_DIR)/OCRSelect2.app
LENS_APP_BIN=$(LENS_APP)/Contents/MacOS/TextGrabber
LENS_INFO=$(LENS_APP)/Contents/Info.plist
LENS_INFO_TEMPLATE=$(ROOT_DIR)/mac/TextGrabber.Info.plist

.PHONY: all build vision app install test test-all clean help

all: build

help:
	@echo "Targets:"
	@echo "  make vision   - build Vision OCR CLI"
	@echo "  make app      - build OCRScreenshot app binary"
	@echo "  make build    - build all components"
	@echo "  make test     - run sample OCR test"
	@echo "  make clean    - remove build artifacts"

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

vision: $(BIN_DIR) $(VISION_SRC)
	$(SWIFTC) -O -o $(VISION_BIN) $(VISION_SRC) -framework Vision -framework AppKit
	@echo "Built $(VISION_BIN)"

app: $(APP_SRC)
	$(SWIFTC) -parse-as-library -O -o $(APP_BIN) $(APP_SRC) -framework Cocoa -framework Vision -framework SwiftUI
	@echo "Built $(APP_BIN)"

build: vision app
 
lens: $(LENS_SRC)
	$(SWIFTC) -parse-as-library -O -o $(LENS_BIN) $(LENS_SRC) -framework Cocoa -framework Vision -framework SwiftUI
	@echo "Built $(LENS_BIN)"

.PHONY: lens-bundle
lens-bundle: lens $(LENS_INFO)
	mkdir -p $(dir $(LENS_APP_BIN))
	cp $(LENS_BIN) $(LENS_APP_BIN)
	chmod +x $(LENS_APP_BIN)
	@echo "Bundled $(LENS_APP_BIN)"

$(LENS_INFO):
	mkdir -p $(dir $(LENS_INFO))
	@echo "Copying $(LENS_INFO_TEMPLATE) -> $(LENS_INFO)"
	cp $(LENS_INFO_TEMPLATE) $(LENS_INFO)

test: build
	./scripts/test_ocr.sh

test-all: build
	./scripts/test_ocr.sh
	./scripts/test_ocrshot_unified.sh

clean:
	rm -rf $(BIN_DIR)
	@echo "Cleaned bin directory"