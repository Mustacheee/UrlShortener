# Url Shortener

## Setup

### Docker

- Install Docker if you do not have it already
  - https://docs.docker.com/get-docker/
- Open terminal in root directory
- Build docker containers
  - `docker-compose up` if you are okay with sacrificing this shell
  - `docker-compose up -d` if you'd like to run in background
- The application should begin settings itself up
- Once you see the following line printed `[info] Access UrlShortenerWeb.Endpoint at http://localhost:8080` you are able to interact with application
- Navigate to `http://localhost:8080/dev/dashboard/home` if you'd like to see telemetry dashboard!

### Non-Docker (Additional Functionality Available):

- Install `asdf` for elixir/erland package manager
  - https://asdf-vm.com/guide/getting-started.html#_1-install-dependencies
- Install Erlang 26
  - `asdf plugin add erlang`
  - `asdf install erlang 26.2.2`
  - `asdf global erlang 26.2.2`
- Install Elixir 1.16
  - `asdf plugin add elixir`
  - `asdf install elixir 1.16.1-otp-26`
  - `asdf global elixir 1.16.1-otp-26`
- Install Postgres
  - Recommended:
    - You can utlize the docker-compose DB still if you'd like
    - Comment out the `urlshortserver` service in the docker-compose file, and the DB will still work as expected
  - Not Recommended:
    - Install Postgres directly at https://www.postgresql.org/download/
- Install Phoenix 1.7.11
  - https://hexdocs.pm/phoenix/installation.html
    - Run `mix local.hex`
    - Run `mix archive.install hex phx_new`
- Navigate to root directory in terminal
- Install dependencies and set up DB
  - `mix setup`
- Start Phoenix endpoint with `mix phx.server` or with interactive ability `iex -S mix phx.server`
  - NOTE: If you get issues with starting the server after running the Dockerized version of the app, delete the `_build/` directory and try again
- To run elixir tests `mix test`
- To run and see code coverage
  - `mix coveralls` for cli output
  - `mix coveralls.html` for HTML output
    - Results are spit out to `cover/excoveralls.html`

## Learn more

- Official website: https://www.phoenixframework.org/
- Guides: https://hexdocs.pm/phoenix/overview.html
- Docs: https://hexdocs.pm/phoenix
- Forum: https://elixirforum.com/c/phoenix-forum
- Source: https://github.com/phoenixframework/phoenix
