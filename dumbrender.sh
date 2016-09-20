#!/bin/bash
#draws a point on the canvas.
drawPoint() {
	canvas[$[ $[ $2*80 ]+$1 ]]=1
	return 0
}
#always draws a line between the two points correctly. Chooses the right algorithm and, if needed, flips the coordinates.
drawLineSafe() { #function line(x0, y0, x1, y1)
	if [ $1 -eq $3 ];
	then
		if [$2 -lt $4];
		then
			drawVertical $1 $2 $3 $4
			return 0
		else
			drawVertical $3 $4 $1 $2
			return 0
		fi
	fi
	if [ $1 -lt $3 ];
	then
		drawLine $1 $2 $3 $4
		return 0
	fi
	drawLine $3 $4 $1 $2
	return 0
}
#draws the special case of the vertical line.
drawVertical() {
	y=$2
	while [ $y -le $4 ];
	do
		drawPoint $1 $y
		y=$[$y+1]
	done
	return 0
}
#draws a line on the canvas using bresenham's line drawing algorithm (integral version). Only works if x0 is lt x1.
drawLine() { #function line(x0, y0, x1, y1)
    error=-1
    errorrem=0
    deltaerr=$[$4-$2]/$[$3-$1] # deltaerr=abs(deltay/deltax)
    deltarem=$[$4-$2]%$[$3-$1]
    y=$2
    x=$1
    while [ $x -le $3 ];
    do
     	drawPoint $x $y
     	errorrem=$[$errorrem+$deltarem]
     	y=$[$y+$deltaerr+$[$errorrem / $[$3-$1]]]
     	errorrem=$[$errorrem % $[$3-$1]]
		echo $error
		x=$[$x+1]
	done
	return 0
}
#blanks the canvas (no shit!)
canvasBlank() {
	unset canvas
	return 0
}
i=0
clear
canvasBlank
drawLineSafe 0 12 79 6
#outputs the canvas to the screen
while [ $i -lt 1920 ];
do
	if [ "${canvas[$i]}" = "1" ];
	then
		printf "#"
	else
		printf " "
	fi
	i=$[$i+1]
done