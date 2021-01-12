FROM debian:buster

# Install the target system with multistrap
COPY files/install_dependencies.sh /tmp
COPY files/build_erlang_deb.sh /
COPY files/build_elixir_deb.sh /

RUN /tmp/install_dependencies.sh
