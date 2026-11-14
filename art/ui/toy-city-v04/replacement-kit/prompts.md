# 내장 ImageGen 생성 프롬프트

스타일 참조: ../ui-style-sheet-v04.png. 최신 맵 UI 예시는 docs/studio-changes/2026-11-14-map-color-grade/after-street.jpg도 함께 참조했다. 아래는 실제 전달한 원문이다.

## panels-atlas

Use case: ui-mockup. Asset type: blank, reusable GAME UI PANEL SKINS atlas.
Match the attached ProjectMS UI style sheet as the exact art direction reference: chunky painted mobile game UI, thick DARK NAVY outlines, rounded/beveled corners, crisp top-left glossy highlights, short solid lower extrusion shadows. Saturated electric BLUE, real warm RED, rich GOLDEN YELLOW, small GREEN positive accents, white/pale interiors and navy secondary panels. Clean toy-like 2.5D painted raster graphics, excellent silhouettes at mobile size. No scene, no logos, no watermark. Every sprite must be original and consistent with the reference. Do not draw any letters, labels, numbers or interface text on component atlases. TRUE transparent alpha outside components, not a checkerboard image.
Production sprite atlas, exactly 4 equal columns by 3 equal rows, overall aspect ratio 4:3; use a high resolution such as 1536x1152 or 2048x1536. All cell centers must align mathematically to a regular grid. Each cell has generous transparent padding of at least 12% on each side; NOTHING touches cell edges or overlaps adjacent cells. One component per cell. No visible grid, no background, no text or captions. Interior content areas are EMPTY, to hold dynamic native game text and icons later. Do not add decorative symbols unless specifically requested.
Exact row-major contents:
Row1: (1) primary BLUE modal window frame, shallow blank blue title header and pale white filled body; (2) GOLD modal window same construction; (3) RED modal window same construction; (4) dark SLATE/NAVY modal window with darker blank header.
Row2: (1) small blue HUD information plate with pale filled body; (2) navy HUD info plate with dark body; (3) BLUE notification/toast plate; (4) GREEN success notification plate.
Row3: (1) RED error/warning notification plate; (2) compact BLUE interaction prompt card with pale empty center; (3) RED boss information banner plate, dark navy empty interior; (4) blue-framed currency capsule with dark empty interior.
All twelve components are blank. Windows in row1 almost square, width equals height. Plates in row2 and row3 horizontal rounded rectangles about 2.4:1, centered in their square cells. Keep edge decoration confined to the border, corners and header. Flat quiet center regions suitable for 9-slice stretching. No close icons, no coins, no text, no bars inside.

## buttons-atlas

Use case: ui-mockup. Asset type: complete BUTTON STATES sprite atlas.
Match the attached ProjectMS UI style sheet as the exact art direction reference: chunky painted mobile game UI, thick DARK NAVY outlines, rounded/beveled corners, crisp top-left glossy highlights, short solid lower extrusion shadows. Saturated electric BLUE, real warm RED, rich GOLDEN YELLOW, small GREEN positive accents, white/pale interiors and navy secondary panels. Clean toy-like 2.5D painted raster graphics, excellent silhouettes at mobile size. No scene, no logos, no watermark. Every sprite must be original and consistent with the reference. Do not draw any letters, labels, numbers or interface text on component atlases. TRUE transparent alpha outside components, not a checkerboard image.
Production sprite atlas, exactly 4 equal columns by 3 equal rows, overall aspect ratio 4:3; use a high resolution such as 1536x1152 or 2048x1536. All cell centers must align mathematically to a regular grid. Each cell has generous transparent padding of at least 12% on each side; NOTHING touches cell edges or overlaps adjacent cells. One component per cell. No visible grid, no background, no text or captions. Interior content areas are EMPTY, to hold dynamic native game text and icons later. Do not add decorative symbols unless specifically requested.
Exactly twelve BLANK wide rounded-rectangle buttons of aspect 2.4:1, identical size, center aligned within every square cell, no icons or text.
Exact row-major order:
Row1: BLUE default raised button, BLUE pressed button, BLUE disabled desaturated slate button, YELLOW default raised button.
Row2: YELLOW pressed button, YELLOW disabled muted ochre/slate button, RED default raised button, RED pressed button.
Row3: RED disabled dusty red/slate button, GREEN default raised confirm button, GREEN pressed confirm button, GREEN disabled muted slate green button.
Pressed states visibly compress the lower rim and darken the top surface, while keeping the same overall bounds. Disabled states retain their recognizable hue in muted form, with no bright shine. Blue/red/yellow colors have equal importance. All corners and border weights consistent. Borders thick enough for phone displays. Quiet fill centers for overlaid native labels.

## controls-atlas

Use case: ui-mockup. Asset type: blank gameplay CONTROL/GAUGE/TAB components.
Match the attached ProjectMS UI style sheet as the exact art direction reference: chunky painted mobile game UI, thick DARK NAVY outlines, rounded/beveled corners, crisp top-left glossy highlights, short solid lower extrusion shadows. Saturated electric BLUE, real warm RED, rich GOLDEN YELLOW, small GREEN positive accents, white/pale interiors and navy secondary panels. Clean toy-like 2.5D painted raster graphics, excellent silhouettes at mobile size. No scene, no logos, no watermark. Every sprite must be original and consistent with the reference. Do not draw any letters, labels, numbers or interface text on component atlases. TRUE transparent alpha outside components, not a checkerboard image.
Production sprite atlas, exactly 4 equal columns by 3 equal rows, overall aspect ratio 4:3; use a high resolution such as 1536x1152 or 2048x1536. All cell centers must align mathematically to a regular grid. Each cell has generous transparent padding of at least 12% on each side; NOTHING touches cell edges or overlaps adjacent cells. One component per cell. No visible grid, no background, no text or captions. Interior content areas are EMPTY, to hold dynamic native game text and icons later. Do not add decorative symbols unless specifically requested.
Twelve components, exact row-major order:
Row1: (1) large circular focus-fire button face, RED interior GOLD rim, EMPTY center (no missile art); (2) same circular focus face pressed and slightly darker; (3) disabled circular focus face dark blue/slate; (4) EMPTY long horizontal dark navy progress-bar trough with blue rim.
Row2: (1) long horizontal BLUE gauge fill, no trough; (2) long horizontal YELLOW gauge fill; (3) long horizontal RED health fill; (4) empty red shield badge with gold rim, no text or symbols.
Row3: (1) BLUE active rounded tab with bright face; (2) dark navy inactive rounded tab; (3) thick YELLOW rounded-square selection border with fully transparent open center (no fill at all); (4) small WHITE/BLUE blank keyboard keycap, EMPTY center for native E/F/G label.
Circular buttons and selection border should be square. Bars and tabs horizontal aspect 3:1 and centered in cell. Each bar fill is a simple uninterrupted rounded strip suitable for clipping by a native progress frame. One object per cell, no little UI assembled around it.

## rarity-cards-atlas

Use case: ui-mockup. Asset type: collectible item CARD BACKGROUND atlas.
Match the attached ProjectMS UI style sheet as the exact art direction reference: chunky painted mobile game UI, thick DARK NAVY outlines, rounded/beveled corners, crisp top-left glossy highlights, short solid lower extrusion shadows. Saturated electric BLUE, real warm RED, rich GOLDEN YELLOW, small GREEN positive accents, white/pale interiors and navy secondary panels. Clean toy-like 2.5D painted raster graphics, excellent silhouettes at mobile size. No scene, no logos, no watermark. Every sprite must be original and consistent with the reference. Do not draw any letters, labels, numbers or interface text on component atlases. TRUE transparent alpha outside components, not a checkerboard image.
High resolution transparent sprite atlas exactly FOUR equal columns and TWO equal rows, overall canvas aspect 2:1, equal square cells. Each cell contains ONE portrait rounded rectangle card of aspect 0.72:1 with at least 12% transparent padding on all sides. No grid, labels, numbers, text, rockets, weapons, stars, padlocks or currency. These are EMPTY BACKGROUNDS so actual in-game item art can be placed on top. Same identical card silhouette and bounds in every cell.
Exact row-major contents:
Row1: COMMON cool white/slate trim with pale blue quiet center; UNCOMMON green trim; RARE saturated blue trim; EPIC purple trim.
Row2: LEGENDARY rich golden yellow trim; MYTHIC warm red trim; COSMIC cyan outer rim and pink/magenta inner trim with dark blue center; LOCKED dark slate trim with subdued dark center.
Use subtle radial rays or soft center glows inside cards, centered faint decoration only, fully blank header/footer. Thick dark navy outlines and beveled rims match reference; no tiny details.

## utility-icons-atlas

Use case: stylized-concept. Asset type: supplemental GAME UI ICON atlas.
Match the attached ProjectMS UI style sheet as the exact art direction reference: chunky painted mobile game UI, thick DARK NAVY outlines, rounded/beveled corners, crisp top-left glossy highlights, short solid lower extrusion shadows. Saturated electric BLUE, real warm RED, rich GOLDEN YELLOW, small GREEN positive accents, white/pale interiors and navy secondary panels. Clean toy-like 2.5D painted raster graphics, excellent silhouettes at mobile size. No scene, no logos, no watermark. Every sprite must be original and consistent with the reference. Do not draw any letters, labels, numbers or interface text on component atlases. TRUE transparent alpha outside components, not a checkerboard image.
A square high-resolution transparent atlas with exactly FOUR columns and FOUR rows, sixteen equal square cells. All icons same apparent size, centered, occupy inner 72% of each cell, generous alpha gutters. No square button backgrounds, no grid lines, no text, numbers or labels.
Exact row-major order:
Row1: blue-green globe inside gold portal ring for world travel; toy prank pistol white body with red slide and yellow muzzle (no realistic gun markings); happy golden sun with short rays; pale yellow crescent moon and tiny blue star.
Row2: blue stopwatch with white face and red hand (no numerals); gold closed padlock; gold open padlock; large white X on small red chunky close badge.
Row3: large green checkmark; gold back arrow pointing left; white-blue rocket with green check badge for equipped; gold coins with red outgoing arrow for sell.
Row4: gold warning triangle with a red exclamation pictogram; white-blue finger pressing a cyan touch ripple; white upward jump arrow on a blue circular disc; red shield with golden star for raid.
Icons must be readable at 48px, thick navy outlines, unified highlights, blue/red/gold palette. No UI screenshots.

## current-map-ui-example

Use case: ui-mockup. Create a polished wide landscape in-game HUD CONCEPT for ProjectMS based on the TWO attached references. Image1 = exact new UI art style, chunky dark navy outlines with vivid BLUE, RED and GOLDEN YELLOW buttons and icons. Image2 = current game's ENVIRONMENT/LIGHTING/GEOMETRY reference, not its old UI.
Preserve current map direction: bright high-key neutral daylight, light cool-concrete building walls, dark slate window trims, small candy red/yellow/green roofs and awnings, broad very pale gray Baseplate-like checker floor, straight 22-stud avenue, white distant haze. Do NOT turn buildings/windows/ground blue. No blue color cast over shadows. Only sky and selected small objects blue.
Overlay redesigned UI matching Image1, while leaving 65% of central play space unobstructed. Left edge a compact vertical menu with big icon+short Korean label buttons "미사일", "도감", "연구", blue backgrounds and one gold emphasis. Right edge short menu "차고" and a red toy pistol equip icon. Top-left compact gold coins "1,250" and blue research blueprint "18". Top center small sun+timer "2:20"; below it compact red/navy raid health banner "공동 레이드". Bottom center modest round red/gold focus button with three rockets, label "집중 발사", and narrow gold charge gauge below. Bottom-left translucent mobile joystick, bottom-right compact jump button. A small single unobtrusive interaction card near a workshop reads "E 제작".
Everything fits landscape mobile safe areas, generous empty aim center, no huge menu windows, no floating sale ads, no app watermark. Korean typography thick white with navy outline. Treat sample numbers as mockup only. This must visibly look like the supplied CURRENT neutral concrete game environment wearing the new colorful game UI, not an unrelated fantasy city.

## controls-atlas 투명 영역 정리

Use case: precise-object-edit. This is a production GAME UI sprite atlas edit.
Keep all 12 existing components, their exact order, positions, dimensions, proportions, colors and styling unchanged.
Make ONE cleanup pass: remove every stray isolated colored pixel/speck in the transparent gutters and especially INSIDE the GOLD SELECTION BORDER in row 3 column 3. That rounded square must have a completely empty, uniformly transparent hole, with no red flecks, no yellow mist, no sparkle fragments and no dark fill inside. Its gold border and highlights remain sharp. All outside background stays genuinely transparent alpha. Other eleven sprites stay exactly as shown. No new text, symbols, shadows or objects. Preserve canvas size and alignment.
