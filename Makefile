ODIR=build
ROOT_DIRECTORY=.
exclude=$(ODIR) \
	${ROOT_DIRECTORY}/Makefile \
	${ROOT_DIRECTORY}/README.md \
	${ROOT_DIRECTORY}/test
checks=$(filter-out $(exclude),$(wildcard ${ROOT_DIRECTORY}/*))
build : clean
	mkdir -p $(ODIR)
	cp -r .common $(checks) $(ODIR)
test :

.PHONY : clean
clean :
	-rm -rf $(ODIR)
