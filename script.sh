#!/bin/bash

if [ $(/usr/bin/id -u) -ne 0 ]; then
    echo "Not running as root"
    exit
fi

sourcePath=$1
echo $sourcePath
if [ ! "$sourcePath" ]; then
	echo Source path argument is empty, enter source path
	read sourcePath
fi

echo Enter wallpapers set name:
read name

durationStatic=600.0
durationTransition=2.0
destination=~/.local/share/gnome-background-properties
xmlBG=$destination/xmls/$name.xml
xmlConfig=$destination/$name.xml

mkdir -p $destination
mkdir -p $destination/xmls

cat >$xmlConfig <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">
<wallpapers>
EOF

cat >$xmlBG <<XML
<background>
  <starttime>
    <year>2009</year>
    <month>08</month>
    <day>04</day>
    <hour>00</hour>
    <minute>00</minute>
    <second>00</second>
  </starttime>
XML


for file in $(find $sourcePath -regextype posix-extended -regex ".+\.(jpe?g|JPE?G|png|PNG)" | sort -R); do
	if [ $fileprev ]; then
	cat >>$xmlConfig<<XML
  <wallpaper>
    <name>$file</name>
    <filename>$file</filename>
    <options>zoom</options>
    <pcolor>#000000</pcolor>
    <scolor>#000000</scolor>
    <shade_type>solid</shade_type>
  </wallpaper>
XML
	cat >>$xmlBG <<XML
  <static>
    <duration>$durationStatic</duration>
    <file>$fileprev</file>
  </static>
  <transition>
    <duration>$durationTransition</duration>
    <from>$fileprev</from>
    <to>$file</to>
  </transition>
XML
	fi
	fileprev=$file
	echo "Image $file found"
done

cat >>$xmlConfig <<XML
  <wallpaper deleted="false">
    <name>$name</name>
    <filename>$xmlBG</filename>
    <options>zoom</options>
  </wallpaper>
XML

echo '</wallpapers>' >> $xmlConfig
echo '</background>' >> $xmlBG

echo "Added dynamic wallpapers config $xmlBG"
echo "Added wallpapers config $xmlConfig"
