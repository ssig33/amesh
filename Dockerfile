FROM ruby:2.7
RUN mkdir /app
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle -j9
COPY app.rb ./
ENV PORT=5000
CMD ruby app.rb -p $PORT -o 0.0.0.0
