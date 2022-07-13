#!/usr/bin/env bash
DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
STACK_DIR="$DIR/stack"

mkdir -p "$STACK_DIR"
gucci -f "$1" "$DIR/templates/main.tf.tpl" > "$STACK_DIR/main.tf.tmp"
grep "\S" "$STACK_DIR/main.tf.tmp" > "$STACK_DIR/main.tf"
rm "$STACK_DIR/main.tf.tmp"
terraform fmt "$STACK_DIR"
terraform -chdir="$STACK_DIR" init -upgrade
terraform -chdir="$STACK_DIR" apply -auto-approve