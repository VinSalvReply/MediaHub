import { createApp } from "./app.js";

const PORT = Number(process.env.PORT ?? 3000);

createApp().listen(PORT, () => {
  // eslint-disable-next-line no-console
  console.log(`MediaHub API listening on http://localhost:${PORT}`);
});
