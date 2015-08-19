@(TEMPLATE(
    'snippet/add_generated_comment.Dockerfile.em',
    user_name=user_name,
    tag_name=tag_name,
    source_template_name=template_name,
    now_str=now_str,
))@
@(TEMPLATE(
    'snippet/from_base_image.Dockerfile.em',
    template_packages=template_packages,
    os_name=os_name,
    os_code_name=os_code_name,
    arch=arch,
    base_image=base_image,
))@
MAINTAINER Nate Koenig nkoenig@@osrfoundation.org
@[if 'packages' in locals()]@
@[if packages]@

# install packages
RUN apt-get update && apt-get install -q -y \
    @(' \\\n    '.join(packages))@ \
    && rm -rf /var/lib/apt/lists/*

@[end if]@
@[end if]@
# install gazebo packages
RUN apt-get update && apt-get install -q -y \
    @(' \\\n    '.join(gazebo_packages))@  \
    && rm -rf /var/lib/apt/lists/*

# clone gzweb
RUN hg clone https://bitbucket.org/osrf/gzweb ~/gzweb

# build gzweb
RUN cd ~/gzweb \
    && hg up default \
    && ./deploy.sh -m

# setup environment
EXPOSE 8080
EXPOSE 7681

# run gzserver and gzweb
@{
cmds = [
'./root/gzweb/start_gzweb.sh',
'gzserver',
]
}@
CMD @(' && '.join(cmds))
