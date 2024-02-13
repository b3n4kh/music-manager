FROM ubuntu:latest

LABEL org.opencontainers.image.authors="b@akhras.at"
LABEL org.opencontainers.image.source="https://github.com/b3n4kh/music-manager"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y ffmpeg inotify-tools parallel file && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY convert_to_opus.sh /usr/local/bin/convert_to_opus.sh
COPY organize.sh /usr/local/bin/organize.sh
COPY watch_and_convert.sh /usr/local/bin/watch_and_convert.sh

RUN chmod +x /usr/local/bin/*.sh

# Define mount points
VOLUME ["/downloads", "/music"]

CMD ["/usr/local/bin/watch_and_convert.sh"]
