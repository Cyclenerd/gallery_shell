# gallery.sh

[![Bagde: GNU Bash](https://img.shields.io/badge/GNU%20Bash-4EAA25.svg?logo=gnubash&logoColor=white)](https://github.com/Cyclenerd/gallery_shell#readme)
[![Bagde: Linux](https://img.shields.io/badge/Linux-FCC624.svg?logo=linux&logoColor=black)](https://github.com/Cyclenerd/gallery_shell#readme)
[![Bagde: Apple](https://img.shields.io/badge/Apple-000000.svg?logo=apple&logoColor=white)](https://github.com/Cyclenerd/gallery_shell#readme)
[![Badge: License](https://img.shields.io/github/license/cyclenerd/gallery_shell)](https://github.com/Cyclenerd/gallery_shell/blob/master/LICENSE)
[![Badge: ShellCheck](https://github.com/Cyclenerd/gallery_shell/actions/workflows/shellcheck.yml/badge.svg?branch=master)](https://github.com/Cyclenerd/gallery_shell/actions/workflows/shellcheck.yml)
[![Badge: Ubuntu](https://github.com/Cyclenerd/gallery_shell/actions/workflows/ubuntu.yml/badge.svg?branch=master)](https://github.com/Cyclenerd/gallery_shell/actions/workflows/ubuntu.yml)
[![Badge: macOS](https://github.com/Cyclenerd/gallery_shell/actions/workflows/macos.yml/badge.svg?branch=master)](https://github.com/Cyclenerd/gallery_shell/actions/workflows/macos.yml)

Bash Script to generate static web galleries. No server-side programs (i.e. PHP, MySQL) required.

## Overview

`gallery.sh` is simple bash shell script which generates static html thumbnail (image, photo) galleries using the `convert` and `jhead` command-line utilities.
It requires no special server-side script to run to view image galleries because everything is pre-rendered. 

It offers several features:
* Responsive layout
* Thumbnails which fill the browser efficiently
* Download the original image file
* Nice and simple Bootstrap CSS layout
* Locally previewable galleries by accessing images locally (e.g. `file:///home/nils/pics/gallery/index.html`)
* JPEG header EXIF data extraction
* Auto-rotation of vertical images

This combination of features makes a better user experience than pretty much all the big online photo hosts. 
All you need is a place to host your plain html and jpeg files. This can also be Amazon S3.

## Installation

Download Bash script `gallery.sh`:

```shell
curl -O "https://raw.githubusercontent.com/Cyclenerd/gallery_shell/master/gallery.sh"
```

## Requirements

* [ImageMagick](http://www.imagemagick.org/) for the `convert` utility.
* [JHead](http://www.sentex.net/~mwandel/jhead/) for EXIF data extraction

On a debian-based system (Ubuntu), just run:

```shell
sudo apt install imagemagick jhead
```

Under macOS you can install it with...

[MacPort](https://www.macports.org/):

```shell
sudo port install imagemagick jhead
```

[Homebrew](https://brew.sh/):

```shell
brew install imagemagick jhead
```

## Usage

```text
gallery.sh [-t <title>] [-d <thumbdir>] [-h]:
	[-t <title>]     sets the title (default: Gallery)
	[-d <thumbdir>]  sets the thumbdir (default: __thumbs)
	[-h]             displays help (this message)
```

Example: `gallery.sh` or `gallery.sh -t "My Photos" -d "thumbs"`

`gallery.sh` works in the **current** directory.
Just load the `index.html` in a browser see the output. 

The directory should contain a bunch of JPEG (.jpg or .JPG) files.
It does not work recursively. 
ZIP files (.zip or .ZIP) and movies (.mov, .MOV, .mp4 or .MP4) are also considered.
They appear as a download button in the gallery.

## Hint

Create a Bash alias for `gallery.sh`.

Open the `~/.bash_profile`,  `~/.bashrc` or `~/.bash_aliases` in your text editor:

```shell
nano ~/.bash_aliases
```

Add your alias:

```shell
alias gallery='/home/nils/gallery_shell/gallery.sh'
```

## Demo

This [demo page](https://cyclenerd.github.io/gallery_shell/) is generated with [GitHub Action](https://github.com/Cyclenerd/gallery_shell/blob/master/.github/workflows/main.yml): <https://cyclenerd.github.io/gallery_shell/>

## Screenshots

[![Screenshot: Gallery](images/gallery.jpg?v1)](https://cyclenerd.github.io/gallery_shell/)

[![Screenshot: Image](images/image.jpg?v1)](https://cyclenerd.github.io/gallery_shell/thumbs/Landscape_8.jpg.html)

## License

GNU Public License version 3.
Please feel free to fork and modify this on GitHub (<https://github.com/Cyclenerd/gallery_shell>).