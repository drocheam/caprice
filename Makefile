
# name of program
INSTALLNAME=caprice

# name of file
FILENAME=caprice.sh

PREFIX=/usr/bin/
DESTDIR=

install:
	install $(FILENAME) $(DESTDIR)/$(PREFIX)/$(INSTALLNAME)
uninstall:
	rm $(DESTDIR)/$(PREFIX)/$(INSTALLNAME)
