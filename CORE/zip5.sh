#!/bin/bash
zip -r9 "KakarotKernel-Samsung-A52-SSJ1-Neel0210-$(date +"%H-%M").zip" META-INF ramdisk tools anykernel.sh version Image
rm -rf Image