PREFIX = /usr

all:
	@echo Run \'make install\' to install iOSMount.

install:
	@mkdir -p $(DESTDIR)$(PREFIX)/bin
	install -m 0755 iosmount.sh $(DESTDIR)$(PREFIX)/bin/iosmount

uninstall:
	@rm -rf $(DESTDIR)$(PREFIX)/bin/iosmount
