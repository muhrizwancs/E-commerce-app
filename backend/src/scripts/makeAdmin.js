require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../models/User');

const email = process.argv[2]?.toLowerCase();

async function makeAdmin() {
  if (!email) {
    console.error('Usage: npm run make-admin -- user@example.com');
    process.exit(1);
  }

  if (!process.env.MONGODB_URI) {
    console.error('MONGODB_URI is missing in backend/.env');
    process.exit(1);
  }

  await mongoose.connect(process.env.MONGODB_URI);

  const user = await User.findOneAndUpdate(
    { email },
    { isAdmin: true, updatedAt: Date.now() },
    { new: true }
  ).select('-password');

  if (!user) {
    console.error(`No user found with email: ${email}`);
    await mongoose.disconnect();
    process.exit(1);
  }

  console.log(`${user.email} is now an admin.`);
  await mongoose.disconnect();
}

makeAdmin().catch(async (error) => {
  console.error(error.message);
  await mongoose.disconnect();
  process.exit(1);
});
