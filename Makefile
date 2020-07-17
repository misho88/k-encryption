LOCATION=/usr/local/bin

TOOLS=$(wildcard tools/*)
DESTINATIONS=$(subst tools,$(LOCATION),$(TOOLS))

$(LOCATION)/%: tools/%
	install $< $@

uninstall:
	rm $(DESTINATIONS)

install: $(DESTINATIONS)
