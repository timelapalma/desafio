> Repositório dedicado à criação da estrutura para um desafio técnico, com foco em conceitos de observabilidade e na abordagem mental do nosso novo colega de equipe, carinhosamente chamado de novo membro do conselho

## O que é o La Palma?

O La Palma é uma equipe multidisciplinar comprometida com a observabilidade dos produtos da empresa. Diferente de monitoramentos isolados, pontuais ou reativos, buscamos integrar e conectar diferentes áreas funcionais, proporcionando ferramentas escaláveis e reutilizáveis.

**Por que "La Palma"?** La Palma é uma ilha do arquipélago das Ilhas Canárias, no Oceano Atlântico. Devido à sua localização e altitudes elevadas, abriga diversos observatórios, incluindo o sítio astronômico com a maior concentração de telescópios do Hemisfério Norte.

![monitoring](imgsrc/monitoring.png?raw=true)

## A entrevista não é o bastante?

Optamos por criar um desafio que não serve apenas como um teste, mas como uma oportunidade de apresentação. Nesta etapa, queremos que você compreenda um pouco das arquiteturas e estruturas utilizadas em nossos sistemas e, ao mesmo tempo, observar como você aborda problemas e a sua percepção sobre observabilidade. Em suma, nosso objetivo é garantir que tanto a empresa quanto o candidato estejam alinhados, facilitando a adaptação e aumentando as chances de sucesso.

Para este desafio, sua missão pode ser resumida em 1 tweet:

**Criar uma visão de observabilidade sobre uma aplicação.** 

Para oferecer um contexto mais claro, esperamos que você:

- Em seu projeto, desenvolva alternativas para avaliarmos a disponibilidade da aplicação com base nos conceitos dos "Golden Signals".
- Também será interessante verificar estados internos e comportamentos por meio de rastros (traces), especialmente na avaliação de um perfil sênior de arquiteto.
- O uso de ferramentas open source não é obrigatório, mas seria enriquecedor para a discussão, especialmente considerando que elas estarão presentes em seu dia a dia, como o OpenTelemetry.
- Sinta-se à vontade para alterar a estratégia de instrumentação, trocar o framework, utilizar SDKs ou até mesmo reformular a aplicação inteira, caso prefira.

---

## O que deve ser entregue? <img align="center" alt="JonesTip" height="100" style="border-radius:0px;" src="imgsrc/JonesTip.gif"> 

O objetivo é apresentar uma arquitetura baseada em ferramentas de observabilidade. Nesta entrega, você deverá proporcionar uma visão da saúde de uma aplicação simples, capaz de receber uma requisição HTTP e responder com um valor entre 1 e 6 (simulando um lançamento de dados).

O conceito de saúde é um aspecto que gostaríamos de discutir, portanto, não iremos impor restrições. Você é o arquiteto e o responsável pelo ambiente, então utilize este espaço para demonstrar sua visão sobre como avaliaria a saúde da sua aplicação. Sinta-se à vontade para empregar mais de um pilar, implementar alertas, adicionar novos coletores, utilizar novas ferramentas e explorar abordagens conhecidas, como Golden Signals e Red Metrics, ou até ajustar a aplicação base requerida adicionando por exemplo, uma camada de persistência para armazenar o resultado de cada consulta executada (o valor obtido com o rolar de dados). **A sua interpretação sobre observabilidade é o que realmente importa.**

## Onde deve ser entregue? <img align="center" alt="GirlTip" height="100" style="border-radius:0px;" src="imgsrc/GirlTip.gif"> 

**Onde posso construir minha solução?** Forneceremos uma conta de testes em um ambiente de nuvem, que terá algumas limitações, como a gestão de IAM e um crédito máximo de 100 dólares. No entanto, isso será suficiente, pois nosso foco não está na complexidade do ambiente fornecido, mas sim na estratégia e nas escolhas que você fará durante a construção. 

Alternativamente, você pode optar por desenvolver sua solução em uma infraestrutura própria usando Docker Compose. Durante o processo, você será questionado teoricamente sobre alternativas para garantir a resiliência da arquitetura escolhida em um cenário produtivo hipotético.

**Você decide se quer construir do zero ou partir de um modelo:** Criamos uma arquitetura de referência que serve como uma amostra do nosso ambiente. No entanto, você é encorajado a desenvolver sua própria solução, utilizando as ferramentas com as quais já está familiarizado, para demonstrar sua visão de observabilidade.

## Arquitetura Proposta: <img align="center" alt="Lego" height="150" style="border-radius:0px;" src="imgsrc/lego.gif"> 

O ambiente criado para este desafio é composto por uma aplicação Python simples, entregue em uma instância EC2 usando docker compose, a aplicação utiliza o framework flask e está encapsulada em Docker.

## Instalação na conta de testes na AWS

Toda a configuração do ambiente de referência para o desafio foi entregue em uma automação com docker compose, disponível na pasta [observability](https://github.com/timelapalma/desafio/tree/main/observability), o ambiente foi estruturado para uma entrega dentro da AWS, mas você pode ajustar para uma execução local se preferir, basta que possua uma VM disponível com docker e docker-compose instalados.

Ao acessar a conta na AWS inicie uma sessão no serviço cloud shell:

![cloudshell gif](imgsrc/cloudshell.gif?raw=true)

A partir do cloud shell execute:

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

1.4. Verifique a partir do plan que o modelo fara a entrega de uma instância ubuntu com base no template de [cloud-init](https://cloudinit.readthedocs.io/en/latest/) alocado no arquivo ["infra/templates/server.yaml"](https://github.com/timelapalma/desafio/blob/main/infra/templates/server.yaml) bem como as regras de liberação dos grupos de segurança para comunicacão entre o prometheus e as aplicações.

1.5 Execute a implantação via terraform:

```sh
terraform apply
```

> Será configurada uma nova instância via terraform com o prometheus, grafana e um security group rodando a aplicação de testes, aguarde até o final do setup e acesse as URLs apresentadas no Output do terraform.

## Estrutura do ambiente de referência:

Conforme citado para o desafio criamos uma arquitetura simples de referência que utiliza dois Load Balancers respectivamente para aplicação e monitoração e uma instância EC2 com Docker Compose responsável pelos contâiners que compõem a solução, essa arquitetura pode ser entregue em um ambiente de testes na AWS que será fornecido por nós. 

| LoadBalancer | Descrição                                    | Path        | Porta | Função                                                                                            |
| -------------|----------------------------------------------|-------------|-------|---------------------------------------------------------------------------------------------------|
| Server       | Endpoint com loadbalancer da aplicação flask | /           | 80    | Aplicação rolar dados, retorna um núm. randômico entre 1 e 6                                      |
| Server       | Endpoint com loadbalancer da aplicação flask | /metrics    | 80    | Retorna métricas a partir da biblioteca prometheus-flask-exporter                                 |
| Grafana      | Endpoint com loadbalancer do Grafana         | /           | 80    | Grafana rodando em contêiner com ingestão das métricas da aplicação flask (Usuário e Senha admin) |

Utilizando o endereço público da instância na AWS também é possível acessar os endpoints do node-exporter na porta 9100 e o endpoint do cAdvisor na path /containers e porta 8080.

---

**Até o nosso próximo café ou cerveja, onde discutiremos a sua solução**  <img align="left" alt="Foco" height="50" style="border-radius:0px;" src="imgsrc/coffee.gif?raw=true"> <img align="left" alt="Foco" height="50" style="border-radius:0px;" src="imgsrc/beer.gif?raw=true">
