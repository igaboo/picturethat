"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.generateDailyPrompt = void 0;
const admin = require("firebase-admin");
const axios_1 = require("axios");
const params_1 = require("firebase-functions/params");
const scheduler_1 = require("firebase-functions/v2/scheduler");
const v2_1 = require("firebase-functions/v2");
const prompts_1 = require("./prompts");
admin.initializeApp();
const db = admin.firestore();
const unsplashAccessKey = (0, params_1.defineSecret)("UNSPLASH_ACCESS_KEY");
exports.generateDailyPrompt = (0, scheduler_1.onSchedule)({
    schedule: "0 1 * * *",
    timeZone: "UTC",
    secrets: [unsplashAccessKey],
}, async (event) => {
    var _a, _b, _c, _d, _e, _f;
    v2_1.logger.log("Generating daily prompt...");
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
        v2_1.logger.info("Fetching prompt for date:", date);
        const prompt = prompts_1.PROMPTS.find((e) => e.date === date);
        if (!prompt) {
            v2_1.logger.error("No prompt found for date:", date);
            return;
        }
        const title = prompt.prompt;
        // get an image from Unsplash
        v2_1.logger.info("Fetching image from Unsplash...");
        let imageData = null;
        const url = "https://api.unsplash.com/search/photos";
        const response = await axios_1.default.get(url, {
            headers: { Authorization: `Client-ID ${key}` },
            params: { query: title, per_page: 1 },
        });
        if (((_b = (_a = response.data) === null || _a === void 0 ? void 0 : _a.results) === null || _b === void 0 ? void 0 : _b.length) > 0) {
            v2_1.logger.info(`Relevant image found via search for: ${title}`);
            imageData = response.data.results[0];
        }
        else {
            v2_1.logger.info(`No results for ${title}, falling back to random image`);
            const randomUrl = "https://api.unsplash.com/photos/random";
            const randomResponse = await axios_1.default.get(randomUrl, {
                headers: { Authorization: `Client-ID ${key}` },
                params: { query: title },
            });
            imageData = randomResponse.data;
        }
        const imageUrl = (_c = imageData === null || imageData === void 0 ? void 0 : imageData.urls) === null || _c === void 0 ? void 0 : _c.regular;
        const imageAuthorUrl = (_e = (_d = imageData === null || imageData === void 0 ? void 0 : imageData.user) === null || _d === void 0 ? void 0 : _d.links) === null || _e === void 0 ? void 0 : _e.html;
        const imageAuthorName = (_f = imageData === null || imageData === void 0 ? void 0 : imageData.user) === null || _f === void 0 ? void 0 : _f.name;
        // save the prompt to Firestore
        v2_1.logger.info("Saving prompt to Firestore...");
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
        v2_1.logger.info(`Successfully generated and saved prompt with ID ${promptRef.id} for date ${date}.`);
    }
    catch (error) {
        v2_1.logger.error("Error generating daily prompt:", error);
    }
});
//# sourceMappingURL=index.js.map