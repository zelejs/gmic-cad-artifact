
## vendor
if [ -d gmic-cad-vendor ];then
   git pull origin master
else
   git clone git@github.com:zelejs/gmic-cad-vendor.git
fi

## oms
if [ -d gmic-cad-oms ];then
   git pull origin master
else
   git clone git@github.com:zelejs/gmic-cad-oms.git
fi

## users
if [ -d gmic-cad-users ];then
   git pull origin master
else
   git clone git@github.com:zelejs/gmic-cad-users.git
fi


