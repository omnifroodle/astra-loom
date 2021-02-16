FROM hexpm/elixir:1.11.0-erlang-23.2.4-alpine-3.13.1

RUN apk add --update nodejs npm && \
    mix local.hex --force && \
    mix archive.install hex phx_new 1.5.3 --force && \
    mix local.rebar --force && \
    node -v

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
COPY . .

RUN mix deps.get --only prod && \
    MIX_ENV=prod mix compile && \
    npm install --prefix ./assets && \
    npm run deploy --prefix ./assets && \
    MIX_ENV=prod mix phx.digest && \
    MIX_ENV=prod mix release --overwrite

FROM alpine:3.13.1
ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
RUN apk add --update bash
COPY --from=0 /app/_build/prod/rel/loom/ .
CMD ["/app/bin/loom", "start"]