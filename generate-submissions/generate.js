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

async function getPromptDocuments() {
  const now = new Date();
  const today = new Date(
    now.getUTCFullYear(),
    now.getUTCMonth(),
    now.getUTCDate() + 1
  );

  const snapshot = await admin
    .firestore()
    .collection("prompts")
    .where("date", "<=", today)
    .orderBy("date", "desc")
    .limit(15)
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
  const captions = [
    "Golden hour glow",
    "Still life study",
    "Muted tones only",
    "Wandering shapes",
    "Accidental harmony",
    "Through glass",
    "Weathered beauty",
    "Contrast city",
    "Quiet symmetry",
    "Found in frame",

    "Light was perfect for exactly three minutes",
    "Saw this and couldn't not shoot it",
    "Everything aligned for half a second",
    "Shadow play on an empty street",
    "Geometry hidden in everyday places",
    "Color, chaos, and a little bit of luck",
    "The kind of light you wait weeks for",
    "Forgotten corners have the best stories",
    "This wall has more texture than my week",
    "Nothing staged, just timing and instinct",

    "This shot wasn't planned — I was on my way home and the light just stopped me cold",
    "Sometimes you walk past a hundred scenes and then one just clicks into place",
    "It's not about the subject, it's about the way the light and lines speak to each other",
    "Took a left I don't normally take, and found this waiting like it had always been there",
    "The photo isn't perfect, but the feeling was — and that's enough for me",
    "I could've walked right past this, but something about the texture and light said stop",
    "This one reminds me why I always carry a camera — even when I think I won't need it",
    "Shot this in silence. The kind of silence that feels thick and deliberate.",
    "It's not just a door. It's color, light, weather, and the years no one noticed it",
    "I've passed this spot a dozen times, but today the shadows told a different story",
  ];

  const emojis = ["📸", "🌆", "🌿", "🏙️", "🧱", "✨", "🌫️", "☁️", "🚪", "📷"];

  let caption = getRandomElement(captions);

  if (Math.random() < 0.15) {
    caption += " " + getRandomElement(emojis);
  }

  return caption;
}

function getRandomComment() {
  const comments = [
    "Love this light",
    "Incredible tones",
    "So clean",
    "Perfect timing",
    "Great texture",
    "Wild framing",
    "Subtle and strong",
    "Nice balance",
    "Really satisfying",
    "Sharp work",

    "This feels like a quiet moment frozen",
    "Those lines are doing something special",
    "Framing here is super intentional",
    "Color story is working overtime",
    "Love how minimal this is",
    "Feels like part of a film",
    "That depth is doing heavy lifting",
    "Tones are smooth and deliberate",
    "Really cool sense of scale here",
    "I kept staring at this one",

    "It's always the little things — like the way the shadow cuts across the frame just perfectly",
    "This has a stillness I can't stop looking at. Really strong sense of place.",
    "I love how this tells a story without needing anything else. The mood is so clear.",
    "Every element here feels considered. It's like a calm puzzle that fell into place.",
    "I feel like I've been in this exact moment before — not the place, just the feeling.",
    "You made something ordinary feel cinematic. Really well seen.",
    "There's a softness here that makes this linger in my head — not sure why, but I like it.",
    "The composition is tight, but still gives everything room to breathe. That's hard to pull off.",
    "Honestly, this could be a still from a dream. It's abstract but grounded at the same time.",
    "It takes a good eye to notice something like this. Simple subject, strong execution.",
  ];

  const emojis = ["👏", "🖤", "🔥", "🌫️", "🎞️", "📷", "💯", "📸", "✨", "🧠"];

  let comment = getRandomElement(comments);

  if (Math.random() < 0.25) {
    comment += " " + getRandomElement(emojis);
  }

  return comment;
}

function getRandomTimestamp(original) {
  const now = new Date();
  const date = new Date(
    original.getFullYear(),
    original.getMonth(),
    original.getDate()
  );

  let randomDate;

  while (randomDate > now) {
    const hours = Math.floor(Math.random() * 24);
    const minutes = Math.floor(Math.random() * 60);
    const seconds = Math.floor(Math.random() * 60);

    randomDate = new Date(date);
    randomDate.setHours(hours, minutes, seconds);
  }

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

function getRandomLikes(max) {
  // fill likes with random strings like "userId1"
  const likes = [];
  const numLikes = Math.floor(Math.random() * max);

  for (let i = 0; i < numLikes; i++) {
    likes.push(`userId${i}`);
  }

  return likes;
}

async function generateComments(submissions, userIds, n = 15) {
  for (const submission of submissions) {
    const comments = [];
    const numComments = Math.floor(Math.random() * n);

    console.log(
      `\n--- Generating ${numComments} comments for submission ${submission.id} ---`
    );

    try {
      for (let i = 0; i < numComments; i++) {
        const docRef = admin.firestore().collection("comments").doc();

        const comment = {
          id: docRef.id,
          userId: getRandomElement(userIds),
          submissionId: submission.id,
          text: getRandomComment(),
          date: getRandomTimestamp(new Date(submission.date.toDate())),
        };

        comments.push(comment);
      }

      const promises = comments.map((comment) =>
        admin.firestore().collection("comments").doc(comment.id).set(comment)
      );

      await Promise.all(promises);
    } catch (err) {
      console.error(
        `Error generating comments for submission ${submission.id}: ${err}`
      );
      return;
    }
  }

  console.log(
    `\n--- Comments generated for ${submissions.length} submissions successfully! ---`
  );
}

async function generateSubmissions(userIds, prompts, n) {
  const submissions = [];
  let fail = 0;

  for (let i = 0; i < n; i++) {
    console.log(`\n--- Generating submission ${i + 1} of ${n} ---`);

    try {
      const userId = getRandomElement(userIds);
      const prompt = getRandomElement(prompts);
      const caption = getRandomCaption();
      const date = getRandomTimestamp(prompt.dateString);
      const likes = getRandomLikes(50);
      const image = await getUnsplashImage();

      if (!image) throw new Error("Failed to fetch image from Unsplash.");

      const imageBuffer = await downloadImage(image.url);
      if (!imageBuffer) throw new Error("Failed to download image.");

      const docRef = admin.firestore().collection("submissions").doc();
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

      submissions.push(submission);
      await docRef.set(submission);
    } catch (err) {
      console.error(`Error generating submission ${i + 1}: ${err}`);
      fail++;
      continue;
    }
  }

  console.log(
    `\n--- ${n - fail} / ${n} submissions generated successfully! ---`
  );

  return submissions;
}

async function main(n) {
  if (!UNSPLASH_ACCESS_KEY) {
    console.error("No Unsplash access key provided.");
    return;
  }

  if (!FIREBASE_STORAGE_BUCKET) {
    console.error("No Firebase storage bucket provided.");
    return;
  }

  if (!admin.apps.length) {
    admin.initializeApp({
      credential: admin.credential.cert(SERVICE_ACCOUNT),
      storageBucket: FIREBASE_STORAGE_BUCKET,
    });
  }

  const prompts = await getPromptDocuments();
  const userIds = await getUserIds();

  const submissions = await generateSubmissions(userIds, prompts, n);
  await generateComments(submissions, userIds, 15);

  console.log("\n--- All done! ---");
}

const n = parseInt(process.argv[2], 10) || 10;
main(n);
