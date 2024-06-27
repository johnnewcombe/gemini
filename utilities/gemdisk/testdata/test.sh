#!/usr/bin

# test list and dump
gemdisk list -i="MYDISK.IMG"
gemdisk dump -i "MYDISK.IMG"

# test file operations
gemdisk dump-file -i "MYDISK.IMG" -f "findbad.com"
gemdisk read-file -i "MYDISK.IMG" -f "FINDBAD.COM"
gemdisk read-file -i "MYDISK.IMG" -f "[5]BIOSN.SYS"
gemdisk write-file -i "MYDISK.IMG" -f "[0]BIOSN.SYS"

# TODO need to test that text files to see if the CR/LF and Ctrl Z stuff works correctly.!


# test sequential/interleaved
gemdisk interleaved -i "MYDISK.IMG" -o "MYDISK_I.IMG"
gemdisk sequential -i "MYDISK_i.IMG" -o "MYDISK_S.IMG" # MYDISK_S.IMG should == MYDISK.IMG



