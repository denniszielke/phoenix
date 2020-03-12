FROM node:alpine
ARG appversion=1.0.0
ARG appfolder="app"
RUN mkdir -p /home/node/app/node_modules && chown -R node:node /home/node/app
WORKDIR /home/node/app
COPY ${appfolder} .
USER node
RUN sed -i "s/1.0.0/$appversion/g" package.json
RUN npm install
COPY --chown=node:node . .
EXPOSE 8080
CMD [ "npm", "start" ]