# Domain Model – Fitness Platform (v0.3)

Identificatorii (tabele, câmpuri) sunt în engleză, descrierile în română.
**Statut:** v0.3 – actualizat după deciziile din secțiunea 9. Întrebările rămase deschise sunt în secțiunea 10.

---

## 1. Convenții generale

| Subiect | Decizie |
|---|---|
| ID-uri | `UUID` (`id uuid primary key`) |
| Timp | `timestamptz`, stocat în UTC; conversia la fusul orar în client |
| Câmpuri comune | `created_at`, `updated_at` pe toate tabelele; `deleted_at` (soft delete) doar pe conținutul gestionat de coach (exerciții, șabloane, rețete). **Datele clientului se șterg definitiv la ștergerea contului** (vezi 8.2) |
| Unități | Sistem metric în DB (`kg`, `cm`, `g`, `kcal`); conversia în UI |
| Enum-uri | `varchar` + `CHECK` (mai ușor de migrat decât tipurile enum native) |
| Nume tabele | `snake_case`, singular. **`USER` este cuvânt rezervat în PostgreSQL → tabela se numește `app_user`** |
| Migrări | Doar Flyway. `ddl-auto` = `validate` |
| Valori nutriționale | **Doar macro** (kcal, proteine, carbohidrați, grăsimi), per 100 g în `food`; la logare se salvează *snapshot* |
| Planuri finalizate | **Imutabile**: ce a finalizat clientul nu se mai modifică (vezi 7.1) |
| Offline mobil | Nu este necesar |
| Limbi | Română și engleză (`app_user.locale` = `ro` / `en`); vezi 8.1 |
| Storage fișiere | Doar pozele de progres (S3-compatibil; MinIO local). Fără atașamente în mesaje |
| Timp real | WebSocket pentru mesagerie (și notificări în aplicație) |

---

## 2. Identitate și relația coach–client

Un utilizator are **un singur rol** (`COACH`, `CLIENT` sau `ADMIN`). Un client are **un singur coach activ**. Nu există organizații.

### app_user
| Câmp | Tip | Note |
|---|---|---|
| id | uuid PK | |
| email | varchar, unique | |
| password_hash | varchar | |
| role | varchar | `COACH`, `CLIENT`, `ADMIN` |
| first_name, last_name | varchar | |
| locale | varchar | `ro` sau `en` |
| timezone | varchar | |
| status | varchar | `PENDING`, `ACTIVE`, `SUSPENDED` |
| email_verified_at, last_login_at | timestamptz, null | |

### coach_profile (1–1 cu app_user, role = COACH)
| Câmp | Tip | Note |
|---|---|---|
| user_id | uuid PK/FK → app_user | |
| bio | text, null | |
| specializations | text[] | |

### coach_client
| Câmp | Tip | Note |
|---|---|---|
| id | uuid PK | |
| coach_id | uuid FK → app_user | |
| client_id | uuid FK → app_user | |
| status | varchar | `INVITED`, `ACTIVE`, `PAUSED`, `ENDED` |
| invited_at, started_at, ended_at | timestamptz | |

**Constrângere:** partial unique index pe `client_id` unde `status IN ('INVITED','ACTIVE','PAUSED')` → un client are cel mult o relație curentă. Istoricul (`ENDED`) se păstrează.

---

## 3. Profil client

### client_profile (1–1 cu app_user, role = CLIENT)
| Câmp | Tip | Note |
|---|---|---|
| user_id | uuid PK/FK → app_user | |
| birth_date | date | necesar pentru formulele BMR |
| sex | varchar | necesar pentru formulele BMR |
| height_cm | numeric(5,1) | |
| activity_level | varchar | `SEDENTARY`, `LIGHT`, `MODERATE`, `ACTIVE`, `VERY_ACTIVE` |
| bmr_formula | varchar | formula aleasă pentru acest client (vezi `calculation`); implicit `MIFFLIN_ST_JEOR` |
| dietary_preference | varchar, null | ex. `VEGETARIAN` |

### medical_info  *(simplificat: informații generale, ex. accidentări)*
Câmp de informații generale utile antrenorului. **Nu** se colectează date medicale personale detaliate. Vizibil doar clientului și coach-ului curent.
| Câmp | Tip | Note |
|---|---|---|
| id | uuid PK | |
| client_id | uuid FK → client_profile | |
| type | varchar | `INJURY`, `LIMITATION`, `OTHER` |
| description | text | text liber, scurt |
| since_date | date, null | |
| active | boolean | |

### goal
| Câmp | Tip | Note |
|---|---|---|
| id | uuid PK | |
| client_id | uuid FK | |
| type | varchar | `WEIGHT_LOSS`, `MUSCLE_GAIN`, `MAINTENANCE`, `PERFORMANCE`, `CUSTOM` |
| start_value, target_value, unit | numeric, numeric, varchar | |
| target_date | date, null | |
| status | varchar | `ACTIVE`, `ACHIEVED`, `ABANDONED` |
| set_by | uuid FK → app_user | |

### progress_measurement
| Câmp | Tip | Note |
|---|---|---|
| id | uuid PK | |
| client_id | uuid FK | |
| measured_at | timestamptz | |
| weight_kg | numeric(5,2), null | |
| body_fat_pct | numeric(4,1), null | necesar pentru formulele Katch-McArdle / Cunningham |
| circumferences | jsonb, null | `{waist, hips, chest, arm, thigh}` în cm |
| notes | text, null | |

### progress_photo
Pozele de progres sunt stocate în storage extern; în DB rămâne doar referința. Se șterg definitiv odată cu contul (vezi 8.2).
| Câmp | Tip | Note |
|---|---|---|
| id | uuid PK | |
| client_id | uuid FK → client_profile | |
| measurement_id | uuid, null FK → progress_measurement | |
| storage_key | varchar | cheia obiectului în storage |
| angle | varchar, null | `FRONT`, `SIDE`, `BACK` |
| taken_at | timestamptz | |

Vizibile doar clientului și coach-ului curent; accesul se face prin URL-uri semnate cu expirare scurtă, nu prin linkuri publice.

### nutrition_target
| Câmp | Tip | Note |
|---|---|---|
| id | uuid PK | |
| client_id | uuid FK | |
| valid_from, valid_to | date | `valid_to` null = în vigoare; istoricul se păstrează |
| kcal | int | |
| protein_g, carbs_g, fat_g | numeric | |
| set_by | uuid FK → app_user | |
| origin | varchar | `CALCULATED`, `MANUAL_OVERRIDE` |

### calculation
Trasabilitatea modului în care s-a obținut ținta.
| Câmp | Tip | Note |
|---|---|---|
| id | uuid PK | |
| nutrition_target_id | uuid FK | |
| formula | varchar | `MIFFLIN_ST_JEOR`, `HARRIS_BENEDICT_ORIGINAL`, `HARRIS_BENEDICT_REVISED`, `KATCH_MCARDLE`, `CUNNINGHAM`, `SCHOFIELD`, `OXFORD` |
| inputs | jsonb | greutate, înălțime, vârstă, sex, activitate, % grăsime, obiectiv |
| bmr, tdee | numeric | |
| goal_adjustment_kcal | numeric | deficit/surplus |
| macro_split | jsonb | |
| calculated_at | timestamptz | |

**Reguli:** formula se alege per client (`client_profile.bmr_formula`). `KATCH_MCARDLE` și `CUNNINGHAM` cer `body_fat_pct` din ultima `progress_measurement`; dacă lipsește, API-ul întoarce eroare de validare cu mesaj clar. Logica de calcul stă într-un serviciu dedicat, cu teste unitare pe fiecare formulă.

---

## 4. Alimente și rețete

Ierarhie: `food` (generic) → `food_product` (produs de marcă) → `barcode`.

### food
| Câmp | Tip | Note |
|---|---|---|
| id | uuid PK | |
| name | varchar | |
| category | varchar, null | |
| kcal_100g, protein_100g, carbs_100g, fat_100g | numeric | doar macro |
| serving_g | numeric, null | |
| source | varchar | `SYSTEM`, `COACH`, `IMPORT` |
| owner_id | uuid, null FK → app_user | null = global |

### food_product
| Câmp | Tip | Note |
|---|---|---|
| id | uuid PK | |
| food_id | uuid FK → food | |
| brand, product_name | varchar | |
| package_size_g | numeric, null | |
| external_source | varchar, null | ex. `OPEN_FOOD_FACTS` |
| external_id | varchar, null | |

### barcode
| Câmp | Tip | Note |
|---|---|---|
| id | uuid PK | |
| food_product_id | uuid FK | |
| code | varchar, unique | EAN-13 / UPC |
| format | varchar | `EAN13`, `EAN8`, `UPC_A` |

**Flux de scanare cod de bare:**
1. Clientul scanează codul → API caută în `barcode`.
2. Dacă există local → întoarce produsul cu valorile nutriționale.
3. Dacă nu → interoghează sursa externă (ex. Open Food Facts; verifică licența și condițiile de utilizare), creează `food` + `food_product` + `barcode` cu `source = IMPORT`, apoi întoarce rezultatul.
4. Dacă nu există nici extern → clientul/coach-ul poate introduce manual produsul.

*Notă:* scanarea cu camera funcționează bine pe aplicația mobilă; pe Flutter web camera e mai limitată, deci pe web se oferă introducere manuală a codului.

### recipe
| Câmp | Tip | Note |
|---|---|---|
| id | uuid PK | |
| owner_id | uuid FK → app_user | |
| title | varchar | |
| language | varchar | `ro` sau `en` (limba în care e scrisă rețeta) |
| description, instructions | text | |
| servings | int | |
| prep_minutes, cook_minutes | int, null | |
| visibility | varchar | `PRIVATE`, `SHARED_WITH_CLIENTS` |
| kcal, protein_g, carbs_g, fat_g | numeric | per porție, recalculat la modificare |

### recipe_ingredient
| Câmp | Tip | Note |
|---|---|---|
| id | uuid PK | |
| recipe_id | uuid FK | |
| food_id | uuid FK → food | |
| quantity_g | numeric | gramaj |
| kcal, protein_g, carbs_g, fat_g | numeric | valori pentru gramajul respectiv |
| position | int | |

---

## 5. Jurnal alimentar

### food_diary  *(unul per client per zi)*
| Câmp | Tip | Note |
|---|---|---|
| id | uuid PK | |
| client_id | uuid FK | |
| date | date | unique (client_id, date) |
| notes | text, null | |

### food_diary_entry
| Câmp | Tip | Note |
|---|---|---|
| id | uuid PK | |
| diary_id | uuid FK | |
| meal_type | varchar | `BREAKFAST`, `LUNCH`, `DINNER`, `SNACK` |
| food_id / food_product_id / recipe_id / meal_recipe_id | uuid, null | exact unul completat (CHECK); `meal_recipe_id` = rețeta din plan, cu modificările clientului |
| quantity_g | numeric | |
| kcal, protein_g, carbs_g, fat_g | numeric | **snapshot** la momentul logării |
| meal_id | uuid, null FK → meal | dacă urmează planul |
| logged_at | timestamptz | |

---

## 6. Plan alimentar

Ierarhie: `meal_plan` → `meal_plan_day` → `meal` → `meal_recipe` → `meal_recipe_ingredient`.

### meal_plan
| Câmp | Tip | Note |
|---|---|---|
| id | uuid PK | |
| coach_id | uuid FK → app_user | |
| client_id | uuid, null FK → app_user | null = șablon |
| name | varchar | |
| is_template | boolean | |
| source_template_id | uuid, null FK → meal_plan | dacă e copie din șablon |
| start_date, end_date | date, null | |
| status | varchar | `DRAFT`, `ACTIVE`, `COMPLETED`, `ARCHIVED` |
| nutrition_target_id | uuid, null FK | |

### meal_plan_day
| Câmp | Tip | Note |
|---|---|---|
| id | uuid PK | |
| meal_plan_id | uuid FK | |
| day_index | int | 1..N |
| notes | text, null | |

### meal
| Câmp | Tip | Note |
|---|---|---|
| id | uuid PK | |
| meal_plan_day_id | uuid FK | |
| meal_type | varchar | |
| name | varchar, null | |
| time_of_day | time, null | |
| position | int | |

### meal_recipe
| Câmp | Tip | Note |
|---|---|---|
| id | uuid PK | |
| meal_id | uuid FK | |
| recipe_id | uuid FK → recipe | rețeta originală, **neschimbată** |
| servings | numeric | |
| is_customized | boolean | true dacă clientul a modificat ingredientele |

### meal_recipe_ingredient  *(copia editabilă a ingredientelor)*
Când o rețetă intră într-o masă, ingredientele ei se **copiază** aici. Clientul poate scoate, modifica gramajul sau adăuga ingrediente fără să afecteze rețeta originală.
| Câmp | Tip | Note |
|---|---|---|
| id | uuid PK | |
| meal_recipe_id | uuid FK | |
| food_id | uuid FK → food | |
| source_recipe_ingredient_id | uuid, null FK | null = ingredient adăugat de client |
| quantity_g | numeric | gramaj curent |
| original_quantity_g | numeric, null | gramaj din rețeta originală (pentru comparație) |
| is_removed | boolean | scos de client |
| kcal, protein_g, carbs_g, fat_g | numeric | recalculat la fiecare modificare |
| modified_by | uuid, null FK → app_user | |
| modified_at | timestamptz, null | |

Totalul masei = suma ingredientelor unde `is_removed = false`.

**Vizibilitate coach:** modificările clientului sunt libere (fără aprobare), dar coach-ul le vede: API-ul expune diferența dintre `original_quantity_g` și `quantity_g`, ingredientele scoase și cele adăugate, iar coach-ul primește o notificare `RECIPE_CUSTOMIZED`.

---

## 7. Antrenamente

Ierarhie: `workout_plan` → `workout` → `workout_exercise` → `workout_set`.

### exercise
| Câmp | Tip | Note |
|---|---|---|
| id | uuid PK | |
| name | varchar | |
| primary_muscle_group | varchar | |
| secondary_muscle_groups | text[] | |
| equipment | varchar, null | |
| instructions | text | |
| video_url | varchar, null | |
| owner_id | uuid, null FK → app_user | null = global |

Exercițiile se șterg doar *soft* (`deleted_at`), ca istoricul antrenamentelor să rămână intact.

### workout_plan
| Câmp | Tip | Note |
|---|---|---|
| id | uuid PK | |
| coach_id | uuid FK → app_user | |
| client_id | uuid, null FK → app_user | null = șablon |
| name | varchar | |
| is_template | boolean | |
| source_template_id | uuid, null FK → workout_plan | |
| start_date, end_date | date, null | |
| status | varchar | `DRAFT`, `ACTIVE`, `COMPLETED`, `ARCHIVED` |

**Flux:** coach-ul creează un șablon → „Atribuie clientului" face o **copie profundă** (plan, antrenamente, exerciții, seturi) cu `client_id` setat și `source_template_id` → coach-ul editează copia pentru clientul respectiv. Editarea copiei nu afectează șablonul.

### workout
| Câmp | Tip | Note |
|---|---|---|
| id | uuid PK | |
| workout_plan_id | uuid FK | |
| name | varchar | |
| day_index | int, null | |
| scheduled_date | date, null | |
| status | varchar | `PLANNED`, `IN_PROGRESS`, `COMPLETED`, `SKIPPED` |
| started_at, completed_at | timestamptz, null | |
| client_notes | text, null | |
| perceived_exertion | smallint, null | RPE 1–10 |

### workout_exercise
| Câmp | Tip | Note |
|---|---|---|
| id | uuid PK | |
| workout_id | uuid FK | |
| exercise_id | uuid FK | |
| position | int | |
| superset_group | int, null | |
| rest_seconds | int, null | |
| coach_notes | text, null | |

### workout_set
| Câmp | Tip | Note |
|---|---|---|
| id | uuid PK | |
| workout_exercise_id | uuid FK | |
| set_number | int | |
| set_type | varchar | `WARMUP`, `WORKING`, `DROP`, `FAILURE` |
| planned_reps, planned_weight_kg, planned_rpe | int, numeric, numeric, null | |
| actual_reps, actual_weight_kg, actual_rpe | int, numeric, numeric, null | completate de client |
| completed_at | timestamptz, null | |

### 7.1 Regula de imutabilitate
- Un `workout` cu `status = COMPLETED` (împreună cu `workout_exercise` și `workout_set` aferente) **nu mai poate fi modificat** de coach sau client. Se impune în service layer și se acoperă cu teste.
- Editările unui plan activ se aplică doar antrenamentelor `PLANNED` / viitoare.
- Astfel istoricul rămâne fidel pentru calculul progresului.

---

## 8. Interacțiune și transversale

### task
| Câmp | Tip | Note |
|---|---|---|
| id | uuid PK | |
| client_id, coach_id | uuid FK → app_user | |
| title | varchar | |
| description | text, null | |
| due_at | timestamptz, null | |
| status | varchar | `OPEN`, `DONE`, `CANCELLED` |
| completed_at | timestamptz, null | |

### feedback  *(doar clientul evaluează antrenamentul, cu stele)*
| Câmp | Tip | Note |
|---|---|---|
| id | uuid PK | |
| workout_id | uuid FK → workout, **unique** | un singur feedback per antrenament |
| client_id, coach_id | uuid FK → app_user | |
| rating | smallint | `CHECK (rating BETWEEN 1 AND 5)` |
| comment | text, null | opțional |
| created_at | timestamptz | |

Se poate crea doar după ce antrenamentul este `COMPLETED`.

### message  *(mesagerie client–coach)*
Mesajele aparțin relației `coach_client`; dacă relația se încheie și clientul își schimbă coach-ul, noua relație începe o conversație nouă.

**Timp real:** livrare prin WebSocket (Spring WebSocket + STOMP). Autentificarea JWT se verifică la handshake, iar la fiecare abonare/trimitere se verifică că utilizatorul face parte din `coach_client`-ul respectiv. Mesajele se salvează întotdeauna în DB înainte de livrare; un utilizator offline le primește la reconectare și printr-o notificare.
| Câmp | Tip | Note |
|---|---|---|
| id | uuid PK | |
| coach_client_id | uuid FK → coach_client | |
| sender_id | uuid FK → app_user | |
| body | text | |
| sent_at | timestamptz | |
| read_at | timestamptz, null | |

### calendar_event
| Câmp | Tip | Note |
|---|---|---|
| id | uuid PK | |
| coach_id | uuid FK → app_user | |
| client_id | uuid, null FK → app_user | null = eveniment personal / blocare program |
| type | varchar | `APPOINTMENT`, `WORKOUT`, `BLOCKED`, `REMINDER` |
| title | varchar | |
| start_at, end_at | timestamptz | |
| all_day | boolean | |
| recurrence_rule | varchar, null | RRULE |

### appointment  *(1–1 cu calendar_event de tip APPOINTMENT)*
| Câmp | Tip | Note |
|---|---|---|
| id | uuid PK | |
| calendar_event_id | uuid FK, unique | |
| status | varchar | `REQUESTED`, `CONFIRMED`, `CANCELLED`, `COMPLETED`, `NO_SHOW` |
| mode | varchar | `IN_PERSON`, `ONLINE` |
| location_or_link | varchar, null | |
| cancelled_by | uuid, null FK | |
| cancel_reason | text, null | |

### reschedule_request
| Câmp | Tip | Note |
|---|---|---|
| id | uuid PK | |
| appointment_id | uuid FK | |
| requested_by | uuid FK → app_user | |
| proposed_start_at, proposed_end_at | timestamptz | |
| reason | text, null | |
| status | varchar | `PENDING`, `ACCEPTED`, `REJECTED`, `EXPIRED` |
| responded_at | timestamptz, null | |

### notification
| Câmp | Tip | Note |
|---|---|---|
| id | uuid PK | |
| user_id | uuid FK | |
| type | varchar | ex. `WORKOUT_ASSIGNED`, `MESSAGE_RECEIVED`, `RECIPE_CUSTOMIZED`, `RESCHEDULE_REQUESTED` |
| payload | jsonb | |
| channel | varchar | `IN_APP`, `EMAIL`, `PUSH` |
| read_at, sent_at | timestamptz, null | |

### audit_log  *(append-only)*
| Câmp | Tip | Note |
|---|---|---|
| id | uuid PK | |
| actor_user_id | uuid, null FK | null = sistem |
| action | varchar | `CREATE`, `UPDATE`, `DELETE`, `LOGIN`, `EXPORT`, `ACCESS_MEDICAL_INFO` |
| entity_type, entity_id | varchar, uuid | |
| subject_user_id | uuid, null | |
| ip_address | inet, null | |
| details | jsonb, null | |
| occurred_at | timestamptz | |

---

## 8.1 Traduceri (română / engleză)

- **Interfața:** fișiere de localizare în Flutter (`ro`, `en`).
- **Conținut de sistem** (alimente și exerciții globale, cu `owner_id` null): traduceri în tabele separate; câmpurile din tabela de bază conțin limba implicită.
- **Conținut creat de utilizatori** (rețete, planuri, mesaje): într-o singură limbă, fără traducere automată; rețetele au câmpul `language`.
- **Alimente importate extern:** păstrează numele din sursă; dacă nu există traducere în limba utilizatorului, se afișează numele original.

### food_translation
| Câmp | Tip | Note |
|---|---|---|
| food_id | uuid FK → food | |
| locale | varchar | `ro`, `en` |
| name | varchar | |
| | | PK (food_id, locale) |

### exercise_translation
| Câmp | Tip | Note |
|---|---|---|
| exercise_id | uuid FK → exercise | |
| locale | varchar | `ro`, `en` |
| name | varchar | |
| instructions | text | |
| | | PK (exercise_id, locale) |

---

## 8.2 Ștergerea contului

**Regula:** când un client își șterge contul, **toate datele lui se șterg definitiv** (fără soft delete).

Flux propus:
1. Clientul cere ștergerea și o confirmă (reintroducere parolă).
2. Într-o singură tranzacție se șterg: `client_profile`, `medical_info`, `goal`, `progress_measurement`, `progress_photo`, `nutrition_target` + `calculation`, `food_diary` + intrări, planurile atribuite lui (`meal_plan`, `workout_plan` cu tot ce conțin, inclusiv `meal_recipe_ingredient`), `task`, `feedback`, `calendar_event` / `appointment` / `reschedule_request`, `notification`, `coach_client` și `message`, apoi `app_user`. Se implementează cu `ON DELETE CASCADE` unde e sigur și cu ștergere explicită în service, acoperită de teste.
3. Fișierele din storage (pozele de progres) se șterg printr-un job asincron, cu reîncercare dacă eșuează. Până se confirmă ștergerea, cheia rămâne într-o tabelă de ștergeri în așteptare, fără alte date personale.
4. `audit_log`: rândurile unde utilizatorul este actor sau subiect se **anonimizează** (`actor_user_id` / `subject_user_id` = null, `details` curățat) sau se șterg.
5. Mesajele din conversația cu coach-ul dispar și la coach.

Notă: copiile din backup-uri dispar abia la rotația backup-urilor; politica de retenție a backup-urilor trebuie definită și comunicată în politica de confidențialitate.

---

## 9. Decizii luate

| # | Subiect | Decizie |
|---|---|---|
| 1 | Coach-i per client | Unul singur |
| 2 | Cont dual | Nu; un singur rol per utilizator |
| 3 | Organizații | Nu |
| 4 | Șabloane | Da: șablon → copie per client → editare |
| 5 | Planuri finalizate | Imutabile |
| 6 | Rețete în plan | Copie editabilă a ingredientelor; clientul poate scoate/modifica/adăuga |
| 7 | Surse alimente | Manual + import extern; scanare cod de bare |
| 8 | Nutrienți | Doar macro |
| 9 | Formule BMR | Toate, selectabile per client |
| 10 | Acces `medical_info` | Doar client + coach curent; câmp general (accidentări) |
| 11–12 | GDPR / criptare câmpuri | Decizie luată; vezi nota de mai jos |
| 13 | Feedback | Doar client → antrenament, 1–5 stele |
| 14 | Mesagerie | Da, client ↔ coach |
| 15 | Plăți | Nu |
| 17 | Offline | Nu |
| 18 | Storage fișiere | Doar poze de progres |
| 19 | Rol ADMIN | Da |
| 20 | Mesagerie | WebSocket, timp real |
| 21 | Modificări rețete de client | Coach-ul le vede, fără aprobare |
| 22 | Schimbare coach | Fără opțiune dedicată; regula implicită în 10.1 |
| 23 | Limbi | Română și engleză |
| 24 | Ștergere cont client | Ștergere completă și definitivă (8.2) |

### Notă privind datele personale
Se pornește de la decizia „fără reguli GDPR". Totuși, platforma stochează și așa date cu caracter personal (nume, email, greutate, măsurători corporale, fotografii de progres, mesaje, note despre accidentări), iar dacă utilizatorii sunt în UE, GDPR se aplică indiferent de cât de puține date se colectează. Nu e o problemă de arhitectură, dar pentru un lansament public merită un minim practic: politică de confidențialitate și termeni, acord la înregistrare, posibilitatea ca utilizatorul să-și șteargă contul și să-și exporte datele, acces strict pe roluri, HTTPS și parole hash-uite. Acestea nu schimbă modelul de mai sus (sunt în mare parte funcționalități de cont), dar e bine de știut. Pentru certitudine, consultă un specialist juridic; acesta nu este sfat juridic.

---

## 10. Întrebări rămase deschise

1. **Schimbare de coach (de confirmat):** am interpretat „nu avem nevoie de opțiune" ca *regulă fixă, fără alegere*. Propunerea mea: datele aparțin clientului, deci noul coach vede istoricul lui (profil, măsurători, antrenamente finalizate, jurnal), dar **nu** mesajele dintre client și fostul coach. E în regulă, sau noul coach pornește de la zero?
2. **Ștergerea contului de coach:** ce se întâmplă cu planurile deja atribuite clienților? Propunere: ștergerea e permisă doar după ce clienții sunt detașați; planurile rămân clientului, cu `coach_id` null.
3. **Rolul ADMIN:** ce poate face exact? Propunere: gestionare conturi, alimente și exerciții globale, traduceri. Fără acces la datele clienților (poze, măsurători, mesaje).
4. **Poze de progres:** limite (dimensiune maximă, formate acceptate, număr per client) și regiune de hosting (în UE)?
5. **Traduceri conținut global:** cine le face la început (seed în ambele limbi pentru alimentele și exercițiile de pornire)?

---

## 11. Ordinea propusă de implementare

1. `app_user` (roluri COACH/CLIENT/ADMIN), `coach_profile`, `coach_client`, autentificare JWT, localizare ro/en
2. `client_profile`, `medical_info`, `goal`, `progress_measurement`, `progress_photo` (+ storage), `audit_log`
3. `exercise`, `workout_plan`, `workout`, `workout_exercise`, `workout_set`, `feedback` ← **MVP**
4. `message` (WebSocket) + ștergerea contului (8.2)
5. `food`, `food_product`, `barcode` (+ import extern), `recipe`, `recipe_ingredient`
6. `meal_plan`, `meal_plan_day`, `meal`, `meal_recipe`, `meal_recipe_ingredient`, `food_diary`, `food_diary_entry`
7. `nutrition_target`, `calculation` (toate formulele)
8. `task`, `calendar_event`, `appointment`, `reschedule_request`, `notification`
