#!/bin/sh
##############################################################
DOCKER_NAME=cinema-dist
WAR=$1
##############################################################
if [ ! -f $WAR ];then
    echo Target file $WAR not found.
    exit
fi

if [ -d dist ];then
    tar zcf dist.rollback_$(date "+%m-%d") dist
    sh ./predeploy.sh rollback keep dist.rollback_ 6 
    rm -rf ./dist/*
else
    mkdir dist
fi
tar zxf dist.tar.gz 
rm dist.tar.gz
docker restart $DOCKER_NAME