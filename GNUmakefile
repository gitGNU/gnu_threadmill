PACKAGE_NAME = threadmill
export PACKAGE_NAME

include $(GNUSTEP_MAKEFILES)/common.make

include ./Version

SUBPROJECTS = TMLib TMKit TMPaletteKit

#
# Threadmill Application
#

APP_NAME = Threadmill

Threadmill_PRINCIPAL_CLASS=Threadmill
Threadmill_APPLICATION_ICON=Threadmill.tiff
Threadmill_RESOURCE_FILES = \
			    Images/Threadmill.tiff \
			    Images/Threadmill-Logo.tiff \
			    TMKit/FiberPattern.tiff \
			    TMKit/BackStructurePattern.tiff \
			    TMKit/Plug.tiff \

Threadmill_LOCALIZED_RESOURCE_FILES = Threadmill.gorm

Threadmill_MAIN_MODEL_FILE=Threadmill.gorm

Threadmill_LANGUAGES = English

Threadmill_HEADERS = 

Threadmill_OBJC_FILES = main.m \
			Threadmill.m \

TOOL_NAME = tmill
tmill_OBJC_FILES = tmill.m

-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/aggregate.make
include $(GNUSTEP_MAKEFILES)/application.make
include $(GNUSTEP_MAKEFILES)/tool.make
