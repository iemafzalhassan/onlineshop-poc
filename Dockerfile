# Base image 
FROM node:23-alpine3.20 as build

# Working Directory 
WORKDIR /onlineshop-poc

# Copy package.json file to working directory
COPY package*.json  ./

# To install dependancy
RUN npm install

# copy code from source to destination
COPY . .

RUN npm run build


# Stage 2 start

FROM nginx:alpine

# Copy the built files from the build stage
COPY --from=build /onlineshop-poc/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx","-g","daemon off;"]
