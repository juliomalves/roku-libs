APPNAME = roku-utils
VERSION = 0.3.0
IP = 192.168.1.1
USERNAME = rokudev
USERPASS = password
ZIP_EXCLUDE = -x \*.pkg -x keys\* -x LICENSE\* -x \*.md -x \*/.\* -x .\* -x build\* -x package\*

PKGREL = ./package
ZIPREL = ./build
SOURCEREL = ..

.PHONY: zip install remove tests package

zip:
# Remove old application zip
	@if [ -e "$(ZIPREL)/$(APPNAME).zip" ]; \
	then \
		rm  $(ZIPREL)/$(APPNAME).zip; \
	fi

# Create destination directory	
	@if [ ! -d $(ZIPREL) ]; \
	then \
		mkdir -p $(ZIPREL); \
	fi

# Set directory permissions
	@if [ ! -w $(ZIPREL) ]; \
	then \
		chmod 755 $(ZIPREL); \
	fi

# Zip .png files without compression do not zip Makefiles or any files ending with '~'
	@echo "    Creating application zip: $(ZIPREL)/$(APPNAME).zip"	
	@if [ -d $(SOURCEREL)/$(APPNAME) ]; \
	then \
		(zip -q -0 -r "$(ZIPREL)/$(APPNAME).zip" . -i \*.png $(ZIP_EXCLUDE)); \
		(zip -q -9 -r "$(ZIPREL)/$(APPNAME).zip" . -x \*~ -x \*.png -x Makefile $(ZIP_EXCLUDE)); \
	else \
		echo "    Source for $(APPNAME) not found at $(SOURCEREL)/$(APPNAME)"; \
	fi

install: zip
# Close current app to avoid crashes
	@curl -d "" "http://$(IP):8060/keypress/home"
	@sleep 1

	@echo "    Installing $(APPNAME).zip to host $(IP)"
	@curl --user $(USERNAME):$(USERPASS) --digest -s -S -F "mysubmit=Install" -F "archive=@$(ZIPREL)/$(APPNAME).zip" -F "passwd=" http://$(IP)/plugin_install | grep "<font color" | sed "s/<font color=\"red\">//" | sed "s[</font>[[" ; \

remove:
# Close current app to avoid crashes
	@curl -d "" "http://$(IP):8060/keypress/home"
	@sleep 1
	
	@echo "    Removing $(APPNAME) from host $(IP)"
	@curl --user $(USERNAME):$(USERPASS) --digest -s -S -F "mysubmit=Delete" -F "archive=" -F "passwd=" http://$(IP)/plugin_install | grep "<font color" | sed "s/<font color=\"red\">//" | sed "s[</font>[[" ; \

tests: install
	@echo "    Running tests at $(IP)"
	@curl -d '' "http://${IP}:8060/launch/dev?RunTests=true"

package: install
	@echo "    Creating package file"

	@echo "    Creating destination directory $(PKGREL)"	
	@if [ ! -d $(PKGREL) ]; \
	then \
		mkdir -p $(PKGREL); \
	fi

	@echo "    Setting directory permissions for $(PKGREL)"
	@if [ ! -w $(PKGREL) ]; \
	then \
		chmod 755 $(PKGREL); \
	fi

	@echo "    Packaging $(APPNAME) on host $(IP)"
	@read -p "Password: " REPLY ; echo $$REPLY | xargs -i curl --user $(USERNAME):$(USERPASS) --digest -s -S -Fmysubmit=Package -Fapp_name=$(APPNAME)/$(VERSION) -Fpasswd={} -Fpkg_time=`expr \`date +%s\` \* 1000` "http://$(IP)/plugin_package" | grep '^<font face=' | sed 's/.*href=\"\([^\"]*\)\".*/\1/' | sed 's#pkgs/##' | xargs -i curl --user $(USERNAME):$(USERPASS) --digest -s -S -o $(PKGREL)/$(APPNAME)_{} http://$(IP)/pkgs/{}

	@echo "    Package $(APPNAME) complete" 
