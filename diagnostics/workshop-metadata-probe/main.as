// EXPERIMENTAL READ-ONLY PROBE.
// Requires a custom Plugin Manager build with Workshop::Metadata(id).
// This is NOT compatible with the normal public Plugin Manager host.
// It does not alter maps, scores, leaderboards, or the Map Roulette plugin.

const string SEARCH = "Ballistic Banzai";
int query = -1;
bool finished = false;

void Main()
{
    Log::Info("[author-time-probe] Searching Workshop for: " + SEARCH);
    query = Workshop::Find(SEARCH, "relevance", 1, 7);
    if (query < 0)
    {
        Log::Warn("[author-time-probe] Workshop query could not start. Check Steam.");
        finished = true;
    }
}

void Update(float dt)
{
    if (finished || query < 0) return;
    string state = Workshop::State(query);
    if (state == "" || state == "searching") return;
    if (state != "done")
    {
        Log::Warn("[author-time-probe] Query failed: " + state);
        Workshop::Forget(query);
        finished = true;
        return;
    }

    int matches = 0;
    int count = Workshop::Count(query);
    Log::Info("[author-time-probe] Search returned " + count + " items on page 1.");
    for (int i = 0; i < count; i++)
    {
        string id = Workshop::Id(query, i);
        string title = Workshop::Title(id);
        if (title != SEARCH) continue; // Avoid confusing similarly named results.
        matches++;
        string meta = Workshop::Metadata(id);
        Log::Info("[author-time-probe] ID: " + id);
        Log::Info("[author-time-probe] Title: " + title);
        Log::Info("[author-time-probe] Updated: " + Workshop::Updated(id));
        if (meta == "")
            Log::Info("[author-time-probe] Developer metadata: EMPTY");
        else
            Log::Info("[author-time-probe] Developer metadata: " + meta);
    }
    if (matches == 0)
        Log::Warn("[author-time-probe] No exact-title match. Check search results or try another map.");
    Log::Info("[author-time-probe] Completed. Compare values with Ballest Hub author time: 27.581 seconds.");
    Workshop::Forget(query);
    finished = true;
}
