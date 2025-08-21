export const createMagicLink = async (
  discordId: string,
  displayName: string,
  username: string,
  avatar: string,
): Promise<string> => {
  const apiUrl = process.env.API_URL;
  const botUser = process.env.BOT_USERNAME;
  const botPassword = process.env.BOT_PASSWORD;
  const authorization = btoa(`${botUser}:${botPassword}`);
  const response = await fetch(`${apiUrl}/api/bot/magic-link`, {
    method: "post",
    headers: {
      Authorization: `Basic ${authorization}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      discord_id: discordId,
      display_name: displayName,
      username: username,
      avatar_url: avatar,
    }),
  }).then((response) => response.json());

  return response.magic_link;
};
