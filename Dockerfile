FROM ruby:2.4

RUN apt-get update

COPY ./Gemfile /opt/relink/
WORKDIR /opt/relink/
RUN bundle update

COPY ./web/ /opt/relink/

ENTRYPOINT [ "./api.rb" ]
