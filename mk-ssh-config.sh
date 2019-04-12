# Git does not atore information about full file permissions, only about the
# executable bit.
chmod 600 ssh_id_shared

cat <<EOF > ssh_config
Host $(echo $(terraform output -json | jq -r '.ips.value[][]'))
   User root
   IdentityFile $PWD/ssh_id_shared
   StrictHostKeyChecking no
   UserKnownHostsFile=/dev/null
EOF
