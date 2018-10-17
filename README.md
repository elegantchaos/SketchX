# SketchX

A simple tool to help with exporting Sketch documents to Xcode asset catalogues.

Usage: `sketchx Document.sketch PagesToOutput Output/Path/`

The specified pages (a comma-delimited list) of the document will be exported to an asset catalogue, using the page name as the catalogue name.

Alternatively you can leave out the page name, and all pages in the document will be exported, with the exception of the symbols page.

Each artboard on a page will be exported into the catalogue, using the artboard name to determine the exact path and asset type, and the export presets that you've specified in Sketch.

*Note*: This tool can be run manually, but is really intended to be run from a Run Script phase in Xcode, as part of your build.

## Building

Fetch the contents of this repository with `git clone https://github.com/elegantchaos/SketchX.git`.

Build, using `swift build`.

Run with `.build/debug/sketchx`.


## Installing

Install by copying the executable somewhere, eg `sudo cp .build/debug/sketchx /usr/local/bin/`.


## Usage

If you have a catalogue called "Assets.xcassets", containing an icon set called "AppIcon", and an image set called "Image".

To export into this from Sketch:

- Call your page "Assets".
- For the iconset, make artboards called `AppIcon.appiconset/Icon16`, `AppIcon.appiconset/Icon32`, etc.
- For the image, make artboards called `Image.imageset/Image`, `Image.imageset/Image@2x`, etc.

An example document can be seen in `Example/Example.sketch`.

You can modify it and then export with the following command (from the root SketchX folder):

    `swift run sketchx Example/Example.sketch Assets Example/Example/`


Try modifying the Sketch document and re-exporting; you should see the assets change in Xcode.


## Contents.json

For now, `sketchx` doesn't write the `Contents.json` file for you, so you can't use it to create new catalogues/sets.

You have to create the structure first up in Xcode, use `sketchx` to do an initial export of images. The images you've
exported will then show up, unassigned, in the Xcode user interface. You can then drag them into the various slots
in the image/iconset. Once you've done this, Xcode will remember the assignments. Running `sketchx` again will just
re-export the images, with no further adjustments required in Xcode.



## Future

This is a quick & dirty hack, which could be improved.

Some ideas:

- pass in alternative names somehow
- write the Contents.json and create the complete structure if it's missing
- add a Sketch plugin which downloads/builds/runs this tool from within Sketch
