
install-theme:
    cd site;
    hugo new theme

setup-hugo:
    cd site
    hugo server --buildDrafts
    hugo server -D