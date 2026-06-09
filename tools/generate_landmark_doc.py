#!/usr/bin/env python3
"""Generate LANDMARK_CLUES.md from the real game data — every country's actual
landmark and the spoiler-free clue (emoji + phrase) the player is shown.
Mirrors LandmarkArt.resolve(): override by id -> keyword rule -> continent fallback."""
import re, datetime

DB = "PassportQuest/Data/CountryDatabase.swift"

# --- mirrors of LandmarkArt.swift (static data) ---
overrides = {
    "US": ("🗽", "a famous statue on an island"), "FR": ("🗼", "a famous iron tower"),
    "CN": ("🧱", "a wall thousands of miles long"), "JP": ("🗻", "a snow-capped sacred mountain"),
    "EG": ("🔺", "ancient giant pyramids"), "CL": ("🗿", "giant carved stone heads"),
    "AU": ("🎭", "a famous opera house on the harbour"), "NL": ("🌷", "fields full of tulips"),
    "CU": ("🚗", "colourful classic 1950s cars"), "IN": ("🕌", "a white marble palace of love"),
    "GB": ("🕰️", "a famous clock tower"), "RU": ("⛪", "a cathedral with colourful onion domes"),
    "BR": ("⛰️", "a giant statue on a mountain"), "SA": ("🕋", "a holy black cube building"),
    "AE": ("🏙️", "the world's tallest skyscraper"), "MY": ("🏙️", "famous twin towers"),
    "SG": ("🏙️", "a city of giant 'supertrees'"), "GR": ("🏛️", "ancient marble temples on a hill"),
    "IT": ("🏛️", "a giant ancient arena"), "BE": ("🍫", "a grand old market square"),
    "PE": ("⛰️", "a lost city high in the mountains"), "KR": ("🏯", "a grand royal palace"),
    "KH": ("🛕", "a huge ancient temple"), "MX": ("🛕", "a step-pyramid temple"),
    "JO": ("🏜️", "a city carved into pink rock"), "KE": ("🦁", "a savanna full of wild animals"),
    "TZ": ("🏔️", "the tallest mountain in Africa"), "ZA": ("⛰️", "a famous flat-topped mountain"),
    "NP": ("🏔️", "the world's tallest mountain"), "CH": ("🏔️", "a pointed snowy peak"),
    "PT": ("🗼", "an old riverside watchtower"), "TH": ("🛕", "a glittering royal palace"),
    "ID": ("🛕", "a huge ancient stone temple"), "TR": ("🕌", "a giant domed cathedral-mosque"),
}
keyword_rules = [
    ("pyramid","🔺","ancient pyramids"),("wall","🧱","a great long wall"),("statue","🗽","a famous statue"),
    ("opera","🎭","a grand opera house"),("tower","🗼","a famous tower"),("bridge","🌉","a famous bridge"),
    ("mosque","🕌","a beautiful mosque"),("temple","🛕","an ancient temple"),("pagoda","🛕","a golden pagoda"),
    ("wat","🛕","a huge temple complex"),("cathedral","⛪","a grand cathedral"),("church","⛪","a historic church"),
    ("basilica","⛪","a grand basilica"),("monastery","⛪","an old cliffside monastery"),("castle","🏰","a grand castle"),
    ("fortress","🏰","an old fortress"),("palace","🏰","a grand palace"),("citadel","🏰","a hilltop citadel"),
    ("volcano","🌋","a smoking volcano"),("crater","🌋","a giant crater"),("falls","💧","a mighty waterfall"),
    ("waterfall","💧","a mighty waterfall"),("mountain","🏔️","a famous mountain"),("mount ","🏔️","a famous mountain"),
    ("everest","🏔️","a towering mountain"),("peak","🏔️","a high mountain peak"),("glacier","🧊","a giant glacier"),
    ("desert","🏜️","vast desert sands"),("dunes","🏜️","giant sand dunes"),("sahara","🏜️","vast desert sands"),
    ("island","🏝️","beautiful islands"),("atoll","🏝️","ring-shaped coral islands"),("cays","🏝️","tiny tropical islands"),
    ("archipelago","🏝️","a chain of islands"),("lagoon","🏝️","a turquoise lagoon"),("reef","🐠","a colourful coral reef"),
    ("bay","⛵","a scenic bay"),("fjord","⛵","a deep, steep fjord"),("lake","🏞️","a beautiful lake"),
    ("delta","🏞️","a watery wildlife delta"),("forest","🌳","a wild rainforest"),("park","🌳","a wild national park"),
    ("reserve","🌳","a wildlife reserve"),("sanctuary","🐒","a wildlife sanctuary"),("rock","🪨","a giant rock"),
    ("cave","🕳️","amazing caves"),("market","🛍️","a busy market"),("city","🏙️","a famous old city"),
    ("dam","🌊","a huge dam"),("ruins","🏛️","ancient ruins"),("plateau","⛰️","a dramatic plateau"),
]
fallback = {
    "europe":("🏛️","a famous old landmark"),"americas":("⛰️","a famous natural wonder"),
    "asia":("🛕","a famous temple or palace"),"africa":("🦒","amazing wildlife and scenery"),
    "oceania":("🏝️","a beautiful island sight"),"polar":("❄️","a frozen, remote wonder"),
}
CONT_NAMES = {"europe":"Europe","africa":"Africa","asia":"Asia","americas":"Americas",
              "oceania":"Oceania","polar":"Polar & Territories"}
CONT_ORDER = ["europe","asia","africa","americas","oceania","polar"]

def resolve(cid, landmark, cont):
    if cid in overrides:
        e,p = overrides[cid]; return e,p,"override"
    name = landmark.lower()
    for kw,e,p in keyword_rules:
        if kw in name:
            return e,p,f"keyword “{kw.strip()}”"
    e,p = fallback[cont]; return e,p,"continent fallback"

src = open(DB, encoding="utf-8").read()
pat = re.compile(r'Country\(id:\s*"(?P<id>[^"]+)",\s*name:\s*"(?P<name>[^"]+)"'
                 r'[\s\S]*?continent:\s*\.(?P<cont>\w+)'
                 r'[\s\S]*?landmarkName:\s*"(?P<lm>[^"]+)"')
rows = []
for m in pat.finditer(src):
    cid,name,cont,lm = m["id"],m["name"],m["cont"],m["lm"]
    e,p,sourced = resolve(cid,lm,cont)
    rows.append((cont,name,cid,lm,e,p,sourced))

by_cont = {c:[] for c in CONT_ORDER}
for r in rows:
    by_cont.setdefault(r[0],[]).append(r)

today = datetime.date.today().isoformat()
out = []
out.append("# Passport Quest — Landmark Clues\n")
out.append("Every country's **real landmark** (the answer, revealed on the stamp card) "
           "alongside the **spoiler-free Famous-Place clue** the player actually sees "
           "(emoji + phrase). The clue deliberately hides the landmark's real name, since "
           "the name usually gives away the country.\n")
out.append(f"Auto-generated from `CountryDatabase.swift` + `LandmarkArt.swift` on {today}. "
           f"**{len(rows)} countries.** To regenerate, run `python3 tools/generate_landmark_doc.py` from the repo root.\n")
out.append("The **Clue source** column shows how each clue is chosen — a hand-written "
           "`override`, a `keyword` match on the landmark name, or a generic `continent "
           "fallback`. Fallbacks are the weakest and the best candidates for an editorial pass.\n")

# summary counts
n_over = sum(1 for r in rows if r[6]=="override")
n_fb = sum(1 for r in rows if r[6]=="continent fallback")
n_kw = len(rows)-n_over-n_fb
out.append(f"> **At a glance:** {n_over} hand-written overrides · {n_kw} keyword matches · "
           f"{n_fb} generic continent fallbacks.\n")

for c in CONT_ORDER:
    items = sorted(by_cont.get(c,[]), key=lambda r: r[1])
    if not items: continue
    out.append(f"\n## {CONT_NAMES[c]}  ({len(items)})\n")
    out.append("| Country | Real landmark (answer) | Clue shown | Clue source |")
    out.append("|---|---|---|---|")
    for _,name,cid,lm,e,p,sourced in items:
        out.append(f"| {name} (`{cid}`) | {lm} | {e} {p} | {sourced} |")

doc = "\n".join(out) + "\n"
open("LANDMARK_CLUES.md","w",encoding="utf-8").write(doc)
print(f"wrote LANDMARK_CLUES.md — {len(rows)} countries "
      f"({n_over} overrides, {n_kw} keyword, {n_fb} fallback)")
