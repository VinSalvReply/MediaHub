import { createApp } from "./app.js";
import { formatString } from "./strings.js";

const PORT = Number(process.env.PORT ?? 3000);

createApp().listen(PORT, () => {
  // eslint-disable-next-line no-console
  console.log(
    formatString("logs.serverListening", {
      port: PORT,
    }),
  );
});
