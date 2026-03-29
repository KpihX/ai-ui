.PHONY: help install start stop logs status push

# Default target
help:
	@echo "Open WebUI Deployment Suite"
	@echo ""
	@echo "  make install   — deploy/update service (runs install.sh)"
	@echo "  make start     — start systemd service"
	@echo "  make stop      — stop systemd service"
	@echo "  make logs      — follow live logs"
	@echo "  make status    — show service status"
	@echo "  make push      — commit + push to github + gitlab"

# --- Service Management ---

install:
	sudo ./install.sh

start:
	sudo systemctl start open-webui

stop:
	sudo systemctl stop open-webui

logs:
	journalctl -u open-webui.service -f

status:
	sudo systemctl status open-webui

# --- Git ---

push:
	git add -A
	git commit -m "chore: update" || true
	git push github HEAD
	git push gitlab HEAD

