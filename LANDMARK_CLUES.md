# Passport Quest — Landmark Clues

Every country's **real landmark** (the answer, revealed on the stamp card) alongside the **spoiler-free Famous-Place clue** the player actually sees (emoji + phrase). The clue deliberately hides the landmark's real name, since the name usually gives away the country.

Auto-generated from `CountryDatabase.swift` + `LandmarkArt.swift` on 2026-06-17. **200 countries.** To regenerate, run `python3 tools/generate_landmark_doc.py`.

The **Clue source** column shows how each clue is chosen — a hand-written `override`, a `keyword` match on the landmark name, or a generic `continent fallback`.

> **At a glance:** 85 hand-written overrides · 115 keyword matches · 0 generic continent fallbacks.


## Europe  (46)

| Country | Real landmark (answer) | Clue shown | Clue source |
|---|---|---|---|
| Albania (`AL`) | Berat Castle | 🏰 a grand castle | keyword “castle” |
| Andorra (`AD`) | Casa de la Vall | 🏛️ a historic stone parliament house in the mountains | override |
| Austria (`AT`) | Schönbrunn Palace | 🏰 a grand palace | keyword “palace” |
| Belarus (`BY`) | Mir Castle | 🏰 a grand castle | keyword “castle” |
| Belgium (`BE`) | Grand-Place, Brussels | 🍫 a grand old market square | override |
| Bosnia and Herzegovina (`BA`) | Stari Most (Old Bridge) | 🌉 a famous bridge | keyword “bridge” |
| Bulgaria (`BG`) | Rila Monastery | ⛪ an old cliffside monastery | keyword “monastery” |
| Croatia (`HR`) | Dubrovnik Old Town | 🏰 a walled seaside old town | override |
| Cyprus (`CY`) | Aphrodite's Rock | 🪨 a giant rock | keyword “rock” |
| Czechia (`CZ`) | Charles Bridge | 🌉 a famous bridge | keyword “bridge” |
| Denmark (`DK`) | The Little Mermaid | 🧜 a little mermaid statue by the harbour | override |
| Estonia (`EE`) | Tallinn Old Town | 🏰 a medieval old town full of towers | override |
| Finland (`FI`) | Helsinki Cathedral | ⛪ a grand cathedral | keyword “cathedral” |
| France (`FR`) | Eiffel Tower | 🗼 a famous iron tower | override |
| Germany (`DE`) | Brandenburg Gate | 🏛️ a grand columned city gate | override |
| Greece (`GR`) | Acropolis of Athens | 🏛️ ancient marble temples on a hill | override |
| Hungary (`HU`) | Hungarian Parliament Building | 🏛️ a vast riverside parliament palace | override |
| Iceland (`IS`) | Hallgrímskirkja | ⛪ a soaring rocket-shaped church | override |
| Ireland (`IE`) | Cliffs of Moher | 🌊 towering sea cliffs | override |
| Italy (`IT`) | Colosseum | 🏛️ a giant ancient arena | override |
| Kosovo (`XK`) | Gracanica Monastery | ⛪ an old cliffside monastery | keyword “monastery” |
| Latvia (`LV`) | House of the Black Heads | 🏛️ an ornate guild house on the town square | override |
| Liechtenstein (`LI`) | Vaduz Castle | 🏰 a grand castle | keyword “castle” |
| Lithuania (`LT`) | Trakai Island Castle | 🏰 a grand castle | keyword “castle” |
| Luxembourg (`LU`) | Bock Casemates | 🏰 tunnels carved into a fortress cliff | override |
| Malta (`MT`) | Megalithic Temples | 🛕 an ancient temple | keyword “temple” |
| Moldova (`MD`) | Mileștii Mici Wine Cellars | 🍇 the world's largest underground wine cellars | override |
| Monaco (`MC`) | Monte Carlo Casino | 🎰 a glamorous grand casino | override |
| Montenegro (`ME`) | Bay of Kotor | ⛵ a scenic bay | keyword “bay” |
| Netherlands (`NL`) | Kinderdijk Windmills | 🌷 fields full of tulips | override |
| North Macedonia (`MK`) | Lake Ohrid | 🏞️ a beautiful lake | keyword “lake” |
| Norway (`NO`) | Geirangerfjord | ⛵ a deep, steep fjord | keyword “fjord” |
| Poland (`PL`) | Wawel Castle | 🏰 a grand castle | keyword “castle” |
| Portugal (`PT`) | Belém Tower | 🗼 an old riverside watchtower | override |
| Romania (`RO`) | Bran Castle | 🏰 a grand castle | keyword “castle” |
| Russia (`RU`) | Saint Basil's Cathedral | ⛪ a cathedral with colourful onion domes | override |
| San Marino (`SM`) | Three Towers of San Marino | 🗼 a famous tower | keyword “tower” |
| Serbia (`RS`) | Belgrade Fortress | 🏰 an old fortress | keyword “fortress” |
| Slovakia (`SK`) | Bratislava Castle | 🏰 a grand castle | keyword “castle” |
| Slovenia (`SI`) | Lake Bled | 🏞️ a beautiful lake | keyword “lake” |
| Spain (`ES`) | Sagrada Família | ⛪ a giant fairy-tale church still being built | override |
| Sweden (`SE`) | Stockholm City Hall | 🏙️ a famous old city | keyword “city” |
| Switzerland (`CH`) | The Matterhorn | 🏔️ a pointed snowy peak | override |
| Ukraine (`UA`) | Saint Sophia Cathedral | ⛪ a grand cathedral | keyword “cathedral” |
| United Kingdom (`GB`) | Big Ben | 🕰️ a famous clock tower | override |
| Vatican City (`VA`) | St. Peter's Basilica | ⛪ a grand basilica | keyword “basilica” |

## Asia  (46)

| Country | Real landmark (answer) | Clue shown | Clue source |
|---|---|---|---|
| Afghanistan (`AF`) | Band-e-Amir Lakes | 🏞️ a beautiful lake | keyword “lake” |
| Armenia (`AM`) | Khor Virap Monastery | ⛪ an old cliffside monastery | keyword “monastery” |
| Azerbaijan (`AZ`) | Flame Towers | 🗼 a famous tower | keyword “tower” |
| Bahrain (`BH`) | Tree of Life | 🌳 a lone tree surviving in the desert | override |
| Bangladesh (`BD`) | Sundarbans | 🐅 a vast mangrove forest home to tigers | override |
| Bhutan (`BT`) | Tiger's Nest Monastery | ⛪ an old cliffside monastery | keyword “monastery” |
| Brunei (`BN`) | Sultan Omar Ali Saifuddien Mosque | 🕌 a beautiful mosque | keyword “mosque” |
| Cambodia (`KH`) | Angkor Wat | 🛕 a huge ancient temple | override |
| China (`CN`) | Great Wall of China | 🧱 a wall thousands of miles long | override |
| Georgia (`GE`) | Gergeti Trinity Church | ⛪ a historic church | keyword “church” |
| India (`IN`) | Taj Mahal | 🕌 a white marble palace of love | override |
| Indonesia (`ID`) | Borobudur Temple | 🛕 a huge ancient stone temple | override |
| Iran (`IR`) | Persepolis | 🏛️ ancient ceremonial ruins of a great empire | override |
| Iraq (`IQ`) | Great Mosque of Samarra | 🕌 a beautiful mosque | keyword “mosque” |
| Israel (`IL`) | Western Wall | 🧱 a great long wall | keyword “wall” |
| Japan (`JP`) | Mount Fuji | 🗻 a snow-capped sacred mountain | override |
| Jordan (`JO`) | Petra | 🏜️ a city carved into pink rock | override |
| Kazakhstan (`KZ`) | Bayterek Tower | 🗼 a famous tower | keyword “tower” |
| Kuwait (`KW`) | Kuwait Towers | 🗼 a famous tower | keyword “tower” |
| Kyrgyzstan (`KG`) | Issyk-Kul Lake | 🏞️ a beautiful lake | keyword “lake” |
| Laos (`LA`) | Kuang Si Falls | 💧 a mighty waterfall | keyword “falls” |
| Lebanon (`LB`) | Cedars of God | 🌲 an ancient grove of cedar trees | override |
| Malaysia (`MY`) | Petronas Towers | 🏙️ famous twin towers | override |
| Maldives (`MV`) | Coral Atolls | 🏝️ ring-shaped coral islands | keyword “atoll” |
| Mongolia (`MN`) | Genghis Khan Statue | 🗽 a famous statue | keyword “statue” |
| Myanmar (`MM`) | Shwedagon Pagoda | 🛕 a golden pagoda | keyword “pagoda” |
| Nepal (`NP`) | Mount Everest | 🏔️ the world's tallest mountain | override |
| North Korea (`KP`) | Juche Tower | 🗼 a famous tower | keyword “tower” |
| Oman (`OM`) | Sultan Qaboos Grand Mosque | 🕌 a beautiful mosque | keyword “mosque” |
| Pakistan (`PK`) | Badshahi Mosque | 🕌 a beautiful mosque | keyword “mosque” |
| Philippines (`PH`) | Chocolate Hills | ⛰️ hundreds of round green hills | override |
| Qatar (`QA`) | Museum of Islamic Art | 🕌 a striking modern museum of Islamic art | override |
| Saudi Arabia (`SA`) | Kingdom Centre, Riyadh | 🕋 a holy black cube building | override |
| Singapore (`SG`) | Marina Bay Sands | 🏙️ a city of giant 'supertrees' | override |
| South Korea (`KR`) | Gyeongbokgung Palace | 🏯 a grand royal palace | override |
| Sri Lanka (`LK`) | Sigiriya Rock | 🪨 a giant rock | keyword “rock” |
| Syria (`SY`) | Palmyra | 🏛️ ancient desert ruins of a caravan city | override |
| Tajikistan (`TJ`) | Pamir Mountains | 🏔️ a famous mountain | keyword “mountain” |
| Thailand (`TH`) | Grand Palace, Bangkok | 🛕 a glittering royal palace | override |
| Timor-Leste (`TL`) | Cristo Rei of Dili | 🗽 a tall hilltop statue overlooking the sea | override |
| Turkey (`TR`) | Hagia Sophia | 🕌 a giant domed cathedral-mosque | override |
| Turkmenistan (`TM`) | Darvaza Gas Crater | 🌋 a giant crater | keyword “crater” |
| United Arab Emirates (`AE`) | Burj Khalifa | 🏙️ the world's tallest skyscraper | override |
| Uzbekistan (`UZ`) | Registan, Samarkand | 🕌 grand tiled domes and towers on an old square | override |
| Vietnam (`VN`) | Ha Long Bay | ⛵ a scenic bay | keyword “bay” |
| Yemen (`YE`) | Old City of Sana'a | 🏙️ a famous old city | keyword “city” |

## Africa  (54)

| Country | Real landmark (answer) | Clue shown | Clue source |
|---|---|---|---|
| Algeria (`DZ`) | Tassili n'Ajjer | 🏜️ ancient rock art in the desert | override |
| Angola (`AO`) | Kalandula Falls | 💧 a mighty waterfall | keyword “falls” |
| Benin (`BJ`) | Ganvie Stilt Village | 🛖 a village of houses on stilts over water | override |
| Botswana (`BW`) | Okavango Delta | 🏞️ a watery wildlife delta | keyword “delta” |
| Burkina Faso (`BF`) | Sindou Peaks | 🏔️ a high mountain peak | keyword “peak” |
| Burundi (`BI`) | Lake Tanganyika | 🏞️ a beautiful lake | keyword “lake” |
| Cabo Verde (`CV`) | Pico do Fogo | 🌋 an island volcano | override |
| Cameroon (`CM`) | Mount Cameroon | 🏔️ a famous mountain | keyword “mount” |
| Central African Republic (`CF`) | Dzanga-Sangha Reserve | 🌳 a wildlife reserve | keyword “reserve” |
| Chad (`TD`) | Ennedi Plateau | ⛰️ a dramatic plateau | keyword “plateau” |
| Comoros (`KM`) | Mount Karthala | 🏔️ a famous mountain | keyword “mount” |
| Côte d'Ivoire (`CI`) | Basilica of Our Lady of Peace | ⛪ a grand basilica | keyword “basilica” |
| DR Congo (`CD`) | Virunga National Park | 🌳 a wild national park | keyword “park” |
| Djibouti (`DJ`) | Lake Assal | 🏞️ a beautiful lake | keyword “lake” |
| Egypt (`EG`) | Pyramids of Giza | 🔺 ancient giant pyramids | override |
| Equatorial Guinea (`GQ`) | Pico Basile | 🌋 a tall volcanic peak | override |
| Eritrea (`ER`) | Asmara Art Deco City | 🏙️ a famous old city | keyword “city” |
| Eswatini (`SZ`) | Hlane Royal National Park | 🌳 a wild national park | keyword “park” |
| Ethiopia (`ET`) | Rock-Hewn Churches of Lalibela | ⛪ a historic church | keyword “church” |
| Gabon (`GA`) | Loango National Park | 🌳 a wild national park | keyword “park” |
| Ghana (`GH`) | Cape Coast Castle | 🏰 a grand castle | keyword “castle” |
| Guinea (`GN`) | Mount Nimba | 🏔️ a famous mountain | keyword “mount” |
| Guinea-Bissau (`GW`) | Bijagós Archipelago | 🏝️ a chain of islands | keyword “archipelago” |
| Kenya (`KE`) | Maasai Mara | 🦁 a savanna full of wild animals | override |
| Lesotho (`LS`) | Maletsunyane Falls | 💧 a mighty waterfall | keyword “falls” |
| Liberia (`LR`) | Sapo National Park | 🌳 a wild national park | keyword “park” |
| Libya (`LY`) | Leptis Magna | 🏛️ grand ancient Roman ruins | override |
| Madagascar (`MG`) | Avenue of the Baobabs | 🌳 a road lined with giant baobab trees | override |
| Malawi (`MW`) | Lake Malawi | 🏞️ a beautiful lake | keyword “lake” |
| Mali (`ML`) | Great Mosque of Djenné | 🕌 a beautiful mosque | keyword “mosque” |
| Mauritania (`MR`) | Richat Structure (Eye of the Sahara) | 🏜️ vast desert sands | keyword “sahara” |
| Mauritius (`MU`) | Le Morne Brabant | ⛰️ a dramatic mountain by the sea | override |
| Morocco (`MA`) | Jemaa el-Fnaa, Marrakech | 🛍️ a huge bustling market square | override |
| Mozambique (`MZ`) | Bazaruto Archipelago | 🏝️ a chain of islands | keyword “archipelago” |
| Namibia (`NA`) | Sossusvlei Dunes | 🏜️ giant sand dunes | keyword “dunes” |
| Niger (`NE`) | Aïr Mountains | 🏔️ a famous mountain | keyword “mountain” |
| Nigeria (`NG`) | Zuma Rock | 🪨 a giant rock | keyword “rock” |
| Republic of the Congo (`CG`) | Nouabalé-Ndoki National Park | 🌳 a wild national park | keyword “park” |
| Rwanda (`RW`) | Volcanoes National Park | 🌋 a smoking volcano | keyword “volcano” |
| Senegal (`SN`) | African Renaissance Monument | 🗽 a giant bronze monument of a family | override |
| Seychelles (`SC`) | Anse Source d'Argent | 🏝️ a beach with giant granite boulders | override |
| Sierra Leone (`SL`) | Tacugama Chimpanzee Sanctuary | 🐒 a wildlife sanctuary | keyword “sanctuary” |
| Somalia (`SO`) | Laas Geel Cave Paintings | 🕳️ amazing caves | keyword “cave” |
| South Africa (`ZA`) | Table Mountain | ⛰️ a famous flat-topped mountain | override |
| South Sudan (`SS`) | Boma National Park | 🌳 a wild national park | keyword “park” |
| Sudan (`SD`) | Pyramids of Meroë | 🔺 ancient pyramids | keyword “pyramid” |
| São Tomé and Príncipe (`ST`) | Pico Cão Grande | ⛰️ a towering needle-shaped rock peak | override |
| Tanzania (`TZ`) | Mount Kilimanjaro | 🏔️ the tallest mountain in Africa | override |
| The Gambia (`GM`) | Kunta Kinteh Island | 🏝️ beautiful islands | keyword “island” |
| Togo (`TG`) | Koutammakou | 🛖 traditional mud tower-houses | override |
| Tunisia (`TN`) | Carthage Ruins | 🏛️ ancient ruins | keyword “ruins” |
| Uganda (`UG`) | Bwindi Impenetrable Forest | 🌳 a wild rainforest | keyword “forest” |
| Zambia (`ZM`) | Victoria Falls | 💧 a mighty waterfall | keyword “falls” |
| Zimbabwe (`ZW`) | Victoria Falls | 💧 a mighty waterfall | keyword “falls” |

## Americas  (35)

| Country | Real landmark (answer) | Clue shown | Clue source |
|---|---|---|---|
| Antigua and Barbuda (`AG`) | Nelson's Dockyard | ⛵ a historic harbour and dockyard | override |
| Argentina (`AR`) | Perito Moreno Glacier | 🧊 a giant glacier | keyword “glacier” |
| Bahamas (`BS`) | Exuma Cays | 🏝️ tiny tropical islands | keyword “cays” |
| Barbados (`BB`) | Harrison's Cave | 🕳️ amazing caves | keyword “cave” |
| Belize (`BZ`) | Great Blue Hole | 🕳️ a giant deep-blue ocean sinkhole | override |
| Bolivia (`BO`) | Salar de Uyuni | 🧂 a vast white salt flat | override |
| Brazil (`BR`) | Christ the Redeemer | ⛰️ a giant statue on a mountain | override |
| Canada (`CA`) | Niagara Falls | 💧 a mighty waterfall | keyword “falls” |
| Chile (`CL`) | Easter Island Moai | 🗿 giant carved stone heads | override |
| Colombia (`CO`) | Caño Cristales | 🏞️ a river that runs five colours | override |
| Costa Rica (`CR`) | Arenal Volcano | 🌋 a smoking volcano | keyword “volcano” |
| Cuba (`CU`) | Old Havana | 🚗 colourful classic 1950s cars | override |
| Dominica (`DM`) | Boiling Lake | 🏞️ a beautiful lake | keyword “lake” |
| Dominican Republic (`DO`) | Colonial Zone, Santo Domingo | 🏛️ the oldest colonial old town in the Americas | override |
| Ecuador (`EC`) | Galápagos Islands | 🏝️ beautiful islands | keyword “island” |
| El Salvador (`SV`) | Santa Ana Volcano | 🌋 a smoking volcano | keyword “volcano” |
| Grenada (`GD`) | Underwater Sculpture Park | 🛕 a huge temple complex | keyword “wat” |
| Guatemala (`GT`) | Tikal | 🛕 ancient pyramid temples in the jungle | override |
| Guyana (`GY`) | Kaieteur Falls | 💧 a mighty waterfall | keyword “falls” |
| Haiti (`HT`) | Citadelle Laferrière | 🏰 a hilltop citadel | keyword “citadel” |
| Honduras (`HN`) | Copán Ruins | 🏛️ ancient ruins | keyword “ruins” |
| Jamaica (`JM`) | Dunn's River Falls | 💧 a mighty waterfall | keyword “falls” |
| Mexico (`MX`) | Chichén Itzá | 🛕 a step-pyramid temple | override |
| Nicaragua (`NI`) | Cerro Negro Volcano | 🌋 a smoking volcano | keyword “volcano” |
| Panama (`PA`) | Panama Canal | 🚢 a famous canal joining two oceans | override |
| Paraguay (`PY`) | Itaipú Dam | 🌊 a huge dam | keyword “dam” |
| Peru (`PE`) | Machu Picchu | ⛰️ a lost city high in the mountains | override |
| Saint Kitts and Nevis (`KN`) | Brimstone Hill Fortress | 🏰 an old fortress | keyword “fortress” |
| Saint Lucia (`LC`) | The Pitons | ⛰️ two pointed volcanic peaks by the sea | override |
| Saint Vincent and the Grenadines (`VC`) | Tobago Cays | 🏝️ tiny tropical islands | keyword “cays” |
| Suriname (`SR`) | Central Suriname Nature Reserve | 🌳 a wildlife reserve | keyword “reserve” |
| Trinidad and Tobago (`TT`) | Pitch Lake | 🏞️ a beautiful lake | keyword “lake” |
| United States (`US`) | Statue of Liberty | 🗽 a famous statue on an island | override |
| Uruguay (`UY`) | Punta del Este | 🏖️ a beach resort with a giant hand sculpture | override |
| Venezuela (`VE`) | Angel Falls | 💧 a mighty waterfall | keyword “falls” |

## Oceania  (14)

| Country | Real landmark (answer) | Clue shown | Clue source |
|---|---|---|---|
| Australia (`AU`) | Sydney Opera House | 🎭 a famous opera house on the harbour | override |
| Fiji (`FJ`) | Mamanuca Islands | 🏝️ beautiful islands | keyword “island” |
| Kiribati (`KI`) | Phoenix Islands | 🏝️ beautiful islands | keyword “island” |
| Marshall Islands (`MH`) | Bikini Atoll | 🏝️ ring-shaped coral islands | keyword “atoll” |
| Micronesia (`FM`) | Nan Madol | 🛕 an ancient stone city built on water | override |
| Nauru (`NR`) | Buada Lagoon | 🏝️ a turquoise lagoon | keyword “lagoon” |
| New Zealand (`NZ`) | Milford Sound | 🏔️ a stunning fjord between steep cliffs | override |
| Palau (`PW`) | Jellyfish Lake | 🏞️ a beautiful lake | keyword “lake” |
| Papua New Guinea (`PG`) | Kokoda Track | 🥾 a rugged jungle mountain trail | override |
| Samoa (`WS`) | To Sua Ocean Trench | 🏝️ a deep turquoise swimming hole | override |
| Solomon Islands (`SB`) | Marovo Lagoon | 🏝️ a turquoise lagoon | keyword “lagoon” |
| Tonga (`TO`) | Haʻamonga ʻa Maui | 🗿 an ancient giant stone archway | override |
| Tuvalu (`TV`) | Funafuti Lagoon | 🏝️ a turquoise lagoon | keyword “lagoon” |
| Vanuatu (`VU`) | Mount Yasur Volcano | 🌋 a smoking volcano | keyword “volcano” |

## Polar & Territories  (5)

| Country | Real landmark (answer) | Clue shown | Clue source |
|---|---|---|---|
| Antarctica (`AQ`) | South Pole Research Station | ❄️ a research base at the bottom of the world | override |
| Faroe Islands (`FO`) | Múlafossur Waterfall | 🛕 a huge temple complex | keyword “wat” |
| Greenland (`GL`) | Ilulissat Icefjord | ⛵ a deep, steep fjord | keyword “fjord” |
| South Georgia (`GS`) | Grytviken | 🐧 an old whaling station among penguins | override |
| Svalbard (`SJ`) | Global Seed Vault | 🌱 a vault storing the world's seeds in the ice | override |
