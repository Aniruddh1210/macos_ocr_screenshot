#!/usr/bin/make -f

SWIFTC?=swiftc
ROOT_DIR:=$(shell pwd)
BIN_DIR:=$(ROOT_DIR)/bin
VISION_SRC=$(ROOT_DIR)/tools/vision_ocr/main.swift
VISION_BIN=$(BIN_DIR)/vision_ocr
APP_SRC=$(ROOT_DIR)/OCRScreenshot/OCRScreenshot.swift
APP_BIN=$(ROOT_DIR)/OCRScreenshot/OCRScreenshot

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

test: build
	./scripts/test_ocr.sh

test-all: build
	./scripts/test_ocr.sh
	./scripts/test_ocrshot_unified.sh

clean:
	rm -rf $(BIN_DIR)
	@echo "Cleaned bin directory"