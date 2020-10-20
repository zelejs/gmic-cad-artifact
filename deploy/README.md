# gmic-cad 部署文档

>**测试环境与生产环境都需确保目标服务器已安装Git（用于拉取代码），Docker（用于容器启动管理），Docker-Compose（用于容器编排）**
>
>**测试环境与生产环境都需搭建Jenkins作为同步平台**
>
>**Jenkins**
>
>- 搭建地址：https://github.com/smallsaas/docker-jeninks-sandbox
>
>- 说明文档：https://github.com/smallsaas/docker-jeninks-sandbox/blob/master/README.MD

## 测试环境

### 0. 快速搭建

- 在服务器上拉取`git clone https://github.com/smallsaas/crudless-docker-sandbox.git`
- 确保服务器已安装且启动Docker服务与docker-compose组件
  - 可通过`systemctl status docker`查看Docker状态（**Tips：使用docker-compose应确保Docker服务为开启状态**）
- 确保按照 **[crudless-docker-sandbox中的使用方法](https://github.com/smallsaas/crudless-docker-sandbox/blob/master/%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E.md)** 初始化项目
- 在各自（包括Jenkins）的**docker-compose.yml文件目录下**使用Shell指令执行`docker-compose up`后静观启动结果
  - **刷新docker-compose.yml配置**指令：`docker-compose -f docker-compose.yml up --detach --build  ## for recreating th `；
  - **后台方式启动docker-compose**指令（刷新配置信息）：`docker-compose up -d`；
  - **后台方式启动docker-compose**指令（不刷新配置信息）：`docker-compose start` OR `docker-compose start <MODULE NAME>`。
  - **停止**指令：`docker-compose stop <MODULE NAME>`

### 1. 配置自动部署

#### a. API

>Git地址：git@github.com:zelejs/gmic-cad-artifact.git
>
>Tips：如需要权限，请联系相应管理员处理

>Tips：需保证Jenkins安装 **Maven Integration 与Git 插件**

- 登入Jenkins -> Manage Jenkins ->Configuration System -> Publish over SSH -> ADD 目标服务器

- 登入Jenkins -> New Item -> 构建一个maven项目 -> Source Code Management -> Git -> Repository URL -> 填入git@github.com:zelejs/gmic-cad-artifact.git

- Post-build Actions -> Add Server

  - Name：选择对应的目标服务器
  - Source files：`target/gmic-cad-artifact-1.0.0-standalone.jar`
  - Remove prefix：`target/`
  - Exec command：

  ```shell
  ## 切换至对应api目录下
  cd /home/sandboxs/sandbox_cinema/api/
  ## 配合Sandbox -r --replace选项替换基础包
  sh docker-deploy-lib.sh -r gmic-cad-artifact-1.0.0-standalone.jar
  ```


- 点击下方**Save / Apply按钮**进行保存

至此，Jenkins中已创建好API项目，可参考 [Jenkins使用方法](https://github.com/smallsaas/docker-jeninks-sandbox/blob/master/README.MD) 中的**自动构建（Git Push触发方式）或 构建触发链接**两种不同的方法实现触发自动构建并部署。

#### b. web（pages形式）

>Git地址：git@github.com:zelejs/gmic-cad-web-pages.git
>
>Tips：需保证Jenkins安装 **Conditional BuildStep插件**，用于跳过构建过程，直达部署操作

**构建Jenkis项目可参考 <u>a. API</u> 构建方式，下述不再赘述**

- 完成Job搭建后 -> Build ->选择 Conditional Step (Single) -> 配置Run? -> Builder -> Send files or execute commands over SSH

  - Name：选择对应的目标服务器
  - Source files：`yml/*.yml`
  - Remove prefix：`yml/`
  - Exec command：

  ```shell
  ## 切换至tmp目录下，传输的yml将放置在该目录下
  cd /home/sandboxs/sandbox_cinema/web/tmp
  ## 使用docker中的crudless配合zero-json生成页面至对应的路径下
  docker exec cinema-web crudless --input /tmp --output /src/pages
  ## 清理空间
cd .. && rm -rf ./tmp/*
  ```
  

至此，Jenkins中已创建好API项目，可参考 [Jenkins使用方法](https://github.com/smallsaas/docker-jeninks-sandbox/blob/master/README.MD) 中的**自动构建（Git Push触发方式）或 构建触发链接**两种不同的方法实现触发自动构建并部署。

## 生产环境

>**Tips：拉取代码或环境时缺少权限请联系相应管理员获取权限**
>
>GitHub仓库deploy文件夹内已提供docker-compose相关组件快速安装的Python脚本

### 0. 快速搭建

- 在服务器上拉取`git clone git@github.com:zelejs/gmic-cad-artifact.git`
- 确保服务器已安装且启动Docker服务与docker-compose组件
  - 可通过`systemctl status docker`查看Docker状态（**Tips：使用docker-compose应确保Docker服务为开启状态**）
- 可在当前目录下执行`mvn package`指令生成`*-standalone.jar`包放置于`deploy/api`下
- 保留并设置`deploy`目录下的文件为关键文件（部署基于`deploy`文件夹下），其他文件均可清除

### 1. 配置自动部署

>**生产环境配置自动部署流程与开发环境自动部署流程大体一致，主要区别为web模块，下述将不再赘述配置流程，可参考上述开发环境配置方法**

#### a. API

>Git地址：git@github.com:zelejs/gmic-cad-artifact.git
>
>Tips：如需要权限，请联系相应管理员处理
>
>Tips：需保证Jenkins安装 **Maven Integration 与Git 插件**

- **进入项目 -> Post-build Actions -> Add Server**

  - Name：选择对应的目标服务器
  - Source files：`target/gmic-cad-artifact-1.0.0-standalone.jar`
  - Remove prefix：`target/`
  - Exec command：

  >**用于支持rollback备份**

  ```shell
  cd /home/xing/cinema/api
  if [ -f predeploy.sh ];then
      ## 用于清理多余陈旧的备份文件
      sh ./predeploy.sh rollback keep gmic-cad-artifact-1.0.0-standalone.rollback_ 6 
  fi
  cp -r gmic-cad-artifact-1.0.0-standalone.jar gmic-cad-artifact-1.0.0-standalone.rollback_$(date "+%m-%d")
  mv ./lib/gmic-cad-artifact-1.0.0-standalone.jar ./
  docker restart api
  ```

- 点击下方**Save / Apply按钮**进行保存

#### b. Web（dist形式）

- 进入Jenkins项目配置页面

- Pre Steps -> Add pre-build step -> Execute Shell -> Command

  ```shell
  ## clean gmic-cad-web-jar.jar before mvn build
  rm -rf ~/.m2/repository/com/jfeat/gmic-cad-web-jar/
  ```

- Post Steps -> Add post-build step ->

  - Name：选择对应的目标服务器
  - Source files：`yml/*.yml`
  - Remove prefix：`yml/`
  - Exec command：

  ```shell
  ## mvn install 之后触发装配脚本
  cd target
  rm -rf dist
  mkdir dist
  cd dist
  cp ../gmic-cad-war-1.0.0.jar ./
  jar xf gmic-cad-war-1.0.0.jar
  rm -rf gmic-cad-war-1.0.0.jar
  cd ..
  tar -zcvf dist.tar.gz dist
  rm -rf dist
  ```

至此，Jenkins中已创建好API模块与Web模块，可参考 [Jenkins使用方法](https://github.com/smallsaas/docker-jeninks-sandbox/blob/master/README.MD) 中的**自动构建（Git Push触发方式）或 构建触发链接**两种不同的方法实现触发自动构建并部署。