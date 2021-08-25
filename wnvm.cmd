@echo off
title windows多版本node切换
chcp 65001
set NODE_HOME=%~dp0
set npm_folder=repo_npm
set yarn_folder=repo_yarn
set npm_prefix=""
set yarn_prefix=""
set "PATH=%NODE_HOME%;%PATH%"

call :gnvmCfg %NODE_HOME%
call :nodeInstall %1

call :npmInstall
call :npmConfig npm_prefix %NODE_HOME% %npm_folder%
call :npmMirrorConfig
set NODE_NPM_PATH=%npm_prefix%\global
set "PATH=%NODE_NPM_PATH%;%PATH%"

call :yarnInstall yarn_prefix %NODE_HOME% %yarn_folder% %npm_prefix%
set NODE_YARN_PATH=%yarn_prefix%\bin
set "PATH=%NODE_YARN_PATH%;%PATH%"

call :setBaseEnv
pause
goto:eof

:setBaseEnv
echo ------ 配置系统环境变量开始 ------
setx "NODE_HOME" %NODE_HOME% /m
setx "NODE_NPM_PATH" %npm_prefix%\global /m
setx "NODE_YARN_PATH" %yarn_prefix%\bin /m
echo.
echo ----------------------------------------------
echo   请将 %%NODE_HOME%% 加入到 PATH 系统变量
echo   请将 %%NODE_NPM_PATH%% 加入到 PATH 系统变量
echo   请将 %%NODE_YARN_PATH%% 加入到 PATH 系统变量
echo ----------------------------------------------
echo ------ 配置系统环境变量结束 ------
echo.
goto:eof

:gnvmCfg
echo ------ gnvm 配置开始 ------
if exist %~1.gnvmrc (
  del %~1.gnvmrc
)
call gnvm.cmd
call gnvm.cmd config registry TAOBAO
echo ------ gnvm 配置结束 ------
echo.
goto:eof

:nodeInstall
echo ------ node 安装开始 ------
call gnvm.cmd install %~1
call gnvm.cmd use %~1
REM 打印 node 版本
for /F %%i in ('node -v') do ( set nodeversion=%%i)
echo.
echo node version %nodeversion%
echo ------ node 安装结束 ------
echo.
goto:eof

:npmInstall
echo ------ npm 安装开始 ------
REM 安装 node 对应的 npm
call gnvm.cmd npm global
REM 打印 npm 版本
for /F %%i in ('npm -v') do ( set npmversion=%%i)
echo.
echo npm version %npmversion%
echo ------ npm 安装结束 ------
echo.
goto:eof

:npmConfig
echo ------ npm 配置开始 ------
set npm_down_base=%~2%3
set "%~1=%~2%3"
REM 配置 npm 下载依赖存储路径
call npm config set prefix %npm_down_base%\global
call npm config set cache %npm_down_base%\cache
call npm config get prefix
call npm config get cache
echo ------ npm 配置结束 ------
echo.
goto:eof

:npmMirrorConfig
echo ------ npm 加速配置开始 ------
REM 配置 npm 国内镜像，可以加速下载依赖速度
REM 配置淘宝镜像，可能会影响yarn命令
REM vue-create 报错 command failed: yarn --registry=https://registry.npm.taobao.org --disturl=https://npm.
call npm config set registry https://registry.npm.taobao.org
call npm config set disturl https://npm.taobao.org/dist

REM 配置 node-sass 国内镜像
call npm config set sass_binary_site https://npm.taobao.org/mirrors/node-sass/
REM 配置 phantomjs 国内镜像
call npm config set phantomjs_cdnurl https://npm.taobao.org/mirrors/phantomjs/
REM 配置 chromedriver 国内镜像
call npm config set chromedriver_cdnurl http://npm.taobao.org/mirrors/chromedrive/
REM 配置 electron 国内镜像
call npm config set electron_mirror https://npm.taobao.org/mirrors/electron/

call npm config set registry https://registry.npm.taobao.org
call npm config set disturl https://npm.taobao.org/dist

call npm config get sass_binary_site
call npm config get phantomjs_cdnurl
call npm config get chromedriver_cdnurl
call npm config get electron_mirror
echo ------ npm 加速配置结束 ------
echo.
goto:eof

:yarnInstall
echo ------ yarn 安装开始 ------
set yarn_down_base=%~2%3
set "%~1=%~2%3"
REM 安装 yarn 命令
if not exist %~4\global\yarn.cmd (
    call npm install -g yarn --registry=https://registry.npm.taobao.org
)

REM 配置 yarn 下载依赖存储路径
if not exist %yarn_down_base% (
  call yarn config set prefix "%yarn_down_base%"
  call yarn config set global-folder "%yarn_down_base%\global"
  call yarn config set cache-folder "%yarn_down_base%\cache"
  call yarn config set link-folder "%yarn_down_base%\link"
)

REM 打印 yarn 版本
for /F %%i in ('yarn -v') do ( set yarnversion=%%i)
echo yarn version %yarnversion%
REM 获取 yarn 配置
call yarn config get prefix
call yarn config get global-folder
call yarn config get cache-folder
call yarn config get link-folder
echo ------ yarn 安装结束 ------
echo.
goto:eof
