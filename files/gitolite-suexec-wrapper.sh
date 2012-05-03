#!/bin/bash

USER=$1

export GIT_PROJECT_ROOT="/srv/git/projects"
export GITOLITE_HTTP_HOME="/srv/git"

# OpenSuSE gitolite RPM places gl-auth-command in /usr/bin
exec /usr/bin/gl-auth-command $USER

# End
