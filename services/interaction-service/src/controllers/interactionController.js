import prisma from "../config/db.js";
import { publishEvent } from "../utils/rabbitmq.js";

// @desc    Toggle like/dislike on a post
// @route   POST /api/interactions/:postId
// @access  Private
const toggleInteraction = async (req, res) => {
  const { postId } = req.params;
  const { type } = req.body; // 'LIKE' or 'DISLIKE'
  const userId = req.user.id;

  if (!["LIKE", "DISLIKE"].includes(type)) {
    return res.status(400).json({ message: "Invalid interaction type" });
  }

  try {
    const existingInteraction = await prisma.interaction.findUnique({
      where: {
        userId_postId: {
          userId,
          postId,
        },
      },
    });

    if (existingInteraction) {
      if (existingInteraction.type === type) {
        // If same type, remove interaction (toggle off)
        await prisma.interaction.delete({
          where: { id: existingInteraction.id },
        });
        return res.status(200).json({ message: "Interaction removed" });
      } else {
        // If different type, update it
        const updatedInteraction = await prisma.interaction.update({
          where: { id: existingInteraction.id },
          data: { type },
        });
        return res.status(200).json(updatedInteraction);
      }
    } else {
      // Create new interaction
      const newInteraction = await prisma.interaction.create({
        data: {
          userId,
          postId,
          type,
        },
      });

      // Publish Event
      await publishEvent("interaction_events", {
        event: "INTERACTION_CREATED",
        data: {
          interactionId: newInteraction.id,
          userId: newInteraction.userId,
          postId: newInteraction.postId,
          type: newInteraction.type,
          timestamp: new Date(),
        },
      });

      return res.status(201).json(newInteraction);
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server Error" });
  }
};

// @desc    Get interactions for a post
// @route   GET /api/interactions/:postId
// @access  Public
const getInteractions = async (req, res) => {
  const { postId } = req.params;

  try {
    const likes = await prisma.interaction.count({
      where: {
        postId,
        type: "LIKE",
      },
    });

    const dislikes = await prisma.interaction.count({
      where: {
        postId,
        type: "DISLIKE",
      },
    });

    res.status(200).json({ likes, dislikes });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server Error" });
  }
};

export { toggleInteraction, getInteractions };
