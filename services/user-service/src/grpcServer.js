import grpc from "@grpc/grpc-js";
import protoLoader from "@grpc/proto-loader";
import path from "path";
import { fileURLToPath } from "url";
import prisma from "./config/db.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const PROTO_PATH = path.join(__dirname, "proto/user.proto");

const packageDefinition = protoLoader.loadSync(PROTO_PATH, {
  keepCase: true,
  longs: String,
  enums: String,
  defaults: true,
  oneofs: true,
});

const userProto = grpc.loadPackageDefinition(packageDefinition).user;

const getUser = async (call, callback) => {
  const { id } = call.request;
  try {
    const user = await prisma.user.findUnique({
      where: { id },
    });

    if (user) {
      callback(null, { id: user.id, name: user.name, email: user.email });
    } else {
      callback({
        code: grpc.status.NOT_FOUND,
        details: "User not found",
      });
    }
  } catch (error) {
    console.error("gRPC GetUser Error:", error);
    callback({
      code: grpc.status.INTERNAL,
      details: "Internal Server Error",
    });
  }
};

const startGrpcServer = () => {
  const server = new grpc.Server();
  server.addService(userProto.UserService.service, { GetUser: getUser });
  const port = "0.0.0.0:50051";
  server.bindAsync(
    port,
    grpc.ServerCredentials.createInsecure(),
    (err, port) => {
      if (err) {
        console.error("Failed to bind gRPC server:", err);
        return;
      }
      console.log(`gRPC Server running on port ${port}`);
      // server.start(); // Not needed in newer grpc-js versions, but harmless
    }
  );
};

export default startGrpcServer;
