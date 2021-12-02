PREFIX = /usr

all:
	@echo Run \'make install\' to install iOS-Mount.

install:
	@mkdir -p $(DESTDIR)$(PREFIX)/bin
	install -m 0755 ios-mount.sh $(DESTDIR)$(PREFIX)/bin/ios-mount
	@ln -s $(PREFIX)/bin/ios-mount  $(DESTDIR)$(PREFIX)/bin/iosmount
	install -m 0755 iOS-Mount.desktop $(DESTDIR)$(PREFIX)/share/applications/iOS-Mount.desktop

uninstall:
	@rm -rf $(DESTDIR)$(PREFIX)/bin/ios-mount
	@rm -rf $(DESTDIR)$(PREFIX)/bin/iosmount
	@rm -rf $(DESTDIR)$(PREFIX)/share/applications/iOS-Mount.desktop
