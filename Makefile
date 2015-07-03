all:
	@echo "nothing to do"

install_depend:
	sudo apt-get install udhcpc ipcalc

install:
	mkdir -p ~/bin
	cp -v wpa ~/bin/
	cp -v -r wpa_lib ~/bin/
