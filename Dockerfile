FROM ruby:2.7.0-preview1-buster

WORKDIR /var/app

RUN apt install git -y

ADD push-server.rb /var/app/push-server.rb
ADD 0x42424242.in /var/app/0x42424242.in
RUN gem install bundle && bundle update

EXPOSE 30000

CMD ["bundle exec rackup"]



