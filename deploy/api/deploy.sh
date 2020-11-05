#!/bin/sh

################################
## define your var for lib deploy
export DL_STANDALONE='gmic-cad-artifact-1.0.0-standalone.jar'
export DL_DOCKERNAME='api'
################################

## main
standalone=${DL_STANDALONE}
dockername=${DL_DOCKERNAME}
app='app.jar'
keep=7


## main
#i=0
if [ ! $standalone ];then
  #echo "standalone=$(ls *-standalone.jar)"
  standalone=$(ls *-standalone.jar)
  #i=$((i+1))
fi

if [ ! $standalone ];then
  echo DL_STANDALONE not yet defined
  exit
fi
rollback=$standalone.rollback_$(date "+%m-%d")

## backup app
if [ ! -f $app ];then
  #echo "app=$(ls *-standalone.jar)"
  app=$standalone
  #i=$((i+1))
fi
if [ ! -f $rollback ];then
   echo cp $app $rollback
   cp $app $rollback
   echo predeploy.sh rollback keep ${standalone}.rollback_ $keep
   bash ./predeploy.sh rollback keep ${standalone}.rollback_ $keep
fi


###
### deploying 
###
restarting=() 
app='app.jar'
if [ -f $app ];then  ## only if app.jar manner
  if [ -f $standalone ];then
    echo mv $standalone $app
    mv $standalone $app
    ## flag restart
    restarting=$app
  fi
fi
if [ ! $restarting ];then
  exit
fi
## end deploy


## restart docker container
if [ ! $dockername ];then
  echo DL_DOCKERNAME not yet defined
  exit
fi

echo '# restart docker container required'
echo docker-compose restart $dockername
#docker-compose restart $dockername

