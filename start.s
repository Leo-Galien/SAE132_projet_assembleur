# ===== Section donnees =====
.data 
    grille:     .space 100 #Grille de char de 10x10 soit 100 octet
# ===== Section code =====  
.text

# ----- Main ----- 
main:
    jal initPartie
    jal displayGrille
    #jal simulationJeu
    #jal displayGrille
    j   exit 

# ----- Fonctions -----
# ----- Fonction initPartie -----
# Objectif : Génère une nouvelle partie à chaque appel
# Registres utilises : $a0, $a1

initPartie:
    add     $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
    sw      $ra, 0($sp)

    jal initGrille
    li  $a0, 5
    li  $a1, 65 # 'A' pour Aircraft Carrier (Porte-Avion)
    jal setShip
    li  $a0, 4  
    li  $a1, 66 # 'B' pour Battleship (Cuirassé)
    jal setShip
    li  $a0, 3
    li  $a1, 67 # 'C' pour Cruiser (Croiseur)
    jal setShip
    li  $a0, 3
    li  $a1, 83 # 'S' pour Submarine (Sous-marin)
    jal setShip
    li  $a0, 2
    li  $a1, 68 # 'D' pour Destroyer (Torpilleur)
    jal setShip

    j retourne
# ----- Fonction initGrille -----
# Objectif : Charge la grille avec '.' (Case vide)
# Registres utilises : $t[0-3]

initGrille:
    la      $t0, grille     # Chargement de l'adresse de la grille
    li      $t1, 0          # Initialisation du compteur de boucle dans $t1
    li      $t3, 46         # Charge la valeur ASCII de '.'
    boucle_initGrille:
        bge     $t1, 100, end_initGrille # Si $t1 est plus grand ou egal a 100 alors branchement a end_boucle_initGrille
            add     $t2, $t0, $t1   # $t0 + $t1 -> $t2 ($t0 l'adresse du tableau et $t1 la position dans le tableau)
            sb		$t3, 0($t2)		# On place la valeur de $t3 à l'adresse contenue dans $t2
            addi    $t1, $t1, 1     # $t1 += 1 (On augemente le compteur)
        j boucle_initGrille
    end_initGrille:
        jr $ra

# ----- Fonction displaySpace -----
# Objectif : Affiche la grille avec les indicateur de coordonnées
# Registres utilises :$v0, $a0, $t8
displaySpace:
	add     $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
	sw      $ra, 0($sp)
	
	li $a0, 32	# on charge le charactère a afficher
	li $v0,11	# on charge la valeur de la fonction afficher_char
	syscall 	# on utilise afficher_str pour afficher $a0
	
	j retourne


# ----- Fonction displayGrille -----
# Objectif : Affiche la grille avec les indicateur de coordonnées
# Registres utilises : $t[0-3], $v0, $a[0-1]

displayGrille:
    add     $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
    sw      $ra, 0($sp)
    jal     displayLettres	#affiche les lettres
    la      $t0, grille     #Charge l'adresse de la grille dans $t0
    li      $t1, 0          #Initialisation du compteur de boucle dans $t1
    boucle_displayGrille:
        bge     $t1, 100, end_displayGrille     # Si $t1 est plus grand ou egal a 100 alors branchement a end_displayGrille
        	jal addLineCount		# affiche le numéro de la ligne si on en change
        	jal displaySpace		# affiche un espace pour que le jeu soit pas trop moche
            add     $t2, $t0, $t1           # $t0 + $t1 -> $t2 ($t0 l'adresse du tableau et $t1 la position dans le tableau)
            lb      $a0, ($t2)              # load byte at $t2(adress) in $a0
            li      $v0, 11                 # code pour l'affichage d'un caractère (char)
            syscall
	
            addi    $t1, $t1, 1            # $t1 += 1;
        j boucle_displayGrille
    end_displayGrille:
        jal     addNewLine
        j retourne

# ----- Fonction displayLettres -----
# Objectif : afficher les lettres de A à J
# Regitres utilises : $t0, $v0, $a0

displayLettres:
	add     $sp, $sp, -4       	 # Sauvegarde de la reference du dernier jump
    	sw      $ra, 0($sp)
	jal	    displaySpace	# affiche un espace
    	jal	    displaySpace	# affiche un espace
    	
	li $t0,0	# initialise un iterateur a 0
	boucle_alphabet:
		bge $t0, 10,fin_boucle	# si l'iterateur atteint 10 , on arrète d'afficher des lettres
			jal displaySpace	# affiche un espace
			addi $a0,$t0,65	# on ajoute 65 a l'itérateur pour afficher les lettres de A a J
			li $v0,11	# on charge la valeur de la fonction afficher_char
			syscall 	# on utilise afficher_str pour afficher $a0
			addi $t0,$t0,1	# on augmente l'iterateur de 1
			j boucle_alphabet	# on boucle
	fin_boucle:	
	j retourne
# ----- Fonction addNewLine -----  
# Objectif : fait un retour a la ligne a l'ecran
# Registres utilises : $v0, $a0

addNewLine:
    add     $sp, $sp, -4       	 # Sauvegarde de la reference du dernier jump
    sw      $ra, 0($sp)
    
    li      $v0, 11         # Chargement appel systeme 11 (Affichage d'un char)
    li      $a0, 10         # Chargement chaine à afficher -> '\n'
    syscall
    
    j retourne
# ----- Fonction addLineCount -----
# Objectif : affiche le numéro de la ligne
# Registres utilises : $v0, $a0, $a1
# Paramètre : $a1 (Ligne en cours : res du modulo + 1)

addLineCount:
	add     $sp, $sp, -4       	# Sauvegarde de la reference du dernier jump
    	sw      $ra, 0($sp)
    	
    	move $a0,$t1 			#copie le compteur de charactères de displaGrille en paramètre de getModulo
    	li $a1, 10			#le modulo de getModulo
    	jal getModulo
    	beqz $v0, affichenombre
    	j finCount
    	affichenombre:
    		beq $v1, 9, afficheDixieme	# affiche 10 a la dixieme ligne si on y est , sinon affiche n espace avant le nombre de la ligne
    		jal addNewLine
    		jal displaySpace
    		move $a0,$v1			# met le resulatat de nbCase / 10 dans $a0 pour l'afficher car c'est le numéro de la ligne actuelle
    		addi $a0,$a0,1			# corrige le nombre de la ligne car il est de base en mode tableau ( 012 ) et par en mode normale (123)
    		li $v0,1			# charge la fonction afficherint dans $v0
    		syscall
    	j finCount
    	afficheDixieme:
    		jal addNewLine
    		move $a0,$v1			# met le resulatat de nbCase / 10 dans $a0 pour l'afficher car c'est le numéro de la ligne actuelle
    	    	addi $a0,$a0,1			# corrige le nombre de la ligne car il est de base en mode tableau ( 012 ) et par en mode normale (123)
    		li $v0,1			# charge la fonction afficherint dans $v0
    		syscall
    	j finCount
    	
    	finCount:
    		j retourne
	
# ----- Fonction getModulo ----- 
# Objectif : Fait le modulo (a mod b)
#   $a0 represente le nombre a (doit etre positif)
#   $a1 represente le nombre b (doit etre positif)
# Resultat (reste) dans : $v0
# Resultat (quotient) dans : $v1
# Registres utilises : $a0 et $a1

getModulo: 
    li $v1, 0
    sub     $sp, $sp, 4
    sw      $ra, 0($sp)
    boucle_getModulo:
        blt $a0, $a1, end_getModulo
        addi $v1, $v1, 1
        sub $a0, $a0, $a1
        j boucle_getModulo
    end_getModulo:
    move    $v0, $a0
    j retourne


# ----- Fonction getAleatoire ----- 
# Objectif : Génère un nombre aléatoire de 0 à n-1
#   $a1 represente la valeur max-1
# Resultat dans : $a0
# Registres utilises : $a0, $a1, $v0

getAleatoire:
    li $v0, 42
    syscall
    jr $ra

# ----- Fontion setShip -----
# Objectif : place un bateau de taille donné.
#   $a0 represente la taille en nombre de case du bateau à placer
#   $a1 represente le caractère pour représenter le bateau
# Registres utilises : $a0, $a1, $s[0-4], $t[0-4]

setShip:
    sub     $sp, $sp, 4
    sw      $ra, 0($sp)     	#On sauvegarde l'adresse de retour

    move 	$s0, $a0	# On recopie la taille dans $s0
    move    $s4, $a1        	# On recopie le caractère du bateau
    try_setShip:
        #Choix de l'axe (horizontale ou verticale)
        li      $a1, 2          # Définition de la borne surpérieur (Resultat possbile : 0 ou 1)
        jal getAleatoire        # Saut pour obtenir une valeur aléatoire
        move 	$s1, $a0		# On copie le résultat dans $s1
        # Placement en fonction de l'axe
        beq     $s1, 1, placeVerticale  # Si la valuer est 1 alors le bateau sera placer verticalement
        	j       placeHorizontale        # Si la valuer est 0 alors le bateau sera placer horizontalement

    end_setShip:
        j retourne
        

        
        
# ----- Fontion  -----
# Objectif : dépile $rs et retourne  a l'adresse dépilée ( utilisé a la fin d'une fonction pour retourner a l'adresse d'appel en une ligne au lieu de 3).
retourne:
        lw      $ra, 0($sp)
        add     $sp, $sp, 4     # On rétablie l'adresse de retour
    jr $ra
# ----- Fontion placeHorizontale -----
# Objectif : place aléatoirement un bateau de manière horizontale.
#   Prends les paramètres de setShip 
# Registres utilises : $v0, $a0, $a1, $s[0-4], $t[0-4]

placeHorizontale:
	sub $sp,$sp,4
	sw  $t1,0($sp)		# on sauvegarde la valeur de $t1 car deja utilisé dans la fonctio qui appelle celle ci


    	
    	li $a1,10		# on charge la borne superieur de getaleatoire
	jal getAleatoire	# on génère le n° de la ligne du bateau
	move $s2,$a0		# on stocke la ligne du bateau dans $s2
	li $a1,9		# on charge la borne superieur de getaleatoire (on veut pas plus que 9 car le plus petit bateau fait 2 de long donc si la colone générée est 10 la suite du bateu est systèmatiquement hors ligne) 
	jal getAleatoire	# on génère le n° de la colone du bateau
	move $s3,$a0		# on stocke la colone du bateau dans $s3
	
	jal verifPlaceHorizontale	# vérifie si on peut placer le bato
	beqz $v0,placeHValide		# si on peut placer le bato on le place (incroyable)
	        add     $sp, $sp, 4     # On dépile car on a plus besoin l'adresse de retour de placeH (on retourne dans setship)
		j try_setShip		# sinon on place pas le bato et on reesaye de le placer
	placeHValide:
		li $t1, 0		#initialise un compteur a 0
		mul $t1,$s2,10		# amène notre compteur sur la ligne de départ
		add  $t1,$t1,$s3   	# amène notre compteur sur la colonne de départ
		move $t3, $s0      	# taille
		mul  $t3, $t3, 1
		add  $t3, $t3, $t1	 # borne finale		
	bouclePlaceH:
		bge $t1,$t3,finPlaceH		#tant qu'on a pas finis de placer le bateau on boucle sinon on finis placeHorizontale
			la	$t0,grille	# charge l'adresse de la grille 
			add     $t2, $t0, $t1   # $t0 + $t1 -> $t2 ($t0 l'adresse du tableau et $t1 la position dans le tableau)
        		sb	$s4, 0($t2)		# On place le charactère contenu dans $s4 à l'adresse contenue dans $t2
        		addi    $t1, $t1, 1     # $t1 += 1 (On augemente le compteur et on passe au charactère de droite)
        	j bouclePlaceH
        finPlaceH:
        	lw $t1,0($sp)	# on récupère la valeur $t1 sauvegardée au début de la fonction
        	add $sp,$sp,4
    		j end_setShip	# on finis setship

# ----- Fontion verifPlaceHorizontale -----
# Objectif : verifie si le placement (horizontale) est possible.
#   $s0 contient la taille du navire
#   $s2 contient la ligne 
#   $s3 contient la colonne
# Retourne 0 si placement ok, 1 sinon
# Registres utilises : $v0, $t[0-4], $s0, $s2, $s3

verifPlaceHorizontale:

	# VERIFIE PAS QUE CA SE SUPERPOSE PAS AVEC UN AUTRE ABTO , A COMPLETER
	
	sub     $sp, $sp, 4
        sw      $ra, 0($sp)     #On sauvegarde l'adresse de retour

	li $t3, 0		#initialise un compteur a 0
	add $t3,$t3,$s3   	# amène notre compteur sur la colonne de départ
	add $t4,$s0,$t3		# assigne la borne aux coordonées de la fin du bato

	boucleTestPHGrille:
		bge $t3,$t4,TestPHBato			# teste chaque case du bato , puis branch a boucleTestPHBato si la boucle n'est pas interrompue
			bge $t3,10,PH_impossible	# si la case en train d'être testée sort de la la grille, alors on branch a PV_impossible
				add $t3,$t3,1		# passe a la case du bateau suivante
				j boucleTestPHGrille
			
	TestPHBato:
		la $t0,grille		# charge l'adresse de la grille 
		li $t3, 0		#reinitialise la boucle
		mul $t3,$s2,10		# amène notre compteur sur la ligne de départ
		add $t3,$t3,$s3		# amène notre compteur sur la colonne de départ
		add $t4,$s0,$t3		# assigne la borne aux coordonées de la fin du bato
	boucleTestPHBato:
		bge $t3,$t4,PH_possible		# teste chaque case du bato , puis branch a PH_possible si la boucle n'est pas interrompue
				add     $t2, $t0, $t3   # $t0 + $t3 -> $t2 ($t0 l'adresse du tableau et $t3 la position dans le tableau)
        			lb	$t5, 0($t2)	# On place le charactère contenu à l'adresse $t2 dans $t5 
        			li 	$t6,46		#"."
        			bne 	$t5,$t6,PV_impossible	#si l'espace de la grille en train d'être verifié est pas un point,c'est un autre bato donc le placement est invalide
					add $t3,$t3,1		# passe a la case du bateau suivante
					j boucleTestPHBato
	
	PH_impossible:
		li $v0,1	 #charge la valeur correspondant au retour de la fonction , ici un car le bato ne peut pas être placé
		j retourne
		     	           
        PH_possible :
               	li $v0,0	#charge la valeur correspondant au retour de la fonction , ici zero car le bato peut être placé
               	j retourne



# ----- Fontion placeVerticale -----
# Objectif : place aléatoirement un bateau de manière verticale.
#   Prends les paramètres de setShip
# Registres utilises : $v0, $a0, $a1, $s[0-4], $t[0-4]

placeVerticale:



	sub     $sp, $sp, 4
    	sw      $t1, 0($sp)     #On sauvegarde la valeur de $t1 car deja utilisé dans la fonctio qui appelle celle ci
	
    	li $t1, 0		#initialise un compteur a 0
    	
    	li $a1,10		# on charge la borne superieur de getaleatoire
	jal getAleatoire	# on génère le n° de la colone du bateau
	move $s3,$a0		# on stocke la colone du bateau dans $s3
	li $a1,9		# on charge la borne superieur de getaleatoire (on veut pas plus que 9 car le plus petit bateau fait 2 de long donc si la ligne générée est 10 la suite du bateu est systèmatiquement hors ligne) 
	jal getAleatoire	# on génère le n° de la colone du bateau
	move $s2,$a0		# on stocke la ligne du bateau dans $s3
		
	jal verifPlaceVerticale	# vérifie si on peut placer le bato
	beqz $v0,placeVValide		# si on peut placer le bato on le place (incroyable)
		add     $sp, $sp, 4     # On dépile car on a plus besoin l'adresse de retour de placeV (on retourne dans setship)
		j try_setShip		# sinon on place pas le bato et on reesaye de le placer
	placeVValide:
		li $t1, 0		#initialise un compteur a 0
		mul $t1,$s2,10		# amène notre compteur sur la bonne ligne
		add  $t1,$t1,$s3   	# amène notre compteur sur la colonne de départ
		move $t3, $s0      	# taille
		mul  $t3, $t3, 10
		add  $t3, $t3, $t1 	# borne finale
		bouclePlaceV:
			bge $t1,$t3,finPlaceV		#tant qu'on a pas finis de placer le bateau on boucle sinon on finis placeHorizontale
				la	$t0,grille	# charge l'adresse de la grille 
				add     $t2, $t0, $t1   # $t0 + $t1 -> $t2 ($t0 l'adresse du tableau et $t1 la position dans le tableau)
        			sb	$s4, 0($t2)		# On place le charactère contenu dans $s4 à l'adresse contenue dans $t2
        			addi    $t1, $t1, 10     # $t1 += 1 (On augemente le compteur et on passe au charactère de dessous)
        		j bouclePlaceV
        finPlaceV:
        	lw $t1,0($sp)	# on récupère la valeur $t1 sauvegardée au début de la fonction
        	add $sp,$sp,4
    		j end_setShip	# on finis setship


# ----- Fontion verifPlaceVerticale -----
# Objectif : verifie si le placement (verticale) est possible.
#   $s0 contient la taille du navire
#   $s2 contient la ligne 
#   $s3 contient la colonne
# Retourne 0 si placement ok, 1 sinon
# Registres utilises : $v0, $t[0-5], $s0, $s2, $s3,$4

verifPlaceVerticale:

	# VERIFIE PAS QUE CA SE SUPERPOSE PAS AVEC UN AUTRE ABTO , A COMPLETER

    	sub     $sp, $sp, 4
        sw      $ra, 0($sp)     #On sauvegarde l'adresse de retour

	li $t3, 0		#initialise un compteur a 0
	mul $t3,$s2,10		# amène notre compteur sur la ligne de départ
	add $t3,$t3,$s3   	# amène notre compteur sur la colonne de départ
	li $t4,0		# v
	mul $t4,$s0,10		# assigne la borne aux coordonées de la fin du bato
	add $t4,$t4,$t3		# ^
	boucleTestPV:
		bge $t3,$t4,PV_possible		# teste chaque case du bato , puis branch a PV_possibe si la boucle n'est pas interrompue
			bge $t3,100,PV_impossible	# si la case en train d'être testée sort de la la grille, alors on branch a PV_impossible
				la	$t0,grille	# charge l'adresse de la grille 
				add     $t2, $t0, $t3   # $t0 + $t3 -> $t2 ($t0 l'adresse du tableau et $t3 la position dans le tableau)
        			lb	$t5, 0($t2)	# On place le charactère contenu à l'adresse $t2 dans $t5 
        			li 	$t6,46		#"."
        			bne 	$t5,$t6,PV_impossible	#si l'espace de la grille en train d'être verifié est pas un point,c'est un autre bato donc le placement est invalide
        			
       				add $t3,$t3,10		# passe a la case du bateau suivante ( on ajoute 10 car on change de ligne mais pas de colone)
				j boucleTestPV
			

	PV_impossible:
		li $v0,1	 #charge la valeur correspondant au retour de la fonction , ici un car le bato ne peut pas être placé
		j retourne
		     	           
        PV_possible :
               	li $v0,0	#charge la valeur correspondant au retour de la fonction , ici zero car le bato peut être placé
        	j retourne
            
        


# ----- Fonction simulationJeu -----
# Objectif : Simule une partie avec une grille déjà généré.
# Registres utilises : $s[0-3]

simulationJeu:
	jr $ra

# ----- Fontion traque -----     
# Objectif : Vérifie la présence d'un navire et le traque de manière récursive
# Registres utilises : $t[8-9], $s[0-3]

traque:
	jr $ra

exit: 
    li $v0, 10  #Chargement appel systeme 10 (Sortie)
    syscall
