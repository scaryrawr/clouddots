// @ts-check

/**
 * Copilot CLI extension that sends desktop notifications over SSH
 * when Copilot is waiting for user input (idle after work,
 * permission requested, or ask_user questions).
 *
 * Uses the gh-ado-codespaces notification-sender.sh when available.
 */

import { joinSession } from "@github/copilot-sdk/extension";
import { execFile } from "node:child_process";
import { existsSync } from "node:fs";
import { join } from "node:path";

const notificationSender = join(
  process.env.HOME || "",
  "notification-sender.sh",
);
const isRemote = !!(
  process.env.SSH_CONNECTION ||
  process.env.SSH_CLIENT ||
  process.env.SSH_TTY ||
  process.env.DEVPOD
);

const MIN_DURATION_MS = 5_000;

/**
 * Send a notification via notification-sender.sh.
 * No-op when not in a remote/SSH session or sender is missing.
 * @param {string} title
 * @param {string} message
 */
function sendNotification(title, message) {
  if (!isRemote || !existsSync(notificationSender)) return;
  execFile(notificationSender, ["send", title, message], () => {});
}

/**
 * Return the first non-empty line of a prompt for compact notifications.
 * @param {string} text
 */
function getNotificationLine(text) {
  return text
    .split(/\r?\n/)
    .map((line) => line.trim())
    .find((line) => line.length > 0);
}

let turnStartTime = 0;

const session = await joinSession({
  tools: [],
  hooks: {},
});

// Track when the agent starts a new turn
session.on("assistant.turn_start", () => {
  turnStartTime = Date.now();
});

// Notify when the agent finishes a turn that took a while
session.on("session.idle", () => {
  if (turnStartTime > 0 && Date.now() - turnStartTime >= MIN_DURATION_MS) {
    sendNotification("Copilot CLI", "Waiting for your input");
  }
  turnStartTime = 0;
});

// Always notify on permission requests — the user needs to act
session.on("permission.requested", () => {
  sendNotification("Copilot CLI", "Permission needed to continue");
});

// Notify when the agent explicitly asks the user a question
session.on("user_input.requested", (event) => {
  const question = getNotificationLine(event.data.question);

  sendNotification(
    "Copilot CLI",
    question ? `Question: ${question}` : "Question waiting for your input",
  );
});
