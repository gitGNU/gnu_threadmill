PACKAGE_NAME = threadmill
export PACKAGE_NAME

include $(GNUSTEP_MAKEFILES)/common.make

include ./Version

SUBPROJECTS = TMLib

#
# Threadmill Application
#

APP_NAME = Threadmill

Threadmill_PRINCIPAL_CLASS=Threadmill
Threadmill_APPLICATION_ICON=Threadmill.tiff
Threadmill_RESOURCE_FILES = \
			    Images/Threadmill.tiff \
			    Images/Threadmill-Logo.tiff \
			    Images/Plug.tiff \
			    Images/FiberPattern.tiff \

Threadmill_LOCALIZED_RESOURCE_FILES = Threadmill.gorm

Threadmill_MAIN_MODEL_FILE=Threadmill.gorm

Threadmill_LANGUAGES = English

Threadmill_HEADERS = 

Threadmill_OBJC_FILES = main.m \
			Threadmill.m \

include $(GNUSTEP_MAKEFILES)/aggregate.make
include $(GNUSTEP_MAKEFILES)/application.make
