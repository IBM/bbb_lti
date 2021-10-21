FROM us.icr.io/skills-network/elixir:latest AS builder

# The following are build arguments used to change variable parts of the image.
# The version of the application we are building (required).
ARG APP_VSN=0.1.0
ARG MIX_ENV=prod

ENV APP_NAME=bbb_lti \
    APP_VSN=${APP_VSN} \
    MIX_ENV=${MIX_ENV}

# By convention, /opt is typically used for applications
WORKDIR /opt/app

# This step installs all the build tools we'll need
RUN apk update && \
  apk upgrade --no-cache && \
  apk add --no-cache \
  nodejs \
  yarn \
  git \
  build-base && \
  mix local.rebar --force && \
  mix local.hex --force

# This step copies source code into the build container
COPY . .

# This step installs the dependencies, compiles them and finally compiles source files
RUN mix do deps.get, deps.compile, compile

# This step builds assets for the Phoenix app
RUN cd ./assets && \
  yarn install && \
  yarn deploy && \
  cd - && \
  mix phx.digest;

RUN mkdir -p /opt/built && \
  mix release && \
  tar cvfz ${APP_NAME}.tar.gz _build/${MIX_ENV}/rel/${APP_NAME} &&\
  cp ${APP_NAME}.tar.gz /opt/built && \
  cd /opt/built && \
  tar -xzf ${APP_NAME}.tar.gz && \
  rm ${APP_NAME}.tar.gz

# From this line onwards, we're in a new image, which will be the image used in production
FROM alpine:latest

RUN apk update && \
  apk add --no-cache \
  bash \
  openssl-dev

ENV REPLACE_OS_VARS=true \
  APP_NAME=bbb_lti

WORKDIR /opt/app

COPY --from=builder /opt/built .

# use non-root user
ENV USER=skillsnetwork
ENV UID=1000
RUN adduser --disabled-password --gecos --ingroup $USER --no-create-home --uid $UID $USER
RUN chown -R $USER:$USER /opt/app
USER $USER

CMD trap 'exit' INT; /opt/app/_build/prod/rel/${APP_NAME}/bin/${APP_NAME} start