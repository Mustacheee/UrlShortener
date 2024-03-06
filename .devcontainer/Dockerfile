FROM elixir:1.16.1-otp-26

ENV MIX_ENV dev
ENV NODE_ENV development
ENV PORT 8080
EXPOSE 8080

RUN apt-get update
RUN apt-get install -y postgresql-client inotify-tools

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix archive.install --force hex phx_new

RUN mkdir /app
WORKDIR /app