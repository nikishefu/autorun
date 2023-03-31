VERSION := $(shell sed -n 's/^VERSION="\([^"]*\)".*$$/\1/p' autorun.sh)

all:
	@echo "Builing autorun v$(VERSION)..."
	@shc -o package/usr/local/bin/autorun -f autorun.sh
	@rm autorun.sh.x.c
	@sed -i -e "s/\(Version:\).*/\1 $(VERSION)/" package/DEBIAN/control
	@dpkg-deb --build package
	@mv package.deb "autorun_`dpkg-deb --field package.deb Version`_`dpkg-deb --field package.deb Architecture`.deb"
	@echo "Complete!"
clean:
	@echo "Cleaning up..."
	@rm *.deb
	@echo "Complete!"
init:
	@mkdir -p package/usr/local/bin package/DEBIAN
	@echo "Package: autorun" > package/DEBIAN/control
	@echo "Version: $(VERSION)" >> package/DEBIAN/control
	@echo "Maintainer: Nikita Ardashev" >> package/DEBIAN/control
	@echo "Architecture: amd64" >> package/DEBIAN/control
	@echo "Description: Script to manage systemd services" >> package/DEBIAN/control
