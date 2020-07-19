TOOLS_LOCATION=/usr/local/bin
RECIPES_LOCATION=/usr/local/bin

TOOLS=$(wildcard tools/*)
RECIPES=$(wildcard recipes/*)
TOOLS_DESTINATIONS=$(subst tools,$(TOOLS_LOCATION),$(TOOLS))
RECIPES_DESTINATIONS=$(subst recipes,$(RECIPES_LOCATION),$(RECIPES))

DESTINATIONS=$(TOOLS_DESTINATIONS) $(RECIPES_DESTINATIONS)

$(TOOLS_LOCATION)/%: tools/%
	install $< $@

$(RECIPES_LOCATION)/%: recipes/%
	install $< $@

uninstall:
	rm $(DESTINATIONS)

install: $(DESTINATIONS)
