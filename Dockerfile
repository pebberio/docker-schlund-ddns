FROM python:3.6-slim

# https://github.com/github.com/wosc/schlund-ddns

# Set environment variables for GitHub repo
ENV VERSION=1.1.1 \
    REPO=https://github.com/wosc/schlund-ddns

RUN apt-get update && apt-get install -y curl

RUN curl -SLO "${REPO}/archive/${VERSION}.tar.gz" \
    && tar xzf ${VERSION}.tar.gz \
    && mv /schlund-ddns-${VERSION} /schlund-ddns \
    && rm *.tar.gz

WORKDIR /schlund-ddns

RUN pip install .

ENV FLASK_APP src/ws/ddns/web.py
ENV FLASK_RUN_HOST 0.0.0.0

CMD ["flask","run"]
