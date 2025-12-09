# ===== Section donnees =====
.data 
    grille:     .space 100 #Grille de char de 10x10 soit 100 octet
    debug:	.asciiz "debug"
# ===== Section code =====  
.text

# ----- Main ----- 
main:
    #jal initPartie
    jal initGrille
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

    lw      $ra, 0($sp)                 # On recharge la reference 
    add     $sp, $sp, 4                 # du dernier jump
    jr $ra

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
	sw      $t8, 0($sp)
	
	li $a0, 32	# on charge le charactère a afficher
	li $v0,11	# on charge la valeur de la fonction afficher_char
	syscall 	# on utilise afficher_str pour afficher $a0
	
	lw $t8,0($sp)
	add $sp,$sp,4
	jr $ra


# ----- Fonction displayGrille -----
# Objectif : Affiche la grille avec les indicateur de coordonnées
# Registres utilises : $t[0-3], $v0, $a[0-1]

displayGrille:
    add $sp, $sp, -4          # Sauvegarde $ra
    sw $ra, 0($sp)

    jal displaySpace
    jal displaySpace
    jal displayLettres        # Affiche les lettres de colonne (A à J)
    jal addNewLine            # Retour à la ligne après les lettres

    la $t0, grille            # Charge l'adresse de la grille
    li $t1, 0                 # Initialise le compteur de boucle

boucle_displayGrille:
    bge $t1, 100, end_displayGrille

    # Vérifie si on est au début d'une nouvelle ligne (indice multiple de 10)
    li $t2, 10                # Utilise $t2 pour la division (évite de modifier $a1)
    div $t1, $t2
    mfhi $t3                  # Récupère le reste dans $t3 (pas $a1)
    beqz $t3, nouvelle_ligne  # Si reste = 0, on est au début d'une ligne

    j afficher_caractere

nouvelle_ligne:
    # Affiche le numéro de ligne
    mflo $a0                  # Récupère le quotient (numéro de ligne)
    addi $a0, $a0, 1          # +1 pour obtenir le numéro de ligne (1 à 10)
    jal addLineCount          # Affiche le numéro de ligne
    jal displaySpace          # Affiche un espace après le numéro

afficher_caractere:
    # Affiche le caractère de la grille
    la $t0, grille            # Recharge $t0 (au cas où il aurait été modifié)
    add $t4, $t0, $t1         # Utilise $t4 pour l'adresse (pas $t2)
    lb $a0, ($t4)             # Charge le caractère
    li $v0, 11
    syscall
    jal displaySpace

    # Vérifie si on est à la fin d'une ligne (indice = 9, 19, ..., 99)
    li $t2, 10
    addi $t5, $t1, 1          # Utilise $t5 pour éviter de modifier $t1
    div $t5, $t2
    mfhi $t5
    bnez $t5, suite_boucle    # Si reste != 0, on n'est pas à la fin d'une ligne

    # Sinon, on passe à la ligne
    jal addNewLine

suite_boucle:
    addi $t1, $t1, 1          # Passe à la case suivante
    j boucle_displayGrille

end_displayGrille:
    lw $ra, 0($sp)            # Restaure $ra
    add $sp, $sp, 4           # Libère la pile
    jr $ra                    # Retour à l'appelant



# ----- Fonction displayLettres -----
# Objectif : Affiche les lettres de A à J
# Registres utilisés : $t0, $v0, $a0
displayLettres:
    li $t0, 0                 # Initialise l'itérateur à 0
    add     $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
    sw      $ra, 0($sp)
    jal displaySpace

boucle_alphabet:
    bge $t0, 10, fin_boucle   # Si $t0 >= 10, saute à fin_boucle
    addi $a0, $t0, 65        # $a0 = 'A' + $t0 (65 = 'A' en ASCII)
    li $v0, 11               # Appel système pour afficher un caractère
    syscall                  # Affiche le caractère
    jal displaySpace         # Affiche un espace
    addi $t0, $t0, 1         # Incrémente l'itérateur
    j boucle_alphabet        # Retour au début de la boucle

fin_boucle:
    lw      $ra, 0($sp)      # On recharge la reference 
    add     $sp, $sp, 4      # du dernier jump ,
    jr $ra                   # Retour à l'appelant
    
# ----- Fonction addNewLine -----  
# Objectif : fait un retour a la ligne a l'ecran
# Registres utilises : $v0, $a0

addNewLine:
    li      $v0, 11         # Chargement appel systeme 11 (Affichage d'un char)
    li      $a0, 10         # Chargement chaine à afficher -> '\n'
    syscall
    jr      $ra             # Retour à la fonction précendente

# ----- Fonction addLineCount -----
# Objectif : affiche le numéro de la ligne
# Registres utilises : $v0, $a0, $a1
# Paramètre : $a1 (Ligne en cours : res du modulo + 1)

addLineCount:
    add $sp, $sp, -4          # Sauvegarde $ra
    sw $ra, 0($sp)

    # Affiche le numéro de ligne (1 à 10)
    li $t0, 10
    beq $a0, $t0, affiche_dix

    # Pour les lignes 1 à 9
    add $sp, $sp, -4          # Sauvegarde $a0
    sw $a0, 0($sp)
    jal displaySpace
    lw      $a0, 0($sp)      # On récupère la valeur de $a0 
    add     $sp, $sp, 4      # On dépile
    li $v0, 1		     # On charge afficher_entier
    syscall		     # On affiche l'entier contenu dans $a0
    j fin_addLineCount

	affiche_dix:
	    # Affiche '1' puis '0' pour la ligne 10
	    li $a0, 10               # '1'
	    li $v0, 1
	    syscall
	    
	    
	fin_addLineCount:
    	    lw $ra, 0($sp)           # Restaure $ra
    	    add $sp, $sp, 4          # Libère la pile
    	jr $ra                   # Retour à l'appelant


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
    lw      $ra, 0($sp)
    add     $sp, $sp, 4
    jr $ra


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
    sw      $ra, 0($sp)     #On sauvegarde l'adresse de retour

    move 	$s0, $a0		# On recopie la taille dans $s0
    move    $s4, $a1        # On recopie le caractère du bateau
    try_setShip:
        #Choix de l'axe (horizontale ou verticale)
        li      $a1, 2          # Définition de la borne surpérieur (Resultat possbile : 0 ou 1)
        jal getAleatoire        # Saut pour obtenir une valeur aléatoire
        move 	$s1, $a0		# On copie le résultat dans $s1
        # Placement en fonction de l'axe
        beq     $s1, 1, placeVerticale  # Si la valuer est 1 alors le bateau sera placer verticalement
        j       placeHorizontale        # Si la valuer est 0 alors le bateau sera placer horizontalement

    end_setShip:
        lw      $ra, 0($sp)
        add     $sp, $sp, 4     # On rétablie l'adresse de retour
    jr $ra
        
# ----- Fontion placeHorizontale -----
# Objectif : place aléatoirement un bateau de manière horizontale.
#   Prends les paramètres de setShip
# Registres utilises : $v0, $a0, $a1, $s[0-4], $t[0-4]

placeHorizontale:
    

# ----- Fontion verifPlaceHorizontale -----
# Objectif : verifie si le placement (horizontale) est possible.
#   $s0 contient la taille du navire
#   $s2 contient la ligne 
#   $s3 contient la colonne
# Retourne 0 si placement ok, 1 sinon
# Registres utilises : $v0, $t[0-4], $s0, $s2, $s3

verifPlaceHorizontale:


# ----- Fontion placeVerticale -----
# Objectif : place aléatoirement un bateau de manière verticale.
#   Prends les paramètres de setShip
# Registres utilises : $v0, $a0, $a1, $s[0-4], $t[0-4]

placeVerticale:


# ----- Fontion verifPlaceVerticale -----
# Objectif : verifie si le placement (verticale) est possible.
#   $s0 contient la taille du navire
#   $s2 contient la ligne 
#   $s3 contient la colonne
# Retourne 0 si placement ok, 1 sinon
# Registres utilises : $v0, $t[0-4], $s0, $s2, $s3

verifPlaceVerticale:


# ----- Fonction simulationJeu -----
# Objectif : Simule une partie avec une grille déjà généré.
# Registres utilises : $s[0-3]

simulationJeu:


# ----- Fontion traque -----     
# Objectif : Vérifie la présence d'un navire et le traque de manière récursive
# Registres utilises : $t[8-9], $s[0-3]

traque:


exit: 
    li $v0, 10  #Chargement appel systeme 10 (Sortie)
    syscall
