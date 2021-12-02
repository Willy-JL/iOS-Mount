PREFIX = /usr

all:
	@echo Run \'make install\' to install iOS-Mount.

install:
	@mkdir -p $(DESTDIR)$(PREFIX)/bin
	install -m 0755 ios-mount.sh $(DESTDIR)$(PREFIX)/bin/ios-mount
	@ln -s $(PREFIX)/bin/ios-mount  $(DESTDIR)$(PREFIX)/bin/iosmount

uninstall:
	@rm -rf $(DESTDIR)$(PREFIX)/bin/ios-mount
	@rm -rf $(DESTDIR)$(PREFIX)/bin/iosmount
