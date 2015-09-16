name   = builder
docker = docker run --volume=$(shell pwd):/input:rw $(name)

PERCENT    := %
dimensions := "4000x3000"

all: out/slides.pdf

out/slides.pdf: tmp/pngs
	mkdir -p $(dir $@)
	$(docker) convert \
		-page $(dimensions) \
		/input/$</slide_*.png \
		/input/$@

tmp/pngs: tmp/image.png
	mkdir -p $@
	$(docker) convert \
		-crop $(dimensions) \
		/input/$< \
		/input/$@/slide_$(PERCENT)03d.png

tmp/image.png: src/slides.svg
	$(docker) inkscape \
		--file=/input/$< \
		--export-png=/input/$@ \
		--export-dpi=100 \
		--export-area-page

########################################
#
# Bootstrap the project resources
#
########################################

bootstrap: .image
	mkdir -p tmp out

.image: Dockerfile
	docker build -t $(name) .
	touch $@

clean:
	rm -f tmp/* out/*
