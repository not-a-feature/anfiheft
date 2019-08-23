# Makefile für die Anfihefte

# Fix für Ubuntu-User, bei denen anstatt Bash Dash verwendet wird:
SHELL := /usr/bin/env bash

# Diese Variablen sollten für die aktuelle Version stimmen, müssen aber ggf.
# angepasst werden (am besten über Shell-Variablen, z. B. "export YEAR=2017"
# und "unset YEAR" zum Zurücksetzen):
YEAR ?= $(shell date '+%Y')
# Das Semester ist um 2 Monate nach vorne verschoben, da wir die Briefe ja vor
# dem entsprechenden Semester aktualisieren wollen.
SEMESTER ?= $(shell if [[ $$(date +%m) > 02 && $$(date +%m) < 07 ]]; \
	    then echo sommersemestertrue; \
	    else echo wintersemestertrue; fi)

# Variablen für die Build-Ordner
BUILDDIR = out
# Configuration file generated by the Makefile (current year, edition, etc.):
CONFIG = makeconfig.tex

# set the base year for calculating the edition
BASEYEAR = 2018
BASEEDITION_INFO = 29 # SS 19: 31. Auflage
BASEEDITION_KOGNI = 3 # WS 18/19: 3. Auflage

# automatically set the build parameters like year, semester, edition and if the kogni or info build should be done
BASE_CONF = '\\jahr=$(YEAR) \\$(SEMESTER)'

INFO_AUFLAGE = $(shell if [ $(SEMESTER) = "sommersemestertrue" ]; \
	       then echo $$((($(YEAR)-$(BASEYEAR))*2 + $(BASEEDITION_INFO))); \
	       else echo $$((($(YEAR)-$(BASEYEAR))*2 + $(BASEEDITION_INFO) + 1)); fi)
INFO_CONF = '$(BASE_CONF) \auflage=$(INFO_AUFLAGE) \infotrue'

KOGNI_AUFLAGE = $(shell echo $$(($(YEAR)-$(BASEYEAR) + $(BASEEDITION_KOGNI))))
KOGNI_CONF  = '$(BASE_CONF) \auflage=$(KOGNI_AUFLAGE)'


# Aliases
.PHONY: default
default: all
.PHONY: all
all: info kogni
.PHONY: info
info: anfiheft-info.pdf
.PHONY: kogni
kogni: anfiheft-kogni.pdf

.PHONY: anfiheft-info.pdf # Let latexmk handle the dependencies
anfiheft-info.pdf: anfiheft.tex
	if [ ! -d $(BUILDDIR)-info ]; then mkdir $(BUILDDIR)-info; fi
	echo $(INFO_CONF) > $(CONFIG)
	latexmk -f -output-directory=$(BUILDDIR)-info -pdf -pdflatex="pdflatex" anfiheft.tex $<
	cp $(BUILDDIR)-info/anfiheft.pdf anfiheft-info.pdf
	mv $(CONFIG) info-$(CONFIG)

.PHONY: anfiheft-kogni.pdf # Let latexmk handle the dependencies
anfiheft-kogni.pdf: anfiheft.tex
	if [ ! -d $(BUILDDIR)-kogni ]; then mkdir $(BUILDDIR)-kogni; fi
	echo $(KOGNI_CONF) > $(CONFIG)
	latexmk -f -output-directory=$(BUILDDIR)-kogni -pdf -pdflatex="pdflatex" anfiheft.tex $<
	cp $(BUILDDIR)-kogni/anfiheft.pdf anfiheft-kogni.pdf
	mv $(CONFIG) kogni-$(CONFIG)

.PHONY: clean
clean:
	if [ -d $(BUILDDIR)-info ]; then rm --recursive ./$(BUILDDIR)-info; fi
	if [ -d $(BUILDDIR)-kogni ]; then rm --recursive ./$(BUILDDIR)-kogni; fi
	rm -f info-$(CONFIG)
	rm -f kogni-$(CONFIG)

.PHONY: distclean
distclean: clean
	if [ -f anfiheft-info.pdf ]; then rm anfiheft-info.pdf; fi
	if [ -f anfiheft-kogni.pdf ]; then rm anfiheft-kogni.pdf; fi

.PHONY: help
help:
	@echo 'Building targets:'
	@echo '  all            - Build the info- and kogni-anfiheft (default)'
	@echo '  info           - Build only the info-anfiheft'
	@echo '  kogni          - Build only the kogni-anfiheft'
	@echo 'Auxiliary targets:'
	@echo '  help           - Show this help'
	@echo 'Cleaning targets:'
	@echo '  clean          - Remove both $(BUILDDIR)-Directories'
	@echo '  distclean      - Remove both $(BUILDDIR)-Directories and anfiheft-*.pdf (i.e. everything)'