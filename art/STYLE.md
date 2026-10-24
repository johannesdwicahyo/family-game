# Huddle art style (v3: light, grown-up, stylish)

Earlier looks are archived: `v1-dark/` (neon party night) and `v2-cute/` (cute cartoon, judged too childish).
Audience: adults and young adults (18–35) at a hangout. References: Psych!, Jackbox, the Codenames app,
Spotify Wrapped, Airbnb/Notion-style editorial illustration.

**Style sentence (quote in every prompt):** modern editorial flat illustration, bold simple geometric
shapes, confident limited palette (tomato red, cobalt blue, sunflower gold, deep ink navy, warm off-white),
semi-flat shading with one or two flat shadow tones, subtle risograph grain texture, crisp clean edges,
no outlines (or very thin ink lines only where needed), slightly stylised and witty, NO faces, NO eyes,
NO cute or kawaii features, one isolated object centred on a plain solid white background,
no text, no letters, no numbers.

## Palette anchors
| Job | Hex |
|---|---|
| Page (code) | #FAF7F2 calm off-white |
| Card (code) | #FFFFFF, edge #ECE6DC |
| Ink (text, darkest tone in art) | #1F1A2E |
| Tomato (Impostor, danger) | #C8302A |
| Cobalt (Word Bomb, info) | #1F6FD1 |
| Sunflower gold (Most Likely To; fills with ink text) | #F5B700 |
| Green (Who Am I, correct) | #187A42 |
Other accents: Spin the Wheel #8A3FC7, Emoji #B34E00, Word Chain #0E7F74, Spy #5B4BDB, Two Lies #C42A7A.

## Semantic colour (never swap)
Red = danger / wrong / time. Green = correct / go. Gold = winner.

## Light
Flat, even daylight from the upper left: one flat shadow shape on the lower right of each object.
No glows, no gradients-as-style; grain only, very subtle.

## Rules
- One object per image, isolated on white, cut out with pixelcut, trimmed, ~512 px long edge.
- No faces on objects. No text, plates or labels.
- After the anchor, everything is made with `fal-ai/nano-banana-pro/edit`, passing the anchor in `image_urls`.
- App icon: full-bleed, bold and simple, readable at 60 px; no characters.

## Files
`prompts/` (exact requests), `raw/` (generations, `raw/urls.txt`), `cut/` (cutouts in the app),
`review-v3/` (approval screenshots). Anchor: `raw/anchor-bomb.png`.

## Set (approved v3)
Cards: Word Bomb (anchor), Impostor, Most Likely To, Spy (re-done in violet; the first navy version is in
`v3-first/`), Who Am I, Emoji Riddles, Two Lies, Word Chain, Spin the Wheel. Plus `trophy` (result
screens) and the app icon (three speech bubbles on tomato, `cut/icon-draft-1024.png`, installed as AppIcon).
In-app type: Bricolage Grotesque ExtraBold (SIL OFL) for display, SF Pro for text.
