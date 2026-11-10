# substrate-website

The website for [Substrate](https://github.com/substrate-lang/substrate),
written in Substrate. The page uses
[web-ui](https://github.com/substrate-lang/web-ui), and its playground compiles
and runs programs in the browser. The server uses the standard library's HTTP
server.

It uses the substrate repository next to this one. In the dev shell
(`nix develop`):

    ../substrate/bin/substrate test -A                 # the tests, most of them in Chromium
    ../substrate/bin/substrate site website            # the page, in build/sites/website
    ../substrate/bin/substrate serve build/sites/website

To run the site with its own server:

    ../substrate/bin/substrate build serve.sub -o build/serve
    ../substrate/bin/substrate run -R=build/sites/website -N=127.0.0.1 build/serve build/sites/website
