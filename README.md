# RKE2 test

...

Prerequisites:

- Hyper-V installed
- Vagrant **>= 2.4.0** (<https://developer.hashicorp.com/vagrant/downloads?product_intent=vagrant>)
- kubectl (`winget install --id Kubernetes.kubectl`)
- helm (`winget install --id Helm.Helm`)
- mkcert (`winget install --id FiloSottile.mkcert`)
- [SitecoreDockerTools](https://github.com/Sitecore/docker-tools/blob/main/README.md#powershell-module) installed

## Up

> NOTE: Vagrant commands needs to run as admin.

- `vagrant up`
- `(vagrant ssh nixs1 --no-tty -c "cat /etc/rancher/rke2/rke2.yaml") -replace "server: https://127.0.0.1:6443", "server: https://nixs1.rke2.lab:6443" | Out-File -Path ./.kubeconfig`
- `$env:KUBECONFIG="./.kubeconfig"`

- `helm repo add longhorn https://charts.longhorn.io`
- `helm repo update`
- `helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --version 1.5.1`
- `kubectl apply -f .\workloads\longhorn\ --namespace longhorn-system`
- open <http://longhorn.rke2-test.lab/>

- `kubectl create namespace sample`
- `kubectl apply -f .\workloads\sample\ --namespace sample`
- open <http://sample.rke2-test.lab/>

- `Import-Module SitecoreDockerTools;ConvertTo-CompressedBase64String -Path "C:\License\license.xml" | Out-File -Encoding ascii -NoNewline -FilePath .\workloads\xm\sitecore-license.txt`
- `mkcert -cert-file ".\workloads\xm\cm-tls.crt" -key-file ".\workloads\xm\cm-tls.key" "cm-xm.rke2-test.lab"`
- `mkcert -cert-file ".\workloads\xm\id-tls.crt" -key-file ".\workloads\xm\id-tls.key" "id-xm.rke2-test.lab"`
- `kubectl create namespace xm`
- `kubectl apply -n xm -k .\workloads\xm`
- open <https://cm-xm.rke2-test.lab/>

tools:

- If you don't have k9s installed locally, you can run it with: `vagrant ssh nixs1 -c k9s`

## TODO's

- fix "Nameserver limits were exceeded, some nameservers have been omitted, the applied nameserver line is: 4.2.2.1 4.2.2.2 208.67.220.22"
  - seems to be Ubuntu issue...
- preload "common images" with `C:\var\lib\rancher\rke2\bin\ctr.exe images pull mcr.microsoft.com/dotnet/samples:aspnetapp-nanoserver-ltsc2022`?

## Notes

- Longhorn is Linux only and used for the SQL and Solr volumes.
- Longhorn requires at least 3 nodes to be able to replicate data and become healthy.
- CM and ID logs are only persisted in [emptyDir](https://kubernetes.io/docs/concepts/storage/volumes/#emptydir)
- Launching many servers / agents at the same time may result in various rke2 startup issues due to Docker Hub throttling.

## Links

- Inspired by <https://github.com/rgl/rke2-vagrant>
