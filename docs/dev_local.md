# Local Development

```bash
HUGO_VERSION=0.145.0
HUGO_ENVIRONMENT=production
RUNNER_TEMP="/tmp"

echo $RUNNER_TEMP

wget -O $RUNNER_TEMP/hugo.deb "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.deb"
sudo dpkg -i $RUNNER_TEMP/hugo.deb

# initialize Hugo Theme submodule
git submodule update --init --recursive

make setup-hugo
``` 
