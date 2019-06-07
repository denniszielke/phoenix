FROM node:alpine
ARG appfolder="app"
RUN mkdir -p /home/node/app/node_modules && chown -R node:node /home/node/app
WORKDIR /home/node/app
COPY ${appfolder}/* ./
USER node
RUN npm install
COPY --chown=node:node . .
EXPOSE 8080
CMD [ "npm", "start" ]