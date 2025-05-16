import * as admin from "firebase-admin";

import axios from "axios";

import { defineSecret } from "firebase-functions/params";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { logger } from "firebase-functions/v2";
import {
  onDocumentCreated,
  onDocumentDeleted,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";

import { PROMPTS } from "./prompts";

admin.initializeApp();
const db = admin.firestore();
const unsplashAccessKey = defineSecret("UNSPLASH_ACCESS_KEY");

type UnsplashPhoto = {
  urls?: { regular: string };
  user?: { name?: string; links?: { html?: string } };
};

/**
 * Generates a daily prompt, two days in advance.
 */
export const generateDailyPrompt = onSchedule(
  {
    schedule: "0 1 * * *",
    timeZone: "UTC",
    secrets: [unsplashAccessKey],
  },
  async (event) => {
    logger.log("Generating daily prompt...");
    const key = unsplashAccessKey.value();

    try {
      // determine the date for the prompt (two days ahead in UTC)
      const targetDate = new Date(event.scheduleTime);
      targetDate.setUTCDate(targetDate.getUTCDate() + 2);
      const year = targetDate.getUTCFullYear();
      const month = String(targetDate.getUTCMonth() + 1).padStart(2, "0");
      const day = String(targetDate.getUTCDate()).padStart(2, "0");
      const date = `${year}-${month}-${day}`; // YYYY-MM-DD

      // get the prompt for the determined date
      logger.info("Fetching prompt for date:", date);
      const prompt = PROMPTS.find((e) => e.date === date);
      if (!prompt) {
        logger.error("No prompt found for date:", date);
        return;
      }
      const title = prompt.prompt;

      // get an image from Unsplash
      logger.info("Fetching image from Unsplash...");
      let imageData: UnsplashPhoto | null = null;
      const url = "https://api.unsplash.com/search/photos";
      const response = await axios.get(url, {
        headers: { Authorization: `Client-ID ${key}` },
        params: { query: title, per_page: 1 },
      });

      if (response.data?.results?.length > 0) {
        logger.info(`Relevant image found via search for: ${title}`);
        imageData = response.data.results[0];
      } else {
        logger.info(`No results for ${title}, falling back to random image`);
        const randomUrl = "https://api.unsplash.com/photos/random";
        const randomResponse = await axios.get(randomUrl, {
          headers: { Authorization: `Client-ID ${key}` },
          params: { query: title },
        });
        imageData = randomResponse.data;
      }

      const imageUrl = imageData?.urls?.regular;
      const imageAuthorUrl = imageData?.user?.links?.html;
      const imageAuthorName = imageData?.user?.name;

      // save the prompt to Firestore
      logger.info("Saving prompt to Firestore...");
      const promptRef = db.collection("prompts").doc();

      const promptData = {
        id: promptRef.id,
        date: admin.firestore.Timestamp.fromDate(targetDate),
        title,
        imageUrl,
        imageAuthorUrl,
        imageAuthorName,
      };

      await promptRef.set(promptData);

      logger.info(
        `Successfully generated and saved prompt with ID ${promptRef.id} for date ${date}.`
      );
    } catch (error: any) {
      logger.error("Error generating daily prompt:", error);
    }
  }
);

/**
 * creates a notification whenever a comment is added to a submission
 */
export const notifyComment = onDocumentCreated(
  { document: "comments/{commentId}" },
  async (event) => {
    const comment = event.data?.data();
    if (!comment) return;

    const userSnapshot = await db.collection("users").doc(comment.userId).get();
    const userData = userSnapshot.data();

    const submissionSnapshot = await db
      .collection("submissions")
      .doc(comment.submissionId)
      .get();
    const submissionData = submissionSnapshot.data();

    if (!userData || !submissionData || comment.userId == submissionData.userId)
      return;

    const notificationRef = db.collection("notifications").doc(comment.id);

    let notification = {
      id: notificationRef.id,
      type: "comment",
      createdAt: admin.firestore.Timestamp.now(),
      recipientId: submissionData.userId,
      senderId: comment.userId,
      senderImageUrl: userData.profileImageUrl,
      senderUsername: userData.username,
      submissionId: comment.submissionId,
      submissionImageUrl: submissionData.image.url,
      commentId: comment.id,
      commentText: comment.text.substring(0, 100),
    };

    await notificationRef.set(notification);
  }
);

/**
 * creates a notification whenever a user follows another user
 */
export const notifyRelationship = onDocumentCreated(
  { document: "relationships/{relationshipId}" },
  async (event) => {
    const relationship = event.data?.data();
    if (!relationship) return;

    const userSnapshot = await db
      .collection("users")
      .doc(relationship.follower)
      .get();
    const userData = userSnapshot.data();

    if (!userData) return;

    const notificationRef = db.collection("notifications").doc(relationship.id);

    let notification = {
      id: notificationRef.id,
      type: "follow",
      createdAt: admin.firestore.Timestamp.now(),
      recipientId: relationship.following ?? "",
      senderId: relationship.follower ?? "",
      senderImageUrl: userData.profileImageUrl ?? "",
      senderUsername: userData.username ?? "",
    };

    await notificationRef.set(notification);
  }
);

/**
 * creates/deletes a notification whenever a user likes a submission
 */
export const notifyLike = onDocumentUpdated(
  { document: "submissions/{submissionId}" },
  async (event) => {
    const submission = event.data?.after.data();
    const previousSubmission = event.data?.before.data();

    if (!submission || !previousSubmission) return;

    let userId;
    const newLiked: Array<string> = submission.likes;
    const oldLiked: Array<string> = previousSubmission.likes;

    if (newLiked.length > oldLiked.length) {
      // a like was added
      userId = newLiked.find((id) => !oldLiked.includes(id));
    } else {
      // a like was removed
      userId = oldLiked.find((id) => !newLiked.includes(id));

      const notificationRef = db
        .collection("notifications")
        .doc(`${submission.id}-${userId}`);
      await notificationRef.delete();
      return;
    }

    if (!userId) return;
    const userSnapshot = await db.collection("users").doc(userId).get();
    const userData = userSnapshot.data();
    if (!userData) return;

    // if the user liked their own submission, we don't want to create a notification
    if (userId === submission.userId) return;

    const notificationRef = db
      .collection("notifications")
      .doc(`${submission.id}-${userId}`);

    let notification = {
      id: notificationRef.id,
      type: "like",
      createdAt: admin.firestore.Timestamp.now(),
      recipientId: submission.userId,
      senderId: userId,
      senderImageUrl: userData.profileImageUrl,
      senderUsername: userData.username,
      submissionId: submission.id,
      submissionImageUrl: submission.image.url,
    };

    await notificationRef.set(notification);
  }
);

/**
 * deletes a notification whenever a comment is deleted
 */
export const deleteCommentNotification = onDocumentDeleted(
  { document: "comments/{commentId}" },
  async (event) => {
    const comment = event.data?.data();
    if (!comment) return;

    const notificationRef = db.collection("notifications").doc(comment.id);
    await notificationRef.delete();
  }
);

/**
 * deletes a notification whenever a user unfollows another user
 */
export const deleteRelationshipNotification = onDocumentDeleted(
  { document: "relationships/{relationshipId}" },
  async (event) => {
    const relationship = event.data?.data();
    if (!relationship) return;

    const notificationRef = db.collection("notifications").doc(relationship.id);
    await notificationRef.delete();
  }
);

/**
 * deletes notifications whenever a submission is deleted
 */
export const deleteSubmissionNotifications = onDocumentDeleted(
  { document: "submissions/{submissionId}" },
  async (event) => {
    const submission = event.data?.data();
    if (!submission) return;

    const notificationsRef = db
      .collection("notifications")
      .where("submissionId", "==", submission.id);
    const snapshot = await notificationsRef.get();

    snapshot.forEach(async (doc) => {
      await doc.ref.delete();
    });
  }
);
