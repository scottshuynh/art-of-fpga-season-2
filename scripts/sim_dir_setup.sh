# Set up sim directories
if [ ! -d $SIM_WORKFLOW ]; then
  mkdir $SIM_WORKFLOW
  cd $SIM_WORKFLOW
  mkdir sim
  cd sim
else
  cd $SIM_WORKFLOW
  if [ ! -d "sim" ]; then
    mkdir sim
    cd sim
  else
    cd sim
  fi
fi

if [ "$clean" = true ]; then
  cd ..
  rm -r sim/
  exit 0
fi