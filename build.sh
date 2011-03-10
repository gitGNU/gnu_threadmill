#!/bin/sh

export LD_LIBRARY_PATH=TMLib/obj:TMKit/obj:TMPaletteKit/obj:$LD_LIBRARY_PATH

build()
{
	(mkdir Threadmill 2>/dev/null; cd Threadmill; ln -sf ../TMLib/*.h ../TMKit/*.h ../TMPaletteKit/*.h .)
	make -j 8
}

run()
{
	./Threadmill.app/Threadmill
}

debug()
{
	gdb ./Threadmill.app/Threadmill
}

case "$1" in
	b)
		build
		;;
	g)
		run
		;;
	bg)
		build && run
		;;
	d)
		debug
		;;
	bd)
		build && debug
		;;
	*)
	build
	echo "Usage: $0 {b|g|d|bg|bd}"
	echo "\tb = build"
	echo "\tg = run"
	echo "\td = debug"
	exit 1
esac
