#!/bin/bash

# gallery.sh
# Author: Nils Knieling - https://github.com/Cyclenerd/gallery_shell
# Inspired by: Shapor Naghibzadeh - https://github.com/shapor/bashgal

#########################################################################################
#### Configuration Section
#########################################################################################

height_small=187
height_large=768
quality=85
thumbdir="__thumbs"
htmlfile="index.html"
title="Gallery"
footer='Created with <a href="https://github.com/Cyclenerd/gallery_shell">gallery.sh</a>'

# Use convert from ImageMagick
convert="convert" 
# Use JHead for EXIF Information
exif="jhead"

# Bootstrap (currently v3.4.1)
stylesheet="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/css/bootstrap.min.css"

# Debugging output
# true=enable, false=disable 
debug=true

#########################################################################################
#### End Configuration Section
#########################################################################################


me=$(basename "$0")
datetime=$(date -u "+%Y-%m-%d %H:%M:%S")
datetime+=" UTC"

function usage {
	returnCode="$1"
	echo -e "Usage: $me [-t <title>] [-d <thumbdir>] [-h]:
	[-t <title>]\\t sets the title (default: $title)
	[-d <thumbdir>]\\t sets the thumbdir (default: $thumbdir)
	[-h]\\t\\t displays help (this message)"
	exit "$returnCode"
}

function debugOutput(){
	if [[ "$debug" == true ]]; then
		echo "$1" # if debug variable is true, echo whatever's passed to the function
	fi
}

function getFileSize(){
	# Be aware that BSD stat doesn't support --version and -c
	if stat --version &>/dev/null; then
		# GNU
		myfilesize=$(stat -c %s "$1" | awk '{$1/=1000000;printf "%.2fMB\n",$1}')
	else
		# BSD
		myfilesize=$(stat -f %z "$1" | awk '{$1/=1000000;printf "%.2fMB\n",$1}')
	fi
	echo "$myfilesize"
}

while getopts ":t:d:h" opt; do
	case $opt in
	t)
		title="$OPTARG"
		;;
	d)
		thumbdir="$OPTARG"
		;;
	h)
		usage 0
		;;
	*)
		echo "Invalid option: -$OPTARG"
		usage 1
		;;
	esac
done

debugOutput "- $me : $datetime"

### Check Commands
command -v $convert >/dev/null 2>&1 || { echo >&2 "!!! $convert it's not installed.  Aborting."; exit 1; }
command -v $exif >/dev/null 2>&1 || { echo >&2 "!!! $exif it's not installed.  Aborting."; exit 1; }

### Create Folders
[[ -d "$thumbdir" ]] || mkdir "$thumbdir" || exit 2

heights[0]=$height_small
heights[1]=$height_large
for res in ${heights[*]}; do
	[[ -d "$thumbdir/$res" ]] || mkdir -p "$thumbdir/$res" || exit 3
done

#### Create Startpage
debugOutput "$htmlfile"
cat > "$htmlfile" << EOF
<!DOCTYPE HTML>
<html lang="en">
<head>
	<meta charset="utf-8">
	<title>$title</title>
	<meta name="viewport" content="width=device-width">
	<meta name="robots" content="noindex, nofollow">
	<link rel="stylesheet" href="$stylesheet">
</head>
<body>
<header>
	<div class="navbar navbar-dark bg-dark shadow-sm">
		<div class="container">
			<a href="#" class="navbar-brand">
				<strong>$title</strong>
			</a>
		</div>
	</div>
</header>
<main class="container">
EOF

### Photos (JPG)
if [[ $(find . -maxdepth 1 -type f -iname \*.jpg | wc -l) -gt 0 ]]; then

echo '<div class="row row-cols-sm-1 row-cols-md-2 row-cols-lg-3 row-cols-xl-4 py-5">' >> "$htmlfile"
## Generate Images
numfiles=0
for filename in *.[jJ][pP][gG]; do
	filelist[$numfiles]=$filename
	(( numfiles++ ))
	for res in ${heights[*]}; do
		if [[ ! -s $thumbdir/$res/$filename ]]; then
			debugOutput "$thumbdir/$res/$filename"
			$convert -auto-orient -strip -quality $quality -resize x$res "$filename" "$thumbdir/$res/$filename"
		fi
	done
	cat >> "$htmlfile" << EOF
<div class="col">
	<p>
		<a href="$thumbdir/$filename.html"><img src="$thumbdir/$height_small/$filename" alt="Thumbnail: $filename" class="rounded mx-auto d-block"></a>
	</p>
</div>
EOF
done
echo '</div>' >> "$htmlfile"

## Generate the HTML Files for Images in thumbdir
file=0
while [[ $file -lt $numfiles ]]; do
	filename=${filelist[$file]}
	prev=""
	next=""
	[[ $file -ne 0 ]] && prev=${filelist[$((file - 1))]}
	[[ $file -ne $((numfiles - 1)) ]] && next=${filelist[$((file + 1))]}
	imagehtmlfile="$thumbdir/$filename.html"
	exifinfo=$($exif "$filename")
	filesize=$(getFileSize "$filename")
	debugOutput "$imagehtmlfile"
	cat > "$imagehtmlfile" << EOF
<!DOCTYPE HTML>
<html lang="en">
<head>
<meta charset="utf-8">
<title>$filename</title>
<meta name="viewport" content="width=device-width">
<meta name="robots" content="noindex, nofollow">
<link rel="stylesheet" href="$stylesheet">
</head>
<body>
<header>
	<div class="navbar navbar-dark bg-dark shadow-sm">
		<div class="container">
			<a href="../index.html" class="navbar-brand">
				<strong>$title</strong>
			</a>
		</div>
	</div>
</header>
<main class="container">
EOF

	# Pager
	echo '<div class="row py-3"><div class="col text-left">' >> "$imagehtmlfile"
	if [[ $prev ]]; then
		echo '<a href="'"$prev"'.html" accesskey="p" title="⌨️ PC: [Alt]+[Shift]+[P] / MAC: [Control]+[Option]+[P]" class="btn btn-secondary " role="button">&laquo; Previous</a>' >> "$imagehtmlfile"
	else
		echo '<a href="#" class="btn btn-secondary  disabled" role="button" aria-disabled="true">&laquo; Previous</a>' >> "$imagehtmlfile"
	fi
	cat >> "$imagehtmlfile" << EOF
</div>
<div class="col d-none d-md-block text-center"><h3>$filename</h3></div>
<div class="col text-right">
EOF
	if [[ $next ]]; then
		echo '<a href="'"$next"'.html" accesskey="n" title="⌨️ PC: [Alt]+[Shift]+[N] / MAC: [Control]+[Option]+[N]" class="btn btn-secondary ">Next &raquo;</a>' >> "$imagehtmlfile"
	else
		echo '<a href="#" class="btn btn-secondary  disabled" role="button" aria-disabled="true">Next &raquo;</a>' >> "$imagehtmlfile"
	fi
	echo '</div></div>' >> "$imagehtmlfile"

	cat >> "$imagehtmlfile" << EOF
<div class="row">
	<div class="col">
		<p><img src="$height_large/$filename" class="img-fluid" alt="Image: $filename"></p>
	</div>
</div>
<div class="row">
	<div class="col">
		<p><a class="btn btn-primary" href="../$filename">Download Original ($filesize)</a></p>
	</div>
</div>
EOF

	# EXIF
	if [[ $exifinfo ]]; then
		cat >> "$imagehtmlfile" << EOF
<div class="row">
<div class="col">
<pre>
$exifinfo
</pre>
</div>
</div>
EOF
	fi

	# Footer
	cat >> "$imagehtmlfile" << EOF
</main> <!-- // main container -->
<br>
<footer class="footer mt-auto py-3 bg-light">
	<div class="container">
		<span class="text-muted">$footer - $datetime</span>
	</div>
</footer>
</body>
</html>
EOF
	(( file++ ))
done

fi

### Movies (MOV or MP4)
if [[ $(find . -maxdepth 1 -type f -iname \*.mov  -o -iname '*.mp4' | wc -l) -gt 0 ]]; then
	cat >> "$htmlfile" << EOF
	<div class="row">
		<div class="col">
			<div class="page-header"><h2>Movies</h2></div>
		</div>
	</div>
	<div class="row">
	<div class="col">
EOF
	if [[ $(find . -maxdepth 1 -type f -iname \*.mov | wc -l) -gt 0 ]]; then
	for filename in *.[mM][oO][vV]; do
		filesize=$(getFileSize "$filename")
		cat >> "$htmlfile" << EOF
<a href="$filename" class="btn btn-primary" role="button">$filename ($filesize)</a>
EOF
	done
	fi
	if [[ $(find . -maxdepth 1 -type f -iname \*.mp4 | wc -l) -gt 0 ]]; then
	for filename in *.[mM][pP]4; do
		filesize=$(getFileSize "$filename")
		cat >> "$htmlfile" << EOF
<a href="$filename" class="btn btn-primary" role="button">$filename ($filesize)</a>
EOF
	done
	fi
	echo '</div></div>' >> "$htmlfile"
fi

### Downloads (ZIP)
if [[ $(find . -maxdepth 1 -type f -iname \*.zip | wc -l) -gt 0 ]]; then
	cat >> "$htmlfile" << EOF
	<div class="row">
		<div class="col">
			<div class="page-header"><h2>Downloads</h2></div>
		</div>
	</div>
	<div class="row">
	<div class="col">
EOF
	for filename in *.[zZ][iI][pP]; do
		filesize=$(getFileSize "$filename")
		cat >> "$htmlfile" << EOF
<a href="$filename" class="btn btn-primary" role="button">$filename ($filesize)</a>
EOF
	done
	echo '</div></div>' >> "$htmlfile"
fi

### Footer
cat >> "$htmlfile" << EOF
</main> <!-- // main container -->
<br>
<footer class="footer mt-auto py-3 bg-light">
	<div class="container">
		<span class="text-muted">$footer - $datetime</span>
	</div>
</footer>
</body>
</html>
EOF

debugOutput "= done"