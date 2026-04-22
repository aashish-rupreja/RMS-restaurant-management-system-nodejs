FROM node:lts-alpine3.22

WORKDIR /opt/RMS-restaurant-management-system-nodejs

COPY . .

RUN npm install

CMD ["npm", "start"]