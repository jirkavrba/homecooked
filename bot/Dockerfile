FROM denoland/deno:2.4.3

COPY package.json ./
COPY deno.lock ./
COPY src ./

RUN deno install

ENTRYPOINT ["deno", "run", "--allow-env", "--allow-net",  "index.ts"]
