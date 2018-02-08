export AWS_ACCESS_KEY_ID=AKIAIX5ESCHNGHMM64VQ
export AWS_SECRET_ACCESS_KEY=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
PREFIX=Xcode92
if [ "$1" == "update" ]; then 
	carthage update --platform iOS --use-ssh --no-build
fi

rm -rf Carthage/Build/iOS/*

#otherwise, ignore the carthage update
rome download --platform iOS  --cache-prefix ${PREFIX} # download missing frameworks (or copy from local cache)
rome list --missing --platform iOS  --cache-prefix ${PREFIX} | awk '{print $1}' | xargs carthage bootstrap --platform iOS --cache-builds --use-ssh # list what is missing and update/build if needed
if [ $? -eq 0 ]; then
 	rome list --missing --platform iOS  --cache-prefix ${PREFIX} | awk '{print $1}' | xargs rome upload --platform iOS  --cache-prefix ${PREFIX} # upload what is missing
    rm -rf Carthage/Checkouts
else
  echo "Carthage bootstrap failed.. Investigate and try running this script again when completed"
  say "error with rome"
  exit 1
fi

if type "say" > /dev/null; then
	say dependencies downloaded
fi

