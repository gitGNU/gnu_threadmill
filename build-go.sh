#!/bin/sh
(cd Threadmill;ln -sf ../TMLib/*.h ../TMKit/*.h .)
make
export LD_LIBRARY_PATH="`pwd`"/TMLib/obj:"`pwd`"/TMKit/obj:$LD_LIBRARH_PATH
./Threadmill.app/Threadmill
