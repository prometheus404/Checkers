.data
board:		.space 64
msgPl0: 	.asciiz "Player 0"
msgPl1: 	.asciiz "Player 1"
msgEatAgain:	.asciiz "you can eat another piece"
msgMoveError: 	.asciiz "Illegal move"
msgSyntaxError: .asciiz "Syntax error. Retry"
msgEndPl0: 	.asciiz "The winner is player 0. Play again?"
msgEndPl1: 	.asciiz "The winner is player 1. Play again?"
.align 2
.byte	# 00 = vuota, 10 = pedina giocatore0, 11 = pedina giocatore1, 12 = damone giocatore0, 13 = damone giocatore1
backup:	
	0x10, 0x00, 0x10, 0x00, 0x10, 0x00, 0x10, 0x00,
	0x00, 0x10, 0x00, 0x10, 0x00, 0x10, 0x00, 0x10,
	0x10, 0x00, 0x10, 0x00, 0x10, 0x00, 0x10, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x11, 0x00, 0x11, 0x00, 0x11, 0x00, 0x11,
	0x11, 0x00, 0x11, 0x00, 0x11, 0x00, 0x11, 0x00,
	0x00, 0x11, 0x00, 0x11, 0x00, 0x11, 0x00, 0x11,
moves: .space 192		#4mosse*12pedine*4byte
inMove: .space 6		#6 caratteri	xn-xn\0
.text
.globl main
main:
	j ch_setup		#parte di codice che ho spostato sotto
ch_end:	addi $s7, $zero, 0	#il primo giocatore e' il player 0
turnLoop:
	jal chessboard		#disegno la scacchiera
	jal pieces		#disegno i pezzi
	addi $a0, $s7, 0
	jal turnPlayer
	bltz $v1, lose 		#se non ho mosse disponibili perdo
chk:	andi $t0, $v0, 0x38		#mi servono i 3bit della y
	beq $t0, 7, Dama		#
	bnez $t0, noDama	#rendo dama solo se si muove sulla riga 0 o 7 (non mi servono ulteriori controlli perche il giocatore 0 non puo muovere slla riga 0 a meno che non sia una dama e viceversa)
Dama:	lb $t0, board($v0)	#carico la pedina
	ori $t0, $t0, 2		#rendo una dama
	sb $t0, board($v0)	#aggiorno
noDama:
	beqz  $v1, next		#se non ho mangiato salto il controllo 
	#se ho mangiato controllo se posso mangiare
	jal chessboard
	jal pieces
	addi $a0, $v0, 0	#sposto la pedina che ha mangiato in a0
	jal circle
	addi $a0, $v0, 0	#sposto la pedina che ha mangiato in a0
	la $a1, moves		#array come secondo argomento
	move $a2, $zero		#indice mossa come ultimo argoment0
	jal p_eat		#ora ho in v0 il numero di mosse che puo fare
	beqz $v0, next		#se non ce ne sono vado oltre
	addi $s0, $v0, 0	#sposto in s0 il numero di mosse
ask:	addi $a0, $zero, 2	#chiedo di mostrare il messaggio 2
	jal askMove		#chiedi mossa all'utente
	addi $a0, $v0, 0	#passo la mossa come argomento
	addi $a1, $s0, 0	#passo il numero di mosse possibili
	jal checkMove		#controlla se presente nell'elenco e la restituisce
	addi $a0, $zero, 3	#se non è presente devo chiedere di mostrare il messaggio 3
	beqz $v0, ask		#se non presente torna a ask
	addi $a0, $v0, 0	#passo la mossa come argomento
	jal execMove		#esegue la mossa
	#in v0 ora c'è la nuova posizione  
	j chk 			#ricontrollo	
next:		
	
	xori $s7, $s7, 1	#cambio giocatore
	j turnLoop

lose:				#in s7 ho il giocatore che ha perso
	la $a0, msgEndPl0
	bnez $s7, p0		#se il giocatore 0 ha vinto va bene cosi
	la $a0, msgEndPl1
p0:	li $v0, 50
	syscall
	bnez $a0, fin
	addi $t0, $zero, 0
	j main			#ricomincio	
####################################################################################################################################
ch_setup:
	b_loop:	lw $t1, backup($t0)	#inizializza la matrice con la posizione iniziale
	sw $t1, board($t0)
	addi $t0, $t0, 4
	bne $t0, 64, b_loop
	la $s1, 0xffff0000	#indirizzo di partenza
	li $s2, 0x69cc69
	addi $a0, $s1, 0
	addi $a1, $s2,0
	jal back
	li $a1, 0x00ffffff	#bianco
	jal drawA
	xori $a1, 0x00ffffff	#cambio colore usando xor (veloce e figo)
	addi $a0, $s1, 268
	jal drawB
	xori $a1, 0x00ffffff
	addi $a0, $s1, 24
	jal drawC
	xori $a1, 0x00ffffff
	addi $a0, $s1, 292	#292 = 268 + 24
	jal drawD
	xori $a1, 0x00ffffff
	addi $a0, $s1, 48
	jal drawE
	xori $a1, 0x00ffffff
	addi $a0, $s1, 316
	jal drawF
	xori $a1, 0x00ffffff
	addi $a0, $s1, 72
	jal drawG
	xori $a1, 0x00ffffff
	addi $a0, $s1, 340
	jal drawH
	addi $s0, $zero, 0xffff0fe4	#in s0 salvo l'inizio dal fondo dei numeri
	addi $a0, $s0, 0
	xori $a1, 0x00ffffff
	jal draw8
	xori $a1, 0x00ffffff
	sub $a0, $s0, 376
	jal draw7
	xori $a1, 0x00ffffff
	sub $a0, $s0, 768
	jal draw6
	xori $a1, 0x00ffffff
	sub $a0, $s0, 1144
	jal draw5
	xori $a1, 0x00ffffff
	sub $a0, $s0, 1536
	jal draw4
	xori $a1, 0x00ffffff
	sub $a0, $s0, 1912
	jal draw3
	xori $a1, 0x00ffffff
	sub $a0, $s0, 2304
	jal draw2
	xori $a1, 0x00ffffff
	sub $a0, $s0, 2680
	jal draw1
	j ch_end
####################################################################################################################################	
chessboard:
	#####
	subu $sp, $sp, 4
	sw $ra, 0($sp)
	#####
	
	la $t0, 0xffff0000
	li $a1, 0x00000000	#parto dal nero
	addi $a0, $t0, 1024	#8*128 -> 8 righe
	jal drawLine
	addi $a0, $a0, 32	#visto che drawline restituisce la pos dellultimo pixel devo solo andare a capo
	#visto che restituisce l'ultimo colore e questo e' uguale al primo della nuova riga non devo cambiarlo
	jal drawLine
	addi $a0, $a0, 32
	jal drawLine
	addi $a0, $a0, 32
	jal drawLine
	addi $a0, $a0, 32
	jal drawLine
	addi $a0, $a0, 32
	jal drawLine
	addi $a0, $a0, 32
	jal drawLine
	addi $a0, $a0, 32
	jal drawLine
	
	#####
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	#####
	jr $ra
####################################################################################################################################
pieces: 
	#####
	subu $sp, $sp, 12
	sw $s0, 8($sp)
	sw $s1, 4($sp)
	sw $s3, 0($sp)
	#####
	addi $s0, $zero, 0	#index
	addi $s3, $zero, 64
pLoop:	lb  $t0, board($s0)
	beqz $t0, cont		#se uguale a zero passa alla prossima
	srl $t1, $s0, 3		#divisione per 8 -> riga
	andi $t2, $s0, 7	#resto divisione per 8 -> colonna
	addi $t3, $zero, 256	#indirizzo base scacchiara(8*32) + riga*3*32 + colonna*3 + 2*32 + 2 pixel
	mul $t1, $t1, 96	#offset per la riga
	mul $t2, $t2, 3		#offset per la colonna
	add $t3, $t1, $t3
	add $t3, $t2, $t3
	addi $t3, $t3, 33	#offset pixel centrale
	sll $t3, $t3, 2		#moltiplico per 4byte -> dimensione pixel
	andi $t1, $t0, 1
	addi $t4, $zero ,0x006969cc
	beqz $t1, damone
	addi $t4, $zero ,0x00cc6969
damone:	andi $t1, $t0, 2
	beqz $t1, p_draw
	subi $t4, $t4, 0x00506950
p_draw:	sw $t4, 0xffff0000($t3)
cont:	beq $s3, $s0, x
	addi $s0, $s0, 1
	j pLoop
x:	#####
	lw $s0, 8($sp)
	lw $s1, 4($sp)
	lw $s2, 0($sp)
	addi $sp, $sp, 12
	#####
	jr $ra
####################################################################################################################################
circle:				#in a0 ho la pedina da cerchiare di giallo
	srl $t1, $a0, 3		#divisione per 8 -> riga
	andi $t2, $a0, 7	#resto divisione per 8 -> colonna
	addi $t3, $zero, 256	#indirizzo base scacchiara(8*32) + riga*3*32 + colonna*3 + 2*32 + 2 pixel
	mul $t1, $t1, 96	#offset per la riga
	mul $t2, $t2, 3		#offset per la colonna
	add $t3, $t1, $t3
	add $t3, $t2, $t3
	sll $t3, $t3, 2		#moltiplico per 4byte -> dimensione pixel
	addi $t3, $t3, 0xffff0000
	addi $t4, $zero ,0x00cccc69
	sw $t4, ($t3)
	sw $t4, 4($t3)
	sw $t4, 8($t3)
	sw $t4, 128($t3)
	sw $t4, 136($t3)
	sw $t4, 264($t3)
	sw $t4, 260($t3)
	sw $t4, 256($t3)
	jr $ra
####################################################################################################################################
circleMove:			#in a0 ho il numero di mosse
	#####
	subu $sp, $sp, 8
	sw $ra, 4($sp)
	sw $s0, 0($sp)
	#####
	addi $s0, $a0, 0	#sposto in s0 il numero di mosse
cm_loop:
	subi $s0, $s0, 4	#decremento
	bltz $s0, cm_end
	lw $t1, moves($s0)	#carico la mossa
	andi $a0, $t1, 0x3f	#prendo gli ultimi sei bit (la posizione di partenza)
	jal circle		#cerchio la mossa
	j cm_loop		#ricomincio
cm_end:
	#####
	lw $ra, 4($sp)
	lw $s0, 0($sp)
	addu $sp, $sp, 8
	#####
	jr $ra
	
####################################################################################################################################
turnPlayer:			#in a0 ho il giocatore in turno
				#in v0 restituisco la nuova posizione in cui il giocatore ha mosso, se non posso muovere finisco la partita
	#####
	subu $sp, $sp, 16
	sw $ra, 12($sp)
	sw $s0, 8($sp)
	sw $s1, 4($sp)
	sw $s2, 0($sp)
	#####
	
	addi $s0, $a0, 0	#in s0 ho il giocatore in turno
	addi $s2, $zero, 1
	jal eat
	bnez $v0, dm		#se puo mangiare non controlla altre mosse
	addi $s2, $zero, 0	#se non ha mangiato restituisco 0
	addi $a0, $s0, 0	#passo come argomento il giocatore in turno
	jal move
	bnez $v0, dm		#se non può muoversi ha perso e ritorna -1
	addi $s2, $zero, -1	#restituisco -1
	j t_end
dm:	
	addi $s1, $v0, 0	#ho in s1 il numero di mosse
	addi $a0, $s1, 0
	jal circleMove
	addi $a0, $s0, 0	#giocatore come argomento
am:	jal askMove		#chiedi mossa all'utente
	addi $a0, $v0, 0	#passo la mossa come argomento
	addi $a1, $s1, 0	#passo il numero di mosse possibili
	jal checkMove		#controlla se presente nell'elenco e la restituisce
	addi $a0, $zero, 3	#preparo in a0 l'argomento per ask move nel caso la mossa non sia valida
	beqz $v0, am		#se non presente torna a am
	addi $a0, $v0, 0	#passo la mossa come argomento
	jal execMove		#esegue la mossa
	#in v0 ora c'è la nuova posizione 			
t_end:	
	move $v1, $s2
	#####
	lw $ra, 12($sp)
	lw $s0, 8($sp)
	lw $s1, 4($sp)
	lw $s2, 0($sp)
	addi $sp, $sp, 16
	#####
	jr $ra
####################################################################################################################################
eat:				#in a0 ho il giocatore in turno, in v0 restituisco il numero di mosse
	#####
	subu $sp, $sp, 20
	sw $ra, 16($sp)
	sw $s0, 12($sp)
	sw $s1, 8($sp)
	sw $s2, 4($sp)
	sw $s3, 0($sp)
	#####
	
	addi $s0, $zero, 0	#indice scacchiera
	addi $s1, $zero, 0	#indice mossa *4
	addi $s2, $zero, 64
	addi $s3, $a0, 0	#sposto a0 in s3
	
e_loop:	lb $t2, board($s0)	#metto in t2 la pedina
	beqz $t2, e_cont	#controllo che ci sia una pedina
	andi $t3, $t2, 1	#metto in t3 il bit che indica il giocatore
	bne $s3, $t3, e_cont	#cotrollo che sia la pedina del giocatore se non è sua passo alla prossima
	
	#salvo $a0 e metto in $a0 la posizione della pedina, in $a1 l'indirizzo del vettore mosse e in $a2 l'indice mossa
	move $a0, $s0		#posizione della pedina come primo argomento
	la $a1, moves		#array come secondo argomento
	move $a2, $s1		#indice mossa come ultimo argomento
	jal p_eat		#guarda che pezzi puo mangiare la pedina e aggiorna l'array
	#in $v0 ora ho l'indice mossa aggiornato
	move $s1, $v0		#aggiorna l'indice mossa
e_cont:	addi $s0, $s0, 1	#passo alla prossima pedina
	beq $s0, $s2, e_end	#se ho finito la scacchiera esco
	j e_loop		#altrimenti ricomincio
	
e_end:	
	addi $v0, $s1, 0 	#metto la lunghezza dell'array in $v0
	
	#####
	lw $ra, 16($sp)
	lw $s0, 12($sp)
	lw $s1, 8($sp)
	lw $s2, 4($sp)
	lw $s3, 0($sp)
	addi $sp, $sp, 20
	#####
	jr $ra			#restituisco il numero di mosse
####################################################################################################################################
move:				#in a0 ho il giocatore in turno, in v0 restituisco il numero di mosse
	#####
	subu $sp, $sp, 20
	sw $ra, 16($sp)
	sw $s0, 12($sp)
	sw $s1, 8($sp)
	sw $s2, 4($sp)
	sw $s3, 0($sp)
	#####
	
	addi $s0, $zero, 0	#indice scacchiera
	addi $s1, $zero, 0	#indice mossa *4
	addi $s2, $zero, 64
	addi $s3, $a0, 0	#sposto a0 in s3
	
m_loop:	lb $t2, board($s0)	#metto in t2 la pedina
	beqz $t2, m_cont	#controllo che ci sia una pedina
	andi $t3, $t2, 1	#metto in t3 il bit che indica il giocatore
	bne $s3, $t3, m_cont	#cotrollo che sia la pedina del giocatore se non è sua passo alla prossima
	
	#salvo $a0 e metto in $a0 la posizione della pedina, in $a1 l'indirizzo del vettore mosse e in $a2 l'indice mossa
	move $a0, $s0		#posizione della pedina come primo argomento
	la $a1, moves		#array come secondo argomento
	move $a2, $s1		#indice mossa come ultimo argomento
	jal p_move		#guarda che pezzi puo mangiare la pedina e aggiorna l'array
	#in $v0 ora ho l'indice mossa aggiornato
	move $s1, $v0		#aggiorna l'indice mossa
m_cont:	addi $s0, $s0, 1	#passo alla prossima pedina
	beq $s0, $s2, m_end	#se ho finito la scacchiera esco
	j m_loop		#altrimenti ricomincio
	
m_end:	
	addi $v0, $s1, 0 	#metto la lunghezza dell'array in $v0
	
	#####
	lw $ra, 16($sp)
	lw $s0, 12($sp)
	lw $s1, 8($sp)
	lw $s2, 4($sp)
	lw $s3, 0($sp)
	addi $sp, $sp, 20
	#####
	jr $ra			#restituisco il numero di mosse	
####################################################################################################################################
p_move:				###in a0 la pos della pedina, in a1 l'array, in a2 l'indice al primo spazio libero
	lb $t0, board($a0)	#in t0 carico la pedina
	andi $t1, $t0, 1	###in t1 ho il giocatore
	andi $t2, $t0, 2	
	srl $t2, $t2, 1		###in t2 ho 0 se è una pedina, 1 se è una dama
	or $t3, $t2, $t1	#diverso da zero se è giocatore 1 o dama
	bnez $t3, m_up		#se è diverso da zero può mangiare in su
pm_chk:	xori $t3, $t1, 1	#ottengo 1 se è il giocatore 0, 0 altrimenti
	or $t3, $t3, $t2	#ottengo uno se è una dama o il giocatore 0
	bnez $t3, m_dn
	j ret
m_up:	
	srl $t3, $a0, 3		#in t3 ho la riga
	beqz $t3, pm_chk	#se sulla riga 0 non si puo muovere in su
	andi $t3, $a0, 7	#in t3 ho la colonna
	beqz $t3, mup_r		#se è nella colonna 0 non puo spostarsi a sx
	subi $t3, $a0, 9	## in t3 casella in alto a sx
	lb $t4, board($t3)	#metto in t4 il contenuto della casella
	bnez $t4, mup_r		#se il contenuto non è 0 non ci posso andare
	sll $t3, $t3, 6		#altrimenti ci vado
	or $t3, $t3, $a0	#in t3 ho la mossa
	add $t4, $a1, $a2	#in t4 base + offset
	sw $t3, ($t4)		#salvo nell'array
	addi $a2, $a2, 4	#incremento
mup_r:	andi $t3, $a0, 7	#in t3 ho la colonna
	beq $t3, 7, pm_chk	#se è la settima non posso mangiare a dx
	subi $t3, $a0, 7	#in t3 casella in alto a dx
	lb $t4, board($t3)	#in t4 il contenuto
	bnez $t4, pm_chk	#se il contenuto non è 0 non ci posso andare
	sll $t3, $t3, 6		#altrimenti ci vado
	or $t3, $t3, $a0	#in t3 ho la mossa
	add $t4, $a1, $a2	#in t4 base + offset
	sw $t3, ($t4)		#salvo nell'array
	addi $a2, $a2, 4	#incremento
	j pm_chk
	
m_dn:	srl $t3, $a0, 3		#in t3 ho la riga
	beq $t3, 7, ret		#se sulla riga 7 non si puo muovere in giu
	andi $t3, $a0, 7	#in t3 ho la colonna
	beqz $t3, mdn_r		#se è nella colonna 0 non puo spostarsi a sx
	addi $t3, $a0, 7	## in t3 casella in basso a sx
	lb $t4, board($t3)	#metto in t4 il contenuto della casella
	bnez $t4, mdn_r		#se il contenuto non è 0 non ci posso andare
	sll $t3, $t3, 6		#altrimenti ci vado
	or $t3, $t3, $a0	#in t3 ho la mossa
	add $t4, $a1, $a2	#in t4 base + offset
	sw $t3, ($t4)		#salvo nell'array
	addi $a2, $a2, 4	#incremento
mdn_r:	andi $t3, $a0, 7	#in t3 ho la colonna
	beq $t3, 7, m_ret	#se è la settima non posso mangiare a dx
	addi $t3, $a0, 9	#in t3 casella in alto a dx
	lb $t4, board($t3)	#in t4 il contenuto
	bnez $t4, m_ret		#se il contenuto non è 0 non ci posso andare
	sll $t3, $t3, 6		#altrimenti ci vado
	or $t3, $t3, $a0	#in t3 ho la mossa
	add $t4, $a1, $a2	#in t4 base + offset
	sw $t3, ($t4)		#salvo nell'array
	addi $a2, $a2, 4	#incremento
	
	#restituisco l'indice
m_ret:	move $v0, $a2		#sposto a2 in v0
	jr $ra			#RETURN		
####################################################################################################################################
p_eat:				###in a0 la pos della pedina, in a1 l'array, in a2 l'indice al primo spazio libero
	lb $t0, board($a0)	#in t0 carico la pedina
	andi $t1, $t0, 1	###in t1 ho il giocatore
	andi $t2, $t0, 2	
	srl $t2, $t2, 1		###in t2 ho 0 se è una pedina, 1 se è una dama
	or $t3, $t2, $t1	#diverso da zero se è giocatore 1 o dama
	bnez $t3, e_up		#se è diverso da zero può mangiare in su
p_chk:	xori $t3, $t1, 1	#ottengo 1 se è il giocatore 0, 0 altrimenti
	or $t3, $t3, $t2	#ottengo uno se è una dama o il giocatore 0
	bnez $t3, e_down
	j ret
	
e_up:				#puo mangiare in su se è una dama o giocatore1
	srl $t3, $a0, 3		#in t3 ho la riga
	addi $t4, $zero, 1
	ble $t3, $t4, p_chk	#se si trova sulla riga 0 o 1 non puo mangiare in su
	#controllo a sx, incremento indice mossa e aggiungo
	andi $t3, $a0, 7	#in t3 ho la colonna
	ble $t3, $t4, up_r	#se si trova sulla colonna 0 o 1 non puo mangiare a sx
	subi $t3, $a0, 9	###in t3 ho la casella in alto a sx
	lb $t4, board($t3)	#in t4 ho la pedina in alto a sx
	beqz $t4, up_r		#se non c'è nessuna pedina passo al prossimo
	andi $t5, $t4, 1	#in t5 ho il giocatore della seconda pedina
	xor $t5, $t5, $t1	#è 1 se i giocatori sono diversi
	beqz $t5, up_r		#può essere mangiata solo se è nemica
	andi $t5, $t4, 2	#t5 = 0 -> pedina, altrimenti damone
	beqz $t5, upl_chk_free	#
	bnez $t2, upl_chk_free	#può essere mangiata solo se non è una dama o se quella che controllo è una dama
	j up_r			#
upl_chk_free:
	subi $t4, $t3, 9	###in t4 ho la casella di arrivo
	lb $t5, board($t4)	#in t5 ho il contenuto della casella di arrivo
	bnez $t5, up_r		#se non è vuota non posso mangiare
	##FORMATO MOSSA## dal bit 0 -> vecchia pos (6bit) -> nuova pos (6bit) -> pos mangiata (6bit)
	sll $t3, $t3, 12	#pos mangiata
	sll $t4, $t4, 6		#pos nuova
	or $t3, $t3, $t4
	or $t3, $t3, $a0	#in $t3 ho la codifica della mossa
	add $t4, $a1, $a2	#sommo base + offset
	sw $t3, ($t4)		#salvo la mossa nell'array
	addi $a2, $a2, 4	#incremento l'indice
	
up_r:	#controllo a dx, incremento indice mossa e aggiungo
	andi $t3, $a0, 7	#in t3 ho la colonna
	addi $t4, $zero, 6
	bge $t3, $t4, p_chk	#se si trova sulla colonna 6 o 7 non puo mangiare a dx
	subi $t3, $a0, 7	###in t3 ho la casella in alto a dx
	lb $t4, board($t3)	#in t4 ho la pedina in alto a dx
	beqz $t4, p_chk		#se non c'è nessuna pedina salto al prossimo
	andi $t5, $t4, 1	#in t5 ho il giocatore della seconda pedina
	xor $t5, $t5, $t1	#è 1 se i giocatori sono diversi
	beqz $t5, p_chk		#può essere mangiata solo se è nemica
	andi $t5, $t4, 2	#t5 = 0 -> pedina, altrimenti damone
	beqz $t5, upr_chk_free	#
	bnez $t2, upr_chk_free	#può essere mangiata solo se non è una dama o se quella che controllo è una dama
	j up_r			#
upr_chk_free:
	subi $t4, $t3, 7	###in t4 ho la casella di arrivo
	lb $t5, board($t4)	#in t5 ho il contenuto della casella di arrivo
	bnez $t5, p_chk		#se non è vuota non posso mangiare
	##FORMATO MOSSA## dal bit 0 -> vecchia pos (6bit) -> nuova pos (6bit) -> pos mangiata (6bit)
	sll $t3, $t3, 12	#pos mangiata
	sll $t4, $t4, 6		#pos nuova
	or $t3, $t3, $t4
	or $t3, $t3, $a0	#in $t3 ho la codifica della mossa
	add $t4, $a1, $a2	#sommo base + offset
	sw $t3, ($t4)		#salvo la mossa nell'array
	addi $a2, $a2, 4	#incremento l'indice
	j p_chk

e_down:				#puo mangiare in giu se e una dama o giocatore0
	srl $t3, $a0, 3		#in t3 ho la riga
	addi $t4, $zero, 6
	bge $t3, $t4, ret	#se si trova sulla riga 6 o 7 non puo mangiare in giu
	#controllo a sx, incremento indice mossa e aggiungo
	andi $t3, $a0, 7	#in t3 ho la colonna
	addi $t4, $zero, 1
	ble $t3, $t4, dn_r	#se si trova sulla colonna 0 o 1 non puo mangiare a sx
	addi $t3, $a0, 7	###in t3 ho la casella in basso a sx
	lb $t4, board($t3)	#in t4 ho la pedina in basso a sx
	beqz $t4, dn_r
	andi $t5, $t4, 1	#in t5 ho il giocatore della seconda pedina
	xor $t5, $t5, $t1	#è 1 se i giocatori sono diversi
	beqz $t5, dn_r		#può essere mangiata solo se è nemica
	andi $t5, $t4, 2	#t5 = 0 -> pedina, altrimenti damone
	beqz $t5, dnl_chk_free	#
	bnez $t2, dnl_chk_free	#può essere mangiata solo se non è una dama o se quella che controllo è una dama
	j dn_r			#
dnl_chk_free:
	addi $t4, $t3, 7	###in t4 ho la casella di arrivo
	lb $t5, board($t4)	#in t5 ho il contenuto della casella
	bnez $t5, dn_r		#se non è vuota non posso mangiare
	##FORMATO MOSSA## dal bit 0 -> vecchia pos (6bit) -> nuova pos (6bit) -> pos mangiata (6bit)
	sll $t3, $t3, 12	#pos mangiata
	sll $t4, $t4, 6		#pos nuova
	or $t3, $t3, $t4
	or $t3, $t3, $a0	#in $t3 ho la codifica della mossa
	add $t4, $a1, $a2	#sommo base + offset
	sw $t3, ($t4)		#salvo la mossa nell'array
	addi $a2, $a2, 4	#incremento l'indice
	
dn_r:	#controllo a dx, incremento indice mossa e aggiungo
	andi $t3, $a0, 7	#in t3 ho la colonna
	addi $t4, $zero, 6
	bge $t3, $t4, ret	#se si trova sulla colonna 6 o 7 non puo mangiare a dx
	addi $t3, $a0, 9	###in t3 ho la casella in basso a dx
	lb $t4, board($t3)	#in t4 ho la pedina in alto a dx
	beqz $t4, ret
	andi $t5, $t4, 1	#in t5 ho il giocatore della seconda pedina
	xor $t5, $t5, $t1	#è 1 se i giocatori sono diversi
	beqz $t5, ret		#può essere mangiata solo se è nemica
	andi $t5, $t4, 2	#t5 = 0 -> pedina, altrimenti damone
	beqz $t5, dnr_chk_free	#
	bnez $t2, dnr_chk_free	#può essere mangiata solo se non è una dama o se quella che controllo è una dama
	j ret			#
dnr_chk_free:
	addi $t4, $t3, 9	###in t4 ho la casella di arrivo
	lb $t5, board($t4)	#in t5 ho il contenuto della casella di arrivo
	bnez $t5, ret		#se non è vuota non posso mangiare
	##FORMATO MOSSA## dal bit 0 -> vecchia pos (6bit) -> nuova pos (6bit) -> pos mangiata (6bit)
	sll $t3, $t3, 12	#pos mangiata
	sll $t4, $t4, 6		#pos nuova
	or $t3, $t3, $t4
	or $t3, $t3, $a0	#in $t3 ho la codifica della mossa
	add $t4, $a1, $a2	#sommo base + offset
	sw $t3, ($t4)		#salvo la mossa nell'array
	addi $a2, $a2, 4	#incremento l'indice
	

	#restituisco l'indice
ret:	move $v0, $a2		#sposto a2 in v0
	jr $ra			#RETURN	
####################################################################################################################################	
askMove:			#in a0 il messaggio da mostrare(0=pl0, 1=pl1, 2=EatAgain, 3=MoveError, 4=SyntaxError), in v0 restituisce la mossa
	move $t5, $a0		#salvo a0 in t5
again:	bnez $t5, msg_1		#se non è il pl0 passo al prossimo
	la $t0, msgPl0		#altrimenti metto il messaggio per il pl0
	j s_end
msg_1:	bne $t5, 1, msg_2		#se non è il pl1 passo al prossimo
	la $t0, msgPl1		#se è il giocatore 1 cambio il messaggio
	j s_end
msg_2:	bne $t5, 2, msg_3	
	la $t0, msgEatAgain
	j s_end
msg_3:	bne $t5, 3, msg_4
	la $t0, msgMoveError
	j s_end
msg_4:	la $t0, msgSyntaxError
s_end:	move $a0, $t0
	la $a1, inMove
	li $a2, 6
	addi $v0, $zero, 54	#codice syscall
	syscall
	beqz $a1, humanToMachine #se non ci sono errori continua
	beq $a1, -2, lose
	j syntaxError			#altrimenti chiede ancora
	
humanToMachine:			#elabora la mossa
	la $t6, inMove
	lb $t0, 0($t6)	#carico il primo byte
	subi $t0, $t0, 97	#trovo l'offset dalla a -> x oldPos
	andi $t1, $t0, 0xfffffff8#sarà diverso da zero solo se non è una lettera compresa tra a e h
	bnez $t1, syntaxError
	lb $t1, 1($t6)	#secondo byte
	subi $t1, $t1, 49	#distanza da 1 
	andi $t2, $t1, 0xfffffff8
	bnez $t2, syntaxError
	sll $t1, $t1, 3		#y oldPos
	or $t0, $t0, $t1	# oldPos
	lb $t1, 2($t6)	#terzo byte
	bne $t1, 45, syntaxError #deve essere uguale a -
	lb $t1, 3($t6)	#quarto byte
	subi $t1, $t1, 97	#distanza da a 
	andi $t2, $t1, 0xfffffff8
	bnez $t2, syntaxError
	sll $t1, $t1, 6		#x newPos
	or $t0, $t0, $t1	
	lb $t1, 4($t6)	#quinto byte
	subi $t1, $t1, 49	#distanza da 1 
	andi $t2, $t1, 0xfffffff8
	bnez $t2, syntaxError
	sll $t1, $t1, 9		#y newPos
	or $t0, $t0, $t1
	addi $v0, $t0, 0
	jr $ra
syntaxError:
	addi $t5, $zero, 4
	j again
####################################################################################################################################
checkMove:			#in a0 la mossa da controllare in a1 il numero di mosse possibili
	addi $t0, $a0, 0	#sposto in $t0 la mossa
	addi $t1, $a1, 0	#sposto in $t1 il numero di mosse possibili
c_loop:	subi $t1, $t1, 4	#decremento
	bltz $t1, notFound
	lw $t2, moves($t1)	#carico la mossa
	andi $t3, $t2, 0xfff	#prendo gli ultimi dodici bit (non mi interessa per ora chi viene mangiato)
	bne $t3, $a0, c_loop	#se sono diverse continuo la ricerca
	addi $v0, $t2, 0	#restituisco la mossa
	jr $ra
notFound:
	addi $v0, $zero, 0	#se non la trovo restituisco 0 (00-00 non è uno spostamento lecito)
	jr $ra
####################################################################################################################################
execMove:			#in a0 la mossa da eseguire
	andi $t0, $a0, 0x3f	#oldPos = ultimi 6 bit
	andi $t1, $a0, 0xfc0	#newPos = dal 6 all' 11 bit
	srl $t1, $t1, 6
	andi $t2, $a0, 0x3f000	#eatenPos
	srl $t2, $t2, 12
	lb $t3, board($t0)	#pedina da spostare in t3
	sb $zero, board($t0)	#rimpiazzo con 0
	sb $t3, board($t1)	#sposto la pedina
	beqz $t2, ex_end	#se presente una pedina mangiata
	sb $zero, board($t2)	#mangio la pedina
	addi $v0, $t1, 0
ex_end:	jr $ra
####################################################################################################################################
hor:			#crea una linea orizzontale di $a0 pixel dalla posizione $a1 e colore $a2
addi $t4, $zero, 2
j proc
ver:			#crea una linea verticale di $a0 pixel dalla posizione $a1 e colore $a2
addi $t4, $zero, 7

	
		

proc:	add $t3, $a2, $zero	#mette il numero di pixel in $t3
	add $t1, $a0, $zero	#mette la posizione di partenza in $t1
	add $t2, $a1, $zero	#mette il colore in $t2
l:	sllv $t0, $t3, $t4	#se orizzontale moltiplica il numero x4(byte x pixel) se verticale lo moltiplica x128 (byte per riga)
	add $t0, $t1, $t0	#somma l'offset ottenuto con l'indirizzo di partenza
	sw $t2, ($t0)
	beqz $t3, end
	sub $t3, $t3, 1
	j l
end:
	jr $ra
####################################################################################################################################
back:				#disegna 1024 pixel di sfondo a partire da $a0
	addi $t0, $zero, 0	#inizializza $t1 a 0
loop:	
	add $t1, $a0, $t0
	sw $a1, ($t1)
	beq $t0, 4096, end		#1024*4byte
	add $t0,$t0,4
	j loop
####################################################################################################################################
drawA:				#a partire dalla posizione $a0 disegna una a di colore $a1
	addi $t5, $ra, 0	
	addi $a2, $zero, 4	#lunghezza riga = 5
	jal ver
	
	addi $a0, $a0, 8
	jal ver
	
	addi $a0, $a0, -4
	sw $a1, ($a0)
	addi $a0, $a0, 256
	sw $a1, ($a0)
	addi $ra, $t5, 0
	jr $ra			#return
####################################################################################################################################
drawB:				#a partire dalla posizione $a0 disegna una b di colore $a1
	addi $t5, $ra, 0
	addi $a2, $zero, 4	#lunghezza riga = 5
	jal ver
	
	addi $a0, $a0, 8
	jal ver
	
	addi $a0, $a0, -4
	sw $a1, ($a0)
	addi $a0, $a0, 256
	sw $a1, ($a0)
	addi $a0, $a0, 256
	sw $a1, ($a0)
	addi $ra, $t5, 0
	jr $ra			#return
####################################################################################################################################
drawC:				#a partire dalla posizione $a0 disegna una c di colore $a1
	addi $t5, $ra, 0
	addi $a2, $zero, 4	#lunghezza riga = 5
	jal ver
	addi $a2, $zero, 2
	jal hor
	addi $a0, $a0, 512	# 512 = 4*128 = 4 righe sotto
	jal hor
	addi $ra, $t5, 0
	jr $ra
####################################################################################################################################
drawD:				#a partire dalla posizione $a0 disegna una D di colore $a1
	addi $t5, $ra, 0
	addi $a2, $zero, 4	#lunghezza riga = 5
	jal ver
	addi $a2, $zero, 2
	jal hor
	addi $a0, $a0, 512	# 512 = 4*128 = 4 righe sotto
	jal hor
	addi $a0, $a0, -504	# -508 = -512 + 8 -> quattro righe sopra e due avanti
	addi $a2, $zero, 4	#lunghezza riga = 5
	jal ver
	addi $ra, $t5, 0
	jr $ra
####################################################################################################################################
drawE:				#a partire dalla posizione $a0 disegna una E di colore $a1
	addi $t5, $ra, 0
	addi $a2, $zero, 4	#lunghezza riga = 5
	jal ver
	addi $a2, $zero, 2
	jal hor
	addi $a0, $a0, 256	# 255 = 2*128 = 4 righe sotto
	jal hor
	addi $a0, $a0, 256
	jal hor
	addi $ra, $t5, 0
	jr $ra
####################################################################################################################################
drawF:				#a partire dalla posizione $a0 disegna una F di colore $a1
	addi $t5, $ra, 0
	addi $a2, $zero, 4	#lunghezza riga = 5
	jal ver
	addi $a2, $zero, 2
	jal hor
	addi $a0, $a0, 256	# 255 = 2*128 = 4 righe sotto
	jal hor
	addi $ra, $t5, 0
	jr $ra
####################################################################################################################################
drawG:				#a partire dalla posizione $a0 disegna una G di colore $a1
	addi $t5, $ra, 0
	addi $a2, $zero, 4	#lunghezza riga = 5
	jal ver
	addi $a2, $zero, 2
	jal hor
	addi $a0, $a0, 512	# 512 = 4*128 = 4 righe sotto
	jal hor
	addi $a0, $a0, -120
	sw $a1, ($a0)
	addi $ra, $t5, 0
	jr $ra
####################################################################################################################################
drawH:				#a partire dalla posizione $a0 disegna una a di colore $a1
	addi $t5, $ra, 0	
	addi $a2, $zero, 4	#lunghezza riga = 5
	jal ver
	
	addi $a0, $a0, 8
	jal ver
	
	addi $a0, $a0, 252
	sw $a1, ($a0)
	addi $ra, $t5, 0
	jr $ra
####################################################################################################################################
drawLine:			#a partire dalla posizione $a0 disegna una riga di quadrati
				#di colore alternato. il primo colore e' $a1
	addi $t0, $zero, 0	#inizializza a 0 $t0
step1:	addi $t1, $zero, 0
step2:	#disegna un segmento di tre
	sw $a1, ($a0)
	addi $a0, $a0, 4 
	sw $a1, ($a0)
	addi $a0, $a0, 4 
	sw $a1, ($a0)
	addi $a0, $a0, 4
	addi $t1, $t1, 1
	xori $a1, $a1, 0x00ffffff
	bne $t1, 8, step2	#se non ho fatto otto caselle ricomincio
	addi $a0, $a0, 32	#salto alla riga successiva
	addi $t0, $t0, 1
	bne $t0, 3, step1	#se non ho fatto tre righe ricomincio
	subi $a0, $a0, 32
	xori $a1, $a1, 0x00ffffff
	jr $ra			#ritorna in $a0 la posizione dell'ultimo pixel e in $a1 il suo colore
####################################################################################################################################
draw1:				#a partire dalla posizione $a0 disegna un 1 di colore $a1
	addi $t5, $ra, 0
	sw $a1, 4($a0)
	sw $a1, 16($a0)
	sw $a1, -240($a0)	#16-2*128
	addi $a0, $a0, -128		
	addi $a2, $zero, 4	#lunghezza riga = 5
	jal hor
	addi $ra, $t5, 0
	jr $ra
####################################################################################################################################
draw2:
	addi $t5, $ra, 0
	sub $a0, $a0, 256
	addi $a2, $zero, 2
	jal ver
	sw $a1, 4($a0)
	addi $a0, $a0, 8
	jal ver
	sw $a1, 260($a0)
	addi $a0, $a0, 8
	jal ver
	addi $ra, $t5, 0
	jr $ra
####################################################################################################################################
draw3:
	addi $t5, $ra, 0
	sub $a0, $a0, 256
	addi $a2, $zero, 2
	jal ver
	sw $a1, 4($a0)
	addi $a0, $a0, 8
	jal ver
	sw $a1, 4($a0)
	addi $a0, $a0, 8
	jal ver
	addi $ra, $t5, 0
	jr $ra
####################################################################################################################################
draw4:
	addi $t5, $ra, 0
	addi $a2, $zero, 3
	jal hor
	sw $a1, -116($a0)
	sw $a1, -244($a0)
	sw $a1, -240($a0)
	sw $a1, -248($a0)
	addi $ra, $t5, 0
	jr $ra
####################################################################################################################################
draw5:
	addi $t5, $ra, 0
	sub $a0, $a0, 256
	addi $a2, $zero, 2
	jal ver
	sw $a1, 260($a0)
	addi $a0, $a0, 8
	jal ver
	sw $a1, 4($a0)
	addi $a0, $a0, 8
	jal ver
	addi $ra, $t5, 0
	jr $ra
####################################################################################################################################
draw6:
	addi $t5, $ra, 0
	sub $a0, $a0, 256
	addi $a2, $zero, 2
	jal ver
	sw $a1, 260($a0)
	addi $a0, $a0, 8
	jal ver
	sw $a1, 4($a0)
	sw $a1, 260($a0)
	addi $a0, $a0, 8
	jal ver
	addi $ra, $t5, 0
	jr $ra
####################################################################################################################################
draw7:
	addi $t5, $ra, 0
	sub $a0, $a0, 256
	addi $a2, $zero, 2
	jal ver
	addi $a2, $zero, 4
	jal hor
	addi $ra, $t5, 0
	jr $ra
####################################################################################################################################
draw8:
	addi $t5, $ra, 0
	sub $a0, $a0, 256
	addi $a2, $zero, 2
	jal ver
	sw $a1, 4($a0)
	sw $a1, 260($a0)
	addi $a0, $a0, 8
	jal ver
	sw $a1, 4($a0)
	sw $a1, 260($a0)
	addi $a0, $a0, 8
	jal ver
	addi $ra, $t5, 0
	jr $ra
##################
fin:
##################				
