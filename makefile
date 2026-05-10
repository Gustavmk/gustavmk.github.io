
install-reqs:
    apt install -y hugo
    sudo npm install -g sass

setup-hugo:
    hugo server --buildDrafts
    hugo server -D
