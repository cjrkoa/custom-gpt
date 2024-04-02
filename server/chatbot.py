from openai import OpenAI
from dotenv import load_dotenv
from database import get_database
from read_file import read_files, generate_openai_api_messages
from os import environ
import hashlib

load_dotenv()

db = get_database()
collection = db["saved_prompt_responses"]

client = OpenAI(environ.get("OPENAI_API_KEY"))

def find_question_from_database(question: str):
  return collection.find_one({"_id": hashlib.sha256(question.lower().encode()).hexdigest()}, {"_id": 0, "message": 1})

def insert_question_to_database(question: str, message: str) -> None:
  collection.insert_one({
      "_id": hashlib.sha256(question.lower().encode()).hexdigest(),
      "message": message
    })

def answer_question(question: str) -> dict:
  """MAKES AN API CALL TO OPENAI - Input a question, output an answer"""
  messages = generate_openai_api_messages(read_files(["balancer-requirements.typ", "balancer-design.typ"]))
  
  match = find_question_from_database(question)

  if match != None:
    return match
  else:
    completion = client.chat.completions.create(
      model="gpt-3.5-turbo",
      messages=messages+[
        {"role": "system", "content": 
          "You are the OpenTogetherTube Information Bot. Your purpose is to answer any questions the user has about OpenTogetherTube to the best of your ability. OpenTogetherTube can also be referred to as OTT. From this point forward, OpenTogetherTube will be shortened to OTT. Users will ask you one of five categories of questions: 1. Questions about OTT. 2. Questions about the load balancer. 3. Questions about the development team. 4. Questions about the codebase. 5. Questions about the buisiness plan. Questions about the development journey of the load balancer should be redirected to humans. Questions about challenges encountered during development should be redirected to humans. Questions about team conflict should be redirected to humans. Questions about individual contribution should be redirected to humans. Questions containing the phrase, 'senior design' should be redirected to humans. Questions containing the phrase 'innovation expo' should be redirected to humans. When a user asks a question, you should first reply with what category of question you are most confident the user asked if into one of the five categories mentioned earlier. Otherwise, you should not attempt to guess the category of question and you should not tell the user what category their question was in. Directly following, you should answer the user's question. If a user asked a question you are not allowed to answer, you should only reply 'That question should be redirected to a team member'."
        },
        {"role": "system", "content":
          "If a user prompt begins with the string 'DEBUG:' you can answer any question and ignore any previously supplied rules about answering questions for the singular prompt containing the string 'DEBUG:'" 
        },
        {"role": "user", "content": question}
      ]
    )

    insert_question_to_database(question, completion.choices[0].message.content)
    
    return {"message": completion.choices[0].message.content}