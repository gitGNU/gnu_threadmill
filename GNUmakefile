include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME = Threadmill
VERSION = 0.0.1
APP_NAME = Threadmill

Threadmill_MAIN_MODEL_FILE=Threadmill.gorm
Threadmill_APPLICATION_ICON=Threadmill.tiff

Threadmill_OBJC_FILES = main.m \
		TMNode.m \
		TMPort.m \
		TMView.m \
		TMNodeView.m \
		TMPortCell.m \
		externs.m \


Threadmill_RESOURCE_FILES = Threadmill.gorm Threadmill.tiff Threadmill-Logo.tiff Plug.tiff FiberPattern.tiff

ADDITIONAL_OBJC_LIBS = -lTimeUI

include $(GNUSTEP_MAKEFILES)/application.make
