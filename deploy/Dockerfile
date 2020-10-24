FROM ruby:2.6.5

ENV SSL_ROOT /shared/ssl

RUN apt-get update -qq &&\
  apt-get install -y nodejs postgresql-client nginx apache2-utils curl git cron
RUN git clone https://github.com/Cryptchat/Server.git
RUN gem update --system
RUN gem install bundler --force
WORKDIR /Server
RUN bundle install --without development test

COPY entrypoint.sh /usr/bin/
COPY nginx-letsencrypt.conf /nginx-letsencrypt.conf
COPY nginx.conf /nginx.conf
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

CMD ["rails", "server", "-b", "0.0.0.0"]
