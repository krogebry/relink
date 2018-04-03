FROM ruby:2.4

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install python3-pip awscli jq -y
RUN pip3 install awscli --upgrade

COPY ./Gemfile /opt/relink/
WORKDIR /opt/relink/
RUN bundle update

COPY ./web/ /opt/relink/
COPY web/wrapper.sh /opt/relink

ENTRYPOINT [ "/opt/relink/wrapper.sh" ]
