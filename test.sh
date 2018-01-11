#!/usr/bin/env bash

# gallery.sh Test Script
#
# https://github.com/lehmannro/assert.sh

if [ ! -e assert.sh ]; then
	echo "downloading unit test script"
	curl -f "https://raw.githubusercontent.com/lehmannro/assert.sh/v1.1/assert.sh" -o assert.sh
fi

# Download demo files
curl -f "https://cyclenerd.github.io/gallery_shell_demo/Landscape_1.jpg" -o "Landscape_1.jpg"
curl -f "https://cyclenerd.github.io/gallery_shell_demo/Landscape_2.jpg" -o "Landscape_2.jpg"
curl -f "https://cyclenerd.github.io/gallery_shell_demo/Landscape_3.jpg" -o "Landscape_3.jpg"
curl -f "https://cyclenerd.github.io/gallery_shell_demo/Landscape_4.jpg" -o "Landscape_4.jpg"
curl -f "https://cyclenerd.github.io/gallery_shell_demo/Landscape_5.jpg" -o "Landscape_5.jpg"
curl -f "https://cyclenerd.github.io/gallery_shell_demo/Landscape_6.jpg" -o "Landscape_6.jpg"
curl -f "https://cyclenerd.github.io/gallery_shell_demo/Landscape_7.jpg" -o "Landscape_7.jpg"
curl -f "https://cyclenerd.github.io/gallery_shell_demo/Landscape_8.jpg" -o "Landscape_8.jpg"
curl -f "https://cyclenerd.github.io/gallery_shell_demo/Portrait_1.jpg"  -o "Portrait_1.jpg"
curl -f "https://cyclenerd.github.io/gallery_shell_demo/Portrait_2.jpg"  -o "Portrait_2.jpg"
curl -f "https://cyclenerd.github.io/gallery_shell_demo/Portrait_3.jpg"  -o "Portrait_3.jpg"
curl -f "https://cyclenerd.github.io/gallery_shell_demo/Portrait_4.jpg"  -o "Portrait_4.jpg"
curl -f "https://cyclenerd.github.io/gallery_shell_demo/Portrait_5.jpg"  -o "Portrait_5.jpg"
curl -f "https://cyclenerd.github.io/gallery_shell_demo/Portrait_6.jpg"  -o "Portrait_6.jpg"
curl -f "https://cyclenerd.github.io/gallery_shell_demo/Portrait_7.jpg"  -o "Portrait_7.jpg"
curl -f "https://cyclenerd.github.io/gallery_shell_demo/Portrait_8.jpg"  -o "Portrait_8.jpg"

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

assert "cat index.html | grep '<h1>Test</h1>' | tr -d '\011\012\015'" '<div class="page-header"><h1>Test</h1></div>'
assert "cat index.html | grep '__thumbs/Landscape_1.jpg.html' | tr -d '\011\012\015'" '<a href="__thumbs/Landscape_1.jpg.html"><img src="__thumbs/187/Landscape_1.jpg" alt="" class="img-responsive"></a>'

assert "cat __thumbs/Landscape_1.jpg.html | grep '<title>Landscape_1.jpg</title>' | tr -d '\011\012\015'" '<title>Landscape_1.jpg</title>'
assert "cat __thumbs/Landscape_1.jpg.html | grep 'Resolution' | tr -d '\040\011\012\015'" 'Resolution:600x450'

assert_end gallery_sh
