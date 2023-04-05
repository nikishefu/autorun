VERSION := $(shell sed -n 's/^VERSION="\([^"]*\)".*$$/\1/p' autorun.sh)

all:
	@echo "Builing autorun v$(VERSION)..."
	@rm -rf package
	@mkdir -p package/usr/local/bin
	@cp -r debian package/DEBIAN
	@sed -i 's/Version: .*/Version: $(VERSION)/' package/DEBIAN/control
	@shc -o package/usr/local/bin/autorun -f autorun.sh
	@rm autorun.sh.x.c
	@dpkg-deb --build package
	@mv package.deb "autorun_$(VERSION)_`dpkg-deb --field package.deb Architecture`.deb"
	@rm -r package
	@sed -i 's/[0-9]\+\.[0-9]\+\.[0-9]\+/$(VERSION)/g' README.md
	@echo "Complete!"
clean:
	@echo "Cleaning up..."
	@rm *.deb
	@echo "Complete!"
