release:
	agvtool new-version -all `git rev-list --all --count`
	agvtool new-marketing-version ${VERSION}
	git add URLLinker/Info.plist SafariExtension/Info.plist
	git commit -m "Bump version"
	git push
	gh release create v${VERSION}
