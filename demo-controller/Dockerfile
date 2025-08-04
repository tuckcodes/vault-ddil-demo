# This Dockerfile builds the container for the demo-controller service.
# It uses a multi-stage build for a clean and optimized final image.

# --- Build Stage ---
# Use a full Node.js image to build our application
FROM node:18-alpine AS builder

# Set the working directory
WORKDIR /usr/src/app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the application source code
COPY . .


# --- Final Stage ---
# Use a lightweight base image that includes Docker CLI
FROM docker:latest

# Install Node.js and npm
RUN apk add --no-cache nodejs npm

# Set the working directory for the final image
WORKDIR /usr/src/app

# Copy the installed dependencies from the 'builder' stage
COPY --from=builder /usr/src/app/node_modules ./node_modules

# Copy the application source code from the 'builder' stage
COPY --from=builder /usr/src/app/server.js .
COPY --from=builder /usr/src/app/public/ ./public/

# Expose the port the app runs on
EXPOSE 8080

# The command to run the application
CMD [ "node", "server.js" ]
