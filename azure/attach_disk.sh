az vm disk attach \
   -g gb-group-01 \
   --vm-name az-gbp-vert-11 \
   --disk az-gbp-vert-11 \
   --new \
   --size-gb 3072

az vm disk attach \
   -g gb-group-01 \
   --vm-name az-gbp-solr-03 \
   --disk solr-03 \
   --new \
   --size-gb 600

