# gmic-cad-artifact
GMIC CAD Package Standalone 

### 远程触发本地部署

```shell
$ cat post-commit
#!/bin/sh
curl http://admin:11ae14233d5a8e361b728b98b2f76653ef@192.168.3.236:8000/job/gmic-cad-artifact/build?token=sandbox
```

### 星鱼广告
[星+智能营销云平台](http://xingyu.cloud.smallsaas.cn)
