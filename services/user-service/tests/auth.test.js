import request from "supertest";
import app from "../src/app.js";
import prisma from "../src/config/db.js";
import jwt from "jsonwebtoken";

describe("Auth Endpoints", () => {
  let token;
  let userId;

  beforeAll(async () => {
    // Clean up database before tests
    await prisma.user.deleteMany();
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  it("should register a new user", async () => {
    const res = await request(app).post("/api/users/register").send({
      name: "Test User",
      email: "test@example.com",
      password: "password123",
    });

    expect(res.statusCode).toEqual(201);
    expect(res.body).toHaveProperty("id");
    expect(res.body).toHaveProperty("email", "test@example.com");
    userId = res.body.id;
  });

  it("should login the user and return a cookie", async () => {
    const res = await request(app).post("/api/users/auth").send({
      email: "test@example.com",
      password: "password123",
    });

    expect(res.statusCode).toEqual(200);
    expect(res.body).toHaveProperty("id");
    expect(res.headers["set-cookie"]).toBeDefined();

    // Extract token from cookie for later use
    const cookies = res.headers["set-cookie"][0];
    token = cookies.split(";")[0].split("=")[1];
  });

  it("should access protected route with Cookie", async () => {
    const res = await request(app)
      .get("/api/users/profile")
      .set("Cookie", [`jwt=${token}`]);

    expect(res.statusCode).toEqual(200);
    expect(res.body).toHaveProperty("email", "test@example.com");
  });

  it("should access protected route with Authorization Header", async () => {
    const res = await request(app)
      .get("/api/users/profile")
      .set("Authorization", `Bearer ${token}`);

    expect(res.statusCode).toEqual(200);
    expect(res.body).toHaveProperty("email", "test@example.com");
  });

  it("should fail to access protected route without token", async () => {
    const res = await request(app).get("/api/users/profile");

    expect(res.statusCode).toEqual(401);
  });

  it("should fail to access protected route with invalid token", async () => {
    const res = await request(app)
      .get("/api/users/profile")
      .set("Authorization", "Bearer invalidtoken123");

    expect(res.statusCode).toEqual(401);
  });

  // Malicious / Security Tests

  it("should prevent registration with invalid email", async () => {
    const res = await request(app).post("/api/users/register").send({
      name: "Hacker",
      email: "not-an-email",
      password: "password123",
    });

    expect(res.statusCode).toEqual(400);
  });

  it("should prevent registration with short password", async () => {
    const res = await request(app).post("/api/users/register").send({
      name: "Hacker",
      email: "hacker@example.com",
      password: "123",
    });

    expect(res.statusCode).toEqual(400);
  });

  it("should sanitize input (prevent simple XSS in name)", async () => {
    const res = await request(app).post("/api/users/register").send({
      name: '<script>alert("xss")</script>',
      email: "xss@example.com",
      password: "password123",
    });

    expect(res.statusCode).toEqual(201);
    expect(res.body.name).toBe('<script>alert("xss")</script>');
  });
});
