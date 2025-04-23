if [ -z "$1" ]; then
  echo "Error: Version argument is required."
  exit 1
fi
rm -rf emsdk-$1

curl -L https://github.com/emscripten-core/emsdk/archive/refs/tags/$1.zip -o emcc.zip

unzip emcc.zip  || { echo "Error: Failed to extract zip file" >&2; exit 1; }

rm -rf /$HOME/emsdk
cp -r emsdk-$1 /$HOME/emsdk

/$HOME/emsdk/emsdk install $1
/$HOME/emsdk/emsdk activate $1 > /dev/null

#add to .bashrc

if !  grep -q '#emcc_setup' $HOME/.bashrc; then

    echo '#emcc_setup' >>  $HOME/.bashrc
    echo 'export PATH="$PATH:/$HOME/emsdk"' >> $HOME/.bashrc
    echo 'export PATH="$PATH:/$HOME/emsdk/upstream/emscripten"' >> $HOME/.bashrc
    echo 'export PATH="$PATH:/$HOME/emsdk/node/20.18.0_64bit/bin"' >> $HOME/.bashrc
fi

source $HOME/.bashrc
echo "Emscripten $1 installed and activated successfully."
rm -rf emcc.zip
rm -rf emsdk-$1

