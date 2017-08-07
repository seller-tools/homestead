#!/usr/bin/env bash

stpath=$1

echo "Configuring SellerTools"

cd $stpath

for example_f in $(find . | grep -v 'vendor\|node_modules' | grep '.example$'); do
	target_f=${example_f%.example}
	if [ ! -f $target_f ]; then
	    echo "Copying example file for $target_f"
	    cp $example_f $target_f
	fi
done


exit 0