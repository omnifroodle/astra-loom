for e in "ASTRA_ID" "ASTRA_REGION" "ASTRA_USERNAME" "ASTRA_PASSWORD"; do
  if [[ -z "${!e}" ]] ; then
    printf "\n❗ The $e environment variable is required. Please enter its value.\n" &&
    read -s -p "Value: " ${e} ;
    eval "$(gp env -e $e="${!e}")"
  fi
done