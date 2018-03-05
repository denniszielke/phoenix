FROM node:8.2.0-alpine
RUN mkdir -p /usr/src/app
COPY ./app/* /usr/src/app/
RUN mkdir -p /usr/src/app/public
COPY ./app/public/* /usr/src/app/public/
WORKDIR /usr/src/app
RUN npm install
EXPOSE 80
CMD [ "npm", "start" ]
