ARG BUILD_TYPE=production
ARG ENDPOINT=http://localhost:6080

FROM node:16-alpine as frontend

COPY ./web /web
WORKDIR /web
ARG ENDPOINT
ENV VITE_API_URL=${ENDPOINT}

RUN npm install -g pnpm
RUN pnpm install && pnpm build
RUN mv dist /frontend
RUN rm -rf /web

FROM node:16-alpine as backend

COPY ./backend /backend
WORKDIR /backend

RUN npm install -g pnpm
ENV node-linker=pnp
ENV symlink=false
RUN pnpm install && pnpm build

FROM node:16 as prod
COPY ./nginx/front.conf /etc/nginx/conf.d/front.conf

RUN apt-get update
RUN apt-get install -y nginx
RUN npm install -g pnpm

FROM prod as end

COPY --from=frontend /frontend /Sub-Store/web/dist
COPY --from=backend /backend /backend

ENTRYPOINT nginx && cd /backend && pnpm start
