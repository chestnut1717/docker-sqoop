# 도커 환경에서 스쿱을 통한 테이블을 수집해 보자
[![DockerPulls](https://img.shields.io/docker/pulls/dvoros/sqoop.svg)](https://registry.hub.docker.com/u/dvoros/sqoop/)
[![DockerStars](https://img.shields.io/docker/stars/dvoros/sqoop.svg)](https://registry.hub.docker.com/u/dvoros/sqoop/)

_Note: this is the master branch - for a particular Sqoop version always check the related branch_

> 본 페이지는 아파치 하둡을 설치하고 테이블 수집 까지 수행하는 과정을 가이드 하는 페이지입니다. 아파치 스쿱의 경우 최소한 하둡 클라이언트가 설치되어 있어야만 하는데 맥의 경우 brew 를 통해 설치하고, 리눅스 OS 의 경우 별도로 설치하는 것이 일반적입니다.
> 하지만 본 페이지에서는 컨테이너 상에서 하둡과 스쿱을 설치하고, 별도의 컨테이너에서 MySQL 을 올려두고 수집하는 예제를 수행합니다   
> + 기존 Dockerfile에서는 sqoop 1.4.7 사용하려 했으나 에러(not found) => 1.4.6으로 downgrade해서 진행하였습니다
*** 
Notion : https://www.notion.so/1-Sqoop-77a48a324387467c9558a61b83952bcc
***

<aside>
💡 **필요한 것!**

1. **Docker Desktop**
2. **git**
3. **jdk(환경변수 설정까지)**
</aside>

## 1. 하둡 및 Sqoop 설치

```bash
# 사전에 구축해놓은 Dockerfile clone
git clone https://github.com/chestnut1717/docker-sqoop
```
    

### 하둡, sqoop이 한번에 설치되기 위해 이미지 bulid


```bash
cd docker-sqoop
docker build -t psyoblade/sqoop-hive:2.3.3 .

# image가 제대로 올라왔는지 확인
docker images
```


---

## 2. MySQL 설치

```bash
docker run -d --rm --name mysql -e "MYSQL_ALLOW_EMPTY_PASSWORD=yes" -v `pwd`/data/mysql:/var/lib/mysql -it mysql 
```

<aside>
✅ **Windows cmd**창에서 할 경우 `‘pwd’` ⇒ `%cd%`로 하기

</aside>

```bash
# for windows cmd
docker run -d --rm --name mysql -e "MYSQL_ALLOW_EMPTY_PASSWORD=yes" -v %cd%/data/mysql:/var/lib/mysql -it mysql 
```

<aside>
✅ **Windows powershell**에서 할 경우 `‘pwd’` ⇒ `${pwd}`로 하기

</aside>

```bash
# for windows powershell
docker run -d --rm --name mysql -e "MYSQL_ALLOW_EMPTY_PASSWORD=yes" -v ${pwd}/data/mysql:/var/lib/mysql -it mysql 
```
    

### MySQL 컨테이너 실행

```bash
docker exec -it mysql -uroot
mysql
```

<aside>
✅ **Windows** 환경에서는 ****`-uroot` ⇒ `bash`로 하기

</aside>

```bash
docker exec -it mysql bash
mysql
```

### MySQL에 테스트 테이블 만들기

```bash
create database psyoblade;
use psyoblade;

create table users (id int, account varchar(100));
insert into users values (1, 'BOAZ');
insert into users values (2, 'Engineering');
insert into users values (3, '19th');
insert into users values (4, 'Hello Hadoop');
insert into users values (5, 'Hello Sqoop');
insert into users values (6, 'Chestnut1717');
```

### 테이블을 생성했으면, docker 명령어 입력하기 위해 command창으로 돌아오기(cmd)+ C or D)

---

## 3. internal IP 확인

```bash
docker inspect mysql # 명령을 통해 network 섹션을 확인합니다
        [생략]
        						"GlobalIPv6PrefixLen": 0,
                    "IPAddress": "172.17.0.2",
                    "IPPrefixLen": 16,
                    "IPv6Gateway": "",
                    "MacAddress": "02:42:ac:11:00:02",
                    "Networks": {
                        "bridge": {
                            "IPAMConfig": null,
                            "Links": null,
                            "Aliases": null,
                            "NetworkID": "262cd6269a27c837f570cb6a3cc9ed665527e459b43acd0442d6ddd9e60f08e0",
                            "EndpointID": "2f05d5a0aacbd522120ae1941a6453bd960d81f6e8bf3fd9735a15f3c66e1f81",
                            "Gateway": "172.17.0.1",
                            "IPAddress": "172.17.0.2",
                            "IPPrefixLen": 16,
                            "IPv6Gateway": "",
                            "GlobalIPv6Address": "",
                            "GlobalIPv6PrefixLen": 0,
                            "MacAddress": "02:42:ac:11:00:02",
                            "DriverOpts": null
                        }
                    }
                }
            }
        ]
```


---

## 4. Sqoop 실행

### 간단하게 네트워크 생성 후 연결

```bash
# container간(sqoop - mysql) 네트워크 통신 가능하게 하기 위함
docker network create sqoop-mysql
docker network connect sqoop-mysql mysql

# sqoop image run 후 container 실행
docker run --name sqoop --network sqoop-mysql -v %cd%/jars:/jdbc -dit psyoblade/sqoop-hive:2.3.3
docker exec -u root -it sqoop bash
```

### sqoop image run

```bash
docker run --name sqoop --network sqoop-mysql -v `pwd`/jars:/jdbc -dit psyoblade/sqoop-hive:2.3.3
```

<aside>
✅ **Windows cmd**창에서 할 경우 `‘pwd’` ⇒ `%cd%`로 하기

</aside>

```bash
# for windows cmd
docker run --name sqoop --network sqoop-mysql -v %cd%/jars:/jdbc -dit psyoblade/sqoop-hive:2.3.3
```

<aside>
✅ **Windows powershell**에서 할 경우 `‘pwd’` ⇒ `${pwd}`로 하기

</aside>

```bash
# for windows powershell
docker run --name sqoop --network sqoop-mysql -v ${pwd}/jars:/jdbc -dit psyoblade/sqoop-hive:2.3.3
```

### container 실행

```bash
# root 이름으로 sqoop 실행
docker exec -u root -it sqoop -uroot
```

<aside>
✅ **Windows** 환경에서는 ****`-uroot` ⇒ `bash`로 하기

</aside>

```bash
# for windows
docker exec -u root -it sqoop bash
```

### MySQL에 저장된 테이블의 데이터를 import

```bash
sqoop import \
          -jt local \
          -fs local \
        	-m 1 \
        	--connect jdbc:mysql://mysql:3306/psyoblade \
        	--username root \
        	--table users \
        	--target-dir /tmp/sqoop/t2
```

    

### import한 데이터 살펴보기

```bash
vi /tmp/sqoop/t2/part-m-00000
```


    

---

### 참고자료

- [https://hub.docker.com/r/psyoblade/docker-sqoop](https://hub.docker.com/r/psyoblade/docker-sqoop)
- [https://velog.io/@yoounseules/도커-볼륨을-이용한-소스-변경시-볼륨실행-에러윈도우환경](https://velog.io/@yoounseules/%EB%8F%84%EC%BB%A4-%EB%B3%BC%EB%A5%A8%EC%9D%84-%EC%9D%B4%EC%9A%A9%ED%95%9C-%EC%86%8C%EC%8A%A4-%EB%B3%80%EA%B2%BD%EC%8B%9C-%EB%B3%BC%EB%A5%A8%EC%8B%A4%ED%96%89-%EC%97%90%EB%9F%AC%EC%9C%88%EB%8F%84%EC%9A%B0%ED%99%98%EA%B2%BD)
- sqoop version : [https://blog.naver.com/PostView.nhn?isHttpsRedirect=true&blogId=shyoo_1990&logNo=221274353927&parentCategoryNo=&categoryNo=23&viewDate=&isShowPopularPosts=true&from=search](https://blog.naver.com/PostView.nhn?isHttpsRedirect=true&blogId=shyoo_1990&logNo=221274353927&parentCategoryNo=&categoryNo=23&viewDate=&isShowPopularPosts=true&from=search)
