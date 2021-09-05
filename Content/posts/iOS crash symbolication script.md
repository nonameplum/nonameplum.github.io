---
date: 2021-02-20 17:38
description: iOS crash symbolication script
tags: Xcode
tagColors: Xcode=006b75
---
# A script to symbolicate crash log and verify if the crash log file matches the build UUID

To get the best symbolication result, or event to get a proper symbolication of a crash log, the appropriate `dSYM` and application build is required.
The `symbolicatecrash` tool allows to symbolicate a crash log that doesn't exactly match the build and `dSYM` that you would like to use.
This script besides the symbolication, it also checks if the crash log UUID matches the build UUID.
Just run this script on a folder with your `.ipa`, the corresponding `.dSYM`, and (1+) `.crash` files. Will output symbolicated `sym-*.crash`es for you.

[Download the script](https://gist.github.com/nonameplum/484f6a69487f912d89428a9253a14dac/archive/0eec4ccf3822dfc8fdf447b1f08dc0dcc25999a2.zip)

```bash
#!/bin/bash
#
# Fool'n'Lazy-Proof iOS .crash Symbolication
#
# Just run this script on a folder with your `.ipa`, the corresponding `.dSYM`, 
# and (1+) `.crash` files. Will output symbolicated `sym-*.crash`es for you.
#
# Copyright (c) 2016 Ferran Poveda (@fbeeper)
# Provided under MIT License (MIT): http://choosealicense.com/licenses/mit/
#
# Extended by Lukasz Sliwinski to check equality of the build's UUID with the crash logs
#

function checkForRequiredFileOfType() 
{ 
	count=`find $1 -print -quit 2> /dev/null | wc -l | awk '{print \$1}'`
	if [[ $count > 0 ]]; then
		echo "Found a $1 file"
	else
		echo "Missing a $1 file! Need *.ipa + *.dSYM + *.crash files."
		exit
	fi
}

function checkForRequiredFiles()
{
	checkForRequiredFileOfType "*.ipa"
	checkForRequiredFileOfType "*.dSYM"
	checkForRequiredFileOfType "*.crash"
}

# Define location of symbolicatecrash binary (defaults to Xcode location, but can be defined on params)
symbolicatecrash=${symbolicatecrash:-/Applications/Xcode.app/Contents/SharedFrameworks/DVTFoundation.framework/Versions/A/Resources/symbolicatecrash}

# Let's make sure you haven't forgotten any file
checkForRequiredFiles

# Extract .ipa and define where the binary is (assuming it has the same name)
ipa=`find *.ipa -print -quit`
bsdtar -xf "$ipa" -s'|[^/]*/||'
app=`find *.app -print -quit`
app="$app$/${app%.*}"

dSYM=`find *.dSYM -print -quit`
uuid=`dwarfdump -u $dSYM | perl -ne 'print $1 if /UUID: (.*) \(arm64\)/s' | cut -c 1-42 | tr -d '-' | awk '{ print tolower($0) }'`

echo ""
echo "Build UUDD: $uuid"
echo ""

# Symbolicate all .crash files
export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
for i in *.crash; do

	if [[ ! $i == sym* ]]; then # Skips previous output files from this script

		build_name=`grep '{"app_name":' $i | perl -ne 'print $1 if /{"app_name":"([^"]+)","/s' | awk '{ print($0) }'`

		crashFileUuid=`grep --after-context=1000 "Binary Images:" $i | grep "$build_name arm64" | perl -ne 'print $1 if /.*<(.*)>/s' | awk '{ print($0) }'`

		if [ "$uuid" == "$crashFileUuid" ]; then
			"$symbolicatecrash" "$i" "$app" > "sym-$i"
			echo "✅ Symbolicated $i"
		else
			echo "❌ skipped $i (crash UUID [$crashFileUuid] do not match build's UUID: [$uuid]"
		fi

	fi

done
```