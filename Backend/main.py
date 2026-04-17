import os
from typing import Optional, Dict
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
    allow_origins=["*"],  # Tighten this to your Flutter app's domain in production
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
    user_id: int
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
    tshirt_colors: Dict[str, str]  # JSON: {"primary": "#HEX", "secondary": "#HEX"}


class MatchResult(BaseModel):
    match_id: int
    player_id: str
    goals: int
    assists: int
    yellow_card: int
    red_card: int
    is_mvp: bool
    acquisition: float


class TransferRequest(BaseModel):
    player_id: str
    team_id: int
    tournament_id: int


# ============================================================
# --- 1. User & Player Onboarding ---
# ============================================================

@app.post("/api/v1/auth/register")
def create_full_profile(user: UserCreate):
    """Creates a User record and returns the new user ID to begin Player profile creation."""
    try:
        res = supabase.table("USERS").insert(user.dict()).execute()
        return {"status": "success", "user": res.data[0]}
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Registration failed: {str(e)}")


@app.post("/api/v1/players/profile")
def complete_player_profile(profile: PlayerProfile):
    """Links the User account to an athletic Player profile."""
    try:
        res = supabase.table("PLAYERS").insert(profile.dict()).execute()
        return {"status": "success", "profile": res.data[0]}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


# ============================================================
# --- 2. Discovery Endpoints (For the 'Search' Screen) ---
# ============================================================

@app.get("/api/v1/teams/discover")
def list_teams():
    """Returns all teams and their kit colors for the join-team selection screen."""
    try:
        res = supabase.table("TEAMS").select("team_id, team_name, tshirt_colors").execute()
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
# --- 3. Tournament & Match Flow ---
# ============================================================

@app.get("/api/v1/tournaments/active")
def get_tournaments():
    """Fetches all tournaments and their associated matches."""
    try:
        res = supabase.table("TOURNAMENTS").select("*, MATCHES(*)").execute()
        return {"status": "success", "data": res.data}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.get("/api/v1/matches/{match_id}")
def get_match_details(match_id: int):
    """Returns full details of a single match, including both team stats."""
    try:
        res = supabase.table("MATCHES").select(
            "*, TEAM_MATCH_STATS(*)"
        ).eq("match_id", match_id).single().execute()
        return {"status": "success", "match": res.data}
    except Exception as e:
        raise HTTPException(status_code=404, detail="Match not found")


# ============================================================
# --- 4. Match Result Submission ---
# ============================================================

@app.post("/api/v1/matches/result")
def submit_match_result(result: MatchResult):
    """
    Submits a player's stats for a specific match and automatically
    updates their cumulative career totals on the PLAYERS table.
    """
    try:
        # Step 1: Insert the per-match stats row
        supabase.table("PLAYER_MATCH_STATS").insert(result.dict()).execute()

        # Step 2: Fetch current career totals for this player
        player_res = supabase.table("PLAYERS").select(
            "total_goals, total_assists, total_yellow_card, total_red_card, total_appearance, total_acquisition"
        ).eq("player_id", result.player_id).single().execute()

        player = player_res.data

        # Step 3: Calculate updated career totals and increment appearance count
        updated_totals = {
            "total_goals":       player["total_goals"] + result.goals,
            "total_assists":     player["total_assists"] + result.assists,
            "total_yellow_card": player["total_yellow_card"] + result.yellow_card,
            "total_red_card":    player["total_red_card"] + result.red_card,
            "total_appearance":  player["total_appearance"] + 1,
            "total_acquisition": round(player["total_acquisition"] + result.acquisition, 2),
        }

        # Step 4: Write updated totals back to the PLAYERS table
        supabase.table("PLAYERS").update(updated_totals).eq("player_id", result.player_id).execute()

        return {"status": "success", "message": "Match result submitted and career stats updated."}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


# ============================================================
# --- 5. Statistics & Scout Cards (The Core Value) ---
# ============================================================

@app.get("/api/v1/players/{player_id}/scout-card")
def get_player_stats(player_id: str):
    """Returns the aggregated career totals for the Player's profile/scout card dashboard."""
    try:
        res = supabase.table("PLAYERS").select(
            "full_name, position, jersey_number, nationality, height, weight, "
            "total_goals, total_assists, total_appearance, total_acquisition, "
            "total_yellow_card, total_red_card, highest_speed, total_destination"
        ).eq("player_id", player_id).single().execute()
        return {"status": "success", "stats": res.data}
    except Exception as e:
        raise HTTPException(status_code=404, detail="Player not found")


@app.get("/api/v1/players/{player_id}/matches")
def get_player_match_history(player_id: str):
    """Returns a full history of every match this player has participated in."""
    try:
        res = supabase.table("PLAYER_MATCH_STATS").select(
            "goals, assists, yellow_card, red_card, is_mvp, acquisition, "
            "heatmap_image_url, MATCHES(match_date, tournament_id, video_url)"
        ).eq("player_id", player_id).execute()
        return {"status": "success", "history": res.data}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


# ============================================================
# --- 6. Team Transitions (History Management) ---
# ============================================================

@app.post("/api/v1/players/transfer")
def record_team_transfer(transfer: TransferRequest):
    """
    Updates the player's active team and records the move in team history.
    Uses a request body instead of query params for security.
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


@app.get("/api/v1/players/{player_id}/team-history")
def get_player_team_history(player_id: str):
    """Returns the full list of teams a player has been part of across tournaments."""
    try:
        res = supabase.table("TEAM_MEMBERS_HISTORY").select(
            "history_id, TEAMS(team_name, tshirt_colors), TOURNAMENTS(tournament_name, start_date, end_date)"
        ).eq("player_id", player_id).execute()
        return {"status": "success", "history": res.data}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
