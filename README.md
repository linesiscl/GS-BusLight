
# BusLight

**Monitoramento inteligente do tempo de espera do transporte público.**

## 1. Sobre o projeto

O **BusLight** é uma solução desenvolvida no contexto da iniciativa **CitizenTech**, com o objetivo de melhorar o acesso à informação sobre o transporte público e auxiliar os cidadãos no acompanhamento do tempo de espera dos ônibus.

O projeto utiliza dados disponibilizados pela API Olho Vivo da SPTrans para consultar previsões de chegada dos veículos em pontos de ônibus cadastrados. A partir dessas informações, uma automação verifica se o tempo de espera ultrapassa um limite previamente estabelecido, registra os resultados e gera alertas quando necessário.

Esses alertas são utilizados pelo MVP físico do projeto, no qual um robô consulta as informações registradas e sinaliza situações que precisam de atenção por meio de luzes e/ou movimentos.

## 2. Problema identificado

A espera pelo transporte público pode gerar incerteza para os passageiros, principalmente quando não há informações acessíveis sobre a previsão de chegada dos ônibus.

O BusLight busca contribuir para esse cenário por meio do monitoramento automatizado das previsões de chegada, permitindo identificar situações em que o tempo de espera está acima do padrão configurado e transmitir essa informação ao cidadão por meio de uma sinalização física.

## 3. Objetivos

- Consultar automaticamente as previsões de chegada dos ônibus.
- Monitorar diferentes combinações de linhas e pontos de parada.
- Calcular o tempo estimado de espera dos veículos.
- Identificar esperas acima do limite configurado.
- Registrar previsões, alertas e informações de execução.
- Integrar os alertas ao MVP físico, responsável pela sinalização visual ou por movimentos.

## 4. Integrantes

| Integrante | RM |
|---|---|
| Aline Fernandes | RM97966 |
| Camilly Breitbach Ishida | RM551474 |
| Julia Leite Galvão | RM550201 |

## 5. Arquitetura da solução

A solução é composta por quatro componentes principais:

1. **API Olho Vivo – SPTrans:** fornece os dados de previsão de chegada e informações sobre os veículos das linhas consultadas.
2. **Power Automate Desktop:** executa o fluxo de automação, realiza as consultas, processa os dados e aplica as regras de negócio.
3. **PowerShell e Excel:** o PowerShell realiza as requisições à API, enquanto o Excel armazena os cadastros, previsões, alertas e logs.
4. **Robô físico – MVP:** consulta os alertas registrados e realiza a sinalização por meio de luzes e/ou movimentos.

### Fluxo geral da arquitetura

```text
API Olho Vivo – SPTrans
          |
          v
Power Automate Desktop
          |
          v
PowerShell – Consultas e processamento
          |
          v
Excel – Previsões, alertas e logs
          |
          v
Robô físico – MVP
          |
          v
Sinalização ao cidadão
```

## 6. Tecnologias utilizadas

| Tecnologia | Finalidade |
|---|---|
| Power Automate Desktop | Desenvolvimento e execução da automação |
| PowerShell | Requisições HTTP e processamento das respostas da API |
| Excel | Armazenamento dos cadastros, previsões, alertas e logs |
| API Olho Vivo – SPTrans | Obtenção dos dados de previsão dos ônibus |
| GitHub | Versionamento e documentação do projeto |
| Robô físico | Sinalização dos alertas gerados pela automação |

## 7. Regras de negócio

A automação utiliza os parâmetros cadastrados na planilha de linhas para determinar quando uma espera deve gerar um alerta.

As principais regras são:

- Somente linhas cadastradas como ativas são processadas.
- Cada linha é consultada considerando seu código de linha e código de parada.
- O tempo de espera é calculado a partir do horário previsto de chegada.
- O limite de espera é definido pela soma do tempo normal de espera com o limite de excedente configurado.
- Quando o tempo previsto ultrapassa esse limite, a previsão recebe o status `ESPERA_ACIMA_PADRAO`.
- Quando o tempo permanece dentro do limite, recebe o status `NORMAL`.
- A automação evita gerar alertas duplicados para a mesma combinação de linha, ponto de parada e data.
- Quando não existem previsões disponíveis, a situação é registrada sem ser automaticamente considerada uma falha de execução.

### Exemplo de cálculo

Considerando uma linha com:

- Espera normal: 15 minutos.
- Limite de excedente: 10 minutos.

O limite configurado será de 25 minutos.

Se a previsão indicar uma espera de 30 minutos, a automação identificará uma situação de espera acima do padrão e poderá gerar um alerta.

## 8. Instruções de utilização

### Pré-requisitos

- Windows.
- Power Automate Desktop instalado.
- Microsoft Excel.
- PowerShell disponível no sistema.
- Token de acesso à API Olho Vivo da SPTrans.
- Arquivo Excel do projeto com as abas e tabelas necessárias.

### Configuração

1. Obtenha um token de acesso à API Olho Vivo da SPTrans.
2. Configure o token na variável de ambiente do Windows com o nome `SPTRANS_TOKEN`.
3. Disponibilize o arquivo `BusLight.xlsx`, configurando seu caminho no fluxo de automação.
4. Preencha a aba `Linhas` com os códigos das linhas e pontos que serão monitorados.
5. Configure os parâmetros de espera normal, limite excedente e status de ativação de cada cadastro.
6. Abra o fluxo no Power Automate Desktop.
7. Execute a automação para iniciar as consultas e o processamento das informações.

### Estrutura da planilha

O arquivo Excel possui as seguintes abas:

| Aba | Finalidade |
|---|---|
| Linhas | Cadastro das linhas e pontos monitorados |
| Previsões | Registro das previsões e dos tempos de espera |
| Alertas | Armazenamento dos alertas gerados |
| Logs | Registro das execuções e possíveis falhas |

## 10. Testes realizados

Os testes do projeto têm como objetivo verificar o funcionamento das consultas, o processamento das informações e a geração dos alertas.

Entre os cenários de teste estão:

- Consulta de uma linha e ponto de parada cadastrados.
- Consulta de múltiplas linhas e pontos.
- Processamento de linhas ativas e desativadas.
- Identificação de espera dentro do limite configurado.
- Identificação de espera acima do limite.
- Geração e prevenção de alertas duplicados.
- Tratamento de consultas sem previsões disponíveis.
- Registro das execuções na aba de logs.

As evidências dos testes estão organizadas na pasta `tests/`.

## 11. Segurança e privacidade

O projeto utiliza dados de previsão do transporte público disponibilizados pela API Olho Vivo da SPTrans.

O token de autenticação é armazenado em uma variável de ambiente do Windows, evitando sua exposição direta no código-fonte ou nas planilhas compartilhadas.

A solução não tem como finalidade coletar dados pessoais dos passageiros. Os registros são voltados ao monitoramento das linhas, pontos de parada, previsões e alertas.

## 12. MVP e demonstração

O MVP do Ponto Vivo utiliza um robô físico para transformar os alertas gerados pela automação em notificações perceptíveis ao cidadão.

A integração permite que as informações processadas digitalmente sejam utilizadas pelo dispositivo físico para realizar sinalizações por meio de luzes e/ou movimentos.

- **Vídeo demonstrativo:** [https://youtu.be/7DY7e3Tm4jg]


