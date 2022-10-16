
#   Fourmilab Chaos Butterfly Demonstration Script

script set segment "45"
script set texture "5"

@echo Lorenz attractor with line trail, critical points shown

set path lines
run asynchronous
set critical on
script pause {segment}
run off
set path off

@echo Lorenz attractor with particle system trail

set path on
run {segment}
set path off

@echo You can sit on the butterfly and fly with it.  Click on
@echo the butterfly to sit, and we'll go for a ride.

script pause 10
@echo And away we go!
set path on
run {segment}
set path off
@echo That was fun, wasn't it?  Now stand to leave the butterfly.

@echo You can choose the butterfly image from any
@echo of the following:
set texture

script pause 5
@echo Let's look at them.

set texture butterfly1
script pause {texture}
set texture butterfly2
script pause {texture}
set texture butterfly3
script pause {texture}
set texture butterfly4
script pause {texture}
set texture butterfly5
script pause {texture}
set texture butterfly6
script pause {texture}
set texture butterfly7
script pause {texture}
set texture butterfly8
script pause {texture}
set texture butterfly9
script pause {texture}
set texture butterfly10
script pause {texture}
set texture falcon
@echo Wait!  That's not a butterfly!
script pause {texture}
set texture butterfly10
script pause {texture}

@echo
@echo This concludes the demonstration.  To explore further,
@echo see the Fourmilab Chaos Butterfly User Guide which
@echo you can obtain with /1963 help.  Also, see the YouTube
@echo demonstration video:
@echo     https://www.youtube.com/watch?v=bKa171nw3eA
