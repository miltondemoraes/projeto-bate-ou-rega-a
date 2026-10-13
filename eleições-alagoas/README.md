# Bate ou Regaça da Matemática: Marco dos Corais

Jogo educativo de matemática para crianças, feito em **Godot 4.6**. É inspirado no quadro *Bate ou Regaça* e se passa no **Marco dos Corais**, na orla de Ponta Verde, em Maceió-AL.

## Como jogar
1. No menu, escolha o personagem (Marechal Deodoro, Roberto Firmino, Djavan ou Zagallo) e a dificuldade.
2. Os outros 3 personagens viram **robôs**.
3. Em cada rodada aparece uma pergunta de matemática com 4 opções. Responda com o **mouse** ou as **teclas 1 a 4**.
4. **Acertou:** você escolhe qual robô leva o tapa. Uma barra de força começa a correr e você aperta **ESPAÇO** (ou clica) na hora certa:
   - zona verde = **TAPA PERFEITO** (o robô voa mais alto e mais longe);
   - amarela = forte; vermelha = fraco.
5. **Errou ou o tempo acabou:** a resposta certa aparece com a explicação, e um robô dá o tapa em você.
6. Quem leva o tapa é **arremessado aos ares e cai no mar** do Marco dos Corais (TCHIBUM!) e perde 1 vida.
7. Você tem 3 vidas e cada robô tem 2. Tire todos os robôs do deck para ser o campeão.

| Dificuldade | Tempo | Conteúdo | Barra de força |
|---|---|---|---|
| Fácil | 20 s | + e − até 20, formas geométricas, dobro, probleminhas | lenta |
| Médio | 14 s | contas até 100, tabuada, divisão exata, metade | média |
| Difícil | 9 s | multiplicação maior, ordem das operações, número que falta, quadrados, frações | rápida |

## Restrições do trabalho

| Requisito | Como foi atendido |
|---|---|
| Engine Godot | Godot 4.6, GDScript. A cena `scenes/main.tscn` monta tudo por código. |
| Só iluminação global | Não há **nenhum** `DirectionalLight3D`, `OmniLight3D` ou `SpotLight3D`, e nenhum material usa emissão. A cena é iluminada só pela luz ambiente do `WorldEnvironment` (céu procedural). O céu clareia o topo dos objetos e escurece a parte de baixo, o que dá volume. O SSAO escurece as frestas. Veja `world.gd → _environment()`. |
| Tudo com primitivas 3D | Só `BoxMesh`, `SphereMesh`, `CylinderMesh` (também usado como cone), `CapsuleMesh`, `PrismMesh`, `TorusMesh` e `PlaneMesh`. Não há nenhum modelo importado. Até os números das camisas (9 e 13) são caixas no estilo display de 7 segmentos. |
| Personagens reconhecíveis | Veja a tabela abaixo. |

### Personagens

- **Marechal Deodoro**: sobrecasaca militar azul do século XIX, dragonas e botões dourados, **faixa presidencial verde e amarela** (foi o 1º presidente), medalhas, espada, botas de montaria, calça com lista vermelha e barba branca cheia. Segura o **quepe** na mão e o ergue ao acenar no menu, lembrando o quadro da Proclamação da República.
- **Roberto Firmino**: uniforme vermelho do Liverpool com o **9** nas costas, chuteiras coloridas, o famoso **sorrisão branco**, cavanhaque, tatuagens nos braços e uma bola de futebol.
- **Djavan**: **dreadlocks grisalhos**, barba grisalha, camisa de linho clara, colar de contas coloridas, **violão nas costas** e notas musicais flutuando.
- **Zagallo**: camisa amarela da Seleção com gola verde e o **13** (seu número da sorte), **4 estrelas** (as 4 Copas que ganhou), calção azul, meião branco, cabelo grisalho, **óculos** e prancheta de técnico.

### Cenário (Marco dos Corais, Maceió)
- O **deck** de madeira sobre o mar serve de palco, com pórtico de programa de TV e marcas coloridas no chão.
- **Escultura de cavalo-marinho** dentro d'água, revestida de "pastilhas de vidro" coloridas, que é o símbolo do Marco.
- **Esculturas de corais** no calçadão e corais no mar ao redor do deck.
- O **Gogó da Ema**, coqueiro de tronco torto que dá nome à praça.
- **Jangadas** balançando no mar, **piscinas naturais** (recifes) e água verde-azulada (shader com ondas).
- Ao fundo, a orla de Pajuçara, o **Porto de Maceió** (guindastes) e o farol.

## A animação do tapa
1. O atacante caminha até o alvo e a câmera muda para um plano cinematográfico lateral.
2. O atacante gira o tronco e leva a mão para trás, tremendo de "carga", enquanto a barra de força corre.
3. Ao apertar ESPAÇO, o braço varre para frente. No impacto entram **câmera lenta**, estrelinhas, tremida de câmera e o texto "PAAAF!".
4. O alvo vira um "boneco de pano" e é **arremessado em arco** (parábola), girando no ar, com a câmera acompanhando de lado.
5. Ele cai no mar com respingos e ondas circulares ("TCHIBUM!") e fica boiando. Se ainda tiver vida, afunda e reaparece no deck. Se não tiver, fica boiando com uma **boia laranja**.

## Estrutura do código
```
scenes/main.tscn      cena principal (só o nó raiz com main.gd)
scripts/main.gd       máquina de estados do jogo, rodadas, tapa, câmera e efeitos
scripts/world.gd      cenário + luz global (WorldEnvironment) + shader do mar
scripts/characters.gd os 4 personagens (roupas e detalhes)
scripts/fighter.gd    boneco articulado (cabeça, braços e pernas com pivôs) + animações com Tween
scripts/questions.gd  gerador de perguntas por dificuldade (com explicação da resposta)
scripts/ui.gd         menu, placar, perguntas, barra de força, telas de fim
scripts/prim.gd       fábrica de formas primitivas
```

## Executar
Abra a pasta no Godot 4.6 e aperte **F5**. Para gerar o executável, use *Projeto → Exportar*.
