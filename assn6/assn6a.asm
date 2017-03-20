TITLE Programming Assignment #6 Low Level I/O (assn6a.asm)

; ====================================================================================================================
; Author: Alec Merdler
; Description:
;   Write and test a MASM program to perform the following tasks:
;   1. User’s numeric input must be validated the hard way: Read the user's input as a string, and convert the string
;      to numeric form. If the user enters non-digits or the number is too large for 32-bit registers, an error message
;      should be displayed and the  number should be discarded.
;   2. Conversion routines must appropriately use the lodsb and/or stosb operators.
;   3. All procedure parameters must be passed on the system stack.
;   4. Addresses of prompts, identifying strings, and other memory locations should be passed by address to the macros.
;   5. Used registers must be saved and restored by the called procedures and macros.
;   6. The stack must be “cleaned up” by the called procedure.
;   7. The usual requirements regarding documentation, readability, user-friendliness, etc., apply.
; ====================================================================================================================

INCLUDE Irvine32.inc

.data
MIN      = 0
LO       = 30h
HI       = 39h
MAX_SIZE = 10

welcome					   BYTE	  "PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures programmed by Alec Merdler.", 0
instructions_1			   BYTE	  "Please provide 10 unsigned decimal integers. Each number needs to be small enough to fit inside a 32 bit register.", 0
instructions_2			   BYTE   "After you have finished inputting the raw numbers I will display a list of the integers, their sum, and their average value.", 0
instructions_3			   BYTE   "Please enter an unsigned integer: ", 0
errString				   BYTE	  "ERROR: You did not enter an unsigned number or your number was too big.", 0
spacingMessage			   BYTE	  ", ", 0
goodbye					   BYTE	  "Thanks for playing!", 0
enteredString			   BYTE   "You entered the following numbers: ", 0
sumMessage				   BYTE   "The sum of these numbers is: ", 0
averageMessage			   BYTE	  "The average is: ",0
request					   DWORD  10 DUP(0)
requestCount			   DWORD  ?
list					   DWORD MAX_SIZE DUP(?)
strResult				   db 16 dup (0)


; ====================================================================================================================
;             Macro: getString
;       Description: Prompt the user for input and store input as string.
;          Receives: none
;           Returns: none
; Registers Changed: edx
; ====================================================================================================================
getString MACRO	instruction, request, requestCount
	push	edx
	push	ecx
	push	eax
	push	ebx

	mov		edx, OFFSET instructions_3
	call	WriteString
	mov		edx, OFFSET request
	mov		ecx, SIZEOF	request
	call	ReadString
	mov		requestCount, 00000000h
	mov		requestCount, eax

	pop     ebx
	pop		eax
	pop		ecx
	pop		edx

ENDM


; ====================================================================================================================
;             Macro: displayString
;       Description: Calls other procedures to drive the program.
;          Receives: none
;           Returns: none
; Registers Changed: edx
; ====================================================================================================================
displayString MACRO  strResult
	push	edx
	mov		edx, strResult
	call	WriteString
	pop		edx

ENDM

.code
; ====================================================================================================================
;         Procedure: main
;       Description: Calls other procedures to drive the program.
;          Receives: none
;           Returns: none
; Registers Changed: edx
; ====================================================================================================================
 main PROC
	call	introduction

	push	OFFSET list
	push	OFFSET request
	push	OFFSET requestCount
	call	readVal

	call	CrLf

	push	OFFSET averageMessage
	push	OFFSET sumMessage
	push	OFFSET list
	call	displayAve

	call	CrLf

	push	edx
	mov		edx, OFFSET enteredString
	call	WriteString
	pop		edx

	push	OFFSET strResult
	push	OFFSET list
	call	writeVal

	call	CrLf

	push	OFFSET goodbye
	call	farewell

	exit
main ENDP


; ====================================================================================================================
;         Procedure: introduction
;       Description: Prints program instructions and introduction.
;          Receives: none
;           Returns: none
; Registers Changed: none
; ====================================================================================================================
introduction PROC
	call	 CrLf
	mov		 edx, OFFSET welcome
	call	 WriteString
	call	 CrLf
	call	 CrLf

	mov		edx, OFFSET instructions_1
	call	WriteString
	mov		edx, OFFSET instructions_2
	call	WriteString
	call	CrLf

	ret
introduction ENDP


; ====================================================================================================================
;         Procedure: readVal
;       Description: Receives and validates an integer from the user and
;                    transforms decimal value into string.
;          Receives: an array to store values in, a buffer to read the input
;           Returns: puts user's integers into an array of strings
; Registers Changed: edx, eax, ecx, ebx
; ====================================================================================================================
readVal PROC
		push  ebp
		mov	  ebp, esp
		mov	  ecx, 10								; we need 10 numbers total.
		mov	  edi, [ebp+16]							; we want to store stuff in the list array

	userNumberLoop:

					getString instructions_3, request, requestCount    ; Call Macro

					push	ecx
					mov		esi, [ebp+12]			; put request into esi
					mov		ecx, [ebp+8]			; put the requestCount which is the number of digits the person entered
					mov		ecx, [ecx]				; get the value at ecx into ecx
					cld								; were moving forward through the array
					mov		eax, 00000000			; clear eax
					mov		ebx, 00000000			; we will use ebx as ACCUMULATOR

						str2int:
							lodsb					; this should load request into eax one byte at a time

							cmp		eax, LO			; error checking
							jb		errMessage		; error checking
							cmp		eax, HI			; error checking
							ja		errMessage		; error checking

							sub		eax, LO			; 30
							push	eax
							mov		eax, ebx
							mov		ebx, MAX_SIZE
							mul		ebx
							mov		ebx, eax
							pop		eax
							add		ebx, eax
							mov		eax, ebx

							continn:
							mov		eax, 00000000
							loop	str2int

					mov		eax,ebx
					stosd							; put eax into list array

					add		esi, 4					; next element
					pop		ecx
					loop	userNumberLoop
					jmp		readValEnd

		errMessage:
				pop		ecx
				mov		edx, OFFSET  errString
				call	WriteString
				call	CrLf
				jmp		userNumberLoop

	readValEnd:
	pop ebp
	ret 12													; clean up the stack.
readVal ENDP


; ====================================================================================================================
;         Procedure: writeVal
;       Description: Utilizes 'displayString' macro to convert strings to ASCII
;                    and print to console.
;          Receives: list: @array and request: number of array elements
;           Returns: none
; Registers Changed: eax, ecx, ebx, edx
; ====================================================================================================================
writeVal PROC
	push	ebp
	mov		ebp, esp
	mov		edi, [ebp + 8]				; @list
	mov		ecx, 10
	L1:
				push	ecx
				mov		eax, [edi]
			    mov		ecx, 10         ; divisor!
				xor		bx, bx          ; count number of digits

			divide:
				xor		edx, edx				  ; high part = 0
				div		ecx						  ; eax = quotient, edx = remainder
				push	dx						  ; DL should be between 0 and 9
				inc		bx						  ; count number of digits
				test	eax, eax				  ; check if EAX zero.
				jnz		divide					  ; no, continue

												  ; Reversed order POP!
				mov		cx, bx					  ; number of digits
				lea		esi, strResult			  ; string buffer
			next_digit:
				pop		ax
				add		ax, '0'					  ; convert each number to ASCII
				mov		[esi], ax				  ; then write to strResult

				displayString OFFSET strResult

				loop	next_digit

		pop		ecx
		mov		edx,	OFFSET spacingMessage
		call	WriteString
		mov		edx, 0
		mov		ebx, 0
		add		edi, 4
		loop L1

	pop		ebp
	ret		8											; clean up the stack. we only have 1 extra DWORD to get rid of.
writeVal ENDP


; ====================================================================================================================
;         Procedure: displayAve
;       Description: Calculates the average and sum of a given array of numbers
;          Receives: list: @array
;           Returns: none
; Registers Changed: eax, ebx, ecx, edx
; ====================================================================================================================
displayAve PROC
	push ebp
	mov  ebp, esp
	mov  esi, [ebp + 8]  ; @list
	mov	 eax, 10 ; loop control
	mov  edx, 0
	mov	 ebx, 0
	mov	 ecx, eax

	medianLoop:
		mov		eax, [esi]
		add		ebx, eax
		add		esi, 4
		loop	medianLoop

	endMedianLoop:

	mov		edx, 0
	mov		eax, ebx
	mov		edx, [ebp+12]
	call	WriteString
	call	WriteDec
	call	CrLf
	mov		edx, 0
	mov		ebx, 10
	div		ebx
	mov		edx, [ebp+16]
	call	WriteString
	call	WriteDec
	call	CrLf

	endDisplayMedian:

	pop		ebp
	ret		12
displayAve ENDP


; ====================================================================================================================
;         Procedure: farewell
;       Description: Prints farewell message.
;          Receives: message: string message
;           Returns: none
; Registers Changed: edx
; ====================================================================================================================
farewell PROC
	push	ebp
	mov		ebp, esp
	; Farewell message parameter
	mov		edx, [ebp + 8]

	call	CrLf
	call	WriteString
	call	CrLf
	pop		ebp

	ret		4
farewell ENDP

exit
END main