FROM node:12-alpine

LABEL "name"="GitHub-actions-hexo"
LABEL "maintainer"="yrpang <yrpang@outlook.com>"
LABEL "version"="0.0.1"

LABEL "com.github.actions.name"="GitHub actions hexo"
LABEL "com.github.actions.description"="A GitHub action used to automatic generate publish hexo-based blog and clear Cloudflare cache."
LABEL "com.github.actions.icon"="cloud"
LABEL "com.github.actions.color"="green"

COPY README.md entrypoint.sh /

RUN apk add --no-cache git
RUN apk add --no-cache openssh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
