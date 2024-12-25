date = $(date '+%y.%m.%d')
team = "TODO"

xcodegen: clean
	ETOILE_VERSION=$(date) DEV_TEAM=$(team) xcodegen

clean:
	rm -rf derived Etoile.xcodeproj

build-ios:
	xcodebuild -workspace Etoile.xcodeproj/project.xcworkspace -scheme etoile -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.0' -allowProvisioningUpdates build | xcpretty

build-tvos:
	xcodebuild -workspace Etoile.xcodeproj/project.xcworkspace -scheme etoile.EtoileTvOS -destination 'platform=tvOS Simulator,name=Apple TV 4k,OS=18.0' -allowProvisioningUpdates build | xcpretty

build-tvos:
	xcodebuild -workspace Etoile.xcodeproj/project.xcworkspace -scheme etoile.EtoileWatchos -destination 'platform=watchOS Simulator,name=Apple Watch Ultra,OS=10.0' -allowProvisioningUpdates build | xcpretty

run-ios-sim: build-ios
	xcrun simctl install booted derived/Build/Products/Debug-iphonesimulator/etoile.app
	xcrun simctl launch --console booted page.juliette.etoile
