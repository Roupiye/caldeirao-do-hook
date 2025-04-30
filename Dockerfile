FROM crystallang/crystal:1.16.2-alpine as crystal_dependencies
WORKDIR /app
COPY . .

RUN  shards install
RUN shards build

CMD ["./bin/caldeirao_do_hook"]
