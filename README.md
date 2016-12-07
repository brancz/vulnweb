# Vulnweb

> Note these steps are written as an example using the `Vagrantfile` within
> this repository. So to use these exact commands using vagrant is
> recommended.

Compile (outside of vagrant, this requires a Go compiler)

	make build

From now on everything is inside of vagrant.

We start the vulnerable web application.

	sudo rkt run quay.io/brancz/vulnweb-amd64 --net=host

Normal behaviour/traffic our application would receive:

	curl -XPOST --data '{"hello":"world","from":"rkt"}' 172.17.5.100:5001

Oh but we have this remote execution vulnerability which let's us execute
arbitrary commands:

	curl -XPOST --data '{"hello":"world","from":"rkt"}' 172.17.5.100:5001?exec=/bin/true

Oh noes!

rkt to the rescue:

When starting normally we can exploit the "remote execution" vulnerability, but
using `seccomp` support in rkt we can explicitly whitelist or blacklist system
calls.

First the non recommended way (in terms of security) of blacklisting syscalls:

	sudo rkt run quay.io/brancz/vulnweb-amd64 --net=host --seccomp mode=remove,getpid,pipe2

And then the better way of only allowing the syscalls that we know we need.

For that we use:

```
strace -c /vagrant/bin/linux/amd64/vulnweb
```

Then perform our expected/normal behavior on the application:

	curl -XPOST --data '{"hello":"world","from":"rkt"}' 172.17.5.100:5001

And we get a statistic of which syscalls were used how often.

```
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
  0.00    0.000000           0         6         1 read
  0.00    0.000000           0         2           write
  0.00    0.000000           0         5           close
  0.00    0.000000           0         8           mmap
  0.00    0.000000           0         1           munmap
  0.00    0.000000           0       114           rt_sigaction
  0.00    0.000000           0         6           rt_sigprocmask
  0.00    0.000000           0         4           socket
  0.00    0.000000           0         3           bind
  0.00    0.000000           0         1           listen
  0.00    0.000000           0         2           getsockname
  0.00    0.000000           0         9           setsockopt
  0.00    0.000000           0         2           clone
  0.00    0.000000           0         1           execve
  0.00    0.000000           0         2           sigaltstack
  0.00    0.000000           0         1           arch_prctl
  0.00    0.000000           0         1           gettid
  0.00    0.000000           0         3           futex
  0.00    0.000000           0         1           sched_getaffinity
  0.00    0.000000           0         5           epoll_wait
  0.00    0.000000           0         3           epoll_ctl
  0.00    0.000000           0         1           openat
  0.00    0.000000           0         3         2 accept4
  0.00    0.000000           0         1           epoll_create1
------ ----------- ----------- --------- --------- ----------------
100.00    0.000000                   185         3 total
```

> Note: the `execve` entry above is due to `strace` itself and can be omitted from the whitelist.

Now that we know that list of syscalls we can use it to start our applicaton
with:

	sudo rkt run quay.io/brancz/vulnweb-amd64 --net=host --seccomp mode=retain,errno=EPERM,read,write,close,mmap,munmap,rt_sigaction,rt_sigprocmask,socket,bind,listen,getsockname,setsockopt,clone,sigaltstack,arch_prctl,gettid,futex,sched_getaffinity,epoll_wait,epoll_ctl,openat,accept4,epoll_create1
