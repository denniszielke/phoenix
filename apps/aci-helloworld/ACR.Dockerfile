FROM node:alpine
ARG basedir="apps/aci-helloworld/app"
ARG build_info="Docker container build"
ENV NODE_ENV production
ENV BUILD_INFO $build_info
# Place our app here
WORKDIR /home/app

# NPM install packages
COPY ${basedir}/package*.json ./
RUN npm install --production --silent

# NPM is done, now copy in the the whole project to the workdir
COPY ${basedir}/ ./

EXPOSE 80
CMD node index.js