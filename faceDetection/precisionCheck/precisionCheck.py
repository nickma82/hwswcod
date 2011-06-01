#!/usr/bin/python

import sys
import string

armstrong = (343, 107, 467, 275)
aldrin = (224, 78, 356, 275)
collins = (323, 175, 418, 277)

def usage():
    print """Usage: precisionCheck <armstrong|aldrin|collins> x1 y1 x2 y2
\t<x1, y1> ... top-left corner of detected face
\t<x2, y2> ... bottom-right corner of detected face"""
    sys.exit(-1)
 
if len(sys.argv) != 6:
    usage()

refRect = ()

if sys.argv[1].lower() == "armstrong":
    refRect = armstrong
elif sys.argv[1].lower() == "aldrin":
    refRect = aldrin
elif sys.argv[1].lower() == "collins":
    refRect = collins
else:
    print "Error: Wrong reference image name!\n"
    usage()

x1 = int(sys.argv[2])
y1 = int(sys.argv[3])
x2 = int(sys.argv[4])
y2 = int(sys.argv[5])

print "Reference rectangle (%s): x1=%d, y1=%d, x2=%d, y2=%d" % (sys.argv[1], refRect[0], refRect[1], refRect[2], refRect[3])
if x1 > refRect[2] or x2 < refRect[0] or y1 > refRect[3] or y2 < refRect[1]:
    # no overlap
    precision = 0
    print "Detected region does not overlap with face at all! Invalid solution!"
    sys.exit(0)
else:
    diffX1 = abs(refRect[0] - x1)
    diffY1 = abs(refRect[1] - y1)
    diffX2 = abs(refRect[2] - x2)
    diffY2 = abs(refRect[3] - y2)

    refWidth = float(refRect[2] - refRect[0])
    refHeight = float(refRect[3] - refRect[1])
    xPrecision = float(refWidth - diffX1 - diffX2) / (refWidth)
    yPrecision = float(refHeight - diffY1 - diffY2) / (refHeight)

    precision = (xPrecision + yPrecision) / 2
    if precision < 0:
        print "Detected region too wide! Invalid solution!"
    else:
        print "Precision: %f" % precision
        minusPoints = (1 - precision) * 10000
        print "Minus points = %d" % minusPoints

