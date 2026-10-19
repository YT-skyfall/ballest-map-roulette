// Independent Ballest Map Roulette beta. Requires Plugin Manager host >= 0.26.0.
// Author times are unavailable in Workshop search metadata. Filtered roulette
// is fail-closed: only confirmed author times from the current Workshop revision
// can win. Unknown maps can be inspected individually before a spin.
// Reads real Steam Workshop listings/images and opens the winner via Tracks::OpenWorkshop.
const string FONT = "/Game/UI/Fonts/CocogoosePro.CocogoosePro";
const int MAX_PAGES = 200; // >10,000 records: ask for tighter filters, never silently use a partial sample.
const int SLOTS = 5; // Wider previews; the larger middle tile is the selection target.

UI::FooterButton@ footerButton;
UI::FooterButton@ mainButton;
UI::Window@ win;
UI::Button@ closeButton;
UI::Button@ findButton;
UI::Button@ resetButton;
UI::Button@ advancedButton;
UI::Button@ doneAdvancedButton;
UI::Button@ precheckButton;
UI::Button@ cancelButton;
UI::Button@ spinButton;
UI::Button@ spinAgainButton;
UI::Button@ playButton;
UI::Button@ backButton;
UI::Button@ reelBackButton;
UI::Button@ stopButton;
UI::TextInput@ termBox;
UI::TextInput@ tagsBox;
UI::TextInput@ excludeBox;
UI::TextInput@ minAuthorBox;
UI::TextInput@ maxAuthorBox;
UI::Dropdown@ sortBox;
UI::Dropdown@ ratingBox;
UI::Dropdown@ playsBox;
UI::CheckBox@ unfinishedBox;
UI::CheckBox@ autoPlayBox;
UI::Dropdown@ musicVolumeBox;
UI::CheckBox@ soundsBox;
UI::Text@ statusText;
UI::Text@ helpText;
UI::Text@ reelStatus;
UI::Text@ reelPoolText;
UI::Text@ reelProgressText;
UI::Text@ filterSummary;
UI::Text@ reelTitle;
UI::Text@ pickedTitle;
UI::Text@ pickedInfo;
UI::Text@ autoPlayTimer;
UI::Image@ winnerImage;
float reelScale = 1.0f;
float winnerPreviewWidth = 560.0f;
float winnerPreviewHeight = 338.0f;
double nextWinnerPreviewCheck = 0;
array<UI::Image@> thumbs;
int setupView = 0;
int advancedView = 0;
string advancedSnapshot = "";
int reelView = 0;
int winnerView = 0;

bool showing = false;
bool scanning = false;
int query = -1;
int page = 1;
int pages = 0;
int total = 0;
int checked = 0;
array<string> ids;
array<string> unknownIds;
// An unplayed map can be prechecked by loading it once (no finish needed).
// The user exits through Ballest's native menu before checking another.
string precheckId = "";
bool precheckSawTrack = false;
bool precheckVerified = false;
bool precheckAccepted = false;
double precheckTime = 0;
string precheckMessage = "";
array<string> includeTags;
array<string> excludeTags;
string queryText = "";
string querySort = "top";
int minStars = 0;
int64 minPlays = 0;
bool unfinishedOnly = false;
double minAuthorTime = 0;
double maxAuthorTime = 0;
bool filterAuthorTime = false;
int missingAuthorTimes = 0;
string lastAuthorTrack = "";
double lastStoredAuthorTime = 0;

bool spinning = false;
bool winnerReady = false;
bool loading = false;
bool failedLoading = false;
int center = 0;
int winner = -1;
int ticks = 0;
int tick = 0;
double nextBeat = 0;
double winnerTime = 0;
// Music is a quiet, newly synthesized rendition of a public-domain Grieg theme.
// Draw::Sound only supports one-shots, not stopping a sound, so play short
// crossfaded chunks while spinning. Closing/STOP cancels any future chunks;
// the current one fades within less than a second.
const int MUSIC_PARTS = 16;
int musicPart = 0;
double nextMusicCue = 0;
double lastTickSound = -100;
bool audioMissingWarned = false;

// AngelScript rejects the C++ style 123u unsigned literal suffix. Use
// ordinary integer literals / explicit uint casts instead.
uint rng = 314159265;

void Highlight(UI::Text@ t) { t.SetColor(0.62f, 1, 0.02f, 1); }
void Muted(UI::Text@ t) { t.SetColor(0.43f, 0.51f, 0.58f, 1); }
void BrightButton(UI::Button@ b)
{
    b.SetBackground(0.59f, 0.98f, 0.02f, 1);
    b.SetTextColor(0.005f, 0.008f, 0.01f, 1);
    b.SetCornerRadius(6);
}
void DarkButton(UI::Button@ b)
{
    b.SetBackground(0.058f, 0.068f, 0.082f, 1);
    b.SetTextColor(1, 1, 1, 1);
    b.SetCornerRadius(6);
}

string Trim(const string &in v)
{
    uint start = 0, end = v.length();
    while (start < end && (v.substr(start, 1) == " " || v.substr(start, 1) == "\t")) start++;
    while (end > start && (v.substr(end - 1, 1) == " " || v.substr(end - 1, 1) == "\t")) end--;
    return v.substr(start, end - start);
}
array<string> Tags(const string &in text)
{
    array<string> tags;
    uint start = 0;
    while (start < text.length())
    {
        int pos = text.findFirst(",", start);
        string word = Trim(pos < 0 ? text.substr(start) : text.substr(start, uint(pos) - start));
        if (word != "") tags.insertLast(word);
        if (pos < 0) break;
        start = uint(pos) + 1;
    }
    return tags;
}
// Author times aren't exposed by Workshop::Find/Workshop::Title/etc.
// Race::AuthorTime becomes valid after the player has started a map. Save
// only that real value rather than attempting to guess a duration from tags.
void ObserveAuthorTime()
{
    if (!Race::OnTrack() || !Race::IsCustomTrack()) return;
    string track = Race::TrackKey();
    if (track.findFirst("custom:") != 0) return;
    int end = track.findFirst(":", 7);
    if (end <= 7) return;
    string id = track.substr(7, uint(end) - 7);
    if (id == "") return;
    double author = Race::AuthorTime();
    if (author <= 0 || author > 86400) return;
    // Cache against the exact Workshop update stamp. A map can be revised,
    // which can change its medal goal. Stale or pre-v0.1.4 entries fail closed.
    // Metadata may not be cached for a map the player opens outside Roulette;
    // those times are learned, but need a subsequent precheck to certify revision.
    int64 updated = Workshop::Updated(id);
    bool changed = lastAuthorTrack != id || Math::abs(lastStoredAuthorTime - author) >= 0.005;
    if (changed || (precheckId == id && !precheckVerified))
    {
        Storage::Set("author-time:" + id, formatFloat(author, "", 0, 3));
        Storage::Set("author-time-updated:" + id, updated > 0 ? formatInt(updated) : "");
        lastAuthorTrack = id;
        lastStoredAuthorTime = author;
        Log::Info("Learned author time for map " + id + ": " + formatFloat(author, "", 0, 3) + " seconds");
    }
    if (precheckId == id && !precheckVerified)
    {
        precheckVerified = true;
        precheckTime = author;
        precheckAccepted = updated > 0 && (minAuthorTime <= 0 || author >= minAuthorTime) &&
            (maxAuthorTime <= 0 || author <= maxAuthorTime);
        if (precheckAccepted) ids.insertLast(id);
        Log::Info("Map Roulette precheck " + id + ": " + formatFloat(author, "", 0, 3) +
            "s, eligible=" + (precheckAccepted ? "yes" : "no"));
    }
}

// Accept seconds, m:ss, or h:mm:ss; blank means no bound. Reject any other
// format instead of silently treating accidental input as zero seconds.
bool TimePart(const string &in raw, bool decimalAllowed, double &out value)
{
    string text = Trim(raw);
    if (text == "") return false;
    bool dot = false;
    for (uint i = 0; i < text.length(); i++)
    {
        string ch = text.substr(i, 1);
        if (ch == "." && decimalAllowed && !dot && i > 0 && i + 1 < text.length()) dot = true;
        else if (ch < "0" || ch > "9") return false;
    }
    value = parseFloat(text);
    return value >= 0;
}

bool ParseDuration(const string &in raw, double &out seconds)
{
    string text = Trim(raw);
    seconds = 0;
    if (text == "") return true;
    array<string> pieces;
    uint start = 0;
    while (start <= text.length())
    {
        int colon = text.findFirst(":", start);
        if (colon < 0)
        {
            pieces.insertLast(text.substr(start));
            break;
        }
        pieces.insertLast(text.substr(start, uint(colon) - start));
        start = uint(colon) + 1;
    }
    if (pieces.length() < 1 || pieces.length() > 3) return false;
    for (uint i = 0; i < pieces.length(); i++)
    {
        double part = 0;
        if (!TimePart(pieces[i], i + 1 == pieces.length(), part)) return false;
        if (i > 0 && part >= 60) return false;
        seconds = seconds * 60 + part;
    }
    return seconds <= 86400;
}

string Sorting(int choice)
{
    if (choice == 1) return "trending";
    if (choice == 2) return "new";
    if (choice == 3) return "updated";
    if (choice == 4) return "played";
    if (choice == 5) return "liked";
    if (choice == 6) return "relevance";
    return "top";
}
string Title(const string &in id)
{
    string title = Workshop::Title(id);
    return title == "" ? "map " + id : title;
}
int Wrap(int n, int length)
{
    if (length <= 0) return 0;
    return ((n % length) + length) % length;
}
uint Rand()
{
    rng ^= rng << 13;
    rng ^= rng >> 17;
    rng ^= rng << 5;
    if (rng == 0) rng = 987654321;
    return rng;
}
float MusicGain()
{
    if (musicVolumeBox is null) return 0;
    if (musicVolumeBox.selected == 1) return 0.18f; // default: quiet
    if (musicVolumeBox.selected == 2) return 0.34f;
    return 0; // off
}
void PlaySpinnerClick()
{
    if (soundsBox is null || !soundsBox.checked) return;
    // Early thumbnail steps arrive every 45ms: don't pile sounds on top of
    // each other. The cadence is deliberately light and slows with the reel.
    if (Host::Time() - lastTickSound < 0.11) return;
    lastTickSound = Host::Time();
    Draw::Sound(Plugins::Folder() + "sounds/tick.wav", 0.20, 0.99 + double(Rand() % uint(10)) * 0.01);
}
void PlayWinnerSound()
{
    if (soundsBox !is null && soundsBox.checked)
        Draw::Sound(Plugins::Folder() + "sounds/reveal.wav", 0.32, 1.0);
}
void StartSpinAudio()
{
    musicPart = 0;
    nextMusicCue = Host::Time();
    lastTickSound = -100;
}
void StopSpinAudio()
{
    // Already-playing WAV one-shots can't be stopped using the public API.
    // Their final 0.11 seconds fade out and the whole chunk ends within 0.86s.
    musicPart = MUSIC_PARTS;
}
void SpinAudioUpdate()
{
    if (!spinning || MusicGain() <= 0 || musicPart >= MUSIC_PARTS || Host::Time() < nextMusicCue) return;
    string name = "sounds/music_" + (musicPart < 10 ? "0" : "") + musicPart + ".wav";
    bool played = Draw::Sound(Plugins::Folder() + name, MusicGain(), 1.0);
    if (!played && !audioMissingWarned)
    {
        Log::Warn("Could not play roulette music. Check the sounds folder and host.log.");
        audioMissingWarned = true;
    }
    musicPart++;
    nextMusicCue = Host::Time() + 0.75;
}
void OpenUI()
{
    showing = true;
    win.visible = true;
    win.ShowView(setupView);
    UI::SetCursorVisible(true);
}
void CloseUI()
{
    // Closing must also cancel the automatic launch countdown. The player
    // should never enter another map after dismissing the picker.
    showing = false;
    spinning = false;
    StopSpinAudio();
    winnerReady = false;
    win.visible = false;
    UI::SetCursorVisible(false);
}
void SearchPage(int num)
{
    page = num;
    query = Workshop::Find(queryText, querySort, num, 7, includeTags, excludeTags, false);
    if (query < 0)
    {
        scanning = false;
        statusText.text = "Search unavailable. Are Steam and Workshop online?";
        cancelButton.visible = false;
        return;
    }
    statusText.text = "Searching Workshop ... page " + page + (pages > 0 ? "/" + pages : "");
}
void StartSearch()
{
    if (scanning && query >= 0) Workshop::Forget(query);
    ids.resize(0);
    unknownIds.resize(0);
    precheckId = "";
    precheckMessage = "";
    precheckButton.visible = false;
    query = -1;
    page = 1;
    pages = 0;
    total = 0;
    checked = 0;
    missingAuthorTimes = 0;
    spinning = false;
    StopSpinAudio();
    loading = false;
    winnerReady = false;
    failedLoading = false;
    spinButton.visible = false;
    queryText = Trim(termBox.typed);
    includeTags = Tags(tagsBox.typed);
    excludeTags = Tags(excludeBox.typed);
    querySort = Sorting(sortBox.selected);
    if (querySort == "relevance" && queryText == "") querySort = "top";
    minStars = ratingBox.selected == 1 ? 3 : ratingBox.selected == 2 ? 4 : ratingBox.selected == 3 ? 5 : 0;
    minPlays = playsBox.selected == 1 ? 10 : playsBox.selected == 2 ? 100 : playsBox.selected == 3 ? 1000 : 0;
    unfinishedOnly = unfinishedBox.checked;
    if (!ParseDuration(minAuthorBox.typed, minAuthorTime) ||
        !ParseDuration(maxAuthorBox.typed, maxAuthorTime))
    {
        statusText.text = "Invalid author time. Use 45, 1:30, or 2:05.500.";
        helpText.text = "Leave either time blank for no minimum or maximum.";
        cancelButton.visible = false;
        return;
    }
    filterAuthorTime = Trim(minAuthorBox.typed) != "" || Trim(maxAuthorBox.typed) != "";
    UpdateFilterSummary();
    if ((Trim(minAuthorBox.typed) != "" && minAuthorTime <= 0) ||
        (Trim(maxAuthorBox.typed) != "" && maxAuthorTime <= 0))
    {
        statusText.text = "Time limits must be greater than zero. Leave blank for none.";
        cancelButton.visible = false;
        return;
    }
    if (filterAuthorTime && maxAuthorTime > 0 && minAuthorTime > maxAuthorTime)
    {
        statusText.text = "Minimum author time is greater than the maximum.";
        cancelButton.visible = false;
        return;
    }
    helpText.text = filterAuthorTime
        ? "Only confirmed short maps can win. Check unknown maps first; no completion is needed."
        : "Live Hub search across every page. This may take a while for broad searches.";
    scanning = true;
    cancelButton.visible = true;
    SearchPage(1);
}
void CancelSearch()
{
    if (scanning && query >= 0) Workshop::Forget(query);
    query = -1;
    scanning = false;
    ids.resize(0);
    unknownIds.resize(0);
    precheckButton.visible = false;
    statusText.text = "Search cancelled";
    spinButton.visible = false;
    cancelButton.visible = false;
}
void ResetSearchFilters()
{
    // Filters only: keep the user's music, effects, and auto-play preferences.
    // Resetting also clears any stale result pool, so the next spin must use a fresh search.
    CancelSearch();
    termBox.value = "";
    tagsBox.value = "";
    excludeBox.value = "";
    minAuthorBox.value = "";
    maxAuthorBox.value = "";
    sortBox.selected = 0;
    ratingBox.selected = 0;
    playsBox.selected = 0;
    unfinishedBox.checked = false;
    filterAuthorTime = false;
    precheckMessage = "";
    // Input values are applied by the host on its next UI tick; the old live
    // text can still be present now, so show the reset state directly.
    filterSummary.text = "NO EXTRA FILTERS   /   All public Workshop maps are included";
    statusText.text = "FILTERS RESET  /  Click FIND MAPS to search again.";
    helpText.text = "Search Workshop maps, then spin for a random pick.";
}

string FilterSignature()
{
    // Snapshot only the filters that affect which maps qualify.
    return tagsBox.typed + "|" + excludeBox.typed + "|" +
        formatInt(sortBox.selected) + "|" + formatInt(ratingBox.selected) + "|" +
        formatInt(playsBox.selected) + "|" + formatInt(unfinishedBox.checked ? 1 : 0) + "|" +
        minAuthorBox.typed + "|" + maxAuthorBox.typed;
}

void UpdateFilterSummary()
{
    bool tagsUsed = Trim(tagsBox.typed) != "" || Trim(excludeBox.typed) != "";
    bool timeUsed = Trim(minAuthorBox.typed) != "" || Trim(maxAuthorBox.typed) != "";
    bool optionsUsed = tagsUsed || timeUsed || sortBox.selected != 0 ||
        ratingBox.selected != 0 || playsBox.selected != 0 || unfinishedBox.checked;
    filterSummary.text = optionsUsed
        ? "CUSTOM FILTERS ACTIVE   /   MORE FILTERS to edit them"
        : "NO EXTRA FILTERS   /   All public Workshop maps are included";
}

void ShowPoolStatus()
{
    cancelButton.visible = false;
    spinButton.visible = ids.length() > 0 && !scanning;
    precheckButton.visible = filterAuthorTime && !scanning && unknownIds.length() > 0;
    if (filterAuthorTime)
    {
        statusText.text = ids.length() + " VERIFIED ELIGIBLE / " + unknownIds.length() +
            " UNCHECKED (or updated) / " + checked + " scanned";
        helpText.text = precheckMessage != "" ? precheckMessage :
            "No unknown map can win. CHECK RANDOM MAP opens it once; exit to main menu to continue.";
    }
    else if (ids.length() == 0)
    {
        statusText.text = "NO MATCHES  /  Try broader filters.";
        helpText.text = "Adjust your search, rating or play-count requirements, then click FIND MAPS.";
    }
    else
    {
        statusText.text = ids.length() + (ids.length() == 1 ? " MAP READY" : " MAPS READY") +
            " TO SPIN  /  " + checked + " CHECKED";
        helpText.text = ids.length() == 1
            ? "Only one map matches. A spin will select that map."
            : "Each eligible map has an equal chance. Change filters and search again at any time.";
    }
}
void FinishSearch()
{
    scanning = false;
    query = -1;
    ShowPoolStatus();
    Log::Info(statusText.text);
}

void StartPrecheck()
{
    if (scanning || !filterAuthorTime || precheckId != "" || unknownIds.length() == 0 || Race::OnTrack()) return;
    rng ^= uint(Host::Time() * 1000003.0) + uint(1013904223);
    Rand();
    int pos = int(Rand() % uint(unknownIds.length()));
    string id = unknownIds[uint(pos)];
    unknownIds.removeAt(uint(pos));
    precheckId = id;
    precheckSawTrack = false;
    precheckVerified = false;
    precheckAccepted = false;
    precheckTime = 0;
    precheckMessage = "";
    if (!Tracks::OpenWorkshop(id))
    {
        unknownIds.insertLast(id);
        precheckId = "";
        precheckMessage = "Could not open map to check it. Try another map or check Steam.";
        ShowPoolStatus();
        return;
    }
    // Maps must be loaded to read the author medal row. This does not require
    // finishing a map, but there is no public API to silently inspect it.
    Log::Info("Prechecking unknown map " + id + ". Exit via Ballest menu after it loads.");
    CloseUI();
}

void PrecheckUpdate()
{
    if (precheckId == "") return;
    // If a download never transitions into a map, allow F7 at the main menu
    // to return to filters. Tracks::OpenWorkshop itself has no cancel method.
    if (!precheckSawTrack && UI::MainMenuShown() && Input::Pressed(Input::F7))
    {
        unknownIds.insertLast(precheckId);
        precheckId = "";
        precheckMessage = "Check interrupted. If Steam is still downloading, it may finish loading the map.";
        OpenUI();
        ShowPoolStatus();
        return;
    }
    if (Race::OnTrack()) precheckSawTrack = true;
    string state = Tracks::OpenState();
    if (!precheckSawTrack && state.findFirst("error") == 0)
    {
        unknownIds.insertLast(precheckId);
        precheckMessage = "Map check failed: " + state;
        precheckId = "";
        OpenUI();
        ShowPoolStatus();
        return;
    }
    // No attempted scripting of Ballest's back/exit menus: the player exits
    // normally after inspecting a map, without risking broken controls.
    if (!precheckSawTrack || Race::OnTrack() || !UI::MainMenuShown()) return;
    string id = precheckId;
    if (!precheckVerified)
    {
        unknownIds.insertLast(id);
        precheckMessage = "Could not read author time for that map; still unchecked. Try another.";
    }
    else if (precheckAccepted)
        precheckMessage = "Verified " + Title(id) + " (" + formatFloat(precheckTime, "", 0, 2) +
            "s). This map is now eligible.";
    else
        precheckMessage = "Checked " + Title(id) + " (" + formatFloat(precheckTime, "", 0, 2) +
            "s). Excluded: over/under your limit, or missing Workshop revision.";
    precheckId = "";
    OpenUI();
    ShowPoolStatus();
}
void SearchUpdate()
{
    if (!scanning || query < 0) return;
    string state = Workshop::State(query);
    if (state == "" || state == "searching") return;
    if (state.findFirst("error") == 0)
    {
        statusText.text = "Steam error: " + state;
        Log::Warn(state);
        scanning = false;
        cancelButton.visible = false;
        return;
    }
    if (state != "done") return;
    if (page == 1)
    {
        total = Workshop::Total(query);
        if (total > MAX_PAGES * 50)
        {
            statusText.text = total + " results. Add filters to narrow below 10,000 maps.";
            helpText.text = "Roulette won't spin a partial search. Narrow the filter to keep it fair.";
            scanning = false;
            cancelButton.visible = false;
            spinButton.visible = false;
            precheckButton.visible = false;
            Workshop::Forget(query);
            query = -1;
            return;
        }
        pages = (total + 49) / 50;
    }
    int count = Workshop::Count(query);
    for (int i = 0; i < count; i++)
    {
        string id = Workshop::Id(query, i);
        if (id == "") continue;
        checked++;
        if (minStars > 0 && Workshop::Score(id) * 5.0f < float(minStars)) continue;
        if (minPlays > 0 && Workshop::Plays(id) < minPlays) continue;
        if (unfinishedOnly && Workshop::MyBest(id) > 0) continue;
        if (filterAuthorTime)
        {
            string knownTime = Storage::Get("author-time:" + id, "");
            string savedRevision = Storage::Get("author-time-updated:" + id, "");
            int64 updated = Workshop::Updated(id);
            // Zero and legacy (unstamped) entries are not trusted: the author
            // might have edited the track since its time was last recorded.
            if (knownTime == "" || updated <= 0 || savedRevision != formatInt(updated))
            {
                missingAuthorTimes++;
                unknownIds.insertLast(id);
                continue;
            }
            double authorTime = parseFloat(knownTime);
            if (authorTime <= 0 || (minAuthorTime > 0 && authorTime < minAuthorTime) ||
                (maxAuthorTime > 0 && authorTime > maxAuthorTime)) continue;
        }
        ids.insertLast(id);
    }
    Workshop::Forget(query);
    query = -1;
    statusText.text = checked + " / " + total + " checked  |  " + ids.length() + " match";
    if (page >= pages || count == 0) FinishSearch();
    else SearchPage(page + 1);
}
void UpdateThumbs()
{
    if (ids.length() == 0) return;
    for (int i = 0; i < SLOTS; i++)
    {
        int at = Wrap(center + i - SLOTS / 2, int(ids.length()));
        string path = Workshop::Image(ids[uint(at)]); // May download asynchronously.
        thumbs[uint(i)].path = path == "" ? Plugins::Folder() + "placeholder.png" : path;
    }
    reelTitle.text = Title(ids[uint(center)]);
}

// The winning preview is intentionally a separate, much larger image. Workshop
// thumbnails can still be downloading when the spin ends, so retry briefly.
void UpdateWinnerPreview()
{
    if (!winnerReady || winner < 0 || Host::Time() < nextWinnerPreviewCheck) return;
    nextWinnerPreviewCheck = Host::Time() + 0.35;
    string image = Workshop::Image(ids[uint(winner)]);
    if (image != "") winnerImage.path = image;
}
void StartSpin()
{
    if (scanning || ids.length() == 0 || loading) return;
    if (Race::OnTrack())
    {
        helpText.text = "Return to main menu before spinning; this opens a new track.";
        return;
    }
    rng ^= uint(Host::Time() * 1000003.0) + uint(1013904223);
    Rand();
    winner = int(Rand() % uint(ids.length()));
    ticks = 34 + int(Rand() % uint(17));
    center = Wrap(winner - ticks, int(ids.length()));
    tick = 0;
    nextBeat = Host::Time() + 0.1;
    spinning = true;
    StartSpinAudio();
    winnerReady = false;
    failedLoading = false;
    reelStatus.text = "ROLLING   0%";
    reelPoolText.text = ids.length() + (ids.length() == 1 ? " MAP IN THE DRAW" : " MAPS IN THE DRAW");
    reelProgressText.text = "SHUFFLING";
    pickedTitle.text = "";
    pickedInfo.text = "";
    autoPlayTimer.text = "";
    win.ShowView(reelView);
    playButton.visible = false;
    spinAgainButton.visible = false;
    stopButton.visible = true;
    // A one-map pool is a single preview, not five misleading identical cards.
    for (int i = 0; i < SLOTS; i++)
        thumbs[uint(i)].visible = ids.length() > 1 || i == SLOTS / 2;
    UpdateThumbs();
}
void SpinUpdate()
{
    if (!spinning || ids.length() == 0 || Host::Time() < nextBeat) return;
    tick++;
    PlaySpinnerClick();
    center = Wrap(center + 1, int(ids.length()));
    UpdateThumbs();
    if (tick >= ticks)
    {
        spinning = false;
        StopSpinAudio();
        PlayWinnerSound();
        winnerReady = true;
        center = winner;
        UpdateThumbs();
        winnerTime = Host::Time();
        // Hold on an unmistakable full-size winner reveal rather than showing
        // a similarly-sized carousel of candidates after the spin stops.
        pickedTitle.text = Title(ids[uint(winner)]);
        // One concise line under the selected map: no redundant Workshop/play-count badges.
        pickedInfo.text = filterAuthorTime
            ? "AUTHOR TIME " + Storage::Get("author-time:" + ids[uint(winner)], "?") + "s  /  " +
                ids.length() + (ids.length() == 1 ? " ELIGIBLE MAP" : " ELIGIBLE MAPS")
            : "SELECTED FROM " + ids.length() +
                (ids.length() == 1 ? " MATCHING MAP" : " MATCHING MAPS");
        winnerImage.path = Plugins::Folder() + "placeholder.png";
        nextWinnerPreviewCheck = 0;
        UpdateWinnerPreview();
        playButton.visible = true;
        spinAgainButton.visible = true;
        stopButton.visible = false;
        win.ShowView(winnerView);
        return;
    }
    // The public image widget has no per-pixel horizontal position, so the
    // five-image reel scrolls left in steps and gradually slows to a halt.
    double t = double(tick) / double(ticks);
    nextBeat = Host::Time() + 0.045 + 0.42 * t * t * t;
    reelStatus.text = "ROLLING  " + tick * 100 / ticks + "%";
    reelProgressText.text = t > 0.82 ? "ALMOST THERE" : t > 0.56 ? "SLOWING DOWN" : "SHUFFLING";
}
void PlayWinner()
{
    if (!winnerReady || winner < 0 || loading || Race::OnTrack()) return;
    string id = ids[uint(winner)];
    if (Tracks::OpenWorkshop(id))
    {
        loading = true;
        failedLoading = false;
        autoPlayTimer.text = "LOADING MAP ...";
        playButton.visible = false;
        spinAgainButton.visible = false;
        Log::Info("Opening " + id + " / " + Title(id));
    }
    else
    {
        failedLoading = true;
        winnerReady = false; // Avoid repeating automatic attempts every frame.
        autoPlayTimer.text = "Could not load this map. Check Steam and try another.";
        spinAgainButton.visible = true;
    }
}
void Main()
{
    @footerButton = UI::AddFooterButton("map roulette");
    @mainButton = UI::AddMenuButton("map roulette");
    @win = UI::CreateWindow();
    win.SetScreenSize(0.86f, 0.82f);
    // Size previews relative to the playable viewport, but avoid overflowing on small displays.
    float screenWidth = 1680.0f, screenHeight = 900.0f;
    if (UI::ScreenSize(screenWidth, screenHeight))
    {
        reelScale = (screenWidth * 0.86f - 130.0f) / 1150.0f;
        if (reelScale > 1.0f) reelScale = 1.0f;
        if (reelScale < 0.49f) reelScale = 0.49f;
        winnerPreviewWidth = screenWidth * 0.41f;
        if (winnerPreviewWidth > 645.0f) winnerPreviewWidth = 645.0f;
        if (winnerPreviewWidth < 290.0f) winnerPreviewWidth = 290.0f;
        winnerPreviewHeight = winnerPreviewWidth * 304.0f / 504.0f;
    }
    win.SetAnchor(0.5f, 0.5f);
    win.SetPivot(0.5f, 0.5f);
    win.SetOffset(0, 0);
    win.SetPadding(30, 18);
    win.SetRowGap(12);
    win.SetCornerRadius(10);
    win.SetFont(FONT, "Regular");
    win.SetBackground(0.009f, 0.013f, 0.021f, 0.985f);
    win.SetCardBackground(0.018f, 0.030f, 0.042f, 0.97f);
    win.SetBlocksClicks(true);
    win.zOrder = 550;

    // Navigation is deliberately the only element shared by all three stages.
    win.StartHeader();
    Highlight(win.AddText("MAP ROULETTE", 28));
    win.AddSpace(0);
    UI::Text@ versionTag = win.AddText("BETA  /  v0.1.8", 13);
    Muted(versionTag);
    @closeButton = win.AddButton("close  X");
    DarkButton(closeButton);

    // STEP 1: only the most-used search and playback controls. Detailed filters
    // have their own screen so this page never turns into a full-width form.
    setupView = win.StartView();
    win.SetScrolling(setupView, true);
    Muted(win.AddText("01  /  BUILD YOUR POOL", 15));
    win.NewRow();
    win.AddText("Find something worth playing.", 29);
    win.NewRow();
    Muted(win.AddText("Search Workshop, narrow the results if you want, and let the roulette decide.", 16));
    win.NewRow();

    win.StartCard();
    UI::Text@ searchLabel = win.AddText("WORKSHOP SEARCH", 16);
    Highlight(searchLabel);
    win.NewRow();
    @termBox = win.AddTextInput(0, "Title, description, or tags  /  leave blank for every map", 18);
    termBox.clearOnSubmit = false;
    termBox.clearButton = true;
    @findButton = win.AddButton("FIND MAPS  >");
    BrightButton(findButton);
    findButton.SetSize(178, 43);
    @advancedButton = win.AddButton("MORE FILTERS  >");
    DarkButton(advancedButton);
    advancedButton.SetSize(197, 43);
    win.NewRow();
    @filterSummary = win.AddText("No extra filters applied. Search includes every Workshop map.", 14);
    Muted(filterSummary);
    win.EndCard();

    win.StartCard();
    Muted(win.AddText("HOW SHOULD THE SPIN PLAY?", 15));
    win.NewRow();
    @autoPlayBox = win.AddCheckBox("Auto-open selected map", 16);
    autoPlayBox.checked = true;
    win.AddSpace(38);
    win.AddText("Music", 16);
    @musicVolumeBox = win.AddDropdown(180);
    musicVolumeBox.AddOption("off");
    musicVolumeBox.AddOption("quiet (default)");
    musicVolumeBox.AddOption("normal");
    musicVolumeBox.selected = 1;
    win.AddSpace(34);
    @soundsBox = win.AddCheckBox("Click + reveal sounds", 16);
    soundsBox.checked = true;
    win.EndCard();

    win.StartCard();
    Muted(win.AddText("YOUR RESULTS", 15));
    win.NewRow();
    @statusText = win.AddText("READY  /  Start with FIND MAPS.", 21);
    Highlight(statusText);
    win.NewRow();
    @helpText = win.AddText("Every qualifying map gets one equal chance. No results are preselected.", 15);
    Muted(helpText);
    win.NewRow();
    @spinButton = win.AddButton("SPIN THE ROULETTE  >");
    BrightButton(spinButton);
    spinButton.SetSize(256, 44);
    spinButton.visible = false;
    @precheckButton = win.AddButton("CHECK AN UNKNOWN MAP  >");
    DarkButton(precheckButton);
    precheckButton.visible = false;
    @cancelButton = win.AddButton("CANCEL SEARCH");
    DarkButton(cancelButton);
    cancelButton.visible = false;
    @resetButton = win.AddButton("RESET FILTERS");
    DarkButton(resetButton);
    win.EndCard();

    // Detailed constraints stay available, but don't overwhelm the main page.
    // Tag inputs share a row; shrink them on narrower displays.
    float tagInputWidth = screenWidth * 0.26f;
    if (tagInputWidth > 445.0f) tagInputWidth = 445.0f;
    if (tagInputWidth < 235.0f) tagInputWidth = 235.0f;
    advancedView = win.StartView();
    win.SetScrolling(advancedView, true);
    Muted(win.AddText("01  /  REFINE YOUR POOL", 15));
    win.NewRow();
    win.AddText("More filters", 30);
    win.NewRow();
    Muted(win.AddText("These filters apply when you run FIND MAPS. Empty fields mean no restriction.", 16));
    win.NewRow();

    win.StartCard();
    Highlight(win.AddText("DISCOVERY", 16));
    win.NewRow();
    win.AddText("Sort", 16);
    @sortBox = win.AddDropdown(185);
    sortBox.AddOption("top");
    sortBox.AddOption("trending 7d");
    sortBox.AddOption("newest");
    sortBox.AddOption("updated");
    sortBox.AddOption("most played");
    sortBox.AddOption("liked");
    sortBox.AddOption("relevance");
    sortBox.selected = 0;
    win.AddSpace(35);
    win.AddText("Minimum rating", 16);
    @ratingBox = win.AddDropdown(158);
    ratingBox.AddOption("any");
    ratingBox.AddOption("3 stars");
    ratingBox.AddOption("4 stars");
    ratingBox.AddOption("5 stars");
    win.AddSpace(35);
    win.AddText("Minimum plays", 16);
    @playsBox = win.AddDropdown(158);
    playsBox.AddOption("any");
    playsBox.AddOption("10+");
    playsBox.AddOption("100+");
    playsBox.AddOption("1000+");
    win.EndCard();

    win.StartCard();
    Highlight(win.AddText("WORKSHOP TAGS", 16));
    win.NewRow();
    win.AddText("Include all", 16);
    @tagsBox = win.AddTextInput(tagInputWidth, "e.g. beginner, flow", 17);
    tagsBox.clearOnSubmit = false;
    tagsBox.clearButton = true;
    win.AddSpace(25);
    win.AddText("Exclude", 16);
    @excludeBox = win.AddTextInput(tagInputWidth, "e.g. troll", 17);
    excludeBox.clearOnSubmit = false;
    excludeBox.clearButton = true;
    win.NewRow();
    Muted(win.AddText("Separate tags with commas. Leave either side empty if you don't need it.", 14));
    win.EndCard();

    win.StartCard();
    Highlight(win.AddText("ADDITIONAL RESTRICTIONS", 16));
    win.NewRow();
    @unfinishedBox = win.AddCheckBox("Only maps I haven't finished", 16);
    win.NewRow();
    win.AddText("Author time (checked maps only)", 15);
    win.AddSpace(25);
    win.AddText("From", 15);
    @minAuthorBox = win.AddTextInput(130, "none", 16);
    minAuthorBox.clearOnSubmit = false;
    minAuthorBox.clearButton = true;
    win.AddSpace(22);
    win.AddText("To", 15);
    @maxAuthorBox = win.AddTextInput(130, "e.g. 1:30", 16);
    maxAuthorBox.clearOnSubmit = false;
    maxAuthorBox.clearButton = true;
    win.NewRow();
    Muted(win.AddText("Experimental: unchecked maps are excluded. Leave both blank for normal roulette.", 14));
    win.EndCard();
    win.NewRow();
    @doneAdvancedButton = win.AddButton("<  BACK TO SEARCH");
    BrightButton(doneAdvancedButton);
    doneAdvancedButton.SetSize(236, 43);
    win.AddSpace(14);
    Muted(win.AddText("Changes require a fresh search before spinning.", 14));

    // STEP 2. Dark presentation stage. Use the photos as the visual motion:
    // the changing central image is deliberately larger, while one small status
    // line communicates progress. Avoid repeating the same information 3 times.
    reelView = win.StartView();
    win.AddSpace(0);
    Muted(win.AddText("02  /  THE DRAW", 14));
    win.AddSpace(0);
    win.NewRow();
    win.AddSpace(0);
    @reelStatus = win.AddText("ROLLING   0%", 38);
    Highlight(reelStatus);
    win.AddSpace(0);
    win.NewRow();
    win.AddSpace(0);
    @reelPoolText = win.AddText("MAPS IN THE DRAW", 15);
    Muted(reelPoolText);
    win.AddSpace(0);
    win.NewRow();

    win.StartCard();
    win.AddSpace(0);
    UI::Text@ focusLabel = win.AddText("▼", 23);
    Highlight(focusLabel);
    win.AddSpace(0);
    win.NewRow();
    win.AddSpace(0);
    for (int i = 0; i < SLOTS; i++)
    {
        float width = (i == SLOTS / 2 ? 330.0f : 180.0f) * reelScale;
        float height = width * 304.0f / 504.0f;
        UI::Image@ picture = win.AddImage(Plugins::Folder() + "placeholder.png", width, height);
        thumbs.insertLast(picture);
        if (i < SLOTS - 1) win.AddSpace(13.0f * reelScale);
    }
    win.AddSpace(0);
    win.NewRow();
    win.AddSpace(0);
    @reelTitle = win.AddText("", 31);
    win.AddSpace(0);
    win.NewRow();
    win.AddSpace(0);
    @reelProgressText = win.AddText("SHUFFLING", 14);
    Muted(reelProgressText);
    win.AddSpace(0);
    win.EndCard();
    win.NewRow();
    win.AddSpace(0);
    @stopButton = win.AddButton("STOP SPIN");
    DarkButton(stopButton);
    stopButton.SetSize(171, 45);
    @reelBackButton = win.AddButton("<  FILTERS");
    DarkButton(reelBackButton);
    reelBackButton.SetSize(154, 45);
    win.AddSpace(0);

    // STEP 3. Minimal poster-style winner reveal. Let the authentic full-size
    // map image, selected title, and main play button do the work; no enormous
    // monochrome card and no redundant labels around the screenshot.
    winnerView = win.StartView();
    win.SetScrolling(winnerView, true); // Short displays can still access all actions.
    win.AddSpace(0);
    Muted(win.AddText("03  /  THE RESULT", 14));
    win.AddSpace(0);
    win.NewRow();
    win.AddSpace(0);
    UI::Text@ winnerHeadline = win.AddText("MAP SELECTED", 32);
    Highlight(winnerHeadline);
    win.AddSpace(0);
    win.NewRow();
    win.AddSpace(0);
    @winnerImage = win.AddImage(Plugins::Folder() + "placeholder.png", winnerPreviewWidth, winnerPreviewHeight);
    win.AddSpace(0);
    win.NewRow();
    win.AddSpace(0);
    @pickedTitle = win.AddText("", 41);
    win.AddSpace(0);
    win.NewRow();
    win.AddSpace(0);
    @pickedInfo = win.AddText("", 15);
    Muted(pickedInfo);
    win.AddSpace(0);
    win.NewRow();
    win.AddSpace(0);
    @playButton = win.AddButton("PLAY THIS MAP  >");
    BrightButton(playButton);
    playButton.SetSize(255, 52);
    @spinAgainButton = win.AddButton("SPIN AGAIN");
    DarkButton(spinAgainButton);
    spinAgainButton.SetSize(165, 52);
    @backButton = win.AddButton("<  FILTERS");
    DarkButton(backButton);
    backButton.SetSize(137, 52);
    win.AddSpace(0);
    win.NewRow();
    win.AddSpace(0);
    @autoPlayTimer = win.AddText("", 14);
    Muted(autoPlayTimer);
    win.AddSpace(0);

    playButton.visible = false;
    spinAgainButton.visible = false;
    win.ShowView(setupView);
    win.visible = false;
    Log::Info("Map Roulette v0.1.8 visual redesign ready. Open from main menu, footer, or F7.");
}
void Update(float dt)
{
    // Keep learning exact author times even when the roulette menu is closed.
    ObserveAuthorTime();
    // A single F7 press must not both cancel the check and close the UI.
    bool precheckCancelKey = precheckId != "" && UI::MainMenuShown() &&
        !precheckSawTrack && Input::Pressed(Input::F7);
    PrecheckUpdate();
    if (!precheckCancelKey && precheckId == "" &&
        (footerButton.Clicked() || mainButton.Clicked() || Input::Pressed(Input::F7)))
    {
        if (showing) CloseUI(); else OpenUI();
    }
    if (!showing) return;
    if (closeButton.Clicked() || Input::Pressed(Input::Escape))
    {
        CloseUI();
        return;
    }
    if (findButton.Clicked() || termBox.Submitted() || tagsBox.Submitted() || excludeBox.Submitted() ||
        minAuthorBox.Submitted() || maxAuthorBox.Submitted())
    {
        StartSearch();
        win.ShowView(setupView);
    }
    if (advancedButton.Clicked())
    {
        advancedSnapshot = FilterSignature();
        win.ShowView(advancedView);
    }
    if (doneAdvancedButton.Clicked())
    {
        if (FilterSignature() != advancedSnapshot)
        {
            CancelSearch();
            statusText.text = "FILTERS CHANGED  /  Run FIND MAPS again.";
            helpText.text = "Your previous results were cleared so the next draw uses the new filters.";
        }
        UpdateFilterSummary();
        win.ShowView(setupView);
    }
    if (cancelButton.Clicked()) CancelSearch();
    if (resetButton.Clicked()) ResetSearchFilters();
    SearchUpdate();
    if (precheckButton.Clicked()) StartPrecheck();
    if (spinButton.Clicked() || spinAgainButton.Clicked()) StartSpin();
    if (backButton.Clicked() || reelBackButton.Clicked())
    {
        spinning = false;
        StopSpinAudio();
        winnerReady = false;
        win.ShowView(setupView);
    }
    if (stopButton.Clicked())
    {
        spinning = false;
        StopSpinAudio();
        winnerReady = false;
        reelStatus.text = "SPIN STOPPED";
        reelProgressText.text = "SPIN CANCELLED";
        reelTitle.text = "";
        playButton.visible = false;
        stopButton.visible = false;
    }
    SpinUpdate();
    SpinAudioUpdate();
    UpdateWinnerPreview();
    if (playButton.Clicked()) PlayWinner();
    // Leave the completed selection visible longer for recording before
    // automatic loading (the old 2.4-second delay was difficult to read).
    if (winnerReady && !loading)
    {
        if (autoPlayBox.checked)
        {
            int secondsLeft = int(Math::ceil(6.0 - (Host::Time() - winnerTime)));
            if (secondsLeft < 0) secondsLeft = 0;
            autoPlayTimer.text = "Opening in " + secondsLeft + "s  /  Close to cancel";
            if (Host::Time() - winnerTime > 6.0) PlayWinner();
        }
        else autoPlayTimer.text = "";
    }
    if (loading)
    {
        string state = Tracks::OpenState();
        if (Race::OnTrack() || state == "open")
        {
            loading = false;
            CloseUI();
        }
        else if (state.findFirst("error") == 0)
        {
            loading = false;
            winnerReady = false;
            failedLoading = true;
            autoPlayTimer.text = state;
            spinAgainButton.visible = true;
            playButton.visible = true;
        }
    }
}
