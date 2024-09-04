# Instalación

sudo apt install curl -y 

cd $HOME

sudo apt-get update 

sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt1-dev libcurl4-openssl-dev libffi-dev


### (no usar cuenta root)
git clone https://github.com/rbenv/rbenv.git ~/.rbenv

echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc

echo 'eval "$(rbenv init -)"' >> ~/.bashrc

exec $SHELL

git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc

exec $SHELL

rbenv install 3.3.0

rbenv global 3.3.0


gem install bundler

rbenv rehash

gem install rails

rbenv rehash


sudo apt-get install texlive-latex-base

sudo apt-get install poppler-utils



