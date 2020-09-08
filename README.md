# docker-multi-site

우분투 20.04 LTS 기준 `docker compose`로 그누보드, 워드프레스, 라이믹스를 동시에 운영할 수 있는 셋팅입니다.

`php` 이미지에 `ffmpeg`와 `redis`를 추가합니다.

`ffepeg`를 추가하여 그누보드와 라이믹스에서 움직이는 `gif`파일을 `mp4`와 `webm`으로 인코딩할 수 있습니다.

`redis`를 추가하여 세션 저장소로 활용할 수 있고, 워드프레스와 라이믹스에서 `cache`로 쓸 수 있습니다.

`php`만 `Dockerfile`로 빌드하고, 나머지는 모두 공식 이미지로 구성합니다.

포트는 `80`과 `443`을 사용하고 있습니다. 해당 포트의 방화벽을 열어주세요.

포트를 변경하고 싶다면 docker-compose.yml 파일에서 `80:80`과 `443:443`을 `xx:80`, `yyy:443`의 형태로 바꾸면 됩니다.

상세 원문은 https://www.wsgvet.com/bbs/board.php?bo_table=ubuntu&wr_id=123 를 참조하세요!

## 폴더 구조 설명

```
├── data                       # 자동생성 볼륨들
│   ├── acme.sh
│   ├── dataredis
│   ├── dbdata
│   └── portainer_data
├── db
│   └── create-multiple-db.sh  # 다량의 DB 동시생성 스크립트
├── docker-compose.yml         # 도커 컴퓨터 파일
├── .env                       # 비번 등 중요정보 숨김파일
├── build
│   ├── Dockerfile             # php 빌더를 위한 파일
│   └── docker-entrypoint.sh   # 3종 CMS 자동 설치 스크립트
├── nginx
│   ├── conf.d                 # nginx 설정파일 폴더
│   │   ├── basic              # 공통 설정파일
│   │   ├── options-ssl-nginx  # SSL 설정파일
│   │   ├── ssl-conf           # SSL 경로 설정파일
│   │   ├── phpmyadmin.conf    # phpmyadmin 설정파일
│   │   ├── portainer.conf     # portainer 설정파일
│   │   ├── gnuboard.conf      # 그누보드 설정파일
│   │   ├── gnuboard-rewrite   # 그누보드 짧은주소
│   │   ├── rhymix.conf        # 라이믹스 설정파일
│   │   ├── rhymix-rewrite     # 라이믹스 짧은주소
│   │   └── wordpress.conf     # 워드프레스 설정파일
│   ├── logs                   # nginx 로그 폴더
│   └── nginx.conf             # nginx 설정파일
├── php
│   └── php.ini                # php 설정파일
├── site                       # CMS 폴더 및 SSL인증서 저장 폴더
│   ├── gnuboard
│   ├── rhymix
│   ├── wordpress
│   └── ssl
└── docker_upgrade.sh          # 도커 이미지 최신버전 업그레이드 스크립트
```

## 서버 시간 설정하기

현재 돌아가고 있는 시스템의 `timezone`과 `local time`을 우리나라에 맞게 변경합니다.

우분투 20.04에서는 하나의 명령어로 서울 시간으로 바꿀 수 있습니다.

```
sudo timedatectl set-timezone Asia/Seoul
```

이제 현재 우분투 서버의 시간이 서울로 바뀌었습니다.

잘 바뀌었는지 확인하려면

```
timedatectl
```

위 명령어만 내리면 바로 확인 가능합니다.

```
# timedatectl
               Local time: Fri 2020-08-21 11:29:33 KST
           Universal time: Fri 2020-08-21 02:29:33 UTC
                 RTC time: Fri 2020-08-21 02:29:34
                Time zone: Asia/Seoul (KST, +0900)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no
```

위와 같이 KST와 서울로 표시되는 것을 확인할 수 있습니다.

이 정보를 도커 컨테이너에 모두 넣을 것입니다. 그러면 로그에서도 정확한 시간이 표시될 것입니다.

## 도커 및 도커 컴포즈 설치

https://www.wsgvet.com/bbs/board.php?bo_table=ubuntu&wr_id=96

위 링크의 1,2번을 참조하여 설치하면 됩니다.


## git clone으로 다운 받기

```
git clone https://github.com/woosungchoi/docker-multi-site && cd docker-multi-site
```

위 명령어로 다운 받고 폴더로 이동합니다.


## 와일드카드 인증서 발급받기

https://www.wsgvet.com/bbs/board.php?bo_table=home&wr_id=653

위 내용대로 클라우드플레어나 LuaDNS를 이용하여 DNS API 방식으로 와일드카드 인증서를 발급 받습니다.

`ssl_renew.sh`의 경로 수정까지 완료합니다.


## SMTP 구글 릴레이 메일서버용 구글계정 앱 비밀번호 생성하기(그누보드 전용)

https://www.wsgvet.com/bbs/board.php?bo_table=home&wr_id=594

여기 2번에서 구글 앱 비밀번호를 생성합니다.

SMTP 구글 릴레이 메일서버 및 그누보드에 적용 관련 자세한 내용은

https://www.wsgvet.com/bbs/board.php?bo_table=ubuntu&wr_id=108

위 링크를 참조하세요.

SMTP는 그누보드 전용이며, 워드프레스는 SMTP 구글 릴레이 플러그인, 라이믹스는 메일건 같은 API를 이용하는 것을 추천합니다.

그누보드를 사용하지 않는다면 넘어가면 됩니다.


## .env 내용 채우기

`.env` 파일를 열어보면

```
MYSQL_ROOT_PASSWORD=rootpassword
MYSQL_USER=dbuser
MYSQL_PASSWORD=dbuserpassword
MARIADB_MULTIPLE_DATABASES=gnuboard,wordpress,rhymix
LUA_Key=
LUA_Email=
CF_Key=
CF_Email=
GMAIL_USER=youremail@gmail.com
GMAIL_PASSWORD=abcdefghijklmopr
```

`MYSQL_ROOT_PASSWORD` : mariadb의 루트 비밀번호를 입력합니다.

`MYSQL_USER` : DB 유저를 생성합니다. dbuser라고 놔두면 됩니다.

`MYSQL_PASSWORD` : 원하는 DB 유저의 비밀번호를 입력합니다.

`MARIADB_MULTIPLE_DATABASES`=gnuboard,wordpress,rhymix

위 내용은 자동으로 생성되는 DB의 이름입니다. 콤마로 원하는만큼 생성할 수 있습니다.

이름도 바꿔도 되는데요. 대문자와 `_`밑첨자까지 가능하지만, 가운데 대시 `-`는 불가능합니다.

예를들어 `MARIADB_MULTIPLE_DATABASES=gnuboard,wordpress,rhymix,DB_1,DB_21231,db2,db3`

등등 계속 넣을 수 있습니다. 넣는만큼 자동으로 생성됩니다.

모든 DB의 유저는 `dbuser`입니다.

```
LUA_Key=
LUA_Email=
CF_Key=
CF_Email=
```

이 부분은 SSL 와일드카드 인증서 받을 때 넣었을 것입니다. 필요없는 것은 지워도 됩니다.

```
GMAIL_USER=youremail@gmail.com
GMAIL_PASSWORD=abcdefghijklmopr
```

위 내용을 3번에서 생성한 앱 비밀번호와 지메일 계정을 넣습니다.


## /db/create-multiple-db.sh 수정하기

이 스크립트는 자동으로 DB를 생성하게 해주는 스크립트입니다.

9번째 줄에 있는 `rootpassword` 를 자신이 지정한 `MYSQL_ROOT_PASSWORD` 비밀번호로 바꿔야 합니다.

그리고 DB의 유저 이름을 `dbuser`가 아닌 다른 이름으로 정했다면 11번째 줄에 있는 `dbuser`를 바꾼 이름으로 넣으면 됩니다.


## Nginx에 도메인 주소 수정하기

Nginx 설정파일을 미리 만들어두었습니다.

변경할 부분은 도메인 및 서브도메인입니다.

`/nginx/conf.d/` 이하의 폴더에서

```
gnuboard.conf (그누보드용 Nginx 설정파일)
wordpress.conf  (워드프레스용 Nginx 설정파일)
rhymix.conf (라이믹스용 Nginx 설정파일)
phpmyadmin.conf (phpmyadmin용 Nginx 설정파일)
portainer.conf (portainer용 Nginx 설정파일)
```

를 열어보면 도메인이 전부 `example.com` 이라고 입력되어 있습니다. 모든 파일에서 자신의 도메인으로 변경해주세요.

그리고 그누보드가 대표도메인으로 되어있고, 워드프레스, 라이믹스는 서브도메인으로 되어 있습니다.

그누보드를 서브도메인으로 돌리고 싶다면 

`./nginx/conf.d/gnuboard.conf`을 열어서

```
server {
        listen 80;
        listen [::]:80;

        server_name gnu.example.com;

        location / {
                rewrite ^ https://$host$request_uri? ;
        }
}

server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name gnu.example.com;

        root /var/www/html/gnuboard;

        include /etc/nginx/conf.d/basic;
        include /etc/nginx/conf.d/gnuboard-rewrite;
}
```

위와 같이 변경하면 됩니다.


그리고 워드프레스를 대표도메인으로 하고 싶다면

```
server {
        listen 80;
        listen [::]:80;

        server_name example.com www.example.com;

        location / {
                rewrite ^ https://$host$request_uri? ;
        }
}

server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name example.com www.example.com;
	
	# www로 들어왔을 때 www를 제거해주는 역할입니다.
        if ($host != 'example.com' ) {
                rewrite ^/(.*)$  https://example.com/$1;
        }

        root /var/www/html/wordpress;

        include /etc/nginx/conf.d/basic;
}
```

위와 같이 변경하면 됩니다.

그리고 

`phpmyadmin.conf` (phpmyadmin용 Nginx 설정파일)
`portainer.conf` (portainer용 Nginx 설정파일)

위 두 파일은 열어보면 IP 차단관련 설정이 되어 있습니다.

잘 읽어보고 IP 셋팅을 하면 보안에 큰 도움이 됩니다.

각각의 파일을 열어보면 해당 주소를 확인할 수 있으며, 설정이 끝난 후 각각의 주소로 접속할 수 있습니다. 참고로 서브도메인은 원하는대로 수정이 가능합니다. 와일드카드 SSL 인증서가 있기 때문이죠!

## /build/docker-enrtypoint.sh 파일 권한 변경하기

```
chmod +x ./build/docker-entrypoint.sh
```

위 명령어로 실행가능하게 변경해줍니다.


## docker-compose 파일 변경하기

기존의 SSL용 `docker-compose.yml` 파일을 삭제하고

`docker-compose.full.yml` 파일을 `docker-compose.yml` 로 수정합니다.


## 도커 컴포즈 실행하기

모든 준비는 끝났습니다. 

```
sudo docker-compose up -d
```

위 명령어만 내리면 `그누보드`, `워드프레스`, `라이믹스`, `phpmyadmin`, `portainer`가 자동으로 구동됩니다.

오라클 클라우드 무료 인스턴스 기준

`mariadb`, `redis`, `smtp` 다운 받는데 1분

`php` 빌드하는데 3분 15초

`nginx`와 `phpmyadmin`, `portainer` 다운 받는데 1분

최종 실행에 5분 30초 걸립니다.

```
Creating smtp_relay ... done
Recreating acme.sh  ... done
Creating portainer  ... done
Creating db         ... done
Creating redis      ... done
Creating phpmyadmin ... done
Creating php        ... done
Creating nginx      ... done
```

위와 같이 나오면 성공입니다.

이제 자신의 도메인으로 접속해보세요!

Nginx에서 서브도메인을 변경하지 않았다면

그누보드 : https://example.com

워드프레스 : https://wp.example.com

라이믹스 : https://rhymix.example.com

portainer : https://port.example.com

phpmyadmin : https://pma.example.com

위와 같은 형식으로 접속할 수 있습니다.

## 실행 후 보안 처리

`/db/create-multiple-db.sh`

위 파일에 DB의 `root` 비밀번호가 있기 때문에 삭제해야 합니다.

도커가 실행될 때 `mariadb`의 `volume`이 생성되는데요. 그때 실행되면서 DB를 만듭니다.

즉 이미 `volume`이 생성되었다면 컨테이너를 재생성해도 `create-multiple-db.sh`파일이 실행되지 않습니다.

따라서 `DB`의 `/data/dbdata` 폴더를 삭제 하면 `DB`가 초기화됩니다. 그 후 컨테이너를 재생성하면 `create-multiple-db.sh`파일이 실행됩니다.

## CMS 설치 방법

그누보드는 Host에 `db`, User에는 `dbuser` 또는 지정한 DB의 유저, Password는 DB의 비밀번호, DB는 `gnuboard`, TABLE명 접두사는 그대로 둡니다.

워드프레스는 데이터베이스 이름에 `wordpress`, 사용자명에 `dbuser` 또는 지정한 DB의 유저, 암호는 DB의 비밀번호, 데이터베이스 호스트는 `db`, 테이블 접두어는 그대로 두면 됩니다.

rhymix는 DB 종류에 `mysql`, DB 서버 주소에 `db`, DB 서버 포트에 `3306`, DB 아이디에 `dbuser` 또는 지정한 DB의 유저, DB 비밀번호는 DB의 비밀번호, DB 이름은 `rhymix`, 테이블 접두사는 그대로 두면 됩니다.


## 사용하다가 또다른 사이트를 설치하는 방법

와일드카드 SSL 인증서가 있기 때문에 서브도메인을 무한대로 사용할 수 있습니다.

기본적으로 `./site/` 이하 폴더에 폴더를 생성하고 파일을 넣습니다. 

권한은 `82`로 해야 컨테이너의 `www-data`가 권한 문제없이 쓸 수 있습니다.

`alpine` 리눅스에서는 `www-data`가 `82`로 표현이 되더라구요. ㅎㅎ

컨테이너 내에서는 `www-data`라고 정확하게 표시가 됩니다.

아무튼 폴더를 생성하고 파일을 넣은 뒤, 예를들어 `./site/sample` 이라는 폴더에 파일이 있다면

`./nginx/con.d/` 이하에 `sample.conf` 라는 파일을 만들고

```
server {
        listen 80;
        listen [::]:80;

        server_name sample.example.com;

        location / {
                rewrite ^ https://$host$request_uri? ;
        }
}

server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name sample.example.com;

        root /var/www/html/sample;

        include /etc/nginx/conf.d/basic;
}
```

위와 같이 넣어주면 됩니다. 핵심은 `sample`에 주목하세요.

그리고

```
sudo docker-compose up -d --force-recreate --no-deps nginx
```

위 명령어를 내리면 `nginx`를 재실행하여 설정이 반영됩니다.

도메인을 브라우저에 넣으면 접속이 될 것입니다.

`DB`는 `phpmyadmin`에서 생성하면 됩니다.


## portainer 설명

https://www.wsgvet.com/bbs/board.php?bo_table=ubuntu&wr_id=120

위 링크에 상세하게 설명해두었습니다.


## 그누보드 권한 설정

그누보드는 `data` 폴더에는 `707` 권한을 주고, 나머지는 현재 계정에게 권한을 줘야 셋팅하기 편합니다.

그누보드 특성상 코어 쪽이나 스킨, 테마에 수정을 많이 해야되는데, 권한 문제가 생기면 불편합니다.

```
sudo chown -R $USER site/gnuboard
sudo chmod -R 707 site/gnuboard/data
```

위 두 명령어로 

모든 파일 및 폴더에 현재 로그인 되어있는 유저에게 권한을 주고,

데이터 및 이하의 폴더와 파일에 `707` 권한을 주면 관리하기 편합니다.

혹시 `나리야` 빌더를 사용 중이라면 `/site/gnuboard/theme` 이하에도 권한을 707로 주는 것이 좋습니다.

```
sudo chmod -R 707 site/gnuboard/theme
```

위 명령으로 707 권한을 줍니다.

## 라이믹스 redis 캐시 사용 설정

관리자모드 -> 설정 -> 시스템 설정 -> 고급 설정 -> 캐시 사용 redis 선택

호스트 : `redis`

포트 : `6379`

DB 번호 : `1`


## 워드프레스 redis 캐시 사용 설정

`W3 Total Cache` 기준 

`redis` 캐시 사용 설정 후

각 페이지마다 

`Redis hostname:port / IP:port:` 에 `redis`만 넣으면 됩니다.

`redis:6379` 를 넣어도 됩니다.

## 도커 이미지 최신버전으로 업그레이드

php 이미지를 제외한 나머지 이미지는 모두 공식 이미지입니다.

특정 Tag를 지정하지 않았으므로 최신버전으로 지정되어 있는데요.

```
sudo docker-compose pull
```
위 명령어로 도커 컴포즈 파일에 있는 이미지의 최신버전을 다운 받습니다.


```
sudo docker pull woosungchoi/fpm-alpine
```

그리고 `php` 빌드에 필요한 `woosungchoi/fpm-alpine`도 업데이트합니다.

```
sudo docker-compose up --build -d
```

위 명령어를 내리면 업데이트 된 이미지는 재생성하고, `php`를 빌드하고 백그라운드에서 실행 될 것입니다.

```
~/docker-multi-site$ docker pull woosungchoi/fpm-alpine
Pulling from woosungchoi/fpm-alpine
df20fa9351a1: Already exists
b358d6dbbdff: Already exists
0232d962484c: Already exists
0c1d3ac04d2a: Already exists
b3732f4f24f8: Already exists
fcb8848bd304: Already exists
e3ca18042f44: Already exists
4fdaa57ecb0d: Already exists
f45e8ed5f113: Already exists
206bc7d2ac83: Already exists
08d96594edf0: Pull complete
d450aa90f40c: Pull complete
3992c3d95e5e: Pull complete
ac4165693714: Pull complete
9b20a4be545d: Pull complete
Digest: sha256:de439ed3730232983f8c2261dfc3c0b7fb3051bef803ab0c76ea349e0d514443
Status: Downloaded newer image for woosungchoi/fpm-alpine:latest

~/docker-multi-site$ docker-compose pull
Pulling db          ... done
Pulling redis       ... done
Pulling smtp        ... done
Pulling php         ... done
Pulling nginx       ... done
Pulling acme.sh     ... done
Pulling phpmyadmin  ... done
Pulling portainer   ... done
Pulling code-server ... done

~/docker-multi-site$ docker-compose up --build -d
Building php
Step 1/9 : FROM woosungchoi/fpm-alpine:latest
 ---> 52a00ba84dec
Step 2/5 : VOLUME /var/www/web
 ---> Running in 17a0366ca280
Removing intermediate container 17a0366ca280
 ---> 7154b7f6ac58
Step 3/5 : COPY docker-entrypoint.sh /usr/local/bin/
 ---> bf1edbbd5f25
Step 4/5 : ENTRYPOINT ["docker-entrypoint.sh"]
 ---> Running in a4ac85308159
Removing intermediate container a4ac85308159
 ---> 2e0336c2139d
Step 5/5 : CMD ["php-fpm"]
 ---> Running in ec296281ea37
Removing intermediate container ec296281ea37
 ---> 12d7667ceb38
Successfully built 12d7667ceb38
Successfully tagged docker-multi-site_php:latest
portainer is up-to-date
smtp_relay is up-to-date
Starting acme.sh ...
redis is up-to-date
db is up-to-date
code-server is up-to-date
phpmyadmin is up-to-date
Recreating php   ... done
Starting acme.sh ... done
```

위와 같이 진행됩니다.

그리고 빌드가 새로 되면 기존에 있던 `php`이미지가 태그가 없는 상태로 남겨집니다.

태그가 없는 이미지는 정리해주면 좋겠죠?

```
sudo docker image prune -f
```
위 명령어로 태그가 없는 이미지가 삭제됩니다.

```
sudo docker-compose pull && sudo docker pull woosungchoi/fpm-alpine && sudo docker-compose up --build -d && sudo docker image prune -f
```

그리고 위 명령어로 모아서 실행해도 됩니다.

## 도커 이미지 최신버전 업그레이드 자동 실행 설정

루트에 있는 `docker_upgrade.sh` 파일을 열어서 `cd /your/path/docker-multi-site/` 부분을 `docker-compose.yml` 파일이 있는 경로로 바꿉니다.

그리고 권한을 수정합니다.

```
chmod a+x docker_upgrade.sh
```

위 명령어로 도커 업그레이드 파일을 실행 가능하게 바꿉니다.

그리고 `crontab`에 매일 또는 일주일에 한번 실행하게 추가해줍니다.

```
sudo crontab -e
```
위 명령어를 넣은 후 

```
30 12 * * * /your/path/docker-multi-site/docker_upgrade.sh >> /var/log/docker_upgrade_cron.log 2>&1
```

위와 같이 추가해줍니다. (위 셋팅은 매일 오후 12시 30분마다 실행)

`/your/path/docker-multi-site/` 이 부분은 자신의 경로에 맞게 수정하세요!

컨트롤 + O, 엔터, 컨트롤 + X로 저장해줍니다.

## SSL 인증서 자동갱신 작업하기

```
sudo crontab -e
```

위 명령어를 넣은 후

```
30 13 * * * docker start acme.sh && docker exec nginx nginx -s reload >> /var/log/ssl_update_cron.log 2>&1
```

위와 같이 추가해줍니다.

컨트롤 + O, 엔터, 컨트롤 + X로 저장해줍니다.

## php 8.0으로 업그레이드하는 방법

현재(2020년 8월) php의 최신버전은 `7.4`입니다. 그리고 2020년 11월 중순에 `8.0` 정식 버전이 나올 것입니다.

그때 `8.0`으로 업그레이드 하고 싶다면 `./build/Dockerfile`을 수정하면 됩니다.

`Docker`허브에서 직접 관리하고 있는 `Wordpress Docker`파일을 사용할 것입니다.

`워드프레스` 이미지의 `Dockerfile` 이 관리가 잘되고 있고 그누보드, 라이믹스와 호환이 잘되기 때문입니다.

https://github.com/docker-library/wordpress/tree/master

2020년 11월에 위 링크에서 `php8.0` 폴더가 생길 것입니다. (물론 그 이후에 `8.1`, `8.2`가 나와도 같은 방식으로 업데이트하면 됩니다.)

들어가보면 `apache`, `cli`, `fpm-alpine`, `fpm`이 있을텐데요.

현재 가이드에서는 `fpm-alpine`을 사용하고 있습니다. 용량이 매우 적은 장점이 있습니다.

`php8.0` 폴더의 `fpm-alpine` 폴더에 들어가면 `Dockerfile`이 있을 것입니다.

해당 파일을 `./build` 폴더에 덮어씁니다.

`Dockerfile`을 열어서 11번째 줄에 보면

```
# Alpine package for "imagemagick" contains ~120 .so files, see: https://github.com/docker-library/wordpress/pull/497
		imagemagick
```

위 내용이 있는데요.

```
# Alpine package for "imagemagick" contains ~120 .so files, see: https://github.com/docker-library/wordpress/pull/497
		imagemagick \
# For gnuboard ffmpeg gif2mp4webm
		ffmpeg
```

위 내용으로 바꿔줍니다. 이제 `php` 이미지에 `ffmpeg`가 설치될 것입니다.

추가로 `php-redis`도 설치해줍니다.

대략 34~38번째 줄을 보면

```
pecl install imagick-3.4.4; \
docker-php-ext-enable imagick; \
```

위 내용이 있는데

```
pecl install imagick-3.4.4 redis; \
docker-php-ext-enable imagick redis; \
```

위와 같이 redis를 추가해줍니다.

그러면 이미지 빌드할 때 `php-redis`가 설치됩니다.

그리고 기존 워드프레스를 제거하고 3종 CMS를 사용할 것이므로 

75번째 ~ 92번째 줄에 있는

```
ENV WORDPRESS_VERSION 5.5
ENV WORDPRESS_SHA1 03fe1a139b3cd987cc588ba95fab2460cba2a89e

RUN set -ex; \
	curl -o wordpress.tar.gz -fSL "https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz"; \
	echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c -; \
# upstream tarballs include ./wordpress/ so this gives us /usr/src/wordpress
	tar -xzf wordpress.tar.gz -C /usr/src/; \
	rm wordpress.tar.gz; \
	chown -R www-data:www-data /usr/src/wordpress; \
# pre-create wp-content (and single-level children) for folks who want to bind-mount themes, etc so permissions are pre-created properly instead of root:root
	mkdir wp-content; \
	for dir in /usr/src/wordpress/wp-content/*/; do \
		dir="$(basename "${dir%/}")"; \
		mkdir "wp-content/$dir"; \
	done; \
	chown -R www-data:www-data wp-content; \
	chmod -R 777 wp-content
```

위 내용을 지워줍니다. 

그리고 

```
# fix work iconv library with alpine
# Huge thanks to chodingsana!
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ --allow-untrusted gnu-libiconv
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php
```

위 내용을 넣습니다. iconv 관련 회원가입시 오류를 해결해줍니다.

수정  후 컨트롤 + O, 엔터, 컨트롤 + X 로 저장 후 빠져나옵니다.

저장 후 사용하면 됩니다.

그리고 위에 있는 자동 업그레이드 설정 부분에서 `7.4`로 되어 있는 것을 `8.0` 또는 자신이 원하는 버전으로 바꾸면 됩니다.
