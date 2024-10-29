FROM node:20 AS base

RUN apt update && apt upgrade -y

FROM base AS build
WORKDIR /src
COPY . .
RUN npm install && npm run build

FROM base
EXPOSE 80
ENV NODE_PORT=80
WORKDIR /app

COPY --from=build /src/dist /dist
COPY --from=build /src/node_modules /node_modules

ENTRYPOINT [ "node", "/dist/index.js" ]