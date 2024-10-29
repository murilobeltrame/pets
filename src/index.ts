import "dotenv/config";
import "express-async-errors";
import express, { json } from "express";
import swaggerUi from "swagger-ui-express";
import swaggerJsdoc from "swagger-jsdoc";
import { petsRouter } from "./routes/petsRoutes";
import { errorHandler } from "./middlewares/errorMidleware";
import sequelize from "./config/database";
import { usersRouter } from "./routes/userRoutes";
import { authRouter } from "./routes/authRoutes";
import { securityHandler } from "./middlewares/authMiddleware";
import { usersUnprotectedRouter } from "./routes/userUnprotectedRoutes";

const options = {
  definition: {
    openapi: "3.0.0",
    info: {
      title: "Pets API",
      version: "1.0.0",
      description: "A simple Express Pets API",
    },
    servers: [
      {
        url: "http://localhost:3000",
        description: "Development server",
      },
    ],
  },
  apis: ["./src/**/*.ts"], // files containing annotations
};

export const app = express();
const port = process.env.NODE_PORT;

const specs = swaggerJsdoc(options);

app.use(json());
app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(specs)); // Added user routes under /api prefix
app.use(authRouter);
app.use(usersUnprotectedRouter);
app.use(securityHandler);
app.use(petsRouter);
app.use(usersRouter);
app.use(errorHandler);

if (require.main === module) {
  sequelize.sync({ force: true }).then(() => {
    console.log("Database is synced");
    app.listen(port, () =>
      console.log(`Listening at http://localhost:${port}`),
    );
  });
}
