set -e

rm -rf ../backend/dist/*.{css,js}

spago build -u "-g corefn +RTS -N2 -RTS"

zephyr -f Home.main Talk.main Search.main

NODE_ENV=production webpack -p --progress
