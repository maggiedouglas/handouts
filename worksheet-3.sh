# configure git

git config --global user.name "maggiedouglas"
git config --global user.email "maggiedouglas22@gmail.com"
git commit --no-edit --amend --reset-author

# link your local repository to the origin repository on GitHub

git remote add origin https://github.com/maggiedouglas/handouts.git
git push -u origin master
