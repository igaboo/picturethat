/**
 * Generates a random number of dummy submissions.
 * usage: node generate.js <number_of_submissions>
 *
 * Ensure that ./serviceAccountLey.json exists,
 * as well as a .env.local file containing UNSPLASH_ACCESS_KEY.
 */

const admin = require("firebase-admin");
const axios = require("axios");
require("dotenv").config({ path: ".env.local" });

const SERVICE_ACCOUNT = require("./serviceAccountKey.json");
const UNSPLASH_ACCESS_KEY = process.env.UNSPLASH_ACCESS_KEY;
const FIREBASE_STORAGE_BUCKET = process.env.FIREBASE_STORAGE_BUCKET;
const COLLECTION_NAME = "submissions";

async function getPromptDocuments() {
  const snapshot = await admin
    .firestore()
    .collection("prompts")
    .orderBy("date", "desc")
    .limit(10)
    .get();

  return snapshot.docs.map((doc) => {
    const data = doc.data();
    return {
      id: doc.id,
      title: data.title,
      dateString: data.date.toDate(),
    };
  });
}

async function getUserIds() {
  const snapshot = await admin.firestore().collection("users").get();
  return snapshot.docs.map((doc) => doc.id);
}

function getRandomElement(arr) {
  return arr[Math.floor(Math.random() * arr.length)];
}

function getRandomCaption() {
  const verbs = [
    "capturing",
    "exploring",
    "finding",
    "seeing",
    "feeling",
    "chasing",
    "discovering",
    "watching",
    "admiring",
    "embracing",
    "remembering",
    "sharing",
    "seeking",
    "loving",
    "enjoying",
  ];
  const adjectives = [
    "beautiful",
    "stunning",
    "amazing",
    "peaceful",
    "vibrant",
    "golden",
    "hidden",
    "mysterious",
    "serene",
    "quiet",
    "breathtaking",
    "incredible",
    "magical",
    "fleeting",
    "soft",
    "warm",
    "cool",
    "forgotten",
    "distant",
    "subtle",
  ];
  const nouns = [
    "moment",
    "view",
    "light",
    "path",
    "reflection",
    "shadow",
    "color",
    "world",
    "journey",
    "secret",
    "detail",
    "beauty",
    "landscape",
    "silence",
    "feeling",
    "memory",
    "wonder",
    "atmosphere",
    "horizon",
    "story",
  ];
  const emojis = [
    "✨",
    "📸",
    "☀️",
    "🌿",
    "🌊",
    "🌲",
    "🎨",
    "😌",
    "😍",
    "💖",
    "🤩",
    "👀",
    "🚶‍♀️",
    "🚶‍♂️",
    "🗺️",
    "🤫",
    "💖",
  ];
  const templates = {
    short: [
      "[adjective] [noun].",
      "[verb] this [noun].",
      "The [adjective] [noun].",
      "Just [verb]...",
      "A [adjective] find.",
      "[noun] vibes.",
      "Pure [noun].",
    ],
    medium: [
      "[verb] the [adjective] [noun] on my walk.",
      "This [adjective] [noun] really caught my eye.",
      "Trying to [verb] the essence of this [noun].",
      "Lost in the [adjective] beauty of this [noun].",
      "A perfect, [adjective] [noun] found while [verb].",
      "Sharing this little [adjective] [noun] I discovered.",
      "The way the light was [verb] the [noun].",
    ],
    long: [
      "Spent some time [verb] this absolutely [adjective] [noun], a reminder of the simple joys around us.",
      "It's incredible when you stumble upon a [adjective] [noun] like this while just [verb] the area.",
      "Taking a moment to appreciate the [adjective] [noun] and the quiet sense of [noun] it brings.",
      "The composition of this [noun] felt so [adjective], had to stop [verb] it properly.",
      "Chasing the [adjective] light led me to this unexpected [noun], what a [adjective] discovery!",
      "There's a unique [noun] in [verb] something so [adjective] and fleeting in nature.",
    ],
  };

  const lengthChoice = Math.random();
  let chosenTemplateList;
  if (lengthChoice < 0.33) {
    chosenTemplateList = templates.short;
  } else if (lengthChoice < 0.66) {
    chosenTemplateList = templates.medium;
  } else {
    chosenTemplateList = templates.long;
  }

  let caption = getRandomElement(chosenTemplateList);
  const verb = getRandomElement(verbs);
  const adjective = getRandomElement(adjectives);
  const noun = getRandomElement(nouns);

  caption = caption.replace(/\[verb]/g, () => verb);
  caption = caption.replace(/\[adjective]/g, () => adjective);
  caption = caption.replace(/\[noun]/g, () => noun);

  caption = caption.charAt(0).toUpperCase() + caption.slice(1);

  if (Math.random() > 0.75) {
    caption += " " + getRandomElement(emojis);
  }

  return caption;
}

function getRandomTimestamp(dateString) {
  const date = new Date(dateString.getTime());
  date.setUTCHours(Math.floor(Math.random() * 24));
  date.setUTCMinutes(Math.floor(Math.random() * 60));
  date.setUTCSeconds(Math.floor(Math.random() * 60));

  return admin.firestore.Timestamp.fromDate(date);
}

async function getUnsplashImage() {
  const response = await axios.get("https://api.unsplash.com/photos/random", {
    headers: {
      Authorization: `Client-ID ${UNSPLASH_ACCESS_KEY}`,
    },
  });

  const image = response.data;
  const { width, height } = image;

  return {
    url: image.urls.regular,
    width,
    height,
  };
}

async function downloadImage(url) {
  const response = await axios({
    method: "get",
    url,
    responseType: "arraybuffer",
  });

  return Buffer.from(response.data);
}

async function uploadImageToStorage(buffer, destinationPath) {
  const bucket = admin.storage().bucket(FIREBASE_STORAGE_BUCKET);
  const file = bucket.file(destinationPath);

  await file.save(buffer, {
    public: true,
  });

  return `https://storage.googleapis.com/${FIREBASE_STORAGE_BUCKET}/${destinationPath}`;
}

function getRandomLikes() {
  // fill likes with random strings like "userId1"
  const likes = [];
  const numLikes = Math.floor(Math.random() * 50);

  for (let i = 0; i < numLikes; i++) {
    likes.push(`userId${i}`);
  }

  return likes;
}

async function generateSubmissions(n) {
  if (!UNSPLASH_ACCESS_KEY) {
    console.error("No Unsplash access key provided.");
    return;
  }

  if (!FIREBASE_STORAGE_BUCKET) {
    console.error("No Firebase storage bucket provided.");
    return;
  }

  console.log(
    `Starting generation of ${n} documents in "${COLLECTION_NAME}"...`
  );

  if (!admin.apps.length) {
    admin.initializeApp({
      credential: admin.credential.cert(SERVICE_ACCOUNT),
      storageBucket: FIREBASE_STORAGE_BUCKET,
    });
  }

  const prompts = await getPromptDocuments();
  const userIds = await getUserIds();

  for (let i = 0; i < n; i++) {
    console.log(`\n--- Generating submission ${i + 1} of ${n} ---`);

    try {
      const userId = getRandomElement(userIds);
      const prompt = getRandomElement(prompts);
      const caption = getRandomCaption();
      const date = getRandomTimestamp(prompt.dateString);
      const likes = getRandomLikes();
      const image = await getUnsplashImage();

      if (!image) throw new Error("Failed to fetch image from Unsplash.");

      const imageBuffer = await downloadImage(image.url);
      if (!imageBuffer) throw new Error("Failed to download image.");

      const docRef = admin.firestore().collection(COLLECTION_NAME).doc();
      const destinationPath = `users/${userId}/submissions/${docRef.id}.jpg`;
      const imageUrl = await uploadImageToStorage(imageBuffer, destinationPath);

      console.log(
        `Image (${image.width}x${image.height}) uploaded to "${destinationPath}" and its URL is "${imageUrl}"`
      );

      const submission = {
        id: docRef.id,
        userId,
        caption,
        likes,
        date,
        image: {
          url: imageUrl,
          width: image.width,
          height: image.height,
        },
        prompt: {
          id: prompt.id,
          title: prompt.title,
        },
      };

      await docRef.set(submission);
    } catch (err) {
      console.error(`Error generating submission ${i + 1}: ${err}`);
      continue;
    }
  }

  console.log("\nGeneration complete!");
}

const n = parseInt(process.argv[2], 10) || 10;
if (isNaN(n) || n <= 0) {
  console.error("Please provide a valid number of submissions to generate.");
  process.exit(1);
} else {
  generateSubmissions(n);
}
