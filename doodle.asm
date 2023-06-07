STACK SEGMENT PARA STACK
	DB 64 DUP (' ')
STACK ENDS

DATA SEGMENT PARA 'DATA'
    
    
	window_height DW 200d            ; the height of the window (200 pixels)
	window_width DW 320d             ; the width of the window (320 pixels)
	
	rectangle_x DW 30d               ; first X of real rectangle is 30
	rectangle_y DW 100d              ; first Y of real rectangle is 100
	
	rectangle_x_fake DW 150d         ; first X of fake rectangle is 150
	rectangle_y_fake DW 150d         ; first Y of fake rectangle is 150
	change_fake DW 0d                ; if change_fake 1, it means we have to erase the previous and create a new one
	
	rectangle_width DW 2Fh           ; width of rectangles are 47 in decimal
	rectangle_height DW 05h          ; height of rectangles are 5 in decimal
	
	game_active DB 1h                ; if game_active 0, means the game is over
	
    x_ball DW 30d                    ; first X of ball is 30
    y_ball DW 20d                    ; first Y of ball is 20
    sizeOfball DW 8d                 ; size of ball is 8
    velocity_x_ball DW 4d            ; velocity of ball in X
    velocity_y_ball DW 3d            ; velocity of ball in Y 
    acc_of_y_ball DW 1d              ; acceleration of Y ball
    change_vel_Spr DW 0d             ; if ball has collision with spring, then change velocity to move faster for a little bit
    max_of_y DW 0d                   ; it is the maximum Y that ball can reach after collision with a rectangle or a spring
    
    random_number DW 0h              ; random number to generate rectangles or springs
    
    x_insect DW 250d                 ; X of insect is 200
    y_insect DW 80d                  ; Y of insect is 80 
    sizeOfinsect DW 12d              ; size of insect is 12
                                            
    x_spring DW 40d                  ; first X of spring is 30
    y_spring DW 87d                  ; first Y of spring is 140
    sizeOfspring DW 13d              ; size of spring is 13
    change_spring DW 0d              ; if change_spring 1, it means we have to erase the previous and create a new one
    
    time DB 0d                       ; to get time of system to go on
    score DW 0d                      ; the score of the user
    thirty_score DW 0d               ; it is a boolean to check if the user reaches 30 scores or not (after reaching that, game will be finished)
    
    ; texts part
    text_score DB '0','$'                                    ; text of score to print it on screen
    text_score_sec_digit DB '0','$'                          ; text of second digit from right of score to print it on screen (for example second digit of 23 is 2)
    text_game_over DB 'GAME OVER!', '$'                      ; text of game over
    text_ur_score DB 'Your score is', '$'                    ; text of your score
    text_welcome DB '<< Welcome to doodle jump >>', '$'      ; text of welccome at the first place
    text_playgame DB ' 1. Play Game', '$'                    ; text of option 1 to start game in game menu
    text_exit DB ' 0. Exit','$'                              ; text of option 0 to exit game in game menu
    text_inputStr DB ' Enter your number: ', '$'             ; text of enter your number
    text_user_win DB 'You win the game with 30 scores.','$'  ; text of winning the game with 30 scores
    text_congrat DB 'Congrats!', '$'                         ; text of congrats for winning the game
    
   	
DATA ENDS

CODE SEGMENT PARA 'CODE'

	MAIN PROC FAR
	    
	ASSUME CS:CODE,DS:DATA,SS:STACK      ; assume as code,data and stack segments the respective registers 
	PUSH DS                              ; push to the stack the DS segment
	SUB AX,AX                            ; clean the AX register
	PUSH AX                              ; push AX to the stack
	MOV AX,DATA                          ; save on the AX register the contents of the DATA segment
	MOV DS,AX                            ; save on the DS segment the contents of AX
	POP AX                               ; release the top item from the stack to the AX register
	POP AX                               ; release the top item from the stack to the AX register
	
		
		menuOfGame:
		
		    CALL clear_screen  ; first clear the screen
		    CALL game_menu     ; then show the game menu
		
		
		    CMP AL, 1h         ; if user inputs 1 then game will be started
		    JE clear_before_check_time
		    
		    CMP AL, 0h         ; if user inputs 0 then game will be ended
		    JE end_of_game
		    
		    JMP menuOfGame     ; if user inputs anything except 0 or 1, then this process will run again.
		
		clear_before_check_time:
		    CALL clear_screen    ; clear screen before starting the game
		        
		check_time:              ; game starts from here
		    
		    CMP game_active, 0h  ; check if game active is zero, then end the game
		    JE showGameOver
		    
            MOV AH, 2ch          ; get the current time of system
            INT 21h              ; CH = hour, CL = minute, DH = second, DL = 1/100 second (centisecond)
        
            CMP DL, time
            JE check_time  
            MOV time, DL         ; update time
            
            CALL erase_ball             ; erase the ball
                                        
            CALL moveBall               ; move the ball
        
            CALL draw_ball              ; draw the ball
        
            CALL draw_rectangle         ; draw real rectangle with color green
            
            CALL fake_rectangle         ; draw fake rectangle with color brown
            
            CALL convert_fake           ; erase the middle of the fake paddle
            
            CALL colli_rectangle_fake   ; check collision with fake rectangle
            
            CALL show_scores            ; show scores on up-right corner of the screen
            
            CALL death_insect           ; draw the death insect with color red
            
            CALL colli_insect           ; check collision with insect
            
            CALL draw_spring            ; draw the spring with color gray
            
            CALL colli_spring           ; check collision with spring
             
            JMP check_time              ; run this loop again
            
        showGameOver: 
                                        ; print game over menu
            CALL game_over_menu
            
  
        end_of_game:                    ; end the game
                                       
			CALL clear_screen	        
		    MOV AH,4Ch
		    INT 21h
		
		RET
				
	MAIN ENDP
	
	generate_random_x PROC NEAR         ; genrate random Y in range 20 to 270
	 
		CALL generate_random_number
		MOV AX,random_number
		MOV BX,0003h
		MUL BX                          ; AX = random number * 3 (because the random number is between 0 to 99
		CMP AX,0FAh                  
		JBE LESS_EQUAL250
		GREATER250:
		    SUB AX,1Bh  	        ; if AX > 250 then AX -= 27 to make the rectangle be on screen
		    JMP END1
		LESS_EQUAL250:	                ; if AX <= 250 then AX += 20 to make the rectangle be on screen
		    ADD AX,14h  
        END1:
            MOV BX, change_fake         ; check this random X is for fake rectangle or not
            CMP BX, 1d
            JE putInFakeX
            
            MOV BX, change_spring       ; check this random X is for spring or not
            CMP BX, 1d
            JE putInSprX
            
                         
	    	MOV rectangle_x,AX           ; when it reaches here, means this random X is for real rectangle
	    	RET
	    	
	    	putInFakeX:
	    	    MOV rectangle_x_fake, AX ; put random X for fake rectangle
	    	    RET
	    	    
	    	putInSprX:
	    	    MOV x_spring, AX         ; put random X for spring
	    	    
		
		RET
	generate_random_x ENDP

    generate_random_y PROC NEAR 	     ; generate random Y in range 20 to 190 
        
       
       
		  CALL generate_random_number
		  
		  MOV AX,random_number
		  MOV BX,0002h
		  MUL BX                    ; AX = random number * 2
		  
		  ; instructions below until the default value are for checking that the new rectangle won't go too far with the previous one in Y, if it goes then put a default value
		  MOV BX,rectangle_y
		  CMP BX, AX
		  JLE END2                  ; if the previous value is smaller than the new one, it ok to continue
		  
		  SUB BX, AX                ; here the previous value is bigger than the new one that means the new rectangle is going higher so we have to check it
		  CMP BX, 40d               ; if the new one is not far than 40, it is ok because ball can reach it.   
		  JL END2                   ; otherwise ball cannot reach it so we put a default value for Y
		  
		  MOV AX, 100d              ; put default value 100 for rectangle Y
		  RET
		  
		  END2:
            CMP AX,0B4h                  
		    JBE less_equal_180
		    GREATER180:
		        SUB AX,05h  		    ; if AX > 180 then AX -= 5
		    	JMP END3
		    less_equal_180:	            ; if AX <= 180 then AX += 10
		        ADD AX,0Ah 		  
	      END3:
	    MOV BX, change_fake
            CMP BX, 1d
            JE putInFakeY
            
            MOV BX, change_spring
            CMP BX, 1d
            JE putInSprY
            
		    MOV rectangle_y,AX
		    RET 
		    
		    putInFakeY:
	    	    MOV rectangle_y_fake, AX
	    	    RET
	    	putInSprY:
	    	    MOV y_spring, AX
		
        RET
    generate_random_y ENDP
	
	generate_random_number PROC NEAR
				
	    MOV AH,0h                    ; get system time
	    INT 1Ah                      ; no of clocks ticks will be saved in DX
		
		MOV AX,DX
		MOV DX,0h                    ; clear DX
		MOV BX,100                   ; to generate number between 0 to 99 as remainder
		DIV BX                       ; divide AX by BX
		
		MOV random_number,DX         ; assign random number
		
	    RET
	generate_random_number ENDP
	
	
	
	draw_rectangle PROC NEAR
		
		MOV CX,rectangle_x 		     ; set the initial column (X)
		MOV DX,rectangle_y 		     ; set the initial line (Y)
		
		draw_rectangle_horitontal:
			MOV AH,0Ch 					 ; set the configuration to writing a pixel
			MOV AL,02h 					 ; choose green as color
			MOV BH,00h 					 ; set the page number 
			INT 10h    					 ; execute the configuration
			
			INC CX     				 ; CX = CX + 1
			MOV AX,CX         			 ; CX - RECTANGLE_X > RECTANGLE_WIDTH (Y -> We go to the next line,N -> We continue to the next column
			SUB AX,rectangle_x
			CMP AX,rectangle_width
			JNG draw_rectangle_horitontal
			
			MOV CX,rectangle_x 		     ; the CX register goes back to the initial column
			INC DX       			     ; we advance one line
			
			MOV AX,DX            	     ; DX - RECTANGLE_Y > RECTANGLE_HEIGHT (Y -> we exit this procedure, N -> we continue to the next line
			SUB AX,rectangle_y
			CMP AX,rectangle_height
			JNG draw_rectangle_horitontal
			
		RET
	draw_rectangle ENDP
	
	erase_rectangle PROC NEAR
	    
		MOV CX,rectangle_x 		     ; set the initial column (X)
		MOV DX,rectangle_y 		     ; set the initial line (Y)
		
		erase_rectangle_horitontal:
			MOV AH,0Ch 					 ; set the configuration to writing a pixel
			MOV AL,00h 					 ; choose black as color
			MOV BH,00h 					 ; set the page number 
			INT 10h    					 ; execute the configuration
			
			INC CX     				 ; CX = CX + 1
			MOV AX,CX         			 ; CX - RECTANGLE_X > RECTANGLE_WIDTH (Y -> We go to the next line,N -> We continue to the next column
			SUB AX,rectangle_x
			CMP AX,rectangle_width
			JNG erase_rectangle_horitontal
			
			MOV CX,rectangle_x 		     ; the CX register goes back to the initial column
			INC DX       			     ; we advance one line
			
			MOV AX,DX            	     ; DX - RECTANGLE_Y > RECTANGLE_HEIGHT (Y -> we exit this procedure, N -> we continue to the next line
			SUB AX,rectangle_y
			CMP AX,rectangle_height
			JNG erase_rectangle_horitontal
	    
	    RET
	erase_rectangle ENDP
	
	clear_screen PROC NEAR               ; clear the screen by restarting the video mode
	
			MOV AH,00h                   ; set the configuration to video mode
			MOV AL,13h                   ; choose the video mode
			INT 10h    					 ; execute the configuration 
		
			MOV AH,0Bh 					 ; set the configuration
			MOV BH,00h 					 ; to the background color
			MOV BL,00h 					 ; choose black as background color
			INT 10h    					 ; execute the configuration
			
			RET		
	clear_screen ENDP
	
	draw_ball PROC NEAR
	MOV CX, x_ball
        MOV DX, y_ball
    
    dimensionOfball:
    
        MOV AH, 0Ch ; draw a pixel
        MOV AL, 3h  ; color is cyan
        MOV BH, 0h  ; page is zero
        INT 10h
        
        INC CX
        MOV AX,CX
        SUB AX, x_ball
        CMP AX, sizeOfball
        JLE dimensionOfball ; this loop is for row of the square
        
        MOV CX, x_ball
        INC DX
    
        MOV AX,DX
        SUB AX, y_ball
        CMP AX, sizeOfball
        JLE dimensionOfball ; this loop is for column of the square
        
        CALL convert_circle ; now delete the corners of the square to convert it to ball 
        
        RET
	draw_ball ENDP
	
	erase_ball PROC NEAR
	    
	    MOV CX, x_ball
        MOV DX, y_ball
    
    eraseDimensionOfball:
    
        MOV AH, 0Ch ; draw a pixel
        MOV AL, 0h  ; color is black 
        MOV BH, 0h  ; page
        INT 10h
        
        INC CX
        MOV AX,CX
        SUB AX, x_ball
        CMP AX, sizeOfball
        JLE eraseDimensionOfball ; this loop is for row of the square
        
        MOV CX, x_ball
        INC DX
    
        MOV AX,DX
        SUB AX, y_ball
        CMP AX, sizeOfball
        JLE eraseDimensionOfball ; this loop is for column of the square
        
        RET
	erase_ball ENDP
	
	convert_circle PROC NEAR
	    MOV CX, x_ball
	    MOV DX, y_ball
	    MOV AH, 0Ch
	    MOV AL, 0h
	    MOV BH, 0h
	    INT 10h        ; delete left-up corner
	    
	    MOV AX, sizeOfball
	    ADD CX, AX
	    MOV AH, 0Ch
	    MOV AL, 0h
	    MOV BH, 0h
	    INT 10h        ; delete right-up corner
	    
	    MOV CX, x_ball
	    MOV AX, sizeOfball
	    ADD DX, AX
	    MOV AH, 0Ch
	    MOV AL, 0h
	    MOV BH, 0h
	    INT 10h        ; delete left-down corner
	    
	    MOV AX, sizeOfball
	    ADD CX, AX
	    MOV AH, 0Ch
	    MOV AL, 0h
	    MOV BH, 0h
	    INT 10h        ; delete right-down corner
	    
	    RET
	convert_circle ENDP
	
	moveBall PROC NEAR 
	  
        MOV AH, 1h ; check if any key has been pressed or not
        INT 16h          
        JZ noKey   ; if ZF = 0 means a key has been pressed 
        MOV AH, 0h
        INT 16h    ; AL has the key that been pressed
    
    ; check if the ball has to go to left
        
        CMP AL, 4Ah  ; check if it was J (4A is the ascii of J)
        JE goBallLeft
        CMP AL, 6Ah  ; check if it was j (6A is the ascii of j) 
        JE goBallLeft
        
    ; check if the ball has to go to right
      
        CMP AL, 4Bh  ; check if it was K (4B is the ascii of K)
        JE goBallRight
        CMP AL, 6Bh  ; check if it was k (6B is the ascii of k)
        JE goBallRight
        JMP noKey
        
    goBallLeft:
        MOV AX, velocity_x_ball
        NEG AX
        ADD x_ball, AX
        CMP x_ball, 0h ; if x of ball is less than zero, then do not go left anymore
        JG noKey
        NEG AX
        ADD x_ball, AX
        JMP noKey
        
    goBallRight:
        MOV AX, velocity_x_ball
        ADD x_ball, AX
        
        MOV AX, window_width
        SUB AX, sizeOfball
        CMP x_ball, AX ; if x of ball is greater than 320, then do not go right anymore
        JL noKey
        
        MOV AX, velocity_x_ball
        SUB x_ball, AX
        
        
    noKey:
        ; check Y of ball
        
        MOV AX, change_vel_Spr       ; if it's 1, means ball had collision with spring
        CMP AX, 0d
        JE donotChange
            
            MOV change_vel_Spr, 0d   ; put value 0 to change_vel_Spr as before
            MOV acc_of_y_ball, 1d    ; put acceleration to zero as before
            
        donotChange:
        
        MOV AX, velocity_y_ball     ; add velocity of Y to AX
        CMP AX, 0d                  ; check velocity is positive or negative
        JG postVel
            ; here means velocity is negative
            NEG AX                  ; change velocity to positive number for easy comparing
            CMP AX, 3d              ; if velocity is 2 or smaller, do not add acceleration
            JLE negAgain
            NEG AX                  ; velocity is greater than 2 so we add acceleration
            ADD AX, acc_of_y_ball
            JMP skipAC
            
            negAgain:
                NEG AX               ; change the velocity back to the negative
                JMP skipAC         
            
        postVel:
        CMP AX, 5d                   ; check if velocity is greater than 10, then do not add accelertaion
        JG skipAc
        
            ADD AX, acc_of_y_ball    ; add acceleration 
        skipAC:
        
        ADD y_ball, AX               ; add AX to Y of ball
        
        MOV AX, max_of_y 
        CMP y_ball, AX    ; if y of ball is less than max of y, then negative the velocity of Y
        JL neg_velocity_y
        
        MOV AX, 0h
        CMP y_ball, AX
        JL neg_velocity_y ; if y of ball is less than zero, it means it's going up from the screen so we negtaive the velocity of Y
        
        MOV AX, velocity_y_ball
        CMP AX, 0h
        JG checkCollision ; if the velocity of Y is negative, it means that it is going up so we don't check the collision
        
        RET
        
        checkCollision:
        
        ; check collision for Y of ball and rectangle
        MOV AX, y_ball
        SUB AX, rectangle_y
        CMP AX, 0h         ; check if ball has collision with rectangle or not, if it has then go to bonusScore label
        JL coll_floor
        
        ; check collision for X of ball and rectangle
        MOV AX, x_ball
        SUB AX, rectangle_x 
        CMP AX, 0h    ; first we check that x of ball is greater than x of rectangle
        JL coll_floor ; if less than 0, means ball is in left side of the rectangle and is not above it
        
        SUB AX, rectangle_width
        CMP AX, 0h     ; then we check that x of ball is less than the width of rectangle 
        JLE bonusScore ; if less equal to zero, means ball is not in right of the rectangle and is above it 
         
        coll_floor: ; check collision of ball with the floor
        MOV AX, window_height
        SUB AX, sizeOfball
        CMP y_ball, AX     ; if y of ball is greater than 200 = Game Over
        JG  game_over 
        
        RET
        
    bonusScore:
        
        ADD score, 2h  ; add 1 score to the player
        CALL update_scores
        
        MOV AX, y_ball
        SUB AX, 60d      ; ball goes up for 20 unit because of collision to the right rectangle
        MOV max_of_y, AX ; max of y = y_ball - 60 (ball can go up for 20 unit)
        
        CALL erase_rectangle   ; erase the previous rectangle
        CALL generate_random_x ; generate random X for the new rectangle
		CALL generate_random_y ; generate random Y for the new rectangle
        
    neg_velocity_y:
        NEG velocity_y_ball    ; negative the velocity of Y of ball
        RET
        
    game_over:
        MOV game_active, 0h    ; user loses, so game active is 0 to game over
        RET
        
	moveBall ENDP
	
	show_scores PROC NEAR
	    
	    MOV AX, score
	    CMP AX, 9d
	    JLE showNormally   ; if the user's scores are below 9, print it normally
	    
	    ; if the user's scores are above 9, first we print the second digit as mentioned in data segment
	    ; then print the other digit (for example for 23, first we print 2 then we print 3
	    
	    MOV AH, 02h  ; set cursor position to print score 
	    MOV BH, 0h   ; set page number to 0
	    MOV DH, 01h  ; set row
	    MOV DL, 25h  ; set column
	    INT 10h
	    
	    MOV AH, 09h  ; write string to output
	    LEA DX, text_score_sec_digit
	    INT 21h
	    
	    showNormally:
	    
	    MOV AH, 02h  ; set cursor position to print score 
	    MOV BH, 0h   ; set page number to 0
	    MOV DH, 01h  ; set row
	    MOV DL, 26h  ; set column
	    INT 10h
	    
	    MOV AH, 09h  ; write string to output
	    LEA DX, text_score
	    INT 21h
	    
	    RET
	    
	show_scores ENDP  
	
	update_scores PROC NEAR
	    
	    XOR AX, AX   ; clear AX
	    MOV AX, score
	    CMP AX, 9d
	    JLE convNormally  ; if the user's scores are below 9, update it normally
	    
	    ; if the user's scores are above 9, first we update the second digit as mentioned in data segment
	    ; then update the other digit (for example for 23, first we update 2 then we update 3 
	    
	    SUB AX, 9d        ; subtract the score with 9
	    CMP AX, 10d       ; if it's bigger than 10, it means score is above 20
	    JG twenties       ; so we jump to twenties
	    
	        MOV BL, 1d    ; when it reaches here, means the score is between 10 and 19 so the second digit is 1
	        ADD BL, 48d
	        MOV [text_score_sec_digit], BL   
	        SUB AX, 1d
	        JMP convNormally
	        
	    
	    twenties:        ; the second digit in this part is 2
	        CMP AX, 20d
	        JG endGame
	        
	        MOV BL, 2d
	        ADD BL, 48d
	        MOV [text_score_sec_digit], BL   
	        SUB AX, 11d
	        
	    
	    convNormally:
	        ADD AX, 48d          ; convert to ASCII
	        MOV [text_score], AL ; put new score to the address of 'text_score'
	        RET
	        
	    endGame:
	        MOV game_active, 0h
	        MOV thirty_score, 1d ; it means user finished the game with reaching 30 scores
	    RET
	update_scores ENDP
	
	game_over_menu PROC NEAR
	    
	    CALL clear_screen
	    
	    MOV AX, thirty_score
	    CMP AX, 0d
	    JE userLose      ; if user's score is below 30, it means user lost the game
	    
	        MOV AH, 02h  ; set cursor position to print score 
	        MOV BH, 0h   ; set page number to 0
	        MOV DH, 05h  ; set row
	        MOV DL, 05h  ; set column
	        INT 10h
	    
	        MOV AH, 09h  ; write string to output
	        LEA DX, text_congrat ; write congrats
	        INT 21h
	        
	        MOV AH, 02h  ; set cursor position to print score 
	        MOV BH, 0h   ; set page number to 0
	        MOV DH, 07h  ; set row
	        MOV DL, 05h  ; set column
	        INT 10h
	    
	        MOV AH, 09h  ; write string to output
	        LEA DX, text_user_win ; write user win
	        INT 21h
	           
	        JMP waiting
	   
	    userLose:
	    
	    MOV AH, 02h  ; set cursor position to print score 
	    MOV BH, 0h   ; set page number to 0
	    MOV DH, 05h  ; set row
	    MOV DL, 05h  ; set column
	    INT 10h
	    
	    MOV AH, 09h  ; write string to output
	    LEA DX, text_game_over ; write game over title
	    INT 21h
	    
	    MOV AH, 02h  ; set cursor position to print score 
	    MOV BH, 0h   ; set page number to 0
	    MOV DH, 07h  ; set row
	    MOV DL, 05h  ; set column
	    INT 10h
	    
	    MOV AH, 09h  ; write string to output
	    LEA DX, text_ur_score ; write 'Your score is: '
	    INT 21h
	    
	    
	    MOV AX, score
	    CMP AX, 9d
	    JLE showNorm   ; if the user's scores are below 9, print it normally  
	         
	         MOV AH, 02h  ; set cursor position to print score 
	         MOV BH, 0h   ; set page number to 0
	         MOV DH, 07h  ; set row
	         MOV DL, 13h  ; set column
	         INT 10h
	    
	         MOV AH, 09h  ; write string to output
	         LEA DX, text_score_sec_digit
	         INT 21h 
	         
	    showNorm:
	    MOV AH, 02h  ; set cursor position to print score 
	    MOV BH, 0h   ; set page number to 0
	    MOV DH, 07h  ; set row
	    MOV DL, 14h  ; set column
	    INT 10h
	    
	    MOV AH, 09h   ; write string to output
	    LEA DX, text_score ; write the score 
	    INT 21h
	    
	    waiting: ; wait for a key press
	    MOV AH, 0h
	    INT 16h
	    
	    RET
	game_over_menu ENDP
	
	game_menu PROC NEAR
	     
	    MOV AH, 02h  ; set cursor position to print score 
	    MOV BH, 0h   ; set page number to 0
	    MOV DH, 05h  ; set row
	    MOV DL, 05h  ; set column
	    INT 10h
	    
	    LEA DX, text_welcome ; print welcome message
        MOV AH, 09h
        INT 21h
        
        MOV AH, 02h  ; set cursor position to print score 
	    MOV BH, 0h   ; set page number to 0
	    MOV DH, 07h  ; set row
	    MOV DL, 05h  ; set column
	    INT 10h
	    
	    LEA DX, text_playgame ; pring option 1. Play Game
        MOV AH, 09h
        INT 21h
        
        MOV AH, 02h  ; set cursor position to print score 
	    MOV BH, 0h   ; set page number to 0
	    MOV DH, 09h  ; set row
	    MOV DL, 05h  ; set column
	    INT 10h
	    
	    LEA DX, text_exit ; print option 2. Exit
        MOV AH, 09h
        INT 21h
        
        MOV AH, 02h  ; set cursor position to print score 
	    MOV BH, 0h   ; set page number to 0
	    MOV DH, 11h  ; set row
	    MOV DL, 05h  ; set column
	    INT 10h
	    
	    LEA DX, text_inputStr ; print 'Enter your number:'
        MOV AH, 09h
        INT 21h
        
        
        
        MOV AH, 1h  ; get input the number from user
	    INT 21h
	    SUB AL, 48d ; convert to ASCII
	    
	    RET
	game_menu ENDP
	
	death_insect PROC NEAR  ; it is a red square in the screen
	    
	    MOV CX, x_insect
        MOV DX, y_insect
    
    dimensionOfinsect:
    
        MOV AH, 0Ch ; draw a pixel
        MOV AL, 4h  ; color is red
        MOV BH, 0h  ; page
        INT 10h
        
        INC CX
        MOV AX,CX
        SUB AX, x_insect
        CMP AX, sizeOfinsect
        JLE dimensionOfinsect ; this loop is for row of the insect
        
        MOV CX, x_insect
        INC DX
    
        MOV AX,DX
        SUB AX, y_insect
        CMP AX, sizeOfinsect
        JLE dimensionOfinsect ; this loop is for column of the insect
	    
	    
	    RET
	death_insect ENDP
	
	colli_insect PROC NEAR  ; check if the ball has collision with insect 
	    
	    ; check collision for Y of ball and insect
	    MOV AX, y_ball
        SUB AX, y_insect
        CMP AX, 0h         ; check if ball has collision with insect or not, if it has then game over
        JL NoCol           ; if it jumps, means that y_ball is above the y_insect
        
        SUB AX, sizeOfinsect ; if we reach here, means that ball is below the insect
        CMP AX, 0h           ; check if y_ball has collision from below with y_insect
        JG NoCol
        
        ; check collision for X of ball and insect
        MOV AX, x_ball
        SUB AX, x_insect 
        CMP AX, 0h    ; first we check that x of ball is greater than x of insect
        JL NoCol ; if less than 0, means ball is in left side of the insect and is not above it
        
        SUB AX, sizeOfinsect
        CMP AX, 0h     ; then we check that x of ball is less than the width of insect 
        JG NoCol
             
             MOV game_active, 0h  ; if we reach here, means we had collision so put game active to 0 (game over) 
              
        NoCol:  ; no collision
           
	    
	    RET
	colli_insect ENDP
	
	fake_rectangle PROC NEAR             ; draw the fake rectangle just like the draw_rectangle PROC
	    	
		MOV CX,rectangle_x_fake 	     ; set the initial column (X)
		MOV DX,rectangle_y_fake 	     ; set the initial line (Y)
		
		draw_rectangle_horitontal:
		
			MOV AH,0Ch 					 ; set the configuration to writing a pixel
			MOV AL,06h 					 ; choose brown as color
			MOV BH,00h 					 ; set the page number 
			INT 10h    					 ; execute the configuration
			
			INC CX     				 	 
			MOV AX,CX         			 
			SUB AX,rectangle_x_fake
			CMP AX,rectangle_width
			JNG draw_rectangle_horitontal
			
			MOV CX,rectangle_x_fake
			INC DX       				 
			
			MOV AX,DX            	     
			SUB AX,rectangle_y_fake
			CMP AX,rectangle_height
			JNG draw_rectangle_horitontal
	    
	    RET
	fake_rectangle ENDP
	
	convert_fake PROC NEAR
	    MOV AX, rectangle_x_fake
	    ADD AX, 23d               ; now X is in the middle of fake paddle
	    MOV CX, AX
	    
	    MOV DX, rectangle_y_fake
	    
	    convertFake:              ; in this loop, we erase the middle of the fake paddle
	    
	        MOV AH,0Ch            ; set the configuration to writing a pixel
		    MOV AL,00h 		  ; choose black as color		 
		    MOV BH,00h 		  ; set the page number			 
		    INT 10h               ; execute the configuration
		    
		    INC CX
		    MOV AX, CX
		    SUB AX, rectangle_x_fake
		    CMP AX, 26
		    JNG convertFake
		    
		    MOV AX, rectangle_x_fake
	        ADD AX, 23d
	        MOV CX, AX 
	        
	        INC DX
	        MOV AX, DX
	        SUB AX, rectangle_y_fake
	        CMP AX, rectangle_height
	        JNG convertFake 
	      
	    RET
	convert_fake ENDP
	
	erase_fake_rectangle PROC NEAR       ; erase the fake rectanlge just like erase the real rectangle
	    	
		MOV CX,rectangle_x_fake 		 ; set the initial column (X)
		MOV DX,rectangle_y_fake 		 ; set the initial line (Y)
		
		draw_rectangle_horitontal: 
		
			MOV AH,0Ch 					 ; set the configuration to writing a pixel
			MOV AL,00h 					 ; choose brown as color
			MOV BH,00h 					 ; set the page number 
			INT 10h    					 ; execute the configuration
			
			INC CX     				 	 
			MOV AX,CX         			 
			SUB AX,rectangle_x_fake
			CMP AX,rectangle_width
			JNG draw_rectangle_horitontal
			
			MOV CX,rectangle_x_fake 		 
			INC DX       				 
			
			MOV AX,DX            	     
			SUB AX,rectangle_y_fake
			CMP AX,rectangle_height
			JNG draw_rectangle_horitontal
	    
	    RET
	erase_fake_rectangle ENDP
	
	colli_rectangle_fake PROC NEAR
	    
	    MOV AX, velocity_y_ball
        CMP AX, 0h
        JG checkCollisionFake ; if the velocity of Y is negative, it means that it is going up so we don't check the collision
        
        RET
        
        checkCollisionFake:
	    ; check collision for Y of ball and fake rectangle
	    MOV AX, y_ball
        SUB AX, rectangle_y_fake
        CMP AX, 0h             ; check if ball has collision with fake rectangle or not, if it has then delete this rectangel and make a new one
        JL NoColFake           ; if it jumps, means that y_ball is above the rectangle_fake_y
        
        SUB AX, rectangle_height ; if we reach here, means that ball is below the rectangle
        CMP AX, 0h               ; check if y_ball has collision from below with rectangle_fake_y
        JG NoColFake
        
        ; check collision for X of ball and fake rectangle
        MOV AX, x_ball
        SUB AX, rectangle_x_fake 
        CMP AX, 0h    ; first we check that x of ball is greater than x of fake rectangle
        JL NoColFake  ; if less than 0, means ball is in left side of the fake rectangle and is not above it
        
        SUB AX, rectangle_width
        CMP AX, 0h     ; then we check that x of ball is less than the width of rectangle 
        JG NoColFake
           
           CALL erase_fake_rectangle  
           MOV change_fake, 1d     ; put change fake to 1 so it means we have to make a new fake rectangle
           CALL generate_random_x  ; call random generator for X
		   CALL generate_random_y  ; call random generator for Y
		   MOV change_fake, 0d     ; put change fake to 0 so it won't conflict with green rectangle
              
        NoColFake:     ; no collision 
        
	    RET
	colli_rectangle_fake ENDP
	
	draw_spring PROC NEAR
	    
	    MOV CX, x_spring
        MOV DX, y_spring
    
    dimensionOfspring:
    
        MOV AH, 0Ch ; draw a pixel
        MOV AL, 7h  ; color is gray
        MOV BH, 0h  ; page
        INT 10h
        
        INC CX
        MOV AX,CX
        SUB AX, x_spring
        CMP AX, sizeOfspring
        JLE dimensionOfspring ; this loop is for row of the square
        
        MOV CX, x_spring
        INC DX
    
        MOV AX,DX
        SUB AX, y_spring
        CMP AX, sizeOfspring
        JLE dimensionOfspring ; this loop is for column of the square
         
	    RET
	draw_spring ENDP 
	
	erase_spring PROC NEAR
	    MOV CX, x_spring
        MOV DX, y_spring
    
    dimensionOfspring:
    
        MOV AH, 0Ch ; draw a pixel
        MOV AL, 0h  ; color is black
        MOV BH, 0h  ; page
        INT 10h
        
        INC CX
        MOV AX,CX
        SUB AX, x_spring
        CMP AX, sizeOfspring
        JLE dimensionOfspring ; this loop is for row of the square
        
        MOV CX, x_spring
        INC DX
    
        MOV AX,DX
        SUB AX, y_spring
        CMP AX, sizeOfspring
        JLE dimensionOfspring ; this loop is for column of the square
         
	    RET
	erase_spring ENDP
	
	colli_spring PROC NEAR
	    
	    MOV AX, velocity_y_ball
        CMP AX, 0h
        JG checkCollisionSpr ; if the velocity of Y is negative, it means that it is going up so we don't check the collision
        
        RET
        
        checkCollisionSpr:
	    ; check collision for Y of ball and spring
	    MOV AX, y_ball
        SUB AX, y_spring
        CMP AX, 0h         ; check if ball has collision with spring or not
        JL NoColSpr        ; if it jumps, means that y_ball is above the y_spring
        
        SUB AX, sizeOfspring ; if we reach here, means that ball is below the spring
        CMP AX, 0h           ; check if y_ball has collision from below with y_spring
        JG NoColSpr
        
        ; check collision for X of ball and spring
        MOV AX, x_ball
        SUB AX, x_spring 
        CMP AX, 0h    ; first we check that x of ball is greater than x of spring
        JL NoColSpr   ; if less than 0, means ball is in left side of the spring and is not above it
        
        SUB AX, sizeOfspring
        CMP AX, 0h     ; then we check that x of ball is less than the width of spring 
        JG NoColSpr
             
             CALL erase_spring  
             
             MOV change_vel_Spr, 1d
             MOV AX, y_ball
             SUB AX, 100d
             MOV max_of_y, AX   ; put the maximum Y that ball can reach to 100 from current Y
             
             MOV change_spring, 1d  ; put change spring to 1 so it means we have to change position of the spring
             ADD score, 5d          ; add 5 score to the player
             CALL update_scores     ; update scores
             CALL generate_random_x ; generate random X for new position of spring
             CALL generate_random_y ; generate random Y for new position of spring
             MOV acc_of_y_ball, 25d ; put acceleration to 10
             NEG acc_of_y_ball
             NEG velocity_y_ball    ; change the direction of ball to go to up
             
             MOV change_spring, 0d  ; put change spring to 0 so it won't conflict with other parts like fake and real rectangles
             
              
        NoColSpr:     ; no collision
           
	    RET
	colli_spring ENDP
	
	
CODE ENDS
END MAIN
