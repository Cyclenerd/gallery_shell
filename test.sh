#!/usr/bin/env bash

# gallery.sh Test Script
#
# https://github.com/lehmannro/assert.sh

if [ ! -e assert.sh ]; then
	echo "downloading unit test script"
	curl -f "https://raw.githubusercontent.com/lehmannro/assert.sh/v1.1/assert.sh" -o assert.sh
fi

# Copy demo files
cp images/demo/* ./

# shellcheck disable=SC1091
source assert.sh

# `echo test` is expected to write "test" on stdout
assert "echo test" "test"
# `seq 3` is expected to print "1", "2" and "3" on different lines
assert "seq 3" "1\\n2\\n3"
# exit code of `true` is expected to be 0
assert_raises "true"
# exit code of `false` is expected to be 1
assert_raises "false" 1
# end of test suite
assert_end examples

# $ bash gallery.sh -t Test
assert_raises "bash gallery.sh -t Test"

assert "cat index.html | grep '<title>Test</title>' | tr -d '\011\012\015'" '<title>Test</title>'
assert "cat index.html | grep '__thumbs/Landscape_1.jpg.html' | tr -d '\011\012\015'" '<a href="__thumbs/Landscape_1.jpg.html"><img src="__thumbs/406/Landscape_1.jpg" alt="Thumbnail: Landscape_1.jpg" class="rounded mx-auto d-block" height="203"></a>'

assert "cat __thumbs/Landscape_1.jpg.html | grep '<title>Landscape_1.jpg</title>' | tr -d '\011\012\015'" '<title>Landscape_1.jpg</title>'
assert "cat __thumbs/Landscape_1.jpg.html | grep 'Resolution' | tr -d '\040\011\012\015'" 'Resolution:600x450'

assert_end gallery_sh
