import os
from typing import List, Optional, Dict
from fastapi import FastAPI, HTTPException
from dotenv import load_dotenv
from supabase import create_client, Client
from pydantic import BaseModel

load_dotenv()

# --- Config ---
url: str = os.environ.get("SUPABASE_URL")
key: str = os.environ.get("SUPABASE_KEY")
supabase: Client = create_client(url, key)

app = FastAPI(title="OFFSIDE: Advanced Sports Backend")

# --- Schemas for Flutter ---

class UserCreate(BaseModel):
    name: str
    email: str
    nationality: str
    phone_number: str

class PlayerProfile(BaseModel):
    user_id: int
    full_name: str
    jersey_number: int
    position: str
    team_id: Optional[int] = None
    height: float
    weight: float

class TeamCreate(BaseModel):
    team_name: str
    tshirt_colors: Dict[str, str] # JSON: {"primary": "#HEX", "secondary": "#HEX"}

class MatchResult(BaseModel):
    match_id: int
    player_id: str
    goals: int
    assists: int
    yellow_card: int
    is_mvp: bool

# --- 1. User & Player Onboarding ---

@app.post("/api/v1/auth/register")
def create_full_profile(user: UserCreate):
    """Creates a User and returns the ID to start the Player profile creation."""
    try:
        res = supabase.table("users").insert(user.dict()).execute()
        return {"status": "success", "user": res.data[0]}
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Registration failed: {str(e)}")

@app.post("/api/v1/players/profile")
def complete_player_profile(profile: PlayerProfile):
    """Links the User account to an athletic Player profile."""
    try:
        res = supabase.table("players").insert(profile.dict()).execute()
        return {"status": "success", "profile": res.data[0]}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# --- 2. Discovery Endpoints (For the 'Search' Screen) ---

@app.get("/api/v1/teams/discover")
def list_teams():
    """Returns teams and their kit colors for the join-team selection screen."""
    try:
        res = supabase.table("teams").select("team_id, team_name, tshirt_colors").execute()
        return {"status": "success", "teams": res.data}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# --- 3. Tournament & Match Flow ---

@app.get("/api/v1/tournaments/active")
def get_tournaments():
    """Fetches all active tournaments and their matches."""
    try:
        # Complex join: Tournament -> Matches -> Teams
        res = supabase.table("tournaments").select("*, matches(*)").execute()
        return {"status": "success", "data": res.data}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# --- 4. Statistics & Scout Cards (The Core Value) ---

@app.get("/api/v1/players/{player_id}/scout-card")
def get_player_stats(player_id: str):
    """Returns the aggregated totals for the Player's profile dashboard."""
    try:
        res = supabase.table("players").select(
            "full_name, total_goals, total_assists, total_appearance, total_acquisition"
        ).eq("player_id", player_id).single().execute()
        return {"status": "success", "stats": res.data}
    except Exception as e:
        raise HTTPException(status_code=404, detail="Player stats not found")

@app.get("/api/v1/players/{player_id}/matches")
def get_player_match_history(player_id: str):
    """Returns a list of every match this player has played in."""
    try:
        res = supabase.table("player_match_stats").select(
            "goals, assists, yellow_card, is_mvp, matches(match_date, tournament_id)"
        ).eq("player_id", player_id).execute()
        return {"status": "success", "history": res.data}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# --- 5. Team Transitions (History Management) ---

@app.post("/api/v1/players/transfer")
def record_team_transfer(player_id: str, team_id: int, tournament_id: int):
    """Updates the player's active team and records the history."""
    try:
        # 1. Update Player Table (Current Team)
        supabase.table("players").update({"team_id": team_id}).eq("player_id", player_id).execute()
        # 2. Record in History Table
        history = {"player_id": player_id, "team_id": team_id, "tournament_id": tournament_id}
        supabase.table("team_members_history").insert(history).execute()
        return {"status": "success", "message": "Transfer recorded"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))