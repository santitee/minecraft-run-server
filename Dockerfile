# Use OpenJDK 21 as the base image for Minecraft 1.21+
FROM openjdk:21-jdk-slim

# Set the working directory
WORKDIR /minecraft

# Create a minecraft user to run the server (security best practice)
RUN groupadd -r minecraft && useradd -r -g minecraft minecraft

# Install necessary packages
RUN apt-get update && \
    apt-get install -y wget curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set server properties
ENV SERVER_JAR=server.jar
ENV MEMORY_SIZE=4G
ENV MINECRAFT_VERSION=1.21.10

# Download Minecraft server jar
RUN wget -O ${SERVER_JAR} https://piston-data.mojang.com/v1/objects/59353fb40c36d304f2035d51e7d6e6baa98dc05c/server.jar

# Create necessary directories
RUN mkdir -p /minecraft/data /minecraft/logs

# Copy server configuration files
COPY server.properties /minecraft/
COPY eula.txt /minecraft/

# Set ownership to minecraft user
RUN chown -R minecraft:minecraft /minecraft

# Switch to minecraft user
USER minecraft

# Expose the default Minecraft port
EXPOSE 25565

# Set the default command
CMD ["sh", "-c", "java -Xmx${MEMORY_SIZE} -Xms${MEMORY_SIZE} -jar ${SERVER_JAR} --nogui"]