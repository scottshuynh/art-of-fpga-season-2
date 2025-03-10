generics=()
wave=false
clean=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -g|--generic)
      generics+=("$2")
      shift
      shift
      ;;
    -w|--wave)
      wave=true
      shift
      ;;
    -c|--clean)
      clean=true
      shift
      ;;
    *)
      shift
      ;;
  esac  
done

generics_flat=""
for generic in "${generics[@]}"
do
  generics_flat="${generics_flat}g${generic}"
done