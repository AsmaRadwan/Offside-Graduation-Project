import os
from fastapi import FastAPI, HTTPException
from dotenv import load_dotenv
from supabase import create_client, Client
from pydantic import BaseModel

# 1. Load your Supabase credentials from the .env file
load_dotenv()

url: str = os.environ.get("SUPABASE_URL")
key: str = os.environ.get("SUPABASE_KEY")

# Initialize Supabase client
if not url or not key:
    print("Error: Could not find SUPABASE_URL or SUPABASE_KEY in .env file")
else:
    supabase: Client = create_client(url, key)

# 2. Define the Player Data Structure (matches your Supabase table)
class Player(BaseModel):
    player_id: str
    full_name: str
    jersey_number: int
    nationality: str
    height: float
    weight: float
    position: str
    team_id: int

# 3. Initialize FastAPI
app = FastAPI(title="OFFSIDE Backend API")

@app.get("/")
def root():
    return {"message": "OFFSIDE Backend is running!"}

# 4. The "End Point" for your Flutter developer
@app.post("/register-player")
def register_player(player: Player):
    """
    Receives player data from Flutter and saves it to Supabase.
    """
    try:
        # Convert the player object to a dictionary and insert into Supabase
        data = player.dict()
        response = supabase.table("players").insert(data).execute()
        
        return {"status": "success", "data": response.data}
    
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/test-connection")
def test_db():
    """Check if we can read from the database"""
    try:
        response = supabase.table("players").select("*").limit(1).execute()
        return {"status": "connected", "sample_data": response.data}
    except Exception as e:
        return {"status": "error", "message": str(e)}
    

    # 5. The "Read" Endpoint - To show players in the Flutter app
@app.get("/players")
def get_players():
    """
    Fetches all players from the Supabase 'players' table.
    """
    try:
        # This tells Supabase: "Select all columns (*) from the players table"
        response = supabase.table("players").select("*").execute()
        
        # We return the data so the Flutter app can display it in a list
        return {"status": "success", "count": len(response.data), "data": response.data}
    
    except Exception as e:
        # If the database is down or the table name is wrong, we'll see it here
        raise HTTPException(status_code=400, detail=str(e))


    # 6. Get a specific player by their ID
@app.get("/players/{player_id}")
def get_player_by_id(player_id: str):
    try:
        # Search for the row where player_id matches the one in the URL
        response = supabase.table("players").select("*").eq("player_id", player_id).execute()
        
        # If the list is empty, it means the ID doesn't exist
        if not response.data:
            raise HTTPException(status_code=404, detail="Player not found")
            
        return {"status": "success", "data": response.data[0]}
    
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
    
    # 7. Delete a specific player by their ID
@app.delete("/delete-player/{player_id}")
def delete_player(player_id: str):
    try:
        supabase.table("players").delete().eq("player_id", player_id).execute()
        return {"status": "success", "message": f"Player {player_id} deleted"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
    
    # 8. Update an existing player's details
@app.put("/update-player/{player_id}")
def update_player(player_id: str, player_updates: dict):
    try:
        # We tell Supabase: "Find the player with this ID and update their info"
        response = supabase.table("players").update(player_updates).eq("player_id", player_id).execute()
        
        if not response.data:
            raise HTTPException(status_code=404, detail="Player not found to update")
            
        return {"status": "success", "message": "Player updated", "data": response.data[0]}
    
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))