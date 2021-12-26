bump:
	agvtool new-version -all `git rev-list --all --count`
	agvtool new-marketing-version ${VERSION}
	git add iOS\ \(App\)/Info.plist iOS\ \(Extension\)/Info.plist macOS\ \(App\)/Info.plist macOS\ \(Extension\)/Info.plist
	git commit -m "Bump version"
	git push

release:
	gh release create v${VERSION}
