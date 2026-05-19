#!/bin/sh
cur=$(uname -r)
prev=$(readlink -f /vmlinuz.old) && prev=${prev#*-} || prev=@
keepkernels="^linux-(headers|image|image-extra)-($cur|$prev)"
allkernels='^linux-(headers|image|image-extra)-[0-9]'
exec sudo apt-get --only-upgrade purge "$allkernels" "$keepkernels"+
