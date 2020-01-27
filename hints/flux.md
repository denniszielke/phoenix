# Flux

Flux is an operator running in your cluster that will watch outside repos and configuration files for changes. If a change is detected it will pull and re-apply the desired configuration. The difference to a classic CI/CD pipleline is that you declaratively describe the entire desired state of your system in git.
Read about GitOps and flux: https://www.weave.works/technologies/gitops/

## How to install flux
https://docs.fluxcd.io/en/latest/tutorials/get-started-helm.html

## Design considerations for your config and code repo
https://docs.fluxcd.io/en/1.17.1/faq.html#technical-questions

