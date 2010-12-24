include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME = TestMill
VERSION = 0.0.1
APP_NAME = TestMill

FRAMEWORKS = TimeUI

TestMill_MAIN_MODEL_FILE=TestMill.gorm
TestMill_APPLICATION_ICON=Threadmill.tiff

TestMill_OBJC_FILES = main.m \
		TMNode.m \
		TMPort.m \
		TMView.m \
		TMNodeView.m \


ADDITIONAL_OBJC_LIBS = -lTimeUI
TestMill_RESOURCE_FILES = TestMill.gorm Threadmill.tiff

include $(GNUSTEP_MAKEFILES)/application.make
