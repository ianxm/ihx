#!/bin/sh

haxe build.hxml

libname='ihx'
rm -f "${libname}.zip"
zip -r "${libname}.zip" haxelib.json haxelib.xml run.n src LICENSE gpl-3.0.txt README.md
echo "Saved as ${libname}.zip"
