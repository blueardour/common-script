

# 2020.05.17
## install pandoc and reveal.js
pushd /workspace/git/
if [ ! -f reveal.js ];
then
  git clone https://github.com/hakimel/reveal.js
  sudo apt-get install pandoc npm grunt
fi

