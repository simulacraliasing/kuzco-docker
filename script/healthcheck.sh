#!/bin/bash

# Check if the ollama process is running
pgrep_ollama=$(pgrep ollama)

if [ -z "$pgrep_ollama" ]; then
    exit 1
else
    exit 0
fi