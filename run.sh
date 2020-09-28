#!/bin/sh
auto_gen_ssh_key() {
  expect -c "set timeout -1;
    	spawn ssh-keygen;
	expect {
	    *(/root/.ssh/id_rsa)* {send -- \r;exp_continue;}
		*passphrase)* {send -- \r;exp_continue;}
		*again*	{send -- \r;exp_continue;}
		*(y/n)* {send -- y\r;exp_continue;}
		eof         {exit 0;}
	}";
}


if [ "x${BASE}" == "x" ]; then
  BASE="/"
fi


if [ "x${REMOTE_SSH_SERVER}" == "x" ]; then
  # Login mode, no SSH_SERVER
  node . -p ${WETTY_PORT}
else
  # SSH connect mode
  #
  # Preload key
  REMOTE_SSH_SERVER=$(ip a | grep inet | grep -v inet6 | grep -v 127 | sed 's/^[ \t]*//g' | cut -d ' ' -f2 | cut -d '/' -f1);
  auto_gen_ssh_key;
  cp /root/.ssh/id_rsa.pub ${REMOTE_PUB_KEY_DIR}/authorized_keys
  chmod 700 ${REMOTE_PUB_KEY_DIR}
  ssh-keyscan -H -p ${REMOTE_SSH_PORT} ${REMOTE_SSH_SERVER} > ~/.ssh/known_hosts

  cmd="node . -p ${WETTY_PORT} --sshhost ${REMOTE_SSH_SERVER} --sshport ${REMOTE_SSH_PORT} --base ${BASE} --bypasshelmet" 
  if ! [ "x${REMOTE_SSH_USER}" == "x" ]; then
    cmd="${cmd} --sshuser ${REMOTE_SSH_USER}"
  fi
  if ! [ "x${SSH_AUTH}" == "x" ]; then
    cmd="${cmd} --sshauth ${SSH_AUTH}"
  fi
  if ! [ "x${KNOWN_HOSTS}" == "x" ]; then
    cmd="${cmd} --knownhosts ${KNOWNHOSTS}"
  fi
  if ! [ "x${SSH_KEY}" == "x" ]; then
    cmd="${cmd} --sshkey ${SSH_KEY}"
  fi
  ${cmd}
fi
