#fncWriteVarToNewFile <var> <file> <mode> <user>
#Overwrites file if it exists
function fncWriteVarToNewFile {
  printf "Writing $1 to $2 with ${3+default} for ${4+currentuser}...\n"
  printf "$1\n" > "$2"
  if [ -z "$3" ]; then
    chmod $3 $2 
  fi
  if [ -z "$4" ]; then
    chown $4:$4 $2
  fi
}

#fncWriteVarToFile <var> <file>
function fncWriteVarToFile {
  printf "Writing $1 to $2...\n"
  printf "$1\n" >> "$2"
}

#fncWriteVarToFileIfNotIn <var> <file>
# -q quiet -F not regex -x whole line
function fncWriteVarToFileIfNotIn {
  if [ ! "$(grep -qFx "$1" "$2")" ]; then
    printf "Writing $1 to $2...\n"
    fncWriteVarToFile "$1" "$2"
  else
    printf "$1 is already in $2!\n"
  fi
}
