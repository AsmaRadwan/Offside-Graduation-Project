import os
import uuid
from typing import Optional, List, Dict
from fastapi import FastAPI, HTTPException, UploadFile, File
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
    primary_tshirt_colors: str
    secondary_tshirt_colors: str
    goalkeeper_tshirt_colors: str

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

# --- Requirement 3: Edit Profile Schemas ---
class UpdatePlayerProfile(BaseModel):
    full_name: Optional[str] = None
    phone_number: Optional[str] = None
    jersey_number: Optional[int] = None
    position: Optional[str] = None
    nationality: Optional[str] = None
    height: Optional[float] = None
    weight: Optional[float] = None

class UpdateUserProfile(BaseModel):
    name: Optional[str] = None
    phone_number: Optional[str] = None
    nationality: Optional[str] = None

# --- Requirement 4: Favourites Schema ---
class FavouriteAdd(BaseModel):
    player_id: int
    entity_type: str  # "player", "team", or "tournament"
    entity_id: int

# --- AI Model Integration Schemas ---
class PlayerAIStat(BaseModel):
    track_id: int
    player_name: Optional[str] = None
    total_distance: float
    top_speed: float

class TeamAIStat(BaseModel):
    possession: Dict[str, float]
    passes_red: int
    passes_green: int
    interceptions_red: int
    interceptions_green: int

class AIMatchResult(BaseModel):
    match_id: int
    team_stats: TeamAIStat
    player_stats: List[PlayerAIStat]
    heatmap_urls: Dict[str, str]


# ============================================================
# --- 1. User & Player Onboarding ---
# ============================================================

@app.post("/api/v1/auth/register")
def create_user_profile(user: UserCreate):
    """Creates a standalone User record."""
    try:
        res = supabase.table("USERS").insert(user.dict()).execute()
        return {"status": "success", "user": res.data[0]}
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Registration failed: {str(e)}")


@app.post("/api/v1/players/profile")
def complete_player_profile(profile: PlayerProfile):
    """Creates a standalone athletic Player profile."""
    try:
        res = supabase.table("PLAYERS").insert(profile.dict()).execute()
        return {"status": "success", "profile": res.data[0]}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


# ============================================================
# --- 2. Team Management ---
# ============================================================

@app.post("/api/v1/teams")
def create_team(team: TeamCreate):
    """Creates a new team."""
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
    """Submits manual player stats after a match and updates career totals."""
    try:
        supabase.table("PLAYER_MATCH_STATS").insert(result.dict()).execute()

        player_res = supabase.table("PLAYERS").select(
            "total_goals, total_assists, total_yellow_card, total_red_card, "
            "total_appearance, total_acquisition, highest_speed, total_destination"
        ).eq("player_id", result.player_id).single().execute()

        player = player_res.data

        updated_totals = {
            "total_goals":       player["total_goals"] + result.goals,
            "total_assists":     player["total_assists"] + result.assists,
            "total_yellow_card": player["total_yellow_card"] + result.yellow_card,
            "total_red_card":    player["total_red_card"] + result.red_card,
            "total_appearance":  player["total_appearance"] + 1,
            "total_acquisition": round(player["total_acquisition"] + result.acquisition, 2),
        }

        if result.top_speed and result.top_speed > (player["highest_speed"] or 0.0):
            updated_totals["highest_speed"] = result.top_speed

        if result.total_distance:
            updated_totals["total_destination"] = round(
                (player["total_destination"] or 0.0) + result.total_distance, 2
            )

        supabase.table("PLAYERS").update(updated_totals).eq("player_id", result.player_id).execute()

        return {"status": "success", "message": "Match result submitted and career stats updated."}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.post("/api/v1/matches/team-stats")
def submit_team_match_stats(stats: TeamMatchStats):
    """Submits team-level stats for a specific match."""
    try:
        supabase.table("TEAM_MATCH_STATS").insert(stats.dict()).execute()

        team_res = supabase.table("TEAMS").select(
            "total_goals, total_passes"
        ).eq("team_id", stats.team_id).single().execute()

        team = team_res.data

        supabase.table("TEAMS").update({
            "total_goals":  team["total_goals"] + stats.goals,
            "total_passes": team["total_passes"] + stats.passes,
        }).eq("team_id", stats.team_id).execute()

        return {"status": "success", "message": "Team match stats submitted."}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


# ============================================================
# --- 6. Statistics & Scout Cards ---
# ============================================================

@app.get("/api/v1/players/{player_id}/scout-card")
def get_player_stats(player_id: int):
    """Returns the aggregated career totals for the Player's scout card dashboard."""
    try:
        res = supabase.table("PLAYERS").select(
            "full_name, position, jersey_number, nationality, height, weight, "
            "total_goals, total_assists, total_appearance, total_acquisition, "
            "total_yellow_card, total_red_card, highest_speed, total_destination, "
            "email, phone_number, team_id, profile_picture_url"
        ).eq("player_id", player_id).single().execute()
        return {"status": "success", "stats": res.data}
    except Exception as e:
        raise HTTPException(status_code=404, detail="Player not found")


# ============================================================
# --- 7. Team Transitions (History Management) ---
# ============================================================

@app.post("/api/v1/players/transfer")
def record_team_transfer(transfer: TransferRequest):
    """Updates the player's active team and records the move in team history."""
    try:
        supabase.table("PLAYERS").update(
            {"team_id": transfer.team_id}
        ).eq("player_id", transfer.player_id).execute()

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
# --- 8. Team Invitation System ---
# ============================================================

@app.post("/api/v1/invitations/send")
def send_team_invitation(invite: InvitationSend):
    """Team manager sends an invitation to a player."""
    try:
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
    """Player accepts an invitation and joins the team."""
    try:
        invite_res = supabase.table("INVITATIONS").select("*")\
            .eq("invitation_id", action.invitation_id).single().execute()

        if not invite_res.data:
            raise HTTPException(status_code=404, detail="Invitation not found")

        invite = invite_res.data

        supabase.table("PLAYERS").update({"team_id": invite["team_id"]})\
            .eq("player_id", invite["player_id"]).execute()

        supabase.table("INVITATIONS").update({"status": "accepted"})\
            .eq("invitation_id", action.invitation_id).execute()

        return {"status": "success", "message": "Player has successfully joined the team."}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.post("/api/v1/invitations/decline")
def decline_invitation(action: InvitationAction):
    """Player declines an invitation."""
    try:
        supabase.table("INVITATIONS").update({"status": "declined"})\
            .eq("invitation_id", action.invitation_id).execute()
        return {"status": "success", "message": "Invitation declined."}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.get("/api/v1/players/{player_id}/invitations")
def get_my_invitations(player_id: int):
    """Returns all pending invitations for a player."""
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
    """Receives AI analysis results and saves them to Supabase."""
    try:
        match_res = supabase.table("MATCHES").select(
            "home_team_id, away_team_id"
        ).eq("match_id", match_id).single().execute()

        home_team_id = match_res.data["home_team_id"]
        away_team_id = match_res.data["away_team_id"]

        supabase.table("TEAM_MATCH_STATS").insert({
            "match_id": match_id,
            "team_id": home_team_id,
            "goals": 0,
            "passes": result.team_stats.passes_red,
            "foul": 0,
            "corner": 0,
            "acquisition_avg": result.team_stats.possession.get("Red Team", 0.0)
        }).execute()

        supabase.table("TEAM_MATCH_STATS").insert({
            "match_id": match_id,
            "team_id": away_team_id,
            "goals": 0,
            "passes": result.team_stats.passes_green,
            "foul": 0,
            "corner": 0,
            "acquisition_avg": result.team_stats.possession.get("Green Team", 0.0)
        }).execute()

        for p_ai in result.player_stats:
            if not p_ai.player_name or p_ai.player_name in ("Unknown", "Identifying..."):
                continue

            player_res = supabase.table("PLAYERS").select("player_id").ilike(
                "full_name", f"%{p_ai.player_name}%"
            ).execute()

            if not player_res.data:
                continue

            player_id = player_res.data[0]["player_id"]
            heatmap_url = result.heatmap_urls.get(p_ai.player_name)

            supabase.table("PLAYER_MATCH_STATS").insert({
                "match_id": match_id,
                "player_id": player_id,
                "goals": 0,
                "assists": 0,
                "yellow_card": 0,
                "red_card": 0,
                "is_mvp": False,
                "acquisition": 0.0,
                "top_speed": p_ai.top_speed,
                "total_distance": p_ai.total_distance,
                "heatmap_image_url": heatmap_url
            }).execute()

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


# ============================================================
# --- 10. Profile Picture Upload (Requirement 2) ---
# ============================================================

@app.post("/api/v1/players/{player_id}/upload-photo")
async def upload_profile_picture(player_id: int, file: UploadFile = File(...)):
    """
    Uploads a player's profile picture to Supabase Storage (avatars bucket)
    and saves the public URL to the PLAYERS table.
    Requires: Supabase Storage bucket named 'avatars' set to Public.
    """
    try:
        # Read file bytes
        file_bytes = await file.read()

        # Generate a unique filename to avoid collisions
        ext = file.filename.split(".")[-1]
        filename = f"player_{player_id}_{uuid.uuid4().hex}.{ext}"

        # Upload to Supabase Storage
        supabase.storage.from_("avatars").upload(
            path=filename,
            file=file_bytes,
            file_options={"content-type": file.content_type}
        )

        # Get the public URL
        public_url = supabase.storage.from_("avatars").get_public_url(filename)

        # Save the URL to the PLAYERS table
        supabase.table("PLAYERS").update(
            {"profile_picture_url": public_url}
        ).eq("player_id", player_id).execute()

        return {"status": "success", "profile_picture_url": public_url}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


# ============================================================
# --- 11. Edit Profile (Requirement 3) ---
# ============================================================

@app.patch("/api/v1/players/{player_id}")
def update_player_profile(player_id: int, updates: UpdatePlayerProfile):
    """
    Updates only the fields that are provided — leaves all others unchanged.
    Flutter sends only the fields the user edited.
    """
    try:
        # Filter out None values so we only update what was actually sent
        data = {k: v for k, v in updates.dict().items() if v is not None}

        if not data:
            raise HTTPException(status_code=400, detail="No fields to update.")

        res = supabase.table("PLAYERS").update(data)\
            .eq("player_id", player_id).execute()

        return {"status": "success", "updated": res.data[0]}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.patch("/api/v1/users/{user_id}")
def update_user_profile(user_id: int, updates: UpdateUserProfile):
    """Updates user account info — only provided fields are changed."""
    try:
        data = {k: v for k, v in updates.dict().items() if v is not None}

        if not data:
            raise HTTPException(status_code=400, detail="No fields to update.")

        res = supabase.table("USERS").update(data)\
            .eq("user_id", user_id).execute()

        return {"status": "success", "updated": res.data[0]}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


# ============================================================
# --- 12. Favourites System (Requirement 4) ---
# ============================================================

@app.post("/api/v1/favourites")
def add_favourite(fav: FavouriteAdd):
    """
    Adds a player, team, or tournament to the user's favourites.
    entity_type must be one of: 'player', 'team', 'tournament'
    """
    try:
        res = supabase.table("FAVOURITES").insert(fav.dict()).execute()
        return {"status": "success", "favourite": res.data[0]}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.delete("/api/v1/favourites")
def remove_favourite(fav: FavouriteAdd):
    """Removes an item from favourites (unfavourite action)."""
    try:
        supabase.table("FAVOURITES").delete()\
            .eq("player_id", fav.player_id)\
            .eq("entity_type", fav.entity_type)\
            .eq("entity_id", fav.entity_id).execute()
        return {"status": "success", "message": "Removed from favourites."}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.get("/api/v1/players/{player_id}/favourites")
def get_my_favourites(player_id: int):
    """
    Returns all favourites for a player grouped by type.
    Response: {"player": [1,2], "team": [3], "tournament": [1]}
    Flutter uses this to render the favourites screen.
    """
    try:
        res = supabase.table("FAVOURITES").select("*")\
            .eq("player_id", player_id).execute()

        # Group by entity_type for easier consumption in Flutter
        grouped: Dict[str, List[int]] = {"player": [], "team": [], "tournament": []}
        for fav in res.data:
            entity_type = fav["entity_type"]
            if entity_type in grouped:
                grouped[entity_type].append(fav["entity_id"])

        return {"status": "success", "favourites": grouped}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.get("/api/v1/players/{player_id}/favourites/{entity_type}/{entity_id}")
def check_is_favourite(player_id: int, entity_type: str, entity_id: int):
    """
    Checks if a specific item is favourited.
    Flutter uses this to set the heart icon state (filled/empty).
    """
    try:
        res = supabase.table("FAVOURITES").select("favourite_id")\
            .eq("player_id", player_id)\
            .eq("entity_type", entity_type)\
            .eq("entity_id", entity_id).execute()
        return {"status": "success", "is_favourite": len(res.data) > 0}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
