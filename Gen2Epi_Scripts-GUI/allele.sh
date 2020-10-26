#/bin/bash

sed -n -e '/<br>/I,/<\/textarea>/I p' por.tfa >por1.tfa
sed -i '/<\/textarea>/,$d;$a <\/textarea>' por1.tfa
sed 's/.*>//' por1.tfa | sed 's/&gt;/>/' | sed -r '/^\s*$/d' >/home/gen2epi/Downloads/ngmaster-master/ngmaster/db/POR.tfa

sed -n -e '/<br>/I,/<\/textarea>/I p' tbpb.tfa >tbpb1.tfa
sed -i '/<\/textarea>/,$d;$a <\/textarea>' tbpb1.tfa
sed 's/.*>//' tbpb1.tfa | sed 's/&gt;/>/' | sed -r '/^\s*$/d' >/home/gen2epi/Downloads/ngmaster-master/ngmaster/db/TBPB.tfa

