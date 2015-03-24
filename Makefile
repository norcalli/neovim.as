
all:
	grunt prod && atom-shell-packager build Neovim && rm -rf ~/Applications/Neovim.app && mv Neovim.app ~/Applications/
