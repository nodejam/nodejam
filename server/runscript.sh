cd "$(dirname "$0")"
export NODE_PATH=$NODE_PATH:`pwd`/app/lib
node "$@"
