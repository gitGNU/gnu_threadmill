PACKAGE_NAME = threadmill

include $(GNUSTEP_MAKEFILES)/common.make

#
# Threadmill GUI Library
#

LIBRARY_NAME = libTMillGUI

libTMillGUI_HEADER_FILES_DIR=.
libTMillGUI_HEADER_FILES_INSTALL_DIR=/Threadmill
ADDITIONAL_INCLUDE_DIRS = -I..
srcdir = .

include ../Version

libTMillGUI_LIBRARIES_DEPEND_UPON += -lgnustep-gui -l$(FOUNDATION_LIBRARY_NAME)

libTMillGUI_HEADER_FILES= \
			TMDefs.h \
			TMGraphics.h \
			TMNodeView.h \
			TMPortCell.h \
			TMPortCellInternal.h \
			TMView.h \

libTMillGUI_OBJC_FILES=   \
			externs.m \
			TMNodeView.m \
			TMPortCell.m \
			TMView.m \

libTMillGUI_RESOURCE_FILES = \
			FiberPattern.tiff \
			Plug.tiff \


HEADERS_INSTALL = $(libTMillGUI_HEADER_FILES)
-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/library.make
