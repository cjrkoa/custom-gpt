from pymongo import MongoClient
from dotenv import load_dotenv
from os import environ

load_dotenv()

def get_database():
   USERNAME = environ.get("MONGO_USERNAME")
   PASSWORD = environ.get("MONGO_PASSWORD")
   # Provide the mongodb atlas url to connect python to mongodb using pymongo
   CONNECTION_STRING = f"mongodb+srv://{USERNAME}:{PASSWORD}@savedpromptresponses.hc4a3tj.mongodb.net/?retryWrites=true&w=majority"
 
   # Create a connection using MongoClient. You can import MongoClient or use pymongo.MongoClient
   client = MongoClient(CONNECTION_STRING)
 
   # Create the database for our example (we will use the same database throughout the tutorial
   return client['saved_prompt_responses']
  
# This is added so that many files can reuse the function get_database()
if __name__ == "__main__":   
  
   # Get the database
   dbname = get_database()