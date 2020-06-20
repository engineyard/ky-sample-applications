FROM ruby:2.5-buster
RUN apt-get update && apt-get install -y nodejs build-essential libxml2-dev libxslt1-dev curl bash tzdata imagemagick sqlite3 


# Configure the main working directory. This is the base 
# directory used in any further RUN, COPY, and ENTRYPOINT 
# commands.
# In the running container the code will be under /app
RUN mkdir -p /app 
WORKDIR /app

# Copy the Gemfile as well as the Gemfile.lock and install 
# the RubyGems. This is a separate step so the dependencies 
# will be cached unless changes to one of those two files 
# are made.
COPY Gemfile ./ 
RUN gem install bundler -v '1.16.3' && bundle install --without development test --jobs 20 --retry 5

# Copy the main application.
COPY . ./


# Precompile Rails assets
RUN bundle exec rake assets:precompile

#Run migrations
RUN bundle exec rake db:migrate



# Expose port 5000 to the Docker host, so we can access it 
# from the outside. This is the same as the one set with
# `deis config:set PORT 5000`
EXPOSE 5000

# The main command to run when the container starts. Also 
# tell the Rails dev server to bind to all interfaces by 
# default.
CMD bundle exec rails server -b 0.0.0.0 -p 5000 -e development
#CMD ls