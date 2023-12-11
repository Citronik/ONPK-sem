# Multi-stage build docker file

# app build stage
FROM node:12-alpine as build
WORKDIR /app
ENV PATH /app/node_modules/.bin:$PATH
COPY ./package.json /app/
COPY ./yarn.lock /app/
RUN yarn
COPY . /app
RUN yarn build

# image build stage
FROM nginx:stable-alpine
COPY --from=build /app/build /usr/share/nginx/html
COPY --from=build /app/env.sh /docker-entrypoint.d
RUN chmod +x /docker-entrypoint.d/env.sh
RUN rm /etc/nginx/conf.d/default.conf
COPY conf.d/default.conf /etc/nginx/conf.d

EXPOSE 8080



ENTRYPOINT ["./docker-entrypoint.d/env.sh", "nginx", "-g", "daemon off;"]

## TODO: Vasou ulohou je:
# 1. pridat instrukciu, ktora bude informovat o tom, ze kontajner publikuje TCP port 8080
# 2. pridat instrukciu, ktora zabezpeci, ze po vytvoreni kontajnera sa spusti nginx:
#   nginx -g daemon off;
#   TIP: pozor ako zadavate parametre do instrukcie