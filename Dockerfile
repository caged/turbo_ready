FROM ruby:3.1.2

RUN apt-get -y update && \
apt-get -y upgrade && \
apt-get -y --allow-downgrades --allow-remove-essential --allow-change-held-packages install \
build-essential \
git \
nodejs \
npm \
sqlite3 \
tzdata && \
apt-get clean

# prepare the environment
ENV RAILS_ENV=production RAILS_LOG_TO_STDOUT=true RAILS_SERVE_STATIC_FILES=true

# setup ruby gems
RUN gem update --system && \
gem install bundler && \
bundle config set --global --without test

# setup yarn
RUN npm install -g yarn

# get application code
RUN git clone --origin github --branch main --depth 1 https://github.com/hopsoft/turbo_ready.git /opt/turbo_ready

# install application dependencies 1st time
WORKDIR /opt/turbo_ready
RUN yarn
WORKDIR /opt/turbo_ready/test/dummy
RUN bundle

# prepare and run the application
CMD git pull --no-rebase github main && \
cd /opt/turbo_ready && yarn && \
cd /opt/turbo_ready/test/dummy && bundle && \
rm -f tmp/pids/server.pid && \
bin/rails db:create db:migrate && \
bin/rails assets:clobber && \
bin/rails assets:precompile && \
bin/rails s --binding=0.0.0.0 --port=3000
