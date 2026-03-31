SCHEME   = WhisperClone
BUILD    = .build
DIST     = dist
APP      = WhisperClone.app

.PHONY: setup generate build clean package

## Install XcodeGen if missing and generate the .xcodeproj
setup:
	@command -v xcodegen >/dev/null 2>&1 || brew install xcodegen
	xcodegen generate

## Open the project in Xcode
open: setup
	open WhisperClone.xcodeproj

## Build a Release binary
build: setup
	xcodebuild \
		-scheme $(SCHEME) \
		-configuration Release \
		-derivedDataPath $(BUILD) \
		build

## Zip the .app for distribution / GitHub release
package: build
	@mkdir -p $(DIST)
	cp -R "$(BUILD)/Build/Products/Release/$(APP)" $(DIST)/
	cd $(DIST) && zip -r --symlinks WhisperClone.zip $(APP)
	@echo ""
	@echo "✅  $(DIST)/WhisperClone.zip is ready."
	@echo "    Upload it to a GitHub release, then update Cask/whisper-clone.rb"
	@echo "    with the correct SHA-256:"
	@shasum -a 256 $(DIST)/WhisperClone.zip

clean:
	rm -rf $(BUILD) $(DIST) *.xcodeproj
