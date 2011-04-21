#!/bin/sh

export LD_LIBRARY_PATH=TMLib/obj:TMKit/obj:TMPaletteKit/obj:$LD_LIBRARY_PATH

build()
{
	make -j 8
}

run()
{
	./Threadmill.app/Threadmill
}

valgrind()
{
	valgrind --tool=memcheck ./Threadmill.app/Threadmill
}

debug()
{
	gdb ./Threadmill.app/Threadmill
}

cmd="`basename $0`"

if test "x$cmd" = xbuild.sh; then
cmd=$1
fi

case "$cmd" in
	dm)
		build && gdb ./obj/tmill
		;;
	tm)
		build && ./obj/tmill
		;;
	b)
		build
		;;
	r)
		run
		;;
	br)
		build && run
		;;
	d)
		debug
		;;
	v)
		valgrind
		;;
	bd)
		build && debug
		;;
	*)
		build
		echo "Usage: $0 {b|r|d|bg|bd}"
		echo "\tb = build"
		echo "\tr = run"
		echo "\td = debug"
esac
