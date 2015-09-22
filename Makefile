name   = builder
docker = docker run --volume=$(shell pwd):/input:rw $(name)

PERCENT    := %
dimensions := "2000x1500"

all: out/slides.pdf

out/slides.pdf: tmp/ordered
	mkdir -p $(dir $@)
	$(docker) convert \
		-page $(dimensions) \
		/input/$</* \
                -gravity center \
		-format pdf \
		/input/$@

tmp/ordered: tmp/pngs
	mkdir -p $@
	cp ~/Dropbox/slides/* $@
	cat data/slide_order.txt \
		| parallel --col-sep , "convert -resize $(dimensions) $</{1}.png $@/{2}.png"

tmp/pngs: tmp/image.png
	mkdir -p $@
	$(docker) convert \
		-crop "1x40@" \
		/input/$< \
		/input/$@/$(PERCENT)03d.png

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
	rm -rf tmp/* out/*
