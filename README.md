# docker-multi-site

`docker compose`로 그누보드, 워드프레스, 라이믹스를 한번에 운영할 수 있는 셋팅입니다.

php 이미지에 ffmpeg와 redis를 추가합니다.

`php`만 `Dockerfile`로 빌드하고, 나머지는 모두 공식 이미지로 구성합니다.

원문은 제 홈페이지에 있습니다.


## 서버 시간 설정하기

현재 돌아가고 있는 시스템의 timezone과 local time을 우리나라에 맞게 변경합니다.

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


## git clone으로 다운 받기

```
git clone https://github.com/woosungchoi/docker-multi-site && cd docker-multi-site
```

위 명령어로 다운 받고 폴더로 이동합니다.


## 와일드카드 인증서 발급받기

https://www.wsgvet.com/bbs/board.php?bo_table=home&wr_id=653

위 내용대로 클라우드플레어나 LuaDNS를 이용하여 DNS API 방식으로 와일드카드 인증서를 발급 받습니다.

`ssl_renew.sh`까지 완료합니다.


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

MYSQL_ROOT_PASSWORD : mariadb의 루트 비밀번호를 입력합니다.
MYSQL_USER : DB 유저를 생성합니다. dbuser라고 놔두면 됩니다.
MYSQL_PASSWORD : 원하는 DB 유저의 비밀번호를 입력합니다.

MARIADB_MULTIPLE_DATABASES=gnuboard,wordpress,rhymix

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

그누보드는 `data` 폴더에는 `777` 권한을 주고, 나머지는 현재 계정에게 권한을 줘야 셋팅하기 편합니다.

그누보드 특성상 코어 쪽이나 스킨, 테마에 수정을 많이 해야되는데, 권한 문제가 생기면 매우 불편합니다.

```
sudo chown -R $USER site/gnuboard
sudo chmod -R 777 site/gnuboard/data
```

위 두 명령어로 

모든 파일 및 폴더에 현재 로그인 되어있는 유저에게 권한을 주고,

데이터 및 이하의 폴더와 파일에 `777` 권한을 주면 관리하기 매우 좋습니다.
