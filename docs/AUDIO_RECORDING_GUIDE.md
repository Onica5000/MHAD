# How to Record an Audio File for Autofill

You can describe your wishes **out loud**, upload the recording, and the AI will
transcribe it and fill in your Pennsylvania Mental Health Advance Directive —
the same way it reads an uploaded document. This guide explains how to make a
good recording and, just as importantly, **what the audio can and can't do.**

Use it together with `AUDIO_QUESTIONNAIRE.md` — that's the script of what to say.

---

## The quick version

1. Open the questionnaire and **record yourself answering it**, in your own words.
2. Keep each recording **under about 2 minutes** — record **one clip per
   section** rather than one long file.
3. Save the clips as a common audio format (`.mp3`, `.m4a`, `.wav`, `.aac`,
   `.ogg`, or `.flac`).
4. On the **"Have a photo handy?"** (Snap‑to‑fill) screen, **upload all the
   clips together** and tap **Read with AI**.
5. **Review every field** the AI filled in, fix anything mis‑heard, then apply.
6. Finish the few things audio can't do (signatures, initials, dosages — see
   below) in the app.

---

## Recording the audio

- **Any device works** — your phone's voice‑memo app, a computer's sound
  recorder, etc.
- **Quality doesn't need to be high.** Gemini downsamples all audio to 16 kHz
  mono internally, so a small, low‑bitrate recording transcribes just as well as
  a large high‑quality one. Don't bother with high‑fidelity settings — they only
  make the file bigger, not more accurate.
- **Record somewhere quiet**, hold the mic reasonably close, and **speak
  clearly** at a normal pace.
- For **medication names, doctors' names, and unusual words**, say them slowly
  and **spell them** — this is the single biggest thing you can do to get an
  accurate result.
- **Say numbers clearly** — dates, phone numbers, and ZIP codes.

## Limitations — please read

### Length and the 60‑second timeout
The AI must transcribe **and** extract within **60 seconds** per file. Long
recordings risk timing out. So:

- Keep each clip **under ~2 minutes** of speech.
- **Split your answers into several short clips** — for example one for "About
  you," one for "Medications," one for "Allergies," and so on.
- **Upload them all at once.** The app processes each file and **merges** the
  results into one set of fields, so multiple short clips work better than one
  long one.

### File size
- Each file must be **10 MB or smaller.** At normal voice‑recording quality
  that's roughly 10+ minutes of audio per file — you'll hit the 2‑minute timeout
  guidance long before the size limit, so size is rarely the constraint.

### How many you can upload
- The free AI tier allows **15 requests per minute** and **1,500 per day.** Each
  audio clip counts as **one** request, so a typical set of clips is no problem.

### Accuracy
- The AI is good but **not perfect**, especially with drug names and clinical
  terms. **Always review** the autofilled fields and correct mis‑hearings before
  saving. The AI is instructed **not to invent** a medication or condition it
  didn't clearly hear — so if you mumble a drug name, expect it to be left out
  rather than guessed.

### Privacy
- To transcribe, your recording — **including any personal details you speak** —
  is sent to **Google's AI.** On the free tier, Google may retain that data, use
  it to improve their AI, and have human reviewers see it, and it **can't be
  recalled** afterward.
- Don't say anything you're not comfortable sending. You can always **type**
  sensitive fields by hand instead — typed fields stay on your device.
- The app itself **stores nothing** from the audio; you review the text before
  anything is added to your form.

### What audio CANNOT fill (do these in the app)
- **Your signature and your witnesses' signatures.**
- **Physical initials** that Pennsylvania law (§5805(c)(4)) requires when you let
  your **agent** decide about **ECT, experimental studies, or drug trials.** The
  recording captures your *choice*; you still must initial the **printed** form.
- **Exact medication dosages** for the medications you currently take.
- **On/off authority toggles** — whether your agent may consent to your
  hospitalization, and whether your agent decides your medications.
- **Room‑preference checkboxes**, the **same‑gender‑roommate** sub‑choice, and
  the **treatment‑facility "no preference" vs. specific** selection (your spoken
  facility names and room notes *are* captured as text).
- **The structured crisis plan** and the **side‑effects checklist** — built in
  the app. (Your general crisis and activity notes *are* captured.)
- **The self‑binding (Ulysses) clause** opt‑in.
- **Choosing your form type** (Combined, Declaration, or Power of Attorney) —
  pick this first, in the app.

---

## Recommended workflow

1. **Pick your form type** in the app first (Combined / Declaration / Power of
   Attorney) — it determines which sections apply.
2. Open `AUDIO_QUESTIONNAIRE.md`. Going section by section, **record a short clip
   for each**, spelling names and medications.
3. Transfer the clips to the device you're using the app on (or record directly
   there).
4. Go to the **Snap‑to‑fill** screen ("Have a photo handy?"), **add all the
   clips**, and tap **Read … with AI.** (The AI must be set up — it's free and
   takes about 30 seconds.)
5. **Review** the extracted fields. Fix mis‑heard medications, conditions,
   names, and numbers. Untick anything you don't want.
6. **Apply**, then complete the items audio can't fill: dosages, the
   agent‑authority toggles, the physical **initials** for any ECT / experimental
   / drug‑trial agent authorization, the crisis plan and side‑effects checklist
   if you want them, and your **signatures**.

---

## Troubleshooting

| Problem | What to do |
|---|---|
| "Couldn't read that file" | Use one of the supported formats (`.mp3`, `.m4a`, `.wav`, `.aac`, `.ogg`, `.flac`) and keep it under 10 MB. |
| It timed out / took too long | The clip is too long — split it into shorter clips (aim for under ~2 minutes each). |
| A medication or name is wrong | Re‑record that part, **spelling** the word, or just fix it in the review screen. |
| A field is empty that you spoke | The AI may not have clearly heard it — re‑record that section more slowly, or type it in. |
| "Too many requests" | You've hit the free‑tier limit (15/min, 1,500/day) — wait a minute and try again. |

---

### Related
- `AUDIO_QUESTIONNAIRE.md` — the script of what to say (covers every field audio
  can fill).
