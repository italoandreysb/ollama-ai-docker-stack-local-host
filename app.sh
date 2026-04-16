#!/bin/bash
curl http://localhost:11434/api/generate -d '{
  "model": "mistral",
  "prompt": "Olá, qual é a capital do Brasil?",
  "stream": false
}'