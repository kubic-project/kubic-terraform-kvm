cat <<EOF > ssh_config
Host $(echo $(terraform output -json | jq -r '.ips.value[][]'))
   User root
   IdentityFile $PWD/ssh_id_shared
   StrictHostKeyChecking no
   UserKnownHostsFile=/dev/null
EOF
