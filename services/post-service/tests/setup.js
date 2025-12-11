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
