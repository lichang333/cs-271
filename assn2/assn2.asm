TITLE Programming Assignment #2 (assn2.asm)

; Author: Alec Merdler
;
; Description: Write a program to calculate Fibonacci numbers.
;	           Display the program title and programmer’s name. Then get the user’s name, and greet the user.
;	           Prompt the user to enter the number of Fibonacci terms to be displayed. Advise the user to enter an integer
;		            in the range [1 .. 46].
;	           Get and validate the user input (n).
;	           Calculate and display all of the Fibonacci numbers up to and including the nth term. The results should be
;		            displayed 5 terms per line with at least 5 spaces between terms.
;	           Display a parting message that includes the user’s name, and terminate the program.

INCLUDE Irvine32.inc

.data
programTitle		BYTE	"Fibonacci Numbers, programmed by Alec Merdler", 0
namePrompt			BYTE	"Enter your name: ", 0
termsPrompt			BYTE	"Enter the number of Fibonacci terms you would like to see. Please enter a number between [1 - 46]: ", 0
ecPrompt			BYTE	"EC: Doing something awesome: Setting text color to teal-ish", 0
numFib				DWORD	?
prev1				DWORD	?
prev2				DWORD	?
spaces				BYTE	"     ",0
goodbye				BYTE	"Goodbye, ", 0
firstTwo			BYTE	"1     1     ", 0
firstOne			BYTE	"1", 0
temp				DWORD	?
moduloFive			DWORD	5
UPPERLIMIT = 46
LOWERLIMIT = 1

; User's name
buffer				BYTE 21 DUP(0)
byteCount			DWORD	?

greeting			BYTE	"Hello, ",0

; Validation
tooHighError		BYTE	"The number you entered is too high! It must be 46 or below. ", 0
tooLowError			BYTE	"The number you entered is too low! It must be 1 or above. ", 0

; **EC: Doing something awesome: Setting  Background Color and Text Color
val1 DWORD 11
val2 DWORD 16

.code
main PROC

	;**EC: Doing something awesome like setting the text color
		mov     eax, val2
		imul    eax, 16
		add     eax, val1
		call    setTextColor

	; INTRODUCTION
		mov		edx, OFFSET programTitle
		call	WriteString
		call	CrLf

		; EC Prompt
		mov		edx, OFFSET ecPrompt
		call	WriteString
		call	CrLf

		mov		edx, OFFSET namePrompt
		call	WriteString

		; Get user's name
		mov		edx, OFFSET buffer	;point to the buffer
		mov		ecx, SIZEOF	buffer	; specify max characters
		call	ReadString
		mov		byteCount, eax

		; greet the user
		mov		edx, OFFSET greeting
		call	WriteString
		mov		edx, OFFSET buffer
		call	WriteString
		call	CrLf

	; USER INSTRUCTIONS
topPrompt:
        mov		edx, OFFSET termsPrompt
        call	WriteString

	; GET USER DATA
		call	ReadInt
		mov		numFib, eax

	; Validate user data
		cmp		eax, UPPERLIMIT
		jg		TooHigh
		cmp		eax, LOWERLIMIT
		jl		TooLow
		je		JustOne
		cmp		eax, 2
		je		JustTwo

	; DISPLAY FIBS
		; Prepare loop (post-test), do the first two manually
		mov		ecx, numFib
		sub		ecx, 3
		mov		eax, 1
		call	WriteDec
		mov		edx, OFFSET spaces
		call	WriteString
		call	WriteDec
		mov		edx, OFFSET spaces
		call	WriteString
		mov		prev2, eax
		mov		eax, 2
		call	WriteDec
		mov		edx, OFFSET spaces
		call	WriteString
		mov		prev1, eax

		fib:
			; add prev 2 to eax
			add		eax, prev2
			call	WriteDec

			mov		edx, OFFSET spaces
			call	WriteString

			mov		temp, eax
			mov		eax, prev1
			mov		prev2, eax
			mov		eax, temp
			mov		prev1, eax

			;for spacing (first time it should be % 3, rest %5)
			mov		edx, ecx
			cdq
			div		moduloFive
			cmp		edx, 0
			jne		skip
			call	CrLf

		skip:
				; restore what was on eax
				mov		eax, temp
				; if ecx % 3 = 0 call CrLf
				loop	fib
		jmp		TheEnd

TooHigh:
			mov		edx, OFFSET tooHighError
			call	WriteString
			jmp		TopPrompt

TooLow:
			mov		edx, OFFSET tooLowError
			call	WriteString
			jmp		TopPrompt
JustOne:
			mov		edx, OFFSET firstOne
			call	WriteString
			jmp		TheEnd

JustTwo:
			mov		edx, OFFSET firstTwo
			call	WriteString
			jmp		TheEnd

	; FAREWELL
TheEnd:
			call	CrLf
			mov		edx, OFFSET goodbye
			call	WriteString
			mov		edx, OFFSET buffer
			call	WriteString
			call	CrLf

	exit
main ENDP

END main
