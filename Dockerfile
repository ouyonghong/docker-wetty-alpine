FROM node:carbon-alpine as builder
RUN apk add -U build-base python git
WORKDIR /app
#COPY . /app
RUN git clone https://github.com/butlerx/wetty /app && \
	git checkout d0aaa35dbfcb30d8739c22cb3226238ad23a6d7d && \
    yarn && \
    yarn build && \
    yarn install --production --ignore-scripts --prefer-offline

FROM node:carbon-alpine
WORKDIR /app
ENV NODE_ENV=production
EXPOSE 3000
COPY --from=builder /app/dist /app/dist
COPY --from=builder /app/node_modules /app/node_modules
COPY --from=builder /app/package.json /app/package.json
COPY --from=builder /app/index.js /app/index.js
RUN apk add -U openssh-client sshpass expect
#
VOLUME [ "/remote_ssh" ]
ADD run.sh /app

# Default ENV params used by wetty
ENV REMOTE_SSH_SERVER=127.0.0.1 \
    REMOTE_SSH_PORT=22 \
    WETTY_PORT=3000 \
    SSH_AUTH="publickey" \
    SSH_KEY="/root/.ssh/id_rsa" \
    KNOWNHOSTS="/root/.ssh/known_hosts" \
    REMOTE_PUB_KEY_DIR="/remote_ssh"

EXPOSE 3000

ENTRYPOINT "./run.sh"
