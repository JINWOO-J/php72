REPO = dr.yt.com
REPO_HUB = jinwoo
NAME = php72
VERSION = 7.2.25
TAGNAME = $(VERSION)-xdebug
DEBUG_BUILD = no
#include ENVAR


.PHONY: all build push test tag_latest release ssh

all: build

test:
	echo $(TAGNAME)

changeconfig:
		@CONTAINER_ID=$(shell docker run -d $(REPO_HUB)/$(NAME):$(TAGNAME)) ;\
		 echo "COPY TO [$$CONTAINER_ID]" ;\
		 docker cp "files/." "$$CONTAINER_ID":/ ;\
		 docker exec -it "$$CONTAINER_ID" sh -c "echo `date +%Y-%m-%d:%H:%M:%S` > /.made_day" ;\
		 echo "COMMIT [$$CONTAINER_ID]" ;\
		 docker commit -m "Change config `date`" "$$CONTAINER_ID"  $(REPO_HUB)/$(NAME):$(TAGNAME) ;\

build:
		docker build --no-cache --rm=true  --build-arg DEBUG_BUILD=${DEBUG_BUILD} --build-arg PHP_VERSION=$(VERSION) -t $(REPO_HUB)/$(NAME):$(TAGNAME) .

prod:
		docker tag $(REPO_HUB)/$(NAME):$(TAGNAME)  $(REPO_HUB)/$(NAME):$(VERSION)
		docker push $(REPO_HUB)/$(NAME):$(VERSION)

push:
		docker tag  $(NAME):$(VERSION) $(REPO)/$(NAME):$(TAGNAME)
		docker push $(REPO)/$(NAME):$(TAGNAME)

push_hub:
#		docker tag  $(NAME):$(VERSION) $(REPO_HUB)/$(NAME):$(VERSION)
		docker push $(REPO_HUB)/$(NAME):$(TAGNAME)

tag_latest:
		docker tag  $(REPO)/$(NAME):$(TAGNAME) $(REPO)/$(NAME):latest
		docker push $(REPO)/$(NAME):latest

build_hub:
		echo "TRIGGER_KEY" ${TRIGGERKEY}
		git add .
		git commit -m "$(NAME):$(VERSION) by Makefile"
		git tag -a "$(VERSION)" -m "$(VERSION) by Makefile"
		git push origin --tags
		curl -H "Content-Type: application/json" --data '{"build": true,"source_type": "Tag", "source_name": "$(VERSION)"}' -X POST https://registry.hub.docker.com/u/jinwoo/${NAME}/trigger/${TRIGGERKEY}/


init:
		git init
		git add .
		git commit -m "first commit"
		git remote add origin git@github.com:JINWOO-J/$(NAME).git
		git push -u origin master

bash:
	docker run -it --rm $(REPO_HUB)/$(NAME):$(TAGNAME) bash
