PROJECT_NAME = Avertas

DEBUG = 0
TWEAK_NAME = $(PROJECT_NAME)
BUNDLE_NAME = $(PROJECT_NAME)Preferences

$(PROJECT_NAME)_FILES = $(wildcard src/*.m) $(wildcard src/*.x)
$(PROJECT_NAME)_FRAMEWORKS = UIKit
$(PROJECT_NAME)_CFLAGS = -fobjc-arc
$(PROJECT_NAME)_PRIVATE_FRAMEWORKS = BaseBoardUI FrontBoard BackBoardServices
$(PROJECT_NAME)_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries

$(PROJECT_NAME)Preferences_FILES = $(wildcard pref/*.m)
$(PROJECT_NAME)Preferences_RESOURCE_DIRS = pref/res
$(PROJECT_NAME)Preferences_FRAMEWORKS = UIKit Social
$(PROJECT_NAME)Preferences_PRIVATE_FRAMEWORKS = Preferences
$(PROJECT_NAME)Preferences_INSTALL_PATH = /Library/PreferenceBundles

export TARGET_IPHONEOS_DEPLOYMENT_VERSION = 9.0
export ADDITIONAL_OBJCFLAGS = -fobjc-arc -fvisibility=hidden
export INSTALL_TARGET_PROCESSES = SpringBoard


export TARGET = iphone:clang::11.0
export ARCHS = arm64
SYSROOT = $(THEOS)/sdks/iPhoneOS11.2.sdk

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/bundle.mk

repo::
	@cp packages/*.deb ~/Sites/repo/public/debs/
	@update_repo

internal-stage::
	$(ECHO_NOTHING)pref="$(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences"; mkdir -p "$$pref"; cp Preferences.plist "$$pref/$(PROJECT_NAME).plist"$(ECHO_END);
	@(echo "Generating localization resources..."; twine generate-all-localization-files loc/strings.txt "$(THEOS_STAGING_DIR)/Library/PreferenceBundles/$(PROJECT_NAME)Preferences.bundle" --create-folders --format apple)

simulator: all
	xcrun simctl spawn booted launchctl debug system/com.apple.SpringBoard --environment DYLD_INSERT_LIBRARIES=$(THEOS_OBJ_DIR)/$(PROJECT_NAME).dylib
	xcrun simctl spawn booted launchctl stop com.apple.SpringBoard
