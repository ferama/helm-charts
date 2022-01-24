# k8svpn

## Usage

[Helm](https://helm.sh) must be installed to use the charts.  Please refer to
Helm's [documentation](https://helm.sh/docs) to get started.

Once Helm has been set up correctly, add the repo as follows:

    helm repo add k8svpn https://ferama.github.io/k8svpn

If you had already added this repo earlier, run `helm repo update` to retrieve
the latest versions of the packages.  You can then run `helm search repo
k8svpn` to see the charts.

To install the k8svpn chart:

    helm install vpn k8svpn/k8svpn

To uninstall the chart:

    helm delete vpn