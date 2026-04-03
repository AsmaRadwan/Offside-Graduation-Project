import os
from fastapi import FastAPI, HTTPException
from dotenv import load_dotenv
from supabase import create_client, Client
from pydantic import BaseModel

# Load Supabase credentials from the .env file
load_dotenv()

url: str = os.environ.get("SUPABASE_URL")
key: str = os.environ.get("SUPABASE_KEY")

# Initialize Supabase client
if not url or not key:
    print("Error: Could not find SUPABASE_URL or SUPABASE_KEY in .env file")
else:
    supabase: Client = create_client(url, key)

# Define Data Structures
class Player(BaseModel):
    player_id: str
    full_name: str
    jersey_number: int
    nationality: str
    height: float
    weight: float
    position: str
    team_id: int

class Team(BaseModel):
    team_name: str

# Initialize FastAPI
app = FastAPI(title="OFFSIDE Backend API")

@app.get("/")
def root():
    return {"message": "OFFSIDE Backend is running!"}

# --- Teams Endpoints ---

@app.post("/add-team")
def add_team(team: Team):
    """add new team"""
    try:
        data = team.dict()
        response = supabase.table("teams").insert(data).execute()
        return {"status": "success", "data": response.data}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/teams")
def get_teams():
    """display all teams"""
    try:
        response = supabase.table("teams").select("*").execute()
        return {"status": "success", "data": response.data}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# --- Players Endpoints ---

@app.post("/register-player")
def register_player(player: Player):
    try:
        data = player.dict()
        response = supabase.table("players").insert(data).execute()
        return {"status": "success", "data": response.data}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/test-connection")
def test_db():
    try:
        response = supabase.table("players").select("*").limit(1).execute()
        return {"status": "connected", "sample_data": response.data}
    except Exception as e:
        return {"status": "error", "message": str(e)}

@app.get("/players")
def get_players():
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

@app.delete("/delete-player/{player_id}")
def delete_player(player_id: str):
    try:
        supabase.table("players").delete().eq("player_id", player_id).execute()
        return {"status": "success", "message": f"Player {player_id} deleted"}
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
