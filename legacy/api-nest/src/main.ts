import "reflect-metadata";
import { NestFactory } from "@nestjs/core";
import { ValidationPipe } from "@nestjs/common";
import { AppModule } from "./app.module.js";

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors({ origin: process.env.CORS_ORIGIN?.split(",") ?? true });
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true, forbidNonWhitelisted: false }));
  const port = Number(process.env.PORT ?? 3000);
  await app.listen(port);
  console.log(`BLU IA API escuchando en http://0.0.0.0:${port}`);
}
bootstrap();
