FROM oven/bun:latest AS build
WORKDIR /app
COPY . .
RUN bun build --compile --outfile=/build ./index.ts

FROM archlinux:latest

# Set environment to noninteractive
ENV TERM xterm

# Update and install base dependencies
RUN pacman -Syu --noconfirm \
    && pacman -S --noconfirm base-devel git sudo glibc

# Create a non-root user for building AUR packages
RUN useradd -m auruser \
    && echo "auruser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER auruser
WORKDIR /home/auruser

# Clone yay (AUR helper) and install it
RUN git clone https://aur.archlinux.org/yay.git \
    && cd yay \
    && makepkg -si --noconfirm

# Example: Install an AUR package using yay (replace 'package-name' as needed)
RUN yay -S --noconfirm discord-chat-exporter-cli

# Clean up
RUN yay -Scc --noconfirm || true

# Set back to root for any final steps if needed
USER root

WORKDIR /app
COPY --from=build /app/build /usr/local/bin/archiver
ENV GUILD_ID=id
ENV TOKEN=token
ENV TIME_INTERVAL=5
ENV OUT_DIR=/archive/
CMD [ "archiver" ]