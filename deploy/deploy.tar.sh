tar -cvf deploy.tar \
    --exclude=*.jar --exclude=*.jar.* --exclude=*rollback* \
    --exclude=./mysql/data/* \
    --exclude=./ex-deploy-lib \
    --exclude=./attachments --exclude=./images \
    --exclude=./web/dist \
    --exclude=*.log --exclude=**/log/* \
    --exclude=*.gz --exclude=*.tar --exclude=*.swp\
    . 
