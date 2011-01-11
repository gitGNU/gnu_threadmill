PACKAGE_NAME = threadmill

include $(GNUSTEP_MAKEFILES)/common.make

#
# Threadmill GUI Library
#

LIBRARY_NAME = libTMillPaletteGUI

libTMillPaletteGUI_HEADER_FILES_DIR=.
libTMillPaletteGUI_HEADER_FILES_INSTALL_DIR=/Threadmill
ADDITIONAL_INCLUDE_DIRS = -I..
srcdir = .

include ../Version

libTMillPaletteGUI_LIBRARIES_DEPEND_UPON += -lgnustep-gui -l$(FOUNDATION_LIBRARY_NAME)

libTMillPaletteGUI_HEADER_FILES= \
			TMTimeClockCell.h \
			TMTimeControl.h \

libTMillPaletteGUI_OBJC_FILES=   \
			TMTimeClockCell.m \
			TMTimeControl.m \


libTMillPaletteGUI_RESOURCE_FILES = \
			FiberPattern.tiff \
			Plug.tiff \


HEADERS_INSTALL = $(libTMillPaletteGUI_HEADER_FILES)
-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/library.make
