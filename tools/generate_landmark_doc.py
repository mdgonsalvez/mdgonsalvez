#!/usr/bin/env python3
"""Generate LANDMARK_CLUES.md from the real game data — every country's actual
landmark and the spoiler-free clue (emoji + phrase) the player is shown.

Parses BOTH CountryDatabase.swift (countries) and LandmarkArt.swift (overrides,
keyword rules, continent fallbacks) so the document always mirrors the code.
To regenerate, run `python3 tools/generate_landmark_doc.py` from the repo root."""
import re, datetime

DB = "PassportQuest/Data/CountryDatabase.swift"
ART = "PassportQuest/Data/LandmarkArt.swift"

art = open(ART, encoding="utf-8").read()

def section(name):
    """Return the text of a `let <name> ... = [ ... ]` block."""
    start = art.index(f"let {name}")
    open_br = art.index("= [", start) + 2   # skip the type annotation's own brackets
    depth, i = 0, open_br
    while i < len(art):
        if art[i] == "[": depth += 1
        elif art[i] == "]":
            depth -= 1
            if depth == 0: return art[open_br:i+1]
        i += 1
    return ""

# overrides:  "US": ("🗽", "a famous statue on an island"),
overrides = {m[0]: (m[1], m[2]) for m in
             re.findall(r'"([A-Z]{2})":\s*\("([^"]+)",\s*"([^"]+)"\)', section("overrides"))}
# keywordRules: ("pyramid", "🔺", "ancient pyramids"),
keyword_rules = re.findall(r'\("([^"]+)",\s*"([^"]+)",\s*"([^"]+)"\)', section("keywordRules"))
# continent fallback: case .europe: return ("🏛️", "a famous old landmark")
fallback = {m[0]: (m[1], m[2]) for m in
            re.findall(r'case\s+\.(\w+):\s*return\s*\("([^"]+)",\s*"([^"]+)"\)', art)}

CONT_NAMES = {"europe":"Europe","africa":"Africa","asia":"Asia","americas":"Americas",
              "oceania":"Oceania","polar":"Polar & Territories"}
CONT_ORDER = ["europe","asia","africa","americas","oceania","polar"]

def resolve(cid, landmark, cont):
    if cid in overrides:
        e, p = overrides[cid]; return e, p, "override"
    name = landmark.lower()
    for kw, e, p in keyword_rules:
        if kw in name:
            return e, p, f"keyword “{kw.strip()}”"
    e, p = fallback[cont]; return e, p, "continent fallback"

src = open(DB, encoding="utf-8").read()
pat = re.compile(r'Country\(id:\s*"(?P<id>[^"]+)",\s*name:\s*"(?P<name>[^"]+)"'
                 r'[\s\S]*?continent:\s*\.(?P<cont>\w+)'
                 r'[\s\S]*?landmarkName:\s*"(?P<lm>[^"]+)"')
rows = []
for m in pat.finditer(src):
    e, p, sourced = resolve(m["id"], m["lm"], m["cont"])
    rows.append((m["cont"], m["name"], m["id"], m["lm"], e, p, sourced))

by_cont = {}
for r in rows:
    by_cont.setdefault(r[0], []).append(r)

today = datetime.date.today().isoformat()
n_over = sum(1 for r in rows if r[6] == "override")
n_fb = sum(1 for r in rows if r[6] == "continent fallback")
n_kw = len(rows) - n_over - n_fb

out = ["# Passport Quest — Landmark Clues\n"]
out.append("Every country's **real landmark** (the answer, revealed on the stamp card) "
           "alongside the **spoiler-free Famous-Place clue** the player actually sees "
           "(emoji + phrase). The clue deliberately hides the landmark's real name, since "
           "the name usually gives away the country.\n")
out.append(f"Auto-generated from `CountryDatabase.swift` + `LandmarkArt.swift` on {today}. "
           f"**{len(rows)} countries.** To regenerate, run "
           "`python3 tools/generate_landmark_doc.py`.\n")
out.append("The **Clue source** column shows how each clue is chosen — a hand-written "
           "`override`, a `keyword` match on the landmark name, or a generic `continent "
           "fallback`.\n")
out.append(f"> **At a glance:** {n_over} hand-written overrides · {n_kw} keyword matches · "
           f"{n_fb} generic continent fallbacks.\n")

for c in CONT_ORDER:
    items = sorted(by_cont.get(c, []), key=lambda r: r[1])
    if not items: continue
    out.append(f"\n## {CONT_NAMES[c]}  ({len(items)})\n")
    out.append("| Country | Real landmark (answer) | Clue shown | Clue source |")
    out.append("|---|---|---|---|")
    for _, name, cid, lm, e, p, sourced in items:
        out.append(f"| {name} (`{cid}`) | {lm} | {e} {p} | {sourced} |")

open("LANDMARK_CLUES.md", "w", encoding="utf-8").write("\n".join(out) + "\n")
print(f"wrote LANDMARK_CLUES.md — {len(rows)} countries "
      f"({n_over} overrides, {n_kw} keyword, {n_fb} fallback)")
