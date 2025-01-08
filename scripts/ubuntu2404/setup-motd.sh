#!/usr/bin/env bash
set -ex

# Ubuntu uses pam-motd, for docs see:
# http://www.linux-pam.org/Linux-PAM-html/sag-pam_motd.html

# add the ECS motd banner
cat <<'EOF' >>/tmp/31-banner
   ,     #_
   ~\_  ####_
  ~~  \_#####\
  ~~     \###|
  ~~       \#/ ___   Ubuntu 24.04 (ECS Optimized) by pigri
   ~~       V~' '->
    ~~~         /
      ~~._.   _/
         _/ _/
       _/m/'

For documentation, visit https://github.com/pigri/ubuntu-ecs-ami
EOF
sudo mv /tmp/31-banner /etc/update-motd.d/31-banner
