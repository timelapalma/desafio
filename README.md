> Repositório dedicado à construção da estrutura para um desafio técnico, focando em conceitos de obsaervability e na abordagem e mentalidade do nosso novo colega de equipe ou como chamamos por aqui, nosso novo conselheiro.

## O que é o La Palma?

O La Palma é um time multidisciplinar, preocupado com a observabilidade dos produtos que provê e mantêm ferramentas e técnicas diferentemente de monitorações isoladas, pontuais ou reativas, nosso time busca ouvir e conectar áreas de funcionalidades e disponibilizar ferramentas escaláveis e reutilizáveis.

**Por que "La Palma"?** La Palma é uma ilha pertencente ao arquipélago das Ilhas Canárias, no Oceano Atlântico, devido à sua localização e suas altas montanhas, a ilha abriga inúmeros observatórios, incluindo o sítio astronômico com a maior concentração de telescópios do Hemisfério Norte.

![monitoring](imgsrc/monitoring.png?raw=true)

## A entrevista não é o bastante?

Decidimos criar um desafio não como um teste, mas como um processo de apresentação, a ideia é que, nesta etapa, você entenda um pouco das arquiteturas e estruturas usadas em nossos sistemas e, ao mesmo tempo, possamos ver como você lida com problemas e "pensa" observabilidade. Em resumo, queremos garantir que ambos, empresa e candidato, estejam na mesma página, facilitando a adaptação e aumentando as chances de sucesso.

Para este desafio, sua missão pode ser resumida em 1 tweet:

**Criar uma visão de observabilidade sobre uma aplicação.** 

Para tentar dar um pouco mais de contexto esperamos que:

- Em seu projeto construa alternativas para avaliarmos se a aplicação está disponível considerando estratégia como Golden Signals;
- Também seria interessante que possamos validar estados internos e comportamentos a partir de rastros, traces ou estratégis similares;
- O uso de ferramentas open source não é obrigatório mas será bem bacana para a discussão, principalmente envolvendo o Open Telemetry;
- Fique a vontade para mudar a estratégia de instrumentação, trocar o framework, utilizar sdks ou mudar a aplicação inteira se preferir (Trabalharemos com base em sua lógica na nossa conversa);

---

## O que deve ser entregue? <img align="center" alt="JonesTip" height="100" style="border-radius:0px;" src="imgsrc/JonesTip.gif"> 


**Requisitos Mínimos:** A proposta é que, seja apresentada uma arquitetura baseada em ferramentas de observabilidade, nessa entrega a partir de pelo menos um dos três pilares de observabilidade promova uma visão da saúde de uma aplicação simples escrita em Python, você pode alterar a linguagem se quiser, desde que, mantenha a funcionalidade atual da aplicação;

Aqui o conceito de saúde é algo que queremos discutir; por isso, nada será imposto, você é o arquiteto, e dono do ambiente, então utilize este espaço para mostrar sua ideia de como avaliaria a saúde de uma aplicação, é liberado o uso de mais de um pilar, a criação de alertas, implantação de novos coletores, novas ferramentas a exploração de abordagens conhecidas como Golden Signals, Red Metrics, vale tudo. **sua concepção sobre observabilidade é o que conta.**

## Onde deve ser entregue? <img align="center" alt="GirlTip" height="100" style="border-radius:0px;" src="imgsrc/GirlTip.gif"> 


**Onde posso construir minha solução?** Forneceremos uma conta de testes em um ambiente de nuvem, com algumas limitações, como gestão de IAM e um máximo de 100 dólares de crédito. Mas isso será suficiente, pois o objetivo final não é a complexidade do ambiente entregue, e sim a estratégia e as escolhas na construção, alternativamente você opinar por construir sua solução em uma estrutura própria usando Docker Compose.

**Você decide se quer construir do zero ou partir de nosso modelo:** Optamos por criar uma arquitetura de referência que representa uma amostra do nosso ambiente. Isso facilitará sua compreensão do dia a dia caso você se junte ao time. No entanto, você pode e deve se possível optar por criar sua própria solução, usando as ferramentas que já conhece e mostrando sua visão de observabilidade.

---

## Arquitetura Proposta: <img align="center" alt="Lego" height="150" style="border-radius:0px;" src="imgsrc/lego.gif"> 

O ambiente criado para este desafio é composto por uma aplicação Python simples, entregue em uma instância EC2 usando docke compose, a aplicação utiliza o framework flask e está encapsulada em Docker.

Há uma configuração básica para exposição de métricas implementada usando o [prometheus flask exporter](https://pypi.org/project/prometheus-flask-exporter/), essa solução pode ser consultada na pasta [observability/build](https://github.com/timelapalma/desafio/tree/main/observability/build), aqui o uso da linguagem Python foi uma escolha arbitraria, queríamos ter um ponto de partida que possibilitasse uma arquitetura simples, e demandasse menos do seu tempo.

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

Utilizando o endereço público da instância na AWS também é possível acessar os endpoints do node-exporter na path /metrics e porta 9100 e o endpoint do cAdvisor na path /containers e porta 8080.

---

**Até o nosso próximo café ou cerveja, onde discutiremos a sua solução**  <img align="left" alt="Foco" height="50" style="border-radius:0px;" src="imgsrc/coffee.gif?raw=true"> <img align="left" alt="Foco" height="50" style="border-radius:0px;" src="imgsrc/beer.gif?raw=true">
