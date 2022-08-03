# dev-docker
a Docker container which builds course materials and can run local copy of website

The container needs top be run with a directory mounted which contains
the course-materials repo in the sub-directory **`private`** , e.g. 

```bash
$ mkdir /tmp/my_dev
$ git clone --recursive git@github.com:COMP1511UNSW/course_materials.git /tmp/my_dev/private
$ docker run -it -v /tmp/my_dev:/home/cs1511/public_html/$00T0/ -p 5000 --tmpfs /tmp comp1511/dev
```

Command that can be run in container

```
scripts/build                                # build all course materials	
flask/webpages.py 0.0.0.0					 # run website on localhost
printf '#include <stdio.h>\nint main(void) {printf("Hello, it is good to C you!\\n");}' >bad_pun.c
1511 autotest bad_pun                        # run autotest
1511 autotest -a private/activities/bad_pun  # run autotest being developed 
```

To container should already be available as **`comp1511/dev`**, to rebuild:

```
docker build -t comp1511/dev https://raw.githubusercontent.com/COMP1511UNSW/dev-docker/main/Dockerfile
```