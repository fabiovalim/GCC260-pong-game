![Demonstração do jogo](pong-game-demons.gif)

# Pong Game - Verilog (FPGA)

- Este é um jogo **Pong** implementado em **Verilog** para FPGA, baseado nos capítulos 13 e 14 do livro  
[*FPGA Prototyping by Verilog Examples*](https://www.amazon.com.br/FPGA-Prototyping-Verilog-Examples-Spartan/dp/0470185317) de Pong P. Chu.

## Sobre o projeto

O jogo **Pong** foi adaptado para **um único jogador** e implementado na placa **DE10-Lite**.  
O objetivo é controlar o paddle (barra) para rebater a bola e impedir que ela saia da tela.

## Controles

- **Movimentação do paddle**:  
  - `KEY[0]` → **Sobe**  
  - `KEY[1]` → **Desce**  
- **Reinício do jogo**:  
  - `SW[0]` → **Resetar** o jogo  

## Requisitos

- **Placa FPGA**: [**DE10-Lite**](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&No=1046)
- **Quartus Prime**
- **Conhecimento básico de Verilog**

> 🚀 *Divirta-se jogando Pong na FPGA!*