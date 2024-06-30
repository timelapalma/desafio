# Desafio

Detalhes sobre a arquitetura deste ambiente e o que deve ser entregue no desafio;

## O que deve ser entregue?

**Você é quem decide:** Optamos por criar uma arquitetura de referência que representa uma amostra do nosso ambiente. Isso facilitará sua compreensão do dia a dia caso você se junte ao time. No entanto, você pode optar por criar sua própria solução, usando as ferramentas que já conhece e mostrando sua visão de observabilidade.

**Onde posso construir minha solução?** Forneceremos uma conta de testes em um ambiente de nuvem, com algumas limitações, como gestão de IAM e um máximo de 100 dólares de crédito. Mas isso será suficiente, pois o objetivo final não é a complexidade do ambiente entregue, e sim a estratégia e as escolhas na construção.

## Arquitetura e porposta:

O ambiente criado para este desafio é composto por uma aplicação Python simples, entregue em duas instâncias. A aplicação utiliza o framework Flask e está encapsulada em Docker. (Muitas das aplicações dos nossos times utilizam Docker e fazem parte de arquiteturas de micro serviços). 

Há uma configuração básica para exposição de métricas implementada usando o [prometheus flask exporter](https://pypi.org/project/prometheus-flask-exporter/), essa solução pode ser consultada na pasta build *(utilizamos prometheus em nossa arquitetura de coleta de métricas).*,

## O que precisa ser desenvolvido?

Sua missão pode ser resumida em 1 tweet: **Utilizar pelo menos um dos três pilares de observabilidade para criar uma visão da saúde de uma aplicação.** 

Aqui o conceito de saúde é algo que queremos discutir, por isso nada será imposto, você é o arquiteto, e dono do ambiente, então utilize este espaço para mostrar sua ideia de como avaliaria a saúde de uma aplicação, e claro é ;liberado o uso de mais de um pilar, a criação de alertas, a exploração de abordagens conhecidas como Golden Signals, Red Metrics, vale tudo!

### Lembre-se, a solução e a aplicação é sua... ###

O uso da linguagem Python foi uma escolha arbitraria, queriamos ter um ponto de partida que possibilitasse uma arquitetura simples, e demandasse menos do seu tempo, mas pode ser mudada, se preferir troque a linguagem, troque a solução inteira! sua concepção sobre observabilidade é o que conta aqui.

**Até o nosso próximo café ou cerveja!**

---

## Estrutura do ambiente de referência:

| Desc                                         | Path        | Porta | Função                                                                                                            |
|----------------------------------------------|-------------|-------|-------------------------------------------------------------------------------------------------------------------|
| Endpoint com loadbalancer da aplicação flask | /           | 80    | Aplicação rolar dados, retorna um núm. randômico entre 1 e 6                                                      |
| Endpoint com loadbalancer da aplicação flask | /metrics    | 80    | Retorna métricas a partir da biblioteca prometheus-flask-exporter                                                 |
| Endpoint/porta do prometheus                 | /graph      | 80    | prometheus rodando em contêiner com ingestão das métricas da aplicação flask                                      |
| Endpoint/porta do grafana                    | /           | 3000  | grafana rodando em contêiner para criação dos dashboard e sua visão de observabilidade (usuário e senha admin)    |
| Endpoint/porta do node-exporter              | /metrics    | 9100  | node-exporter rodando em contêiner com ingestão das métricas da EC2 que sustenta a stack com grafana e prometheus |
| Endpoint/porta do cAdvisor                   | /containers | 8080  | cAdvisor rodando em contêiner com ingestão das métricas dos outros componentes da stack                           |