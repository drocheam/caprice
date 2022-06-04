
# with the help of
# https://github.com/jeremija/unipicker/blob/master/Makefile

# name of program
INSTALLNAME=caprice

# name of file
FILENAME=caprice.sh

# install location
PREFIX=/usr/local

install:
	install -d -m755 $(PREFIX)/bin
	install -m755 ${FILENAME} $(PREFIX)/bin/${INSTALLNAME}
	install $(FILENAME) $(PREFIX)/$(INSTALLNAME)
	install -d -m755 $(PREFIX)/share/${INSTALLNAME}
	install -m644 radios.json $(PREFIX)/share/${INSTALLNAME}/radios.json

uninstall:
	rm -r $(PREFIX)/bin/$(INSTALLNAME)
	rm -r $(PREFIX)/share/$(INSTALLNAME)

