# demo-controller/Dockerfile
# Defines the environment for the Node.js server.

FROM node:18-alpine

# Set the working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application source code
COPY . .

# Expose the port the app runs on
EXPOSE 8080

# The command to run the application
CMD [ "node", "server.js" ]
