name   = builder
docker = docker run --volume=$(shell pwd):/input:rw $(name)

PERCENT    := %
dimensions := "2000x1500"

all: out/slides.pdf

out/slides.pdf: tmp/ordered
	mkdir -p $(dir $@)
	convert \
		-page $(dimensions) \
		$</* \
                -gravity center \
		-extent $(dimensions) \
		-format pdf \
		$@

tmp/ordered: data/slide_order.txt tmp/png tmp/jpg
	rm -rf $@
	mkdir -p $@
	cat $< \
		| parallel \
		  --col-sep "\t" \
		  "cp tmp/{1}/{2}.{1} $@/{#}.{1}"
	ls tmp/ordered \
		| awk -F . '{ printf("tmp/ordered/%s tmp/ordered/%03d.%s\n", $$0, $$1, $$NF) }' \
		| xargs -n2 mv


tmp/jpg: tmp/image.png
	mkdir -p $@
	find ~/Dropbox/slides/*.jpg \
		| parallel  "convert -gravity center -resize $(dimensions) {} $@/{/.}.jpg"

tmp/png: tmp/cropped
	mkdir -p $@
	find $</* \
		| parallel "convert -resize $(dimensions) {} $@/{/.}.png"

tmp/cropped: tmp/image.png
	mkdir -p $@
	convert \
		-crop "1x50@" \
		-resize $(dimensions) \
		$< \
		$@/$(PERCENT)03d.png

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
