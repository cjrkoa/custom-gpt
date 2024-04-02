"use client"

import React, { Fragment, useState } from "react";

const axios = require("axios");

export default function Home() {
  const [question, setQuestion] = useState("")
  const [answer, setAnswer] = useState("")
  
  const submitQuestion = async (event) => {
    event.preventDefault();

    const q = {question: question};
    console.log(q);

    await axios.post("http://127.0.0.1:5000/", q).then(
      response => {
        console.log(response);
        
        if(response.status === 200) {
          setAnswer(response.data.message)
        } else { console.log("Error Posting Question") }

      }).catch(error => { console.log(error) });
  }

  return (
    <Fragment>
      <div className="grid grid-cols-5 grid-rows-8 gap-1 h-screen bg-gray-900">
        <h1 className="col-span-5 row-span-1 text-center bg-violet-950 py-10">OTT Chatbot</h1>
        <h1 className="col-span-5 row-span-6 px-5 py-2.5">{answer}</h1>
        <div className="grid grid-cols-subgrid grid-rows-subgrid col-span-5 row-span-1">
          <input 
            type="text" 
            className="col-span-4 px-5 bg-gray-500"
            placeholder="What is a load balancer?"
            onChange={e => setQuestion(e.target.value)}
            />
          <button 
            className="bg-green-500 hover:bg-green-300 text-white font-bold rounded col-span-1"
            onClick={(e) => submitQuestion(e)}
            >
              Submit
          </button>
        </div>
      </div>
    </Fragment>
  );
}
