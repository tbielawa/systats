PRODUCT := "talook"
RPMSPECDIR := contrib/rpm
RPMSPEC := $(RPMSPECDIR)/$(PRODUCT).spec

tests: unittests pep8 pyflakes
	:

unittests:
	@echo "#############################################"
	@echo "# Running Unit Tests"
	@echo "#############################################"
	nosetests -v

clean:
	@find . -type f -regex ".*\.py[co]$$" -delete
	@find . -type f \( -name "*~" -or -name "#*" \) -delete
	@rm -fR build dist rpm-build MANIFEST

pep8:
	@echo "#############################################"
	@echo "# Running PEP8 Compliance Tests"
	@echo "#############################################"
	pep8 --ignore=E501 -r server.py

pyflakes:
	@echo "#############################################"
	@echo "# Running Pyflakes Sanity Tests"
	@echo "# Note: most import errors may be ignored"
	@echo "#############################################"
	-pyflakes server.py

sdist: clean
	python setup.py sdist

rpmcommon: sdist
	@mkdir -p rpm-build
	@cp dist/*.gz rpm-build/

srpm5: rpmcommon
	rpmbuild-md5 --define "_topdir %(pwd)/rpm-build" \
	--define 'dist .el5' \
	--define "_builddir %{_topdir}" \
	--define "_rpmdir %{_topdir}" \
	--define "_srcrpmdir %{_topdir}" \
	--define "_specdir $(RPMSPECDIR)" \
	--define "_sourcedir %{_topdir}" \
	-bs $(RPMSPEC)
	@echo "#############################################"
	@echo "$(PRODUCT) SRPM is built:"
	@find rpm-build -maxdepth 2 -name '$(PRODUCT)*src.rpm' | awk '{print "    " $$1}'
	@echo "#############################################"

srpm: rpmcommon
	rpmbuild --define "_topdir %(pwd)/rpm-build" \
	--define "_builddir %{_topdir}" \
	--define "_rpmdir %{_topdir}" \
	--define "_srcrpmdir %{_topdir}" \
	--define "_specdir $(RPMSPECDIR)" \
	--define "_sourcedir %{_topdir}" \
	-bs $(RPMSPEC)
	@echo "#############################################"
	@echo "$(PRODUCT) SRPM is built:"
	@find rpm-build -maxdepth 2 -name $(PRODUCT)'*src.rpm' | awk '{print "    " $$1}'
	@echo "#############################################"

rpm: rpmcommon
	rpmbuild --define "_topdir %(pwd)/rpm-build" \
	--define "_builddir %{_topdir}" \
	--define "_rpmdir %{_topdir}" \
	--define "_srcrpmdir %{_topdir}" \
	--define "_specdir $(RPMSPECDIR)" \
	--define "_sourcedir %{_topdir}" \
	-ba $(RPMSPEC)
	@echo "#############################################"
	@echo "$(PRODUCT) RPMs are built:"
	@find rpm-build/noarch -maxdepth 2 -name $(PRODUCT)'*.rpm' | awk '{print "    " $$1}'
	@echo "#############################################"
