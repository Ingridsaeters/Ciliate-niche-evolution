#!/bin/bash


echo "(((" > Ciliate_constraint.txt
cat Dinoflagellata.txt.csv >> Ciliate_constraint.txt

echo "), (" >> Ciliate_constraint.txt
cat Apicomplexa.txt.csv >> Ciliate_constraint.txt

echo "), (" >> Ciliate_constraint.txt
cat Colponemidae.txt.csv >> Ciliate_constraint.txt

echo "), (" >> Ciliate_constraint.txt
cat Colpodellidea.txt.csv >> Ciliate_constraint.txt

echo ")), (((" >> Ciliate_constraint.txt
cat Karyorelictea.txt.csv >> Ciliate_constraint.txt

echo "), (" >> Ciliate_constraint.txt
cat Heterotrichea.txt.csv >> Ciliate_constraint.txt

echo ")), (((" >> Ciliate_constraint.txt
cat Litostomatea.txt.csv >> Ciliate_constraint.txt

echo "), (" >> Ciliate_constraint.txt
cat Armophorea.txt.csv >> Ciliate_constraint.txt

echo "), (" >> Ciliate_constraint.txt
cat Spirotrichea.txt.csv >> Ciliate_constraint.txt

echo ")), ((" >> Ciliate_constraint.txt
cat Colpodea.txt.csv >> Ciliate_constraint.txt

echo "), (" >> Ciliate_constraint.txt
cat Oligohymenophorea.txt.csv >> Ciliate_constraint.txt

echo "), (" >> Ciliate_constraint.txt
cat Nassophorea.txt.csv >> Ciliate_constraint.txt

echo "), (" >> Ciliate_constraint.txt
cat Prostomatea.txt.csv >> Ciliate_constraint.txt

echo "), (" >> Ciliate_constraint.txt
cat Plagiopylea.txt.csv >> Ciliate_constraint.txt

echo "), (" >> Ciliate_constraint.txt
cat Phyllopharyngea.txt.csv >> Ciliate_constraint.txt

echo ")))));" >> Ciliate_constraint.txt



cat Ciliate_constraint.txt | tr -d '\n' > Ciliate_constraint.txt.tre
