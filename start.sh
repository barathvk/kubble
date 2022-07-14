#!/usr/bin/env bash
DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
STACK_DIR="$DIR/.stack"

mkdir -p "$STACK_DIR/.temp/html" "$STACK_DIR/html"

gucci -f "$1" "$DIR/templates/main.tf.tpl" > "$STACK_DIR/.temp/main.tf"
gucci -f "$1" "$DIR/templates/Caddyfile.tpl" > "$STACK_DIR/.temp/Caddyfile"
gucci -f "$1" "$DIR/templates/html/index.html" > "$STACK_DIR/.temp/html/index.html"


grep "\S" "$STACK_DIR/.temp/main.tf" > "$STACK_DIR/main.tf"
grep "\S" "$STACK_DIR/.temp/Caddyfile" > "$STACK_DIR/Caddyfile"
grep "\S" "$STACK_DIR/.temp/html/index.html" > "$STACK_DIR/html/index.html"

rm -rf "$STACK_DIR/.temp"

terraform fmt "$STACK_DIR"

terraform -chdir="$STACK_DIR" init -upgrade
terraform -chdir="$STACK_DIR" apply -auto-approve