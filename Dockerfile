FROM debian:stable

ENV UNSW_TERM=00T0

ARG DEBIAN_FRONTEND=noninteractive

ENV LANG=en_AU.UTF-8
ENV LANGUAGE=en_AU:en
ENV LC_ALL=en_AU.UTF-8

RUN \
	echo 'deb http://deb.debian.org/debian oldstable main' > /etc/apt/sources.list.d/oldstable.list &&\
	echo 'deb http://security.debian.org/debian-security oldstable/updates main' >> /etc/apt/sources.list.d/oldstable.list &&\
	echo 'deb http://deb.debian.org/debian oldstable-updates main' >> /etc/apt/sources.list.d/oldstable.list &&\
	apt-get -q -y update &&\
	apt-get -q -y dist-upgrade &&\
	apt-get -q -y install ca-certificates curl locales sed tzdata &&\
	ln -sf /usr/share/zoneinfo/Australia/Sydney /etc/localtime &&\
	echo Australia/Sydney >/etc/timezone &&\
	localedef -i en_AU -c -f UTF-8 -A /usr/share/locale/locale.alias en_AU.UTF-8 &&\
	for stem in atci COMP1511 COMP1521 COMP2041 ;\
	do \
		apt-get install -q -y $(curl -sL https://gitlab.cse.unsw.edu.au/ccs/extrapackages/-/raw/master/$stem.list|sed 's/#.*//') ;\
	done  &&\
	apt-get install -q -y vim &&\
	apt-get	 -q -y clean &&\
	pip3 install --no-cache-dir cachelib pycmarkgfm
	
# install latest version of dcc
   
RUN \
	latest_dcc_version=$(curl --silent "https://api.github.com/repos/COMP1511UNSW/dcc/releases/latest"|grep tag_name|cut -d'"' -f4) &&\
	curl -L --silent "https://github.com/COMP1511UNSW/dcc/releases/download/$latest_dcc_version/dcc" -o /usr/local/bin/dcc &&\
	chmod 755 /usr/local/bin/dcc

# set up symlink like CSE
RUN \
	mkdir -m 755 /web &&\
	for c in cs1511 cs1911 cs1521 cs2041 ;\
	do \
		mkdir -m 755 -p /home/$c/public_html/bin  /home/$c/public_html/$UNSW_TERM/ /web &&\
		ln -s /home/$c/public_html/bin /home/$c/bin &&\
		ln -s /home/$c/public_html /web/$c &&\
		ln -s /usr/bin/python3 /web/$c/bin/python3 &&\
		printf '#!/bin/sh\nPATH=/home/%s/bin:$PATH exec "$@"\n' $c >/usr/local/bin/$(echo $c|cut -c3-) &&\
		ln -s /home/$c/public_html/$UNSW_TERM/scripts/autotest /home/$c/bin &&\
		ln -s /home/$c/public_html/$UNSW_TERM/scripts/c_check /home/$c/bin ;\
	done &&\
	chmod 755 /usr/local/bin/*


ENV ARCH pc.amd64.linux

ENTRYPOINT \
	if test "$0" != "/bin/sh" || test "$#" != "0"  ;\
	then \
		exec "$0" "$@" ;\
	fi ;\
	d=/home/cs1511/public_html/$UNSW_TERM/ &&\
	if test ! -d $d/private/.git;\
	then \
		echo "error: no repo found in $d/private" &&\
		echo "Run the container mounting a directory containing the 1511 repo in a sub-directory named private on $d" &&\
		echo "For example:" &&\
		echo "mkdir /tmp/my_dev" &&\
		echo "git clone --recursive git@github.com:COMP1511UNSW/course_materials.git /tmp/my_dev/private"  &&\
		echo "docker run -it -v /tmp/my_dev:$d -p 5000 --tmpfs /tmp comp1511/dev" &&\
		exit 1 ;\
	fi ;\
	cd $d/private &&\
	echo "scripts/build								   # build all course materials" &&\
	echo "flask/webpages.py 0.0.0.0					   # run website on localhost" &&\
	echo "" &&\
	echo "printf '#include <stdio.h>\\\\nint main(void) {printf(\"Hello, it is good to C you!\\\\\\\\n\");}' >bad_pun.c" &&\
	echo "1511 autotest bad_pun						   # run autotest" &&\
	echo "1511 autotest -a private/activities/bad_pun  # run autotest being developed " &&\
	bash -l
