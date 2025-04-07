const admin = require("firebase-admin");
const axios = require("axios");
require("dotenv").config({ path: ".env.local" });

const SERVICE_ACCOUNT = require("./serviceAccountKey.json");
const UNSPLASH_ACCESS_KEY = process.env.UNSPLASH_ACCESS_KEY;

const COLLECTION_NAME = "submissions";
const USER_IDS = [
  "8oyiN8VUYMTdRCv4Nb7QsFGoFqi2",
  "cRFaIR7MJnTg4stxl96PnF8b2732",
  "qIZQ2zPALaYr0u5HrtL0rInCLpZ2",
];
const PROMPTS = [
  {
    id: "0qDOr6vLnjiAXuA5bxuQ",
    title: "Tiny seed grows",
    dateString: "2025-04-05",
  },
  {
    id: "Ek0iSg0e1oUcyYkzEFWl",
    title: "Reflections in water",
    dateString: "2025-04-06",
  },
  { id: "FBuixqliLy6tVY5ugOML", title: "Growth", dateString: "2025-04-04" },
  {
    id: "MUcAmFPLnsNZHAoHMyn6",
    title: "Gentle light",
    dateString: "2025-04-01",
  },
  {
    id: "O1kZ23q3u0obn6suQBMm",
    title: "Whispers on wind",
    dateString: "2025-04-03",
  },
  {
    id: "P6Bm5VOXvAn553M7WJez",
    title: "Hidden path ahead",
    dateString: "2025-04-02",
  },
];

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

  if (Math.random() < 0.75) {
    caption += " " + getRandomElement(emojis);
  }

  return caption;
}

function getRandomTimestamp(dateString) {
  const date = new Date(dateString + "T00:00:00Z");
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

async function generateSubmissions(n) {
  if (!UNSPLASH_ACCESS_KEY) {
    console.error("No Unsplash access key provided.");
    return;
  }

  console.log("Generating submissions...");

  if (!admin.apps.length) {
    admin.initializeApp({
      credential: admin.credential.cert(SERVICE_ACCOUNT),
      databaseURL: "https://your-database-name.firebaseio.com",
    });
  }

  const db = admin.firestore();
  const collection = db.collection(COLLECTION_NAME);

  console.log(
    `Starting generation of ${n} documents in "${COLLECTION_NAME}"...`
  );

  for (let i = 0; i < n; i++) {
    console.log(`\n--- Generating submission ${i + 1} of ${n} ---`);

    try {
      const userId = getRandomElement(USER_IDS);
      const prompt = getRandomElement(PROMPTS);
      const caption = getRandomCaption();
      const timestamp = getRandomTimestamp(prompt.dateString);
      const image = await getUnsplashImage();

      if (!image) throw new Error("Failed to fetch image from Unsplash.");

      const docRef = collection.doc();

      const submission = {
        id: docRef.id,
        userId,
        caption,
        likes: [],
        date: timestamp,
        prompt: {
          id: prompt.id,
          title: prompt.title,
        },
        image: {
          url: image.url,
          width: image.width,
          height: image.height,
        },
      };

      await docRef.set(submission);
    } catch (err) {
      console.error(
        `Error generating submission ${i + 1}: ${err.response.data}`
      );
      continue;
    }
  }

  console.log(
    `\nGeneration complete! ${n} documents created in "${COLLECTION_NAME}".`
  );
}

const n = parseInt(process.argv[2], 10) || 10;
if (isNaN(n) || n <= 0) {
  console.error("Please provide a valid number of submissions to generate.");
  process.exit(1);
} else {
  generateSubmissions(n);
}
