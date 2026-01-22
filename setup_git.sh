#!/bin/bash
echo "# multi-project-data-plataform" >> README.md
git init
# Note: You might want to add all files, not just README.md?
# git add .
git add .
git commit -m "first commit"
git branch -M main
git remote add origin git@github.com:dedeco/multi-project-data-plataform.git
git push -u origin main
