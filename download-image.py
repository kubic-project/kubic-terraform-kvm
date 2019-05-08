#!/usr/bin/python3
import hashlib
import os
from functools import reduce
from urllib.request import urlretrieve, urlopen

base_url="https://download.opensuse.org/repositories/devel:/kubic:/images/openSUSE_Tumbleweed/"

def download_file(url) -> str:
    with urlopen(url) as f:
        return f.read().decode('utf-8')

def image_name():
    html = download_file(base_url)
    name = 'openSUSE-MicroOS.x86_64-Kubic-kubeadm-kvm-and-xen.qcow2'
    name_xz = 'openSUSE-MicroOS.x86_64-Kubic-kubeadm-kvm-and-xen.qcow2.xz'
    return name_xz if name_xz in html else name

def local_sha256(filename) -> str:
    sha256 = hashlib.sha256()
    with open(filename, 'rb') as f:
        reduce(lambda _, c: sha256.update(c), iter(lambda: f.read(sha256.block_size * 128), b''), None)
    return sha256.hexdigest()

def remote_sha256(url):
    data = download_file(url + '.sha256')
    return [l for l in data.splitlines() if '.qcow2' in l][0].split()[0]

def donload_image(url: str, dst):
    last_percent_reported = 0

    def reporthook(count, blockSize, totalSize):
        nonlocal last_percent_reported
        percent = int(count * blockSize * 100 / totalSize)

        if last_percent_reported != percent:
            if percent % 5 == 0:
                print("%s%%" % percent)

            last_percent_reported = percent

    print("downloading " + url)

    urlretrieve(url, dst, reporthook=reporthook)


if __name__ == '__main__':
    name = image_name()
    dst = 'kubic.qcow2.xz' if name.endswith('xz') else 'kubic.qcow2'
    url = base_url + name
    if local_sha256(dst) == remote_sha256(url):
        print('already downloaded.')
    else:
        donload_image(url, dst)
    if name.endswith('.xz'):
        os.system('xz -k -f -v --decompress kubic.qcow2.xz')
