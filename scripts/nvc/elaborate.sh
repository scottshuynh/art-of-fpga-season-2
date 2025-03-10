generic_args=""
for generic in "${generics[@]}"
do
  generic_args="${generic_args} -g ${generic}"
done
generic_args=`echo $generic_args | xargs`

nvc -e -j $generic_args $DUT