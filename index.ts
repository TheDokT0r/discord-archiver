import { $ } from "bun";
import os from 'node:os';
import { format } from 'date-fns';
import path from "node:path";

declare module "bun" {
    interface Env {
        GUILD_ID: string;
        TOKEN: string;
        TIME_INTERVAL: number;
        OUT_DIR: string;
    }
}

const { GUILD_ID, TIME_INTERVAL, TOKEN, OUT_DIR } = process.env;

if (os.platform() !== 'linux') {
    throw new Error("Program only works on Linux");
}

setInterval(async () => {
    try {
        console.log("Archiving guild...");
        const date = format(new Date(), "dd/MM/yyyy");
        const time = format(new Date(), "hh:mm:ss")
        const currentArchivePath = path.join(OUT_DIR, date, time);

        await $`mkdir -p ${currentArchivePath}`;

        const response = await $`discord-chat-exporter-cli exportguild -t ${TOKEN} -g ${GUILD_ID} --include-vc false --media-dir ${currentArchivePath}`.text();
        console.log(response);
    } catch (e) {
        console.error(e);
    } finally {
        console.log(`Next archive will take place in ${TIME_INTERVAL} hours`);
    }
}, TIME_INTERVAL * 60 * 60 * 1000);