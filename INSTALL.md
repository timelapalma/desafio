# Processo de configuração:

Toda a configuração do ambiente de referência para o desafio foi entregue dentro de uma automação com docker compose, disponível na pasta [observability](https://github.com/timelapalma/desafio/tree/main/observability), o ambiente foi estruturado para uma entrega dentro da AWS, mas você pode ajustar para uma execução local se preferir.

# Instalação na conta de testes na AWS

Ao acessar a conta na AWS inicie uma sessão no serviço cloud shell:

![cloudshell gif](imgsrc/cloudshell.gif?raw=true)

Apartir do cloud shell execute:

1.1. Cópia do repositório git:
```sh
# Git
git clone https://github.com/timelapalma/desafio.git
```

1.2. Instalação das dependências:
```sh
sudo yum install -y yum-utils shadow-utils && \
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo && \
sudo yum -y install terraform
```

1.3. Inicie o terraform:

```sh
cd desafio/infra

terraform init
```

1.4. Verifique a partir do plan que o modelo fara a entrega de uma instancia ubuntu com base no template de [cloud-init](https://cloudinit.readthedocs.io/en/latest/) alocado no diretório "iac/templates" bem como as regras de liberação dos grupos de segurança para comunicacão entre o prometheus e as aplicações

```sh
terraform apply
```

> Será configurada uma nova instancia via terraform com o prometheus e um security group rodando a aplicação de testes, aguarda até o final do setup e acesse as URLs mostradas no Output do terraform.

---

**La Palma**