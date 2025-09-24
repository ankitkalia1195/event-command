.PHONY: env/setup env/teardown dev

env/setup:
	bin/envsetup

env/teardown:
	bin/envteardown

dev:
	make env/setup
	bin/setup
