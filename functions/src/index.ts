import * as admin from "firebase-admin";

import axios from "axios";

import { defineSecret } from "firebase-functions/params";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { logger } from "firebase-functions/v2";

import { PROMPTS } from "./prompts";

admin.initializeApp();
const db = admin.firestore();
const unsplashAccessKey = defineSecret("UNSPLASH_ACCESS_KEY");

type UnsplashPhoto = {
  urls?: { regular: string };
  user?: { name?: string; links?: { html?: string } };
};

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
