#!/bin/bash

if [ -e "ihx" ];
then
    rm -Rf ihx
    mkdir ihx
fi

cp -Rupv src/ihx ihx
cp README ihx
cp doc/LICENSE ihx
cp doc/haxelib.xml ihx
cp bin/ihx.n ihx/run.n

if [ -e "ihx.zip" ];
then
    rm ihx.zip
fi
zip -r ihx.zip ihx

rm -Rf ihx
