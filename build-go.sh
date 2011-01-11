#!/bin/sh
(mkdir Threadmill;cd Threadmill;ln -sf ../TMLib/*.h ../TMKit/*.h ../TMPaletteKit/*.h .)
export LD_LIBRARY_PATH="`pwd`"/TMLib/obj:"`pwd`"/TMKit/obj:"`pwd`"/TMPaletteKit/obj:$LD_LIBRARH_PATH
make && ./Threadmill.app/Threadmill
