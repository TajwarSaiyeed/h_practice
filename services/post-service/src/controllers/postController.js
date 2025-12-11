import prisma from "../config/db.js";
import { getUser } from "../grpcClient.js";
import { publishEvent } from "../utils/rabbitmq.js";

// @desc    Create a new post
// @route   POST /api/posts
// @access  Private
const createPost = async (req, res) => {
  const { title, content } = req.body;

  if (!title || !content) {
    return res.status(400).json({ message: "Please add all fields" });
  }

  try {
    // 1. Synchronous Communication (gRPC)
    // Verify user exists in User Service before creating post
    try {
      const user = await getUser(req.user.id);
      console.log("gRPC User Verified:", user);
    } catch (grpcError) {
      console.error("gRPC Verification Failed:", grpcError);
      return res
        .status(404)
        .json({ message: "User not found or User Service unavailable" });
    }

    const post = await prisma.post.create({
      data: {
        title,
        content,
        userId: req.user.id,
      },
    });

    // 2. Asynchronous Communication (RabbitMQ)
    // Publish event that post was created
    await publishEvent("post_events", {
      event: "POST_CREATED",
      data: {
        postId: post.id,
        userId: post.userId,
        title: post.title,
        timestamp: new Date(),
      },
    });

    res.status(201).json(post);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server Error" });
  }
};

// @desc    Get all posts
// @route   GET /api/posts
// @access  Public
const getPosts = async (req, res) => {
  try {
    const posts = await prisma.post.findMany({
      orderBy: {
        createdAt: "desc",
      },
    });
    res.status(200).json(posts);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server Error" });
  }
};

// @desc    Get single post
// @route   GET /api/posts/:id
// @access  Public
const getPostById = async (req, res) => {
  try {
    const post = await prisma.post.findUnique({
      where: { id: req.params.id },
    });

    if (!post) {
      return res.status(404).json({ message: "Post not found" });
    }

    res.status(200).json(post);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server Error" });
  }
};

// @desc    Update post
// @route   PUT /api/posts/:id
// @access  Private
const updatePost = async (req, res) => {
  try {
    const post = await prisma.post.findUnique({
      where: { id: req.params.id },
    });

    if (!post) {
      return res.status(404).json({ message: "Post not found" });
    }

    // Check if user owns the post
    if (post.userId !== req.user.id) {
      return res.status(401).json({ message: "User not authorized" });
    }

    const updatedPost = await prisma.post.update({
      where: { id: req.params.id },
      data: req.body,
    });

    res.status(200).json(updatedPost);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server Error" });
  }
};

// @desc    Delete post
// @route   DELETE /api/posts/:id
// @access  Private
const deletePost = async (req, res) => {
  try {
    const post = await prisma.post.findUnique({
      where: { id: req.params.id },
    });

    if (!post) {
      return res.status(404).json({ message: "Post not found" });
    }

    // Check if user owns the post
    if (post.userId !== req.user.id) {
      return res.status(401).json({ message: "User not authorized" });
    }

    await prisma.post.delete({
      where: { id: req.params.id },
    });

    res.status(200).json({ message: "Post removed" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server Error" });
  }
};

export { createPost, getPosts, getPostById, updatePost, deletePost };
