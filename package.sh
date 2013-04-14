#!/bin/bash

if [ -e "ihx" ];
then
    rm -Rf dist
    mkdir dist
fi

cp -Rupv src/ihx dist
cp README.md dist
cp doc/LICENSE dist
cp doc/haxelib.xml dist
cp bin/ihx.n dist/run.n

if [ -e "ihx.zip" ];
then
    rm ihx.zip
fi
cd dist
zip -r ../ihx.zip *
cd ..

rm -Rf dist
