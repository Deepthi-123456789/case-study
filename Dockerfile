# Use the official Nginx image from Docker Hub as the base image
FROM nginx:latest

# Copy your static website content (e.g., index.html) into the Nginx container
COPY ./index.html /usr/share/nginx/html/index.html

# Expose port 80 to allow web traffic
EXPOSE 80

# Command to start Nginx (this is the default behavior for the official Nginx image)
CMD ["nginx", "-g", "daemon off;"]

