FROM debian:buster-slim
FROM ruby:2.7.3
RUN ruby -v
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev
WORKDIR /home
RUN gem install rails -v 6.1.3.2
ENV RAILS_ROOT /var/www/app_name
RUN mkdir -p $RAILS_ROOT
WORKDIR $RAILS_ROOT
ENV RAILS_ENV production
ENV RACK_ENV production
ENV SECRET_KEY_BASE f279d7c4029c9a17fd20b155573f6a59b5d435c299a87a55888f57227119b941cb3d844baa0d07fd1b7994aff1051acb8a48c1ffdc4ad6e8659f9d2177970caf
RUN gem install bundler -v 2.2.19
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle _2.2.19_ install --jobs 20 --retry 5
COPY . .
RUN sed -i "s|CipherString = DEFAULT@SECLEVEL=2|# CipherString = DEFAULT@SECLEVEL=2|g" /etc/ssl/openssl.cnf
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 7000