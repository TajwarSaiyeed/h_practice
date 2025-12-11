import { jest } from "@jest/globals";

// Mock RabbitMQ
jest.unstable_mockModule("../src/utils/rabbitmq.js", () => ({
  connectRabbitMQ: jest.fn(),
  publishEvent: jest.fn(),
  getChannel: jest.fn(),
}));

// Mock gRPC Client
jest.unstable_mockModule("../src/grpcClient.js", () => ({
  getUser: jest
    .fn()
    .mockResolvedValue({ id: "test-user-id", name: "Test User" }),
}));

const request = (await import("supertest")).default;
const app = (await import("../src/app.js")).default;
const prisma = (await import("../src/config/db.js")).default;
const jwt = (await import("jsonwebtoken")).default;

describe("Post Endpoints", () => {
  let token;
  let userId = "test-user-id";
  let postId;

  beforeAll(async () => {
    // Clean up database before tests
    await prisma.post.deleteMany();

    // Generate a valid token for testing
    token = jwt.sign({ userId }, process.env.JWT_SECRET, {
      expiresIn: "30d",
    });
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  it("should create a new post", async () => {
    const res = await request(app)
      .post("/api/posts")
      .set("Cookie", [`jwt=${token}`])
      .send({
        title: "Test Post",
        content: "This is a test post content",
      });

    expect(res.statusCode).toEqual(201);
    expect(res.body).toHaveProperty("id");
    expect(res.body).toHaveProperty("title", "Test Post");
    expect(res.body).toHaveProperty("userId", userId);
    postId = res.body.id;
  });

  it("should get all posts", async () => {
    const res = await request(app).get("/api/posts");

    expect(res.statusCode).toEqual(200);
    expect(Array.isArray(res.body)).toBeTruthy();
    expect(res.body.length).toBeGreaterThan(0);
  });

  it("should get a single post by ID", async () => {
    const res = await request(app).get(`/api/posts/${postId}`);

    expect(res.statusCode).toEqual(200);
    expect(res.body).toHaveProperty("id", postId);
  });

  it("should update a post", async () => {
    const res = await request(app)
      .put(`/api/posts/${postId}`)
      .set("Cookie", [`jwt=${token}`])
      .send({
        title: "Updated Test Post",
        content: "Updated content",
      });

    expect(res.statusCode).toEqual(200);
    expect(res.body).toHaveProperty("title", "Updated Test Post");
  });

  it("should fail to update post if not owner", async () => {
    const otherUserToken = jwt.sign(
      { userId: "other-user-id" },
      process.env.JWT_SECRET,
      { expiresIn: "30d" }
    );

    const res = await request(app)
      .put(`/api/posts/${postId}`)
      .set("Cookie", [`jwt=${otherUserToken}`])
      .send({
        title: "Hacked Post",
      });

    expect(res.statusCode).toEqual(401);
  });

  it("should delete a post", async () => {
    const res = await request(app)
      .delete(`/api/posts/${postId}`)
      .set("Cookie", [`jwt=${token}`]);

    expect(res.statusCode).toEqual(200);
    expect(res.body).toHaveProperty("message", "Post removed");
  });

  it("should fail to get deleted post", async () => {
    const res = await request(app).get(`/api/posts/${postId}`);

    expect(res.statusCode).toEqual(404);
  });
});
