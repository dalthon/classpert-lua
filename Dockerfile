FROM alpine:latest

ENV LUA_PACKAGE lua5.4

RUN apk update                                                             && \
    apk add lua5.4 lua5.4-dev build-base git bash unzip curl curl-dev wget && \
    cd /tmp                                                                && \
    git clone https://github.com/keplerproject/luarocks.git                && \
    cd luarocks                                                            && \
    sh ./configure                                                         && \
    make build install                                                     && \
    cd                                                                     && \
    rm -rf /tmp/luarocks                                                   && \
    ln -s /usr/bin/lua5.4 /usr/bin/lua                                     && \
    luarocks install lpeg                                                  && \
    luarocks install luaunit

ENV PS1="\[\033[01;34m\]\u(classpert)\[\033[0m\] @ \[\033[01;32m\]\W\[\033[0m\] > "
ENV LUA_PATH "/course/lib/?.lua;/usr/local/share/lua/5.4/?.lua;"

WORKDIR /course

CMD ["lua"]
