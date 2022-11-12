TITLE Nested Loops and Procedures     (Proj4_arellano.asm)

; Author: Osbaldo Arellano
; Last Modified: 11/07/22
; OSU email address: arellano@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:      4           Due Date: 11/13/22
; Description:  The program asks the user to input an N number in the range of [1, 200] inclusive. 
;				The prpogram will verify that N is in range.
;				If N is not in range, the program will keep requesting input until valid input is detected. 
;				When the program gets valid input, it will calculate N primes and display them to the user. 
;				Ten prime numbers will be displayed per line with three spaces between each prime. 
;				The final line might have fewer than ten primes. 

INCLUDE Irvine32.inc

UPPER = 200
LOWER = 1

.data
intro	        BYTE	"Prime Numbers Programmed by Osbaldo Arellano",13,10,13,10
                BYTE	"Enter a number of primes you would like to see.",13,10
                BYTE	"Number must be within 1 and 200 inclusive.",13,10,0
inputMssg       BYTE	"Enter the number of primes to be displayed in range [1...200]: ",13,10,0
invalid	        BYTE	"Number is not in range. Try again.",13,10,13,10,0
valid           BYTE	" prime number(s) will be displayed",13,10,0
goodbye         BYTE	"Results certified by Osbaldo Arellano. Goodbye! ",13,10,0
threeSpaces     BYTE    "   ",0     ; Three spaces are printed between each prime
current         DWORD	3			; Since we are displaying 2 by default, we'll start at 3 for prime checking
divisor         DWORD	2			; Used to determine the remainder of div 
validFlag       DWORD	0			; Flag set if user input is within range
primeFlag       DWORD   0			; Flag set if current number is prime

range	        DWORD	?			; Once program gets valid input, range will be initialized to valid input
half            DWORD	?			; Used for prime checking a number 
primeCount      DWORD	?			; Holds current number of primes displayed. New line is printed after 10 primes 


.code
; ---------------------------------------------------------------------------------
; Name: main
;
; Entry point of the program. Calls procedures to calculate and display N primes. 
;
; ---------------------------------------------------------------------------------
main PROC
	call	introduction                     ; Displays program introduction. 
	call	getUserData                      ; Asks for user input N in the range of [1,200] inclusive. 
	call	showPrimes                       ; Displays N prime numbers.  
	call	farewell                         ; Displays a goodbye message. 

	Invoke ExitProcess,0	
main ENDP


; ---------------------------------------------------------------------------------
; Name: introduction
;
; Displays a welcome message and displays instructions. 
;
; ---------------------------------------------------------------------------------
introduction PROC
	mov     edx, OFFSET intro
	call	WriteString
	ret
introduction ENDP


; ---------------------------------------------------------------------------------
; Name: getUserData
;
; Displays instructions and asks for input. 
; Range is initialized to input.
; Calls sub-procedure 'validate' to check if range is within [1, 200] inclusive.
; Checks if global variable validFlag is set after calling 'validate'. 
; If validFlag is false, the program will ask for addtional input 
;	until validFlag is true. 
; 
; Returns: none (uses globals)
; ---------------------------------------------------------------------------------
getUserData PROC
	_getInput:
		mov     edx, OFFSET inputMssg
		call	WriteString
		call	ReadDec
		mov     range, eax
		call	validate
        cmp     validFlag,0                  ; If flag != 1, then input is not valid
		je		_getInput
		call	CrLf
		ret
getUserData ENDP


; ---------------------------------------------------------------------------------
; Name: validate
;
; Checks if user input is within range [1, 200] inclusive.
;
; Receives: none (uses globals)
;
; Returns: none (uses globals)
; ---------------------------------------------------------------------------------
validate PROC
    cmp     range, LOWER                     ; Checking lower bound
	jl		_notValid
    cmp     range, UPPER                     ; Checking upper bound
	jg		_notValid
    mov     validFlag, 1                     ; Set flag to 1. Calling procedure wil check flag.
	ret

	_notValid:
    ret                                      ; Dont set flag, just return. 
validate ENDP


; ---------------------------------------------------------------------------------
; Name: showPrimes
;
; Displays prime numbers range number of times (inclusive). For exmaple, if range = 10, 
;	then 10 prime numbers will be printed. Each prime number is padded with 
;	three spaces. Ten prime numbers are displayed per line. The final line might have fewer
;	than 10 primes. 
;
; Preconditions: global variable 'range' to be initialized to a valid number in range [1,200]
;
; Returns: none
; ---------------------------------------------------------------------------------
showPrimes PROC
	mov     eax, range
	call	WriteDec
	mov     edx, OFFSET valid
	call	WriteString
	call	CrLf

	cmp     range, 1
	je      _singlePrime                    ; If range is 1, then we only need to display 2 and return. 

	mov     eax, 2                          ; Display 2 by default
	call	WriteDec
	mov     edx, OFFSET threeSpaces
	call	WriteString

	inc     primeCount                      ; Increment since 2 is always displayed
	dec     range                           ; Decrement range since we already displayed 2 (displaying one less prime). 

	; ----------------------
	; Main loop to iterate through each number
	; up to and including range. Uses ECX and loop instruction.  
	; ECX is preserved before a procedure call to avoid modifying  
	; the loop counter outside the procedure. 
	;
	; Called procedure 'isPrime' sets global variable 'primeFlag' to true or false. 
	; Jumps to _isPrime if primeFlag is true; the current number in the loop is displayed. 
	; -----------------------
    mov     ecx, range                       ; Loop counter initialized to range (user input)
	_loop:
		push    ecx
		call	isPrime
		pop     ecx
		cmp     primeFlag, 1
		je      _isPrime	 
        inc     ecx                          ; Current number is not prime. Increment counter by 1 to not termiate loop early. 
		inc     current
		loop	_loop
		ret
	
	_isPrime:
		mov     eax, current
		call	WriteDec
		mov     edx, OFFSET threeSpaces
		call    WriteString
		inc     current
		inc     primeCount
        cmp     primeCount, 10               ; New line is printed after 10 primes are displayed.
		je      _printLine
		loop	_loop
		ret
		

	; -----------------
	; The range was 1, no need to do calculations, 
	; just display 2 and return.
	; -----------------
	_singlePrime:
		mov     eax, 2
		call	WriteDec
		ret

	; --------------
	; Jumped to when 10 primes are displayed.
	; Prints a new line and sets the prime count to zero. 
	; --------------
	_printLine:
		call	CrLf
		mov     primeCount, 0
		loop	_loop
		ret
showPrimes ENDP


; ---------------------------------------------------------------------------------
; Name: isPrime
;
; Checks if the current number from the calling procedure is prime. 
; Uses DIV and checks remainder in EDX to know if current number is not prime.
; If the remainder is zero, then current number is not prime and the primeFlag is set to flase;
;	the calling procedure wont display the current number. 
; Otherwiese primeFlag is set to true; the calling procedure prints the current number. 
;
; Preconditions: Global variable initialized to a valid number in the range of [1,200]
; ---------------------------------------------------------------------------------
isPrime PROC
    mov     divisor, 2                      ; Reinitalize the divisor since divisor is incremented every call 
	mov     edx, 0
	mov     eax, current
	div     divisor

	; ---------------------
	; Loop range is always 2 to (current number / 2). 
	; No need to check above half the current number. 
	; Using remainder in EDX to check if current number is not prime. 
	; Loop terminates when divsor = half. 
	; ---------------------
	mov     half, eax					   
	_loop:
		mov     edx, 0
		mov     eax, current
		div     divisor
		cmp     edx, 0
		je      _notPrime
		inc     divisor
		mov     eax, half
        cmp     divisor, eax               ; Checks loop range (divisor < half)
		jl      _loop

    mov     primeFlag, 1                   ; If loop terminates, the current number is prime.
	ret

	_notPrime:
		mov     primeFlag, 0
		ret

isPrime ENDP


; ---------------------------------------------------------------------------------
; Name: farewell
;
; Displays a goodbye message. 
;
; ---------------------------------------------------------------------------------
farewell PROC
	call	CrLf
	call	CrLf
	mov     edx, OFFSET goodbye
	call	WriteString
	ret
farewell ENDP

END main