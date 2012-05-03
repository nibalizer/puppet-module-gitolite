#!/bin/bash
 
# $GL_REPO is an environment variable passed to us from gitolite
 
$OLDREV = $1 # This is the shasum of the old revision number
$NEWREV = $2 # This is the shasum of the new revision number (if the update succeeds)
$REF = $3 # This is the ref of the branch the update is applying to
 
cd $HOME/repositories/$GL_REPO/
 
export CONDEMNED=$(git config --get hooks.iscondemned) # If 'hooks.condemned' does not exists, will return ''
 
if [ $CONDEMNED = "true" ]
then
    echo "Repository $GL_REPO is condemned, aborting"
    exit 1
  else
    echo "Repository $GL_REPO is not condemned, proceeding"
    exit 0
fi
