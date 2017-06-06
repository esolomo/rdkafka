LIBSUBDIRS=	src src-cpp

CHECK_FILES+=	CONFIGURATION.md qa_clients/qa_producer qa_Clients/qa_consumer 

PACKAGE_NAME?=	librdkafka
VERSION?=	$(shell python packaging/get_version.py src/rdkafka.h)

# Jenkins CI integration
BUILD_NUMBER ?= 1

.PHONY:

all: mklove-check libs CONFIGURATION.md check

include mklove/Makefile.base

libs:
	@(for d in $(LIBSUBDIRS); do $(MAKE) -C $$d || exit $?; done)

CONFIGURATION.md: src/rdkafka.h qa_clients
	@printf "$(MKL_YELLOW)Updating$(MKL_CLR_RESET)\n"
	@echo '//@file' > CONFIGURATION.md.tmp
	@(qa_clients/qa_performance -X list >> CONFIGURATION.md.tmp; \
		cmp CONFIGURATION.md CONFIGURATION.md.tmp || \
		mv CONFIGURATION.md.tmp CONFIGURATION.md; \
		rm -f CONFIGURATION.md.tmp)

file-check: CONFIGURATION.md LICENSES.txt qa_clients

check: file-check
	@(for d in $(LIBSUBDIRS); do $(MAKE) -C $$d $@ || exit $?; done)

install:
	@(for d in $(LIBSUBDIRS); do $(MAKE) -C $$d $@ || exit $?; done)

qa_clients tests: .PHONY libs
	$(MAKE) -C $@

docs:
	doxygen Doxyfile
	@echo "Documentation generated in staging-docs"

clean-docs:
	rm -rf staging-docs

clean:
	@$(MAKE) -C tests $@
	@$(MAKE) -C qa_clients $@
	@(for d in $(LIBSUBDIRS); do $(MAKE) -C $$d $@ ; done)
	rm -rf src/*.o

distclean: clean
	./configure --clean
	rm -f config.log config.log.old

archive:
	git archive --prefix=$(PACKAGE_NAME)-$(VERSION)/ \
		-o $(PACKAGE_NAME)-$(VERSION).tar.gz HEAD
	git archive --prefix=$(PACKAGE_NAME)-$(VERSION)/ \
		-o $(PACKAGE_NAME)-$(VERSION).zip HEAD

rpm: distclean
	$(MAKE) -C packaging/rpm

LICENSES.txt: .PHONY
	@(for i in LICENSE LICENSE.*[^~] ; do (echo "$$i" ; echo "--------------------------------------------------------------" ; cat $$i ; echo "" ; echo "") ; done) > $@.tmp
	@cmp $@ $@.tmp || mv $@.tmp $@ ; rm -f $@.tmp

