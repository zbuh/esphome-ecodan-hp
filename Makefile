build:
	. ./venv/bin/activate; esphome compile ecodan-esphome.yaml

update: 
	. ./venv/bin/activate; esphome upload --device 192.168.1.13 ecodan-esphome.yaml
