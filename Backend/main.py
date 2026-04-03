import os
from fastapi import FastAPI, HTTPException
from dotenv import load_dotenv
from supabase import create_client, Client
from pydantic import BaseModel
from typing import Optional

# 1. Load your Supabase credentials from the .env file
load_dotenv()

url: str = os.environ.get("SUPABASE_URL")
key: str = os.environ.get("SUPABASE_KEY")

# Initialize Supabase client
if not url or not key:
    print("Error: Could not find SUPABASE_URL or SUPABASE_KEY in .env file")
else:
    supabase: Client = create_client(url, key)

# --- 2. DATA MODELS ---

class Player(BaseModel):
    player_id: str
    full_name: str
    jersey_number: int
    nationality: str
    height: float
    weight: float
    position: str
    team_id: int

# NEW: Team model for the new endpoint
class Team(BaseModel):
    team_name: str
    coach_name: str
    city: Optional[str] = None  # Optional field in case you want to add location later

# --- 3. INITIALIZE FASTAPI ---
app = FastAPI(title="OFFSIDE Backend API")

@app.get("/")
def root():
    return {"message": "OFFSIDE Backend is running!"}

@app.get("/test-connection")
def test_db():
    """Check if we can read from the database"""
    try:
        response = supabase.table("players").select("*").limit(1).execute()
        return {"status": "connected", "sample_data": response.data}
    except Exception as e:
        return {"status": "error", "message": str(e)}

# --- 4. PLAYER ENDPOINTS ---

@app.post("/register-player")
def register_player(player: Player):
    """Receives player data from Flutter and saves it to Supabase."""
    try:
        data = player.dict()
        response = supabase.table("players").insert(data).execute()
        return {"status": "success", "data": response.data}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/players")
def get_players():
    """Fetches all players from the Supabase 'players' table."""
    try:
        response = supabase.table("players").select("*").execute()
        return {"status": "success", "count": len(response.data), "data": response.data}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/players/{player_id}")
def get_player_by_id(player_id: str):
    try:
        response = supabase.table("players").select("*").eq("player_id", player_id).execute()
        if not response.data:
            raise HTTPException(status_code=404, detail="Player not found")
        return {"status": "success", "data": response.data[0]}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.put("/update-player/{player_id}")
def update_player(player_id: str, player_updates: dict):
    try:
        response = supabase.table("players").update(player_updates).eq("player_id", player_id).execute()
        if not response.data:
            raise HTTPException(status_code=404, detail="Player not found to update")
        return {"status": "success", "message": "Player updated", "data": response.data[0]}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.delete("/delete-player/{player_id}")
def delete_player(player_id: str):
    try:
        supabase.table("players").delete().eq("player_id", player_id).execute()
        return {"status": "success", "message": f"Player {player_id} deleted"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# --- 5. TEAM ENDPOINTS (NEW) ---

@app.post("/add-team")
def add_team(team: Team):
    """
    Creates a new team in the Supabase 'teams' table.
    """
    try:
        # Convert the team object to a dictionary
        team_data = team.dict()
        
        # Insert into the 'teams' table in Supabase
        response = supabase.table("teams").insert(team_data).execute()
        
        return {"status": "success", "message": "Team added successfully", "data": response.data}
    
    except Exception as e:
        # If the table 'teams' doesn't exist yet, this will catch the error
        raise HTTPException(status_code=400, detail=f"Database Error: {str(e)}")

@app.get("/teams")
def get_teams():
    """Fetches all teams available."""
    try:
        response = supabase.table("teams").select("*").execute()
        return {"status": "success", "data": response.data}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))