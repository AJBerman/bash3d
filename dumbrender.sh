#!/bin/bash
#[ [ 1, 0, 0, camX ]
#  [ 0, 1, 0, camY ]
#  [ 0, 0, 1, camZ ]
#  [ 0, 0, 0, 1 ] ]
#rounds non-ints
round() {
	echo $2
	echo $(printf %.$2f $(echo "scale=$2;(((10^$2)*$1)+0.5)/(10^$2)" | bc))
}


abs ()                           # Absolute value.
{                                # Caution: Max return value = 255.
  E_ARGERR=-999999

  if [ -z "$1" ]                 # Need arg passed.
  then
    return $E_ARGERR             # Obvious error value returned.
  fi

  if [ "$1" -ge 0 ]              # If non-negative,
  then                           #
    absval=$1                    # stays as-is.
  else                           # Otherwise,
    let "absval = (( 0 - $1 ))"  # change sign.
  fi  

  return $absval
}

signum() {
	if [ $1 -ge 0 ];
	then
		signval=1
	else
		signval=-1
	fi
	return $signval
}

#draws a point on the canvas.
drawPoint() {
	canvas[$[ $[ $2*80 ]+$1 ]]=1
	return 0
}
drawLineNew() {
	local changed="0 -eq 1"
	local x=$1
	local y=$2
	abs $[$3-$1]
	local dx=$absval
	abs $[$4-$2]
	local dy=$absval
	signum $[$3-$1]
	local signx=$signval
	signum $[$4-$2]
	local signy=$signval
	if [ $dy -gt $dx ];
	then
		changed="1 -eq 1"
		local temp=$dx
		dx=$dy
		dy=$temp
	fi
	local e=$[2*$dy-$dx]
	local i=1
	while [ $i -le $dx ];
	do
		echo $x $y
		drawPoint $x $y
		while [ $e -ge 0 ];
		do
			if [ $changed ];
			then
				x=$[$x+1]
			else
				y=$[$y+1]
			fi
			e=$[$e-2*$dx]
		done
		if [ $changed ];
		then
			y=$[$y+$signy]
		else
			x=$[$x+$signx]
		fi
		e=$[$e+2*$dy]
		i=$[$i+1]
	done

}

#always draws a line between the two points correctly. Chooses the right algorithm.
drawLineSafe() { #function line(x0, y0, x1, y1)
	if [ $1 -eq $3 ];
	then
		drawVertical $1 $2 $3 $4
	else
		if [ $2 -eq $4 ];
		then
			drawHorizontal $1 $2 $3 $4
		else
			drawLineNew $1 $2 $3 $4
		fi
	fi
	return 0
}

drawFlatBottomTri() { #bresenham's triangle drawing algorithm
	local x1=$3
	local y1=$4
	abs $[$1-$3]
	local dx1=$absval
	abs $[$2-$4]
	local dy1=$absval
	signum $[$1-$3]
	local signx1=$signval
	signum $[$2-$4]
	local signy1=$signval
	local changed1=0
	if [ $dy1 > $dx1 ];
	then
		local temp=$dx1
		dx1=$dy1
		dy1=$temp
		changed1=1
	fi
	local e1=$[(2*$dy1)-$dx1]
	local x2=$5
	local y2=$6
	abs $[$1-$5]
	local dx2=$absval
	abs $[$2-$6]
	local dy2=$absval
	signum $[$1-$5]
	local signx2=$signval
	signum $[$2-$6]
	local signy2=$signval
	local changed2=0
	if [ $dy2 > $dx2 ];
	then
		local temp=$dx2
		dx2=$dy2
		dy2=$temp
		changed2=1
	fi
	local e2=$[(2*$dy2)-$dx2]
	while [ $y2 -ne $2 ];
	do
		drawLineSafe $x1 $y1 $x2 $y2
		while [ $[$y1*$signy1] -le $[$y2*$signy2] ];
		do
			while [ "${e1:0:1}" != "-" ];
			do
				if [ $changed1 -eq 1 ];
				then
					x1=$[$x1+$signx1]
				else
					#echo "Drawing line between ( $x1 , $y1 ) and ( $x2 , $y2 )"
					drawLineSafe $x1 $y1 $x2 $y2
					y1=$[$y1+$signy1]
				fi
				e1=$[$e1-(2*$dx1)]
			done
			if [ $changed1 -eq 1 ];
			then
				#echo "Drawing line between ( $x1 , $y1 ) and ( $x2 , $y2 )"
				drawLineSafe $x1 $y1 $x2 $y2
				y1=$[$y1+$signy1]
			else
				x1=$[$x1+$signx1]
			fi
			e1=$[$e1+(2*$dy1)]
		done
		while [ $[$y2*$signy2] -lt $[$y1*$signy1] ];
		do
			while [ "${e2:0:1}" != "-" ];
			do
				if [ $changed2 -eq 1 ];
				then
					x2=$[$x2+$signx2]
				else
					#echo "Drawing line between ( $x1 , $y1 ) and ( $x2 , $y2 )"
					drawLineSafe $x1 $y1 $x2 $y2
					y2=$[$y2+$signy2]
				fi
				e2=$[$e2-(2*$dx2)]
			done
			if [ $changed2 -eq 1 ];
			then
				#echo "Drawing line between ( $x1 , $y1 ) and ( $x2 , $y2 )"
				drawLineSafe $x1 $y1 $x2 $y2
				y2=$[$y2+$signy2]
			else
				x2=$[$x2+$signx2]
			fi
			e2=$[$e2+(2*$dy2)]
		done
	done
	return 0
}
drawFlatTopTri() {
	local x1=$1
	local y1=$2
	abs $[$5-$1]
	local dx1=$absval
	abs $[$6-$2]
	local dy1=$absval
	signum $[$5-$1]
	local signx1=$signval
	signum $[$6-$2]
	local signy1=$signval
	local changed1=0
	if [ $dy1 > $dx1 ];
	then
		local temp=$dx1
		dx1=$dy1
		dy1=$temp
		changed1=1
	fi
	local e1=$[(2*$dy1)-$dx1]
	local x2=$3
	local y2=$4
	abs $[$5-$3]
	local dx2=$absval
	abs $[$6-$4]
	local dy2=$absval
	signum $[$5-$3]
	local signx2=$signval
	signum $[$6-$4]
	local signy2=$signval
	local changed2=0
	if [ $dy2 > $dx2 ];
	then
		local temp=$dx2
		dx2=$dy2
		dy2=$temp
		changed2=1
	fi
	local e2=$[(2*$dy2)-$dx2]
	while [ $y2 -ne $6 ];
	do
		drawLineSafe $x1 $y1 $x2 $y2
		while [ $[$y1*$signy1] -le $[$y2*$signy2] ];
		do
			while [ "${e1:0:1}" != "-" ];
			do
				if [ $changed1 -eq 1 ];
				then
					x1=$[$x1+$signx1]
				else
					#echo "Drawing line between ( $x1 , $y1 ) and ( $x2 , $y2 )"
					drawLineSafe $x1 $y1 $x2 $y2
					y1=$[$y1+$signy1]
				fi
				e1=$[$e1-(2*$dx1)]
			done
			if [ $changed1 -eq 1 ];
			then
				#echo "Drawing line between ( $x1 , $y1 ) and ( $x2 , $y2 )"
				drawLineSafe $x1 $y1 $x2 $y2
				y1=$[$y1+$signy1]
			else
				x1=$[$x1+$signx1]
			fi
			e1=$[$e1+(2*$dy1)]
		done
		while [ $[$y2*$signy2] -lt $[$y1*$signy1] ];
		do
			while [ "${e2:0:1}" != "-" ];
			do
				if [ $changed2 -eq 1 ];
				then
					x2=$[$x2+$signx2]
				else
					#echo "Drawing line between ( $x1 , $y1 ) and ( $x2 , $y2 )"
					drawLineSafe $x1 $y1 $x2 $y2
					y2=$[$y2+$signy2]
				fi
				e2=$[$e2-(2*$dx2)]
			done
			if [ $changed2 -eq 1 ];
			then
				#echo "Drawing line between ( $x1 , $y1 ) and ( $x2 , $y2 )"
				drawLineSafe $x1 $y1 $x2 $y2
				y2=$[$y2+$signy2]
			else
				x2=$[$x2+$signx2]
			fi
			e2=$[$e2+(2*$dy2)]
		done
	done
	return 0
}
#draws a triangle using the flat-top-flat-bottom algorithm. Assumes sorted (call drawTriSafe)
drawTri() { #function tri(x0, y0, x1, y1, x2, y2)
	echo "Drawing ( $1 , $2 ) ( $3 , $4 ) ( $5, $6 )"
	if [ $4 -eq $6 ];
	then
		drawFlatBottomTri $1 $2 $3 $4 $5 $6
		return 0
	fi
	if [ $2 -eq $4 ];
	then
		drawFlatTopTri $1 $2 $3 $4 $5 $6
		return 0
	fi
	x4=$(echo "define trunc(x) { auto s; s=scale; scale=0; x=x/1; scale=s; return x }; trunc($1 + (($4 - $2) / ($6 - $2)) * ($5 - $1))" | bc -l)
	drawLineSafe $1 $2 $3 $4
	drawLineSafe $3 $4 $5 $6
	drawLineSafe $1 $2 $5 $6
	echo "FlatBottomTri $1 $2 $x4 $4 $3 $4"
	drawFlatBottomTri $1 $2 $x4 $4 $3 $4
	echo "FlatTopTri $3 $4 $x4 $4 $5 $6"
	drawFlatTopTri $3 $4 $x4 $4 $5 $6
}
drawTriWire() {
	echo "Drawing ( $1 , $2 ) ( $3 , $4 ) ( $5, $6 )"
	drawLineSafe $1 $2 $3 $4
	drawLineSafe $3 $4 $5 $6
	drawLineSafe $1 $2 $5 $6
}
drawTriSafe() {
	if [ $2 -le $4 ];
	then
		if [ $2 -le $6 ];
		then
			if [ $4 -le $6 ];
			then
				coords="$1 $2 $3 $4 $5 $6"
			else
				coords="$1 $2 $5 $6 $3 $4"
			fi
		else
			coords="$5 $6 $1 $2 $3 $4"
		fi
	else
		if [ $4 -le $6 ];
		then
			if [ $2 -le $6 ];
			then
				coords="$3 $4 $1 $2 $5 $6"
			else
				coords="$3 $4 $5 $6 $1 $2"
			fi
		else
			coords="$5 $6 $3 $4 $1 $2"
		fi
	fi
	drawTri $coords
	return 0
}
#blanks the canvas (no shit!)
canvasBlank() {
	unset canvas
	return 0
}
#loads an $1 as $2
loadTeapot() {
	local v=1
	local f=1
	while read -r line
	do
		vars=($line)
	    if [ "${vars[0]}" = "v" ];
    	then
    		teapotVX[$v]=${vars[1]}
    		teapotVY[$v]=${vars[2]}
    		teapotVZ[$v]=${vars[3]}
    		v=$[$v+1]
	    else
    		teapotFX[$v]=${vars[1]}
    		teapotFY[$v]=${vars[2]}
    		teapotFZ[$v]=${vars[3]}
    		f=$[$f+1]
	    fi
	done < "teapot.obj"
}
canvasBlank
loadTeapot 
j=0
while [ $j -lt 1 ];
do
	time drawLineSafe 10 20 20 10
	i=0
	#outputs the canvas to the screen
	#clear
	while [ $i -lt 1920 ]; #1920 is the magic number 80*24
	do
		if [ ${canvas[$i]}1 = 11 ]; #yes, this is hacky. But sometimes canvas[i] is '', which means canvas[i] = 1 causes an error.
		then
			printf "#"
		else
			printf " "
		fi
		i=$[$i+1]
	done
	j=$[$j+1]
done