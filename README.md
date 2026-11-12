# substrate-website

The website for [Substrate](https://github.com/substrate-lang/substrate),
written in Substrate. The site uses
[web-ui](https://github.com/substrate-lang/web-ui), and its playground compiles
and runs programs in the browser. The server uses the standard library's HTTP
server.

The dev shell (`nix develop`) has substrate, from its npm release. In it:

    substrate test -A                  # the tests, most of them in Chromium
    substrate site website             # the site, in build/sites/website
    substrate site website --release   # the site to deploy, in the same place
    social/render.sh                   # the social card, assets/og.png, from social/card.html

The site's server, at http://127.0.0.1:8000/:

    substrate run -R=build/sites/website -N=127.0.0.1 serve.sub build/sites/website
