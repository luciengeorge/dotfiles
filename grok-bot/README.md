# Grok Bot fleet

Templates and a setup prompt for rebuilding my Grok Bot fleet on a new account.

The full version, with personal context for each bot, is private: [Grok Bot fleet: new account setup (Nov 2026)](https://app.notion.com/p/421c39f3f25381ea80b3daac1f179bb8) (Notion, needs my login). This folder only has the parts that are safe to keep in a public repo.

## Templates

Import order is top to bottom. Chief of Staff goes first.

| Bot | Template name | Link | Getting-started skill | What it does |
| --- | --- | --- | --- | --- |
| Chief of Staff | Chief of Staff | https://x.ai/bot/z7giVkETRbKhBCttgGb-i | yes | Front door: triages inbox, calendar and Slack, handles personal admin, briefs before calls, routes work to the other bots and paces fleet usage. |
| Engineering Lead | Engineering Lead | https://x.ai/bot/Y7uZFDDszxPvJlO3as6aa | yes | Orchestrates the engineering bots (QA, PR Reviewer) and cloud coding agents to take features and bugs from idea to merged, deployed and verified. |
| QA Engineer | QA Engineer | https://x.ai/bot/GKHD_XMNU4SJbmWRtaOnw | yes | QA gate for an engineering bot team: verifies release-bound PRs by running them and gives GO or NO-GO on the exact head SHA. |
| PR Reviewer | PR Reviewer | https://x.ai/bot/RYq3U1XoBC8xx7oGR_Fus | yes | Senior code reviewer: reads pull requests and gives a clear verdict with cited findings; never posts on GitHub unless asked. |
| Arthur | Product CEO | https://x.ai/bot/lNyIhdQzjnUUGuhSsHhT6 | yes | Product CEO bot for one small online product: sets priorities, coordinates growth, SEO, engineering and QA bots, merges QA-approved changes, tracks real outcomes. |
| Alfred | Alfred (Product CEO) | https://x.ai/bot/n_D8cbiO4zd_7V5xw1ZdW | yes | Product CEO bot for one small product, distribution first: assigns work to growth, SEO and engineering bots, merges QA-approved PRs, tracks real outcomes. |
| LaunchLoop Growth | Growth Lead | https://x.ai/bot/1UQnkL33roIApj7S5qPnU | no | Growth lead for an indie product: drafts build-in-public X posts for approval, works through launch directories, handles email and monetisation experiments. Reports to the product CEO bot. |
| LaunchLoop SEO | SEO & AEO Lead | https://x.ai/bot/MTPSCwD3fGaeqH8EpGP3E | yes | Search and AI-discovery lead: improves SEO and AEO, tracks indexing and keyword opportunities, ships fixes as branch PRs for review. |
| Job Scout | Job Scout | https://x.ai/bot/qVSsH-Tv8KiXQvOLIxe3A | no | Job search assistant for a senior engineer: daily careers-page watch, screening against criteria, drafting applications for approval. |
| Freelance Manager | Freelance Manager | https://x.ai/bot/mdXk7U6BHD3gs2P0hILUy | no | Runs a freelance side business: platform profiles, lead scoring, proposals in the owner's voice, pricing and a pipeline tracker. Nothing goes out without approval. |
| Interview Coach, prep page | Interview Coach (builds your prep page) | https://x.ai/bot/4A0EdBTlahh-qvs2mQG1B | yes | Temporary coach for one company's interview process: prep page, stories as natural spoken answers, mock interviews, help after each round. |
| Interview Coach, inbox watch | Interview Coach (watches your inbox) | https://x.ai/bot/2MlbbmbvCtxoNc_SZAgbI | no | Temporary coach for one company's interview process: keeps prep notes, gives answers in the owner's voice, runs mock interviews and watches the inbox for next steps. |
| London Rental Scout | London Rental Scout | https://x.ai/bot/m_3pr7X7LlJNG7YHquTew | yes | Watches a city's prime rental market each morning for a flat that beats the current home, vets photos and floorplans, and stays silent when nothing qualifies. |

The two Interview Coach templates have the same title. Tell them apart by the description on the link page. Which interview process each one served is on the Notion page.

Not moved: the archived LaunchLoop Newsletter and Revenue bots.

## How to move

1. Import Chief of Staff and let its getting-started skill run.
2. Paste [setup-prompt.md](setup-prompt.md) into its first chat, then the bot's private context from the Notion page.
3. Reconnect each bot's connectors in its settings. Sign-ins, 2FA and OAuth are done by hand.
4. Import the rest in the order above. Link Engineering Lead, QA Engineer and PR Reviewer as one team.
5. For bots with no getting-started skill (Freelance Manager, LaunchLoop Growth, Job Scout, Interview Coach inbox watch), follow the first-run steps on the Notion page, then ask the bot to save its own getting-started skill.
6. Confirm or recreate each routine. When a routine exists on the new account, pause the matching one on the old account straight away so nothing runs twice.
7. Keep old bots with live events running until those events are done.

## Routines (schedules, UK time unless noted)

| Bot | Routine |
| --- | --- |
| Chief of Staff | Pre-call brief hourly on weekdays; usage guard every 3 hours; Monday brief; fleet review Fridays 16:47 |
| Engineering Lead | Team check-in weekdays at :48 past the hour, 09:48 to 17:48 (paused on the old account) |
| Arthur | Morning run weekdays ~09:15 Paris; decisions list weekdays ~10:00 Paris; end-of-day check weekdays ~18:45 Paris; weekly update Mondays 10:10 Paris; Sentry bug watch (event trigger) |
| Alfred | Morning run weekdays 08:30; end-of-day check weekdays 17:30 |
| LaunchLoop SEO | Weekly SEO report Mondays ~09:00 Paris; PR-merged trigger to draft one post per new article |
| Job Scout | Job watch weekdays 08:57 |
| Freelance Manager | Lead check daily ~18:00 |
| London Rental Scout | Rental watch daily ~09:00 |
| Interview Coach, inbox watch | Inbox watch weekdays ~09:00 and ~17:00, until the process ends |
| QA Engineer, PR Reviewer, Interview Coach prep page, LaunchLoop Growth | No standing routines |
