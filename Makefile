
all:service invoker
invoker:
	valac --pkg gtk+-3.0 src/ShivaInvoker.vala -d build/src
service:
	meson build --prefix=/usr
	cd build;ninja
clean:
	rm -r build
reset: clean all
dependencies:
	sudo pacman -S vala libsecret webkit2gtk gtk3