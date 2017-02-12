TITLE Programming Assignment #3 (assn3.asm)

; Author: Alec Merdler
; Description: Write and test a MASM program to perform the following tasks:
;              1. Display the program title and programmer’s name.
;              2. Get the user’s name, and greet the user.
;              3. Display instructions for the user.
;              4. Repeatedly prompt the user to enter a number. Validate the user input to be in [-100, -1] (inclusive).
;		          Count and accumulate the valid user numbers until a non-negative number is entered. (The non-
;		          negative number is discarded.)
;              5. Calculate the (rounded integer) average of the negative numbers. 6. Display:
;	              i. the number of negative numbers entered (Note: if no negative numbers were entered, display a
;                    special message and skip to iv.)
;	              ii. the sum of negative numbers entered
;	              iii. the average, rounded to the nearest integer (e.g. -20.5 rounds to -20)
;	              iv. a parting message (with the user’s name)

INCLUDE Irvine32.inc

.data
programPrompt		   BYTE	 "Fibonacci Numbers, programmed by Alec Merdler", 0
namePrompt			   BYTE	 "Enter your name: ", 0
instructions_1		   BYTE	 "Please enter numbers between [-100, -1].", 0
instructions_2		   BYTE	 "Then, enter a non-negative number to see the amazing accumulator in action!", 0
instructions_3		   BYTE	 " Enter a number: ", 0
greeting			   BYTE	 "Hi, ", 0
goodbye				   BYTE	 "Ta ta for now, ", 0
number				   DWORD ?
userName			   BYTE  21 DUP(0)
userNameByteCount      DWORD ?
count				   DWORD 1
accumulator			   DWORD 0
totalIs				   BYTE	 "The total is:                  ", 0
quantNumbersEntered    BYTE	 "Amount of numbers accumulated:  ", 0
roundedAve_prompt	   BYTE	 "The Rounded Average is:        ", 0
roundedAve		       DWORD 0
remainder			   DWORD ?
floating_point_point   BYTE	 ".",0
floating_point_prompt  BYTE	 "As a floating point number:    ", 0
neg1k				   DWORD -1000
onek				   DWORD 1000
subtractor			   DWORD ?
floating_point		   DWORD ?
ecMessage1             BYTE  "**EC: Calculate and display the average as a floating-point number.", 0
ecMessage2	           BYTE  "**EC: Number the lines during user input.", 0

; constants
LOWERLIMIT = -100
UPPERLIMIT = -1

; change text color, because white text is a little boring after a while
val1 DWORD 11
val2 DWORD 16


.code
main PROC
    ; Set text color to teal
    mov     eax, val2
    imul    eax, 16
    add     eax, val1
    call    setTextColor

    ; Programmer name and title of assignment
    call	 CrLf
    mov		 edx, OFFSET programPrompt
    call	 WriteString
    call	 CrLf

    ; ec prompts
    mov		 edx, OFFSET ecMessage1
    call	 WriteString
    call	 CrLf
    mov		 edx, OFFSET ecMessage2
    call	 WriteString
    call	 CrLf

    ; get user name
    mov		edx, OFFSET namePrompt
    call	WriteString
    mov		edx, OFFSET userName
    mov		ecx, SIZEOF userName
    call	ReadString
    mov		userNameByteCount, eax

    ; test username
    mov		edx, OFFSET greeting
    call	WriteString
    mov		edx, OFFSET userName
    call	WriteString
    call	CrLF

    ; assignment instructions
    mov		edx, OFFSET instructions_1
    call	WriteString
    call	CrLf
    mov		edx, OFFSET instructions_2
    call	WriteString
    call	CrLf
    mov		ecx, 0


    ; loop to allow user to continue entering negative numbers
    userNumbers:	;read user number
            mov		eax, count
            call	WriteDec
            add		eax, 1
            mov		count, eax
            mov	  edx, OFFSET instructions_3
            call	WriteString
            call  ReadInt
            mov   number, eax
            cmp		eax,LOWERLIMIT
            jb		accumulate;
            cmp		eax, UPPERLIMIT
            jg		accumulate
            add		eax, accumulator
            mov		accumulator, eax
            loop	userNumbers


    ; do the accumulation
    accumulate:
            ; test if they entered any valid numbers, if they didnt, jump to the sayGoodbye
            mov		eax, count
            sub		eax, 2
            jz		sayGoodbye
            mov		eax, accumulator
            call	CrLF

            ; accumulated total
            mov		edx, OFFSET  totalIs
            call	WriteString
            mov		eax, accumulator
            call	WriteInt
            call	CrLF

            ; total numbers accumulated
            mov		edx, OFFSET quantNumbersEntered
            call	WriteString
            mov		eax, count
            sub		eax, 2
            call	WriteDec
            call	CrLf

            ; integer rounded average
            mov		edx, OFFSET roundedAve_prompt
            call	WriteString
            mov		eax, 0
            mov		eax, accumulator
            cdq
            mov		ebx, count
            sub		ebx, 2
            idiv	ebx
            mov		roundedAve, eax
            call	WriteInt
            call	CrLf

            ; integer average for accumulator
            mov		remainder, edx
            mov		edx, OFFSET floating_point_prompt
            call	WriteString
            call	WriteInt
            mov		edx, OFFSET floating_point_point
            call	WriteString


            ; fancy stuff for floating point creation
            mov		eax, remainder
            mul		neg1k
            mov		remainder, eax ; eax now holds remainder * -1000
            mov		eax, count
            sub		eax, 2		   ; ebx now holds something?
            mul		onek
            mov		subtractor, eax

            ; fancy stack stuff for floating point creation
            fld		remainder
            fdiv	subtractor
            fimul	onek
            frndint
            fist	floating_point
            mov		eax, floating_point
            call	WriteDec
            call	CrLf


    ; say goodbye
    sayGoodbye:
            call	CrLf
            mov		edx, OFFSET goodbye
            call	WriteString
            mov		edx, OFFSET userName
            call	WriteString
            mov		edx, OFFSET floating_point_point
            call	WriteString
            call	CrLf
            call	CrLf

; exit to operating system
exit
main ENDP

END main