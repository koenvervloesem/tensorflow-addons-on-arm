.PHONY: check clean dev_requirements tfa 

check:
	./scripts/check_code.sh

clean:
	rm -r addons-* 

dev_requirements:
	./scripts/install_dev_requirements.sh

tfa:
	./scripts/build_tfa.sh
