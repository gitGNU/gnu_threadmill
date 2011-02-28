PACKAGE_NAME = threadmill

include $(GNUSTEP_MAKEFILES)/common.make

#
# Threadmill Non-GUI Library
#

LIBRARY_NAME = libTMill

libTMill_HEADER_FILES_DIR=.
libTMill_HEADER_FILES_INSTALL_DIR=/Threadmill
ADDITIONAL_INCLUDE_DIRS = -I..
srcdir = .

include ../Version

libTMill_LIBRARIES_DEPEND_UPON += -l$(FOUNDATION_LIBRARY_NAME)

libTMill_HEADER_FILES= \
			TMNode.h \
			TMNodeInternal.h \
			TMOperation.h \
			TMTaskNode.h \

libTMill_OBJC_FILES=   \
			externs.m \
			TMNode.m \
			TMConnector.m \
			TMOperation.m \
			TMTaskNode.m \

HEADERS_INSTALL = $(libTMill_HEADER_FILES)

-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/library.make
