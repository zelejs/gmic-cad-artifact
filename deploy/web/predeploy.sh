#!/bin/sh

## deploy.sh sample
#standalone='alliance-api-1.0.0-standalone.jar'
#app='app.jar'
#
#rollback=$standalone.rollback_$(date "+%m-%d")
#if [ ! -f $rollback ];then
#   cp $app $rollback
#
#   bash ./predeploy.sh rollback keep alliance-api-1.0.0-standalone.jar.rollback_ 6
#fi
#
#if [ -f $standalone ];then
#   mv $standalone $app
#fi
#
#docker restart mall-api
## end sample

cmd=$1

usage() {
   echo "Usage:"
   echo '   predeploy.sh rollback keep <pattern> <num>'
   exit
}


cmd2=$1$2

if [ "$cmd2"x == "rollbackkeep"x ];then 
   pattern=$3
   num=$4
   if [ ! $num ];then
      usage
   fi
   cmd=cmdrollbackkeep
fi

rollbackkeep() {
   pattern=$1
   num=$2
   
   i=1
   for it in $(ls "$pattern"* -t);do
      if [ $i -gt $num ];then
        echo $it
        rm $it
      fi
      ## increase
      i=$(($i+1))
   done
}


if [ "$cmd"x == "cmdrollbackkeep"x ];then 
   pattern=$3
   num=$4
   rollbackkeep $pattern $num
else 
   usage
fi

