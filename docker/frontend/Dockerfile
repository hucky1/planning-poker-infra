ARG NODE_VERSION=20-alpine

FROM node:${NODE_VERSION}

WORKDIR /workspace

COPY docker/frontend/start-frontend.sh /usr/local/bin/start-frontend
RUN chmod +x /usr/local/bin/start-frontend

CMD ["start-frontend"]
