bump:
	agvtool new-version -all `git rev-list --all --count`

new_release:
	agvtool new-marketing-version ${VERSION}
