const express = require("express");
const db = require("./models");

const app = express();

app.get("/", (req, res) => {
  res.status(200).send("OK");
});

const PORT = 3000;

app.listen(PORT, async () => {
  console.log(`Server running on port ${PORT}`);
  try {
    await db.sequelize.authenticate();
    console.log("DB connected");
  } catch (err) {
    console.error(err.message);
  }
});