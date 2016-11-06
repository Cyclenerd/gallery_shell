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
thumbdir=__thumbs
htmlfile=index.html
title="Gallery"
footer='Created with <a href="https://github.com/Cyclenerd/gallery_shell">gallery.sh</a>'

# Use convert from ImageMagick
convert="convert" 
# Use JHead for EXIF Information
exif="jhead"

# Bootstrap (currently v3.3.7)
# Latest compiled and minified CSS
stylesheet="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"

downloadicon='<span class="glyphicon glyphicon-floppy-save" aria-hidden="true"></span>'
movieicon='<span class="glyphicon glyphicon-film" aria-hidden="true"></span>'
homeicon='<span class="glyphicon glyphicon-home" aria-hidden="true"></span>'

function debug {
	return 0 # 0=enable, 1=disable debugging output
}

#########################################################################################
#### End Configuration Section
#########################################################################################


me=$(basename "$0")
datetime=$(date -u "+%Y-%m-%d %H:%M:%S")
datetime+=" UTC"

function usage {
	echo "usage: $me [-t <title>] [-h]"
	echo "  [-t <title>] 	sets the title (default: $title)"
	echo "  [-h]	 	displays help (this message)"
}

while getopts ":t:h" opt; do
	case $opt in
	t)
		title="$OPTARG"
		;;
	h)
		usage
		exit 0
		;;
	\?)
		echo "Invalid option: -$OPTARG" >&2
		exit 1
		;;
	esac
done

debug && echo "- $me : $datetime"

### Check Commands
command -v $convert >/dev/null 2>&1 || { echo >&2 "!!! $convert it's not installed.  Aborting."; exit 1; }
command -v $exif >/dev/null 2>&1 || { echo >&2 "!!! $exif it's not installed.  Aborting."; exit 1; }

### Create Folders
[[ -d $thumbdir ]] || mkdir $thumbdir || exit 2

heights[0]=$height_small
heights[1]=$height_large
for res in ${heights[*]}; do
	[[ -d $thumbdir/$res ]] || mkdir -p $thumbdir/$res || exit 3
done

#### Create Startpage
debug && echo "+" $htmlfile
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
<div class="container">
	<div class="row">
		<div class="col-xs-12">
			<div class="page-header"><h1>$title</h1></div>
		</div>
	</div>
EOF

### Photos (JPG)
if [[ $(find . -type f -name \*.jpg -maxdepth 1 | wc -l) -gt 0 ]]; then

echo '<div class="row">' >> "$htmlfile"
## Generate Images
numfiles=0
for filename in *.[jJ][pP][gG]; do
	debug && echo -n "+ $filename: "
	filelist[$numfiles]=$filename
	let numfiles++
	for res in ${heights[*]}; do
		debug && echo -n "$thumbdir/$res "
		if [[ ! -s $thumbdir/$res/$filename ]]; then
			$convert -auto-orient -strip -quality $quality -resize x$res "$filename" "$thumbdir/$res/$filename"
		fi
	done
	debug && echo
	cat >> "$htmlfile" << EOF
<div class="col-md-3 col-sm-12">
	<p>
		<a href="$thumbdir/$filename.html"><img src="$thumbdir/$height_small/$filename" alt="" class="img-responsive"></a>
		<div class="hidden-md hidden-lg"><hr></div>
	</p>
</div>
EOF
[[ $(( $numfiles % 4 )) -eq 0 ]] && echo '<div class="clearfix visible-md visible-lg"></div>' >> "$htmlfile"
done
echo '</div>' >> "$htmlfile"

## Generate the HTML Files for Images in thumbdir
file=0
while [[ $file -lt $numfiles ]]; do
	filename=${filelist[$file]}
	prev= next=
	[[ $file -ne 0 ]] && prev=${filelist[$((file - 1))]}
	[[ $file -ne $((numfiles - 1)) ]] && next=${filelist[$((file + 1))]}
	imagehtmlfile=$thumbdir/$filename.html
	exifinfo=$($exif "$filename")
	filesize=$(wc -c < "$filename" | awk '{$1/=1000000;printf "%.2fMB\n",$1}')
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
<div class="container">
<div class="row">
	<div class="col-xs-12">
		<div class="page-header"><h2><a href="../$htmlfile">$homeicon</a> <span class="text-muted">/</span> $filename</h2></div>
	</div>
</div>
EOF

	# Pager
	echo '<div class="row"><div class="col-xs-12"><nav><ul class="pager">' >> "$imagehtmlfile"
	[[ $prev ]] && echo '<li class="previous"><a href="'$prev'.html"><span aria-hidden="true">&larr;</span></a></li>' >> "$imagehtmlfile"
	[[ $next ]] && echo '<li class="next"><a href="'$next'.html"><span aria-hidden="true">&rarr;</span></a></li>' >> "$imagehtmlfile"
	echo '</ul></nav></div></div>' >> "$imagehtmlfile"

	cat >> "$imagehtmlfile" << EOF
<div class="row">
	<div class="col-xs-12">
		<p><img src="$height_large/$filename" class="img-responsive" alt=""></p>
	</div>
</div>
<div class="row">
	<div class="col-xs-12">
		<p><a class="btn btn-info btn-lg" href="../$filename">$downloadicon Download Original ($filesize)</a></p>
	</div>
</div>
EOF

	# EXIF
	if [[ $exifinfo ]]; then
		cat >> "$imagehtmlfile" << EOF
<div class="row">
<div class="col-xs-12">
<pre>
$exifinfo
</pre>
</div>
</div>
EOF
	fi

	# Footer
	cat >> "$imagehtmlfile" << EOF
</div>
</body>
</html>
EOF
	let file++
done

fi

### Movies (MOV or MP4)
if [[ $(find . -type f -name \*.mov  -o -name '*.mp4' -maxdepth 1 | wc -l) -gt 0 ]]; then
	cat >> "$htmlfile" << EOF
	<div class="row">
		<div class="col-xs-12">
			<div class="page-header"><h2>Movies</h2></div>
		</div>
	</div>
	<div class="row">
	<div class="col-xs-12">
EOF
	if [[ $(find . -type f -name \*.mov -maxdepth 1 | wc -l) -gt 0 ]]; then
	for filename in *.[mM][oO][vV]; do
		filesize=$(wc -c < "$filename" | awk '{$1/=1000000;printf "%.2fMB\n",$1}')
		cat >> "$htmlfile" << EOF
<a href="$filename" class="btn btn-primary" role="button">$movieicon $filename ($filesize)</a>
EOF
	done
	fi
	if [[ $(find . -type f -name \*.mp4 -maxdepth 1 | wc -l) -gt 0 ]]; then
	for filename in *.[mM][pP]4; do
		filesize=$(wc -c < "$filename" | awk '{$1/=1000000;printf "%.2fMB\n",$1}')
		cat >> "$htmlfile" << EOF
<a href="$filename" class="btn btn-primary" role="button">$movieicon $filename ($filesize)</a>
EOF
	done
	fi
	echo '</div></div>' >> "$htmlfile"
fi

### Downloads (ZIP)
if [[ $(find . -type f -name \*.zip -maxdepth 1 | wc -l) -gt 0 ]]; then
	cat >> "$htmlfile" << EOF
	<div class="row">
		<div class="col-xs-12">
			<div class="page-header"><h2>Downloads</h2></div>
		</div>
	</div>
	<div class="row">
	<div class="col-xs-12">
EOF
	for filename in *.[zZ][iI][pP]; do
		filesize=$(wc -c < "$filename" | awk '{$1/=1000000;printf "%.2fMB\n",$1}')
		cat >> "$htmlfile" << EOF
<a href="$filename" class="btn btn-primary" role="button">$downloadicon $filename ($filesize)</a>
EOF
	done
	echo '</div></div>' >> "$htmlfile"
fi

### Footer
cat >> "$htmlfile" << EOF
<hr>
<footer>
	<p>$footer</p>
	<p class="text-muted">$datetime</p>
</footer>
</div> <!-- // container -->
</body>
</html>
EOF

debug && echo "= done :-)"