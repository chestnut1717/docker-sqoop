ARG BASE_CONTAINER=dvoros/hive:2.3.3
FROM $BASE_CONTAINER
LABEL maintainer="Suhyuk Park <park.suhyuk@gmail.com>"


# add sqoop user
ARG USER=sqoop
ARG PASS=sqoop
ARG UID=1004
ARG GID=1004
RUN useradd -m ${USER} --uid=${UID} && echo "${USER}:${PASS}" | chpasswd
USER ${UID}:${GID}

ENV HOME /home/${USER}
RUN mkdir -p $HOME/target
WORKDIR /home/${USER}


# install sqoop as root
USER root
ENV SQOOP_HOME /usr/local/sqoop

RUN curl -L -k1 -s https://www-us.apache.org/dist/sqoop/1.4.7/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz | tar -xz -C /usr/local
RUN ln -s /usr/local/sqoop-1.4.7.bin__hadoop-2.6.0 $SQOOP_HOME

ENV PATH $PATH:$SQOOP_HOME/bin

# Sqoop won't pick up Hive stuff if there's no HCAT_HOME, need to manually add these
ENV SQOOP_USER_CLASSPATH $HIVE_HOME/lib/*:$HIVE_HOME/conf

COPY entrypoint.sh /etc/docker-startup/entrypoint.sh
RUN chown -R root:root /etc/docker-startup
RUN chmod -R 700 /etc/docker-startup

COPY tutorials.sh $HOME/tutorials.sh
COPY jars/*.jar $SQOOP_HOME/lib/
RUN chown -R sqoop:sqoop $HOME/tutorials.sh
