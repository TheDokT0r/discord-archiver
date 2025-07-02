FROM oven/bun:latest AS build

WORKDIR /app
COPY . .
RUN bun i --frozen-lockfile
RUN bun build --compile --outfile=/build/scheduler ./index.ts

FROM debian:latest

RUN apt update && apt install curl unzip -y

RUN curl -L -o /discord-chat-exporter.zip \
    https://github.com/Tyrrrz/DiscordChatExporter/releases/download/2.46/DiscordChatExporter.Cli.linux-x64.zip

RUN mkdir -p /opt/discord-chat-exporter \
    && unzip /discord-chat-exporter.zip -d /opt/discord-chat-exporter \
    && rm /discord-chat-exporter.zip

RUN ln -s /opt/discord-chat-exporter/DiscordChatExporter.Cli /usr/local/bin/discord-chat-exporter-cli

COPY --from=build /build/scheduler /usr/local/bin/scheduler

RUN chmod +x /usr/local/bin/scheduler

ENV PATH="/opt/discord-chat-exporter:${PATH}"
ENV GUILD_ID=id
ENV TOKEN=token
ENV TIME_INTERVAL=5
ENV OUT_DIR=/archive/
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

CMD ["scheduler"]
