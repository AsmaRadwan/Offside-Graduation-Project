import os
from typing import Optional, List, Dict
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
from supabase import create_client, Client
from pydantic import BaseModel

load_dotenv()

# --- Config ---
url: str = os.environ.get("SUPABASE_URL")
key: str = os.environ.get("SUPABASE_KEY")
supabase: Client = create_client(url, key)

app = FastAPI(title="OFFSIDE: Advanced Sports Backend")

# --- CORS Middleware (required for Flutter to communicate with API) ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ============================================================
# --- Schemas (Request/Response Models) ---
# ============================================================

class UserCreate(BaseModel):
    name: str
    email: str
    nationality: str
    phone_number: str

class PlayerProfile(BaseModel):
    full_name: str
    email: str
    phone_number: str
    jersey_number: int
    position: str
    nationality: str
    team_id: Optional[int] = None
    height: float
    weight: float

class TeamCreate(BaseModel):
    team_name: str
    primary_tshirt_colors: str      # e.g. "#FF0000"
    secondary_tshirt_colors: str    # e.g. "#FFFFFF"
    goalkeeper_tshirt_colors: str   # e.g. "#000000"

class MatchResult(BaseModel):
    match_id: int
    player_id: int
    goals: int
    assists: int
    yellow_card: int
    red_card: int
    is_mvp: bool
    acquisition: float
    top_speed: Optional[float] = None
    total_distance: Optional[float] = None
    actions_detected: Optional[dict] = None
    heatmap_image_url: Optional[str] = None

class TransferRequest(BaseModel):
    player_id: int
    team_id: int
    tournament_id: int

class TeamMatchStats(BaseModel):
    match_id: int
    team_id: int
    goals: int
    passes: int
    foul: int
    corner: int
    acquisition_avg: float

class InvitationSend(BaseModel):
    team_id: int
    player_id: int

class InvitationAction(BaseModel):
    invitation_id: int
    # No team_id/player_id needed here, we'll get them from the invitation record

# --- AI Model Integration Schemas ---
class PlayerAIStat(BaseModel):
    track_id: int
    player_name: Optional[str] = None
    total_distance: float
    top_speed: float

class TeamAIStat(BaseModel):
    possession: Dict[str, float]  # {"Red Team": 60.0, "Green Team": 40.0}
    passes_red: int
    passes_green: int
    interceptions_red: int
    interceptions_green: int

class AIMatchResult(BaseModel):
    match_id: int
    team_stats: TeamAIStat
    player_stats: List[PlayerAIStat]
    heatmap_urls: Dict[str, str] # {"Player Name": "public_url"}

# ============================================================
# --- 1. User & Player Onboarding ---
# ============================================================

@app.post("/api/v1/auth/register")
def create_user_profile(user: UserCreate):
    """Creates a standalone User record."""
    try:
        # Note: id is now auto-generated (Identity) in Supabase
        res = supabase.table("USERS").insert(user.dict()).execute()
        return {"status": "success", "user": res.data[0]}
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Registration failed: {str(e)}")

@app.post("/api/v1/players/profile")
def complete_player_profile(profile: PlayerProfile):
    """Creates a standalone athletic Player profile."""
    try:
        # Note: player_id is now auto-generated in Supabase
        res = supabase.table("PLAYERS").insert(profile.dict()).execute()
        return {"status": "success", "profile": res.data[0]}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# ============================================================
# --- 2. Team Management ---
# ============================================================

@app.post("/api/v1/teams")
def create_team(team: TeamCreate):
    """Creates a new team. Colors are strings matching the schema."""
    try:
        res = supabase.table("TEAMS").insert(team.dict()).execute()
        return {"status": "success", "team": res.data[0]}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/api/v1/teams/discover")
def list_teams():
    """Returns all teams and their colors for the join-team selection screen."""
    try:
        res = supabase.table("TEAMS").select(
            "team_id, team_name, primary_tshirt_colors, secondary_tshirt_colors, goalkeeper_tshirt_colors"
        ).execute()
        return {"status": "success", "teams": res.data}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/api/v1/teams/{team_id}")
def get_team_details(team_id: int):
    """Returns full details and aggregate stats for a single team."""
    try:
        res = supabase.table("TEAMS").select("*").eq("team_id", team_id).single().execute()
        return {"status": "success", "team": res.data}
    except Exception as e:
        raise HTTPException(status_code=404, detail="Team not found")

# ============================================================
# --- 3. Tournament Management ---
# ============================================================

@app.get("/api/v1/tournaments/active")
def get_tournaments():
    """Fetches all tournaments and their associated matches."""
    try:
        # Complex join: Tournament -> Matches
        res = supabase.table("TOURNAMENTS").select("*, MATCHES(*)").execute()
        return {"status": "success", "data": res.data}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# ============================================================
# --- 4. Match Flow ---
# ============================================================

@app.get("/api/v1/matches/{match_id}")
def get_match_details(match_id: int):
    """Returns full details of a single match, including team and player stats."""
    try:
        # Complex join: Match -> Team Stats, Player Stats
        res = supabase.table("MATCHES").select(
            "*, TEAM_MATCH_STATS(*), PLAYER_MATCH_STATS(*)"
        ).eq("match_id", match_id).single().execute()
        return {"status": "success", "match": res.data}
    except Exception as e:
        raise HTTPException(status_code=404, detail="Match not found")

# ============================================================
# --- 5. Match Result Submission & Career Sync ---
# ============================================================

@app.post("/api/v1/matches/result")
def submit_match_result(result: MatchResult):
    """
    Submits manual player stats and heatmaps after a match.
    Updates the player's cumulative career totals on the PLAYERS table.
    This handles manual entry (Goals/Assists).
    """
    try:
        # Step 1: Insert the per-match stats row
        supabase.table("PLAYER_MATCH_STATS").insert(result.dict()).execute()

        # Step 2: Fetch current career totals for this player
        player_res = supabase.table("PLAYERS").select(
            "total_goals, total_assists, total_yellow_card, total_red_card, "
            "total_appearance, total_acquisition, highest_speed, total_destination"
        ).eq("player_id", result.player_id).single().execute()

        player = player_res.data

        # Step 3: Calculate updated career totals
        updated_totals = {
            "total_goals":       player["total_goals"] + result.goals,
            "total_assists":     player["total_assists"] + result.assists,
            "total_yellow_card": player["total_yellow_card"] + result.yellow_card,
            "total_red_card":    player["total_red_card"] + result.red_card,
            "total_appearance":  player["total_appearance"] + 1,
            "total_acquisition": round(player["total_acquisition"] + result.acquisition, 2),
        }

        # Update highest speed if new record
        if result.top_speed and result.top_speed > (player["highest_speed"] or 0.0):
            updated_totals["highest_speed"] = result.top_speed

        # Accumulate total distance
        if result.total_distance:
            updated_totals["total_destination"] = round(
                (player["total_destination"] or 0.0) + result.total_distance, 2
            )

        # Step 4: Write updated totals back to the PLAYERS table
        supabase.table("PLAYERS").update(updated_totals).eq("player_id", result.player_id).execute()

        return {"status": "success", "message": "Match result submitted and career stats updated."}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.post("/api/v1/matches/team-stats")
def submit_team_match_stats(stats: TeamMatchStats):
    """Submits team-level stats for a specific match (manual corner/foul entry)."""
    try:
        supabase.table("TEAM_MATCH_STATS").insert(stats.dict()).execute()

        # Update team aggregate totals for Goals/Passes
        team_res = supabase.table("TEAMS").select(
            "total_goals, total_passes"
        ).eq("team_id", stats.team_id).single().execute()

        team = team_res.data

        supabase.table("TEAMS").update({
            "total_goals":   team["total_goals"] + stats.goals,
            "total_passes":  team["total_passes"] + stats.passes,
        }).eq("team_id", stats.team_id).execute()

        return {"status": "success", "message": "Team match stats submitted."}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# ============================================================
# --- 6. Statistics & Scout Cards (The Core Value) ---
# ============================================================

@app.get("/api/v1/players/{player_id}/scout-card")
def get_player_stats(player_id: int):
    """Returns the aggregated career totals for the Player's profile/scout card dashboard."""
    try:
        res = supabase.table("PLAYERS").select(
            "full_name, position, jersey_number, nationality, height, weight, "
            "total_goals, total_assists, total_appearance, total_acquisition, "
            "total_yellow_card, total_red_card, highest_speed, total_destination, "
            "email, phone_number, team_id"
        ).eq("player_id", player_id).single().execute()
        return {"status": "success", "stats": res.data}
    except Exception as e:
        raise HTTPException(status_code=404, detail="Player not found")

# ============================================================
# --- 7. Team Transitions (History Management) ---
# ============================================================

@app.post("/api/v1/players/transfer")
def record_team_transfer(transfer: TransferRequest):
    """
    Updates the player's active team and records the move in team history.
    This also updates the historical history_id to be auto-generated.
    """
    try:
        # Step 1: Update the player's current active team
        supabase.table("PLAYERS").update(
            {"team_id": transfer.team_id}
        ).eq("player_id", transfer.player_id).execute()

        # Step 2: Record the transfer in the history table
        history_entry = {
            "player_id":     transfer.player_id,
            "team_id":       transfer.team_id,
            "tournament_id": transfer.tournament_id,
        }
        supabase.table("TEAM_MEMBERS_HISTORY").insert(history_entry).execute()

        return {"status": "success", "message": "Transfer recorded successfully."}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
    
# ============================================================
# --- 8. Team Invitation System  ---
# ============================================================

@app.post("/api/v1/invitations/send")
def send_team_invitation(invite: InvitationSend):
    """
    Step 1: Team manager sends an invitation to a player.
    The status defaults to 'pending' in Supabase.
    """
    try:
        # Check if an invitation already exists to prevent spam
        existing = supabase.table("INVITATIONS").select("*")\
            .eq("team_id", invite.team_id)\
            .eq("player_id", invite.player_id)\
            .eq("status", "pending").execute()
        
        if existing.data:
            return {"status": "error", "message": "An invitation is already pending for this player."}

        res = supabase.table("INVITATIONS").insert(invite.dict()).execute()
        return {"status": "success", "invitation": res.data[0]}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.post("/api/v1/invitations/accept")
def accept_invitation(action: InvitationAction):
    """
    Step 2: Player accepts. 
    This triggers two actions:
    1. Update invitation status to 'accepted'.
    2. Update the PLAYER table to set their team_id.
    """
    try:
        # 1. Fetch invitation details
        invite_res = supabase.table("INVITATIONS").select("*")\
            .eq("invitation_id", action.invitation_id).single().execute()
        
        if not invite_res.data:
            raise HTTPException(status_code=404, detail="Invitation not found")
        
        invite = invite_res.data

        # 2. Update player's team in the PLAYERS table
        supabase.table("PLAYERS").update({"team_id": invite["team_id"]})\
            .eq("player_id", invite["player_id"]).execute()

        # 3. Mark invitation as accepted
        supabase.table("INVITATIONS").update({"status": "accepted"})\
            .eq("invitation_id", action.invitation_id).execute()

        return {"status": "success", "message": "Player has successfully joined the team."}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.post("/api/v1/invitations/decline")
def decline_invitation(action: InvitationAction):
    """Step 3: Player declines. Just update status to 'declined'."""
    try:
        supabase.table("INVITATIONS").update({"status": "declined"})\
            .eq("invitation_id", action.invitation_id).execute()
        return {"status": "success", "message": "Invitation declined."}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.get("/api/v1/players/{player_id}/invitations")
def get_my_invitations(player_id: int):
    """Allows the Flutter app to show a 'Notifications' list for the player."""
    try:
        res = supabase.table("INVITATIONS").select("*, TEAMS(team_name)")\
            .eq("player_id", player_id)\
            .eq("status", "pending").execute()
        return {"status": "success", "invitations": res.data}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# ============================================================
# --- 9. AI Model Integration ---
# ============================================================

@app.post("/api/v1/ai/analyze-match/{match_id}")
def receive_ai_results(match_id: int, result: AIMatchResult):
    """
    Receives automated analysis results from the AI pipeline.
    Saves team possession/passes to TEAM_MATCH_STATS.
    Saves heatmap URLs, speed, and distance to PLAYER_MATCH_STATS
    by matching player names.
    """
    try:
        # Step 1: Identify both teams in the match
        match_res = supabase.table("MATCHES").select(
            "home_team_id, away_team_id"
        ).eq("match_id", match_id).single().execute()

        home_team_id = match_res.data["home_team_id"]
        away_team_id = match_res.data["away_team_id"]

        # Step 2: Save team match stats for home team (Red)
        supabase.table("TEAM_MATCH_STATS").insert({
            "match_id": match_id,
            "team_id": home_team_id,
            "goals": 0,  # Entered manually
            "passes": result.team_stats.passes_red,
            "foul": 0,
            "corner": 0,
            "acquisition_avg": result.team_stats.possession.get("Red Team", 0.0)
        }).execute()

        # Step 3: Save team match stats for away team (Green)
        supabase.table("TEAM_MATCH_STATS").insert({
            "match_id": match_id,
            "team_id": away_team_id,
            "goals": 0,
            "passes": result.team_stats.passes_green,
            "foul": 0,
            "corner": 0,
            "acquisition_avg": result.team_stats.possession.get("Green Team", 0.0)
        }).execute()

        # Step 4: Map AI Player data to Database Players
        for p_ai in result.player_stats:
            # Skip unidentified players
            if not p_ai.player_name or p_ai.player_name in ("Unknown", "Identifying..."):
                continue

            # Find player by full_name in PLAYERS table
            player_res = supabase.table("PLAYERS").select("player_id").ilike(
                "full_name", f"%{p_ai.player_name}%"
            ).execute()

            if not player_res.data:
                continue # No player found by that name

            player_id = player_res.data[0]["player_id"]

            # Step 5: Save AI data (Heatmaps, Speed, Dist) to per-match stats table
            heatmap_url = result.heatmap_urls.get(p_ai.player_name)

            supabase.table("PLAYER_MATCH_STATS").insert({
                "match_id": match_id,
                "player_id": player_id,
                "goals": 0, # Manual entry
                "assists": 0,
                "yellow_card": 0,
                "red_card": 0,
                "is_mvp": False,
                "acquisition": 0.0,
                "top_speed": p_ai.top_speed,
                "total_distance": p_ai.total_distance,
                "heatmap_image_url": heatmap_url
            }).execute()

            # Step 6: Update cumulative career totals (Highest Speed, Total Distance)
            career_res = supabase.table("PLAYERS").select(
                "highest_speed, total_destination"
            ).eq("player_id", player_id).single().execute()

            career = career_res.data

            updated_career = {}
            if p_ai.top_speed > (career["highest_speed"] or 0.0):
                updated_career["highest_speed"] = p_ai.top_speed
            
            if p_ai.total_distance:
                updated_career["total_destination"] = round(
                    (career["total_destination"] or 0.0) + p_ai.total_distance, 2
                )

            if updated_career:
                supabase.table("PLAYERS").update(updated_career).eq(
                    "player_id", player_id
                ).execute()

        return {
            "status": "success",
            "message": f"AI results for match {match_id} saved successfully.",
            "players_mapped": len(result.player_stats)
        }

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
