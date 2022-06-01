## Read the following instructions carefully.
##
## You will provide your solution to the Data Lab by
## editing the collection of functions in this source file.
##
## A couple of rules from Project 2 are still in effect for your assembly code:
## 2. No global variables allowed.
## 3. You may not define or call any additional functions in this file.
##
## You may assume that your machine:
## 1. Uses two's complement, 32-bit representations of integers.
## 2. Performs right shifts arithmetically.
## 3. Has unpredictable behavior when shifting if the shift amount
## is less than 0 or greater than 31.
##
## Use the btest program to check your functions for correctness.

.text

# bitXor - x^y using only ~ and &
#   Example: bitXor(4, 5) = 1
#   Legal ops: ~ &
#   Max ops: 14
#   Rating: 1
#
.global bitXor
bitXor:

    movl 4(%esp), %eax # load first val in first register
    movl 8(%esp), %ecx # load second val into second val

    xorl %ecx, %eax # perform xor on them like in the equation

    ret 

# isZero - returns 1 if x == 0, and 0 otherwise
#   Examples: isZero(5) = 0, isZero(0) = 1
#   Legal ops: ! ~ & ^ | + << >>
#   Max ops: 2
#   Rating: 1
#
.global isZero
isZero:

    movl 4(%esp), %eax # load first val into register
    
    cmpl $0, %eax # compare the val to zero
    je ISZERO # if it is equal jump
    movl $0, %eax
    jmp END
    ISZERO:
    movl $1, %eax # is this jump is executed, set eax to 1
    jmp END
    END:

    ret 

# allOddBits - return 1 if all odd-numbered bits in word set to 1
#   where bits are numbered from 0 (least significant) to 31 (most significant)
#   Examples allOddBits(0xFFFFFFFD) = 0, allOddBits(0xAAAAAAAA) = 1
#   Legal ops: ! ~ & ^ | + << >>
#   Max ops: 12
#   Rating: 2
#
.global allOddBits
allOddBits:

    pushl %ebx # push these three registers to use later
    pushl %edi
    pushl %esi

    movl 16(%esp), %eax # adjust esp foor loading into first register
    movl $0xAA, %ebx # set masks to be shifted later
    movl $0xAA, %edi
    movl $0xAA, %esi

    movl $8, %ecx # move the amt desired to shift in ecx and then shift each mask 
    shll %ecx, %ebx
    movl $16, %ecx
    shll %ecx, %edi
    movl $24, %ecx
    shll %ecx, %esi

    addl $0xAA, %ebx # add the masks together
    addl %ebx, %edi
    addl %edi, %esi

    andl %esi, %eax

    xorl %esi, %eax # xor the final mask with original value

    cmpl $0, %eax # compare the value to 0, if it is then jump and set eax to either 1 or 0
    je ISZERO8
    movl $0, %eax
    jmp END8
    ISZERO8:
    movl $1, %eax
    jmp END8
    END8:

    popl %esi # make sure to shrink stack once done
    popl %edi
    popl %ebx
    
    ret 


# fitsBits - return 1 if x can be represented as an
#  n-bit, two's complement integer.
#   1 <= n <= 32
#   Examples: fitsBits(5,3) = 0, fitsBits(-4,3) = 1
#   Legal ops: ! ~ & ^ | + << >>
#   Max ops: 15
#   Rating: 2
.global fitsBits
fitsBits:
    pushl %ebx # push to use for later

    movl 8(%esp), %eax # load into registers
    movl 12(%esp), %edx
    notl %edx # take the not of n and add 3  to it to create another mask
    addl $33, %edx
    movl %eax, %ebx # copy the val of eax to use for later comparisons

    movl %edx, %ecx # move the mask of edc into ecx to use for shifting

    sall %ecx, %eax # shift x (eax) left then right bu the value ecx
    sarl %ecx, %eax

    xorl %ebx, %eax # xor the ebx and eax value to compare to 0 like above

    cmpl $0, %eax # jump if it is equal to 0 (not represented)
    je ISINT
    movl $0, %eax
    jmp END9
    ISINT:
    movl $1, %eax
    jmp END9
    END9:
    
    popl %ebx # shrink stack 

    ret

# floatAbsVal - Return bit-level equivalent of absolute value of f for
#   floating point argument f.
#   Both the argument and result are passed as unsigned int's, but
#   they are to be interpreted as the bit-level representations of
#   single-precision floating point values.
#   When argument is NaN, return argument..
#   Legal ops: Any integer/unsigned operations incl. ||, &&. also if, while
#   Max ops: 10
#   Rating: 2
#
.global floatAbsVal
floatAbsVal:
    pushl %ebx # push for later 
    
    movl 8(%esp), %eax # load into reg
    movl $0x7fffffff, %ebx # load mask into reg

    andl %ebx, %eax # take the and of these two 

    cmpl $0x7f800001, %eax # check for NaN
    jge NOTVAL
    jmp END5

    NOTVAL:
    movl 8(%esp), %eax # return val if NaN
    jmp END5

    END5:
    
    popl %ebx # shrink stack

    ret


# floatIsEqual - Compute f == g for floating point arguments f and g.
#   Both the arguments are passed as unsigned int's, but
#   they are to be interpreted as the bit-level representations of
#   single-precision floating point values.
#   If either argument is NaN, return 0.
#   +0 and -0 are considered equal.
#   Legal ops: Any integer/unsigned operations incl. ||, &&. also if, while
#   Max ops: 25
#   Rating: 2
#
.global floatIsEqual
floatIsEqual:

    pushl %ebx # push onto stack for later usage 
    pushl %edi
    pushl %esi

    movl 16(%esp), %eax # load into regs
    movl 20(%esp), %edx
    movl %edx, %esi # copy val for later usage 

    movl $1, %ebx
    shll $31, %ebx
    notl %ebx   # shift mask 

    movl $1, %edi
    shll $23, %edi
    movl $0x00, %ecx
    notl %ecx
    addl %ecx, %edi # fraction

    andl %ebx, %eax # floatF
    andl %ebx, %edx # floatG

    cmpl $0, %eax # compare to 0 to check for all zeros
    jne NEXTIF
    cmpl $0, %edx # compare to zero
    jne NEXTIF
    movl $1, %eax # set eax to 1 and return if conditions above are not met 
    jmp END10

    NEXTIF:
    movl $23, %ecx
    shrl %ecx, %eax
    cmpl $255, %eax # check for a 0 exponent, if not then jump
    jne FLOATARG
    movl 16(%esp), %eax # reload orignial value 
    andl %edi, %eax
    cmpl $0, %eax # compare 0 with mask eax, if 1 then jump
    je FLOATARG
    movl $0, %eax # otherwise, return 0
    jmp END10
    movl $23, %ecx
    shrl %ecx, %esi
    cmpl $255, %esi # check if equal to 0, if it is then jump
    jne FLOATARG
    movl 20(%esp), %edx # reload val
    andl %edi, %edx
    cmpl $0, %edx # compare with 0, if it is then jump
    je FLOATARG
    movl $0, %eax # otherwise return 0
    jmp END10

    FLOATARG:
    movl 16(%esp), %eax # re-load in original values 
    movl 20(%esp), %edx
    
    cmpl %edx, %eax # compare the two, if they are equal then return 1
    je RETURNONE
    movl $0, %eax # if not equal, set eax to zero and return 
    jmp END10

    RETURNONE:
    movl $1, %eax


    END10:

    popl %esi # shrink stack 
    popl %edi
    popl %ebx


    ret


# getByte - Extract byte n from word x
#   Bytes numbered from 0 (least significant) to 3 (most significant)
#   Examples: getByte(0x12345678, 1) = 0x56
#   Legal ops: ! ~ & ^ | + << >>
#   Max ops: 6
#   Rating: 2
#
.global getByte
getByte:

    movl 4(%esp), %eax # set regs
    movl 8(%esp), %edx
    movl $3, %ecx
    shll %ecx, %edx # shift second over by 3

    movl %edx, %ecx

    shrl %ecx, %eax # shift first by the amount that edx is 

    andl $255, %eax # and it with 255 to get the final val

    ret


# addOK - Determine if can compute x+y without overflow
#   Example: addOK(0x80000000,0x80000000) = 0,
#            addOK(0x80000000,0x70000000) = 1,
#   Legal ops: ! ~ & ^ | + << >>
#   Max ops: 20
#   Rating: 3
#
.global addOK
addOK:

    pushl %ebx # push for later use 
    
    movl 8(%esp), %eax # load into regs 
    movl 12(%esp), %edx
    movl %eax, %ebx # copy for later 
    
    addl %edx, %ebx # add these two together and then shoft alwasy by the previous amount 
    movl $31, %ecx
    shrl %ecx, %eax
    shrl %ecx, %edx
    shrl %ecx, %ebx

    xorl %eax, %edx # xor the values twice to check for the differences 
    xorl %eax, %ebx

    notl %edx # do the opposite of the xor value

    andl %edx, %ebx # and original with the xor to compare with 0 next


    cmpl $0, %ebx # same as in above functions, if zero jump and modify eax, if not continue
    je ISOK
    movl $0, %ebx
    jmp END7
    ISOK:
    movl $1, %ebx
    jmp END7
    END7:

    movl %ebx, %eax # move val into eax for return statement
    popl %ebx # shirnk stack

    ret


# bitMask - Generate a mask consisting of all 1's
#   lowbit and highbit
#   Examples: bitMask(5,3) = 0x38
#   Assume 0 <= lowbit <= 31, and 0 <= highbit <= 31
#   If lowbit > highbit, then mask should be all 0's
#   Legal ops: ! ~ & ^ | + << >>
#   Max ops: 16
#   Rating: 3
#
.global bitMask
bitMask:
    pushl %ebx # for later 
    pushl %edi

    movl 12(%esp), %eax # load regs 
    movl 16(%esp), %edx

    movl $0x00, %ebx # set masks and do the opposite of zero (long way)
    movl $0x00, %edi
    notl %ebx
    notl %edi

    movl %eax, %ecx # copy val

    shll %ecx, %ebx # shift values over of masks 
    movl $1, %ecx
    shll %ecx, %ebx

    movl %edx, %ecx # copy val into ecx for shifting purpose 
    shll %ecx, %edi

    notl %ebx # opposite 

    andl %ebx, %edi # and the mask with the val 

    movl %edi, %eax # move the answer into eax 

    popl %edi # shrink stack
    popl %ebx

    ret


# replaceByte(x,n,c) - Replace byte n in x with c
#   Bytes numbered from 0 (LSB) to 3 (MSB)
#   Examples: replaceByte(0x12345678,1,0xab) = 0x1234ab78
#   You can assume 0 <= n <= 3 and 0 <= c <= 255
#   Legal ops: ! ~ & ^ | + << >>
#   Max ops: 10
#   Rating: 3
#
.global replaceByte
replaceByte:
    
    pushl %ebx # later use 

    movl 8(%esp), %eax # load regs 
    movl 12(%esp), %ecx
    movl 16(%esp), %edx

    shll $3, %ecx # set shifting by each way by using ecx (as per project directions)
    movl $255, %ebx
    shll %ecx, %edx

    shll %ecx, %ebx
    notl %ebx

    andl %ebx, %eax # and the value that you got with the orinal eax val 

    orl %edx, %eax # perform and or operation after to nget the final answer

    popl %ebx # shrink stack
    
    ret


# isPower2 - returns 1 if x is a power of 2, and 0 otherwise
#   Examples: isPower2(5) = 0, isPower2(8) = 1, isPower2(0) = 0
#   Note that no negative number is a power of 2.
#   Legal ops: ! ~ & ^ | + << >>
#   Max ops: 20
#   Rating: 4
#
.global isPower2
isPower2:

    pushl %ebx # for later use 

    movl 8(%esp), %eax # load regs 
    movl %eax, %ebx

    cmpl $0, %eax # check if it is 0, becasue we aren't counting that as a power of 0
    je ISNOTPOWER
    cmpl $0, %eax
    js ISNOTPOWER # checked for sign 
    subl $1, %ebx # check for the value before 
    andl %ebx, %eax # and the two values toegther to check if it is a power of 2
    cmpl $0, %eax # compare with 0, if not equal then it is not 
    jne ISNOTPOWER
    movl $1, %eax
    jmp END6

    ISNOTPOWER:
    movl $0, %eax # set to 0 if jumped to here because it is not a power
    jmp END6

    END6:

    popl %ebx # shrink stack
    
    ret


# floatScale4 - Return bit-level equivalent of expression 4*f for
#   floating point argument f.
#   Both the argument and result are passed as unsigned int's, but
#   they are to be interpreted as the bit-level representation of
#   single-precision floating point values.
#   When argument is NaN, return argument
#   Legal ops: Any integer/unsigned operations incl. ||, &&. also if, while
#   Max ops: 30
#   Rating: 4
#
.global floatScale4
floatScale4:

    pushl %ebx # push for later usage 
    pushl %edi
    pushl %esi

    movl 16(%esp), %eax # uf

    movl %eax, %edx # shifting the bit to create sign 
    movl $31, %ecx
    sarl %ecx, %edx # sign

    movl $23, %ecx # setting the registers for exp
    movl %eax, %ebx
    sarl %ecx, %ebx
    andl $0xFF, %ebx # exp

    movl %eax, %edi
    andl $0x7FFFFF, %edi # frac

    cmpl $0, %ebx # compare exp to 0
    jnz EXPISNOTEQUAL # if not equal then jump
    imull $4, %edi # multiply fraction by 4
    cmpl $0x7FFFFF, %edi # compare frac to val
    jbe END11
    movl $1, %ebx # set exp to 1
    jmp LOOP

    LOOP: # start while loop
    movl %edi, %esi # updated frac
    movl $0xFFFFFF, %ecx 
    notl %ecx
    andl %ecx, %esi # while loop condition
    cmpl $0, %esi # set condition for while loop
    jne INLOOP
    andl $0x7FFFFF, %edi # take and of fraction after the while loop is done
    jmp END11

    EXPISNOTEQUAL:
    cmpl $0xFF, %ebx # compare exponenet to 0xFF
    jge END11
    addl $2, %ebx # and 2 to exponenet na d compare the exp to 0xFF again
    cmpl $0xFF, %ebx
    jge GREATERTHAN # jump if greaterthan
    jmp END11

    GREATERTHAN:
    movl $0xFF, %ebx # set both to 0 for infinity/NaN
    movl $0, %edi 
    jmp END11

    INLOOP:
    movl $1, %ecx 
    sarl %ecx, %edi # shift frac to the right 
    addl $1, %ebx # add 1 to exp
    jmp LOOP

    EXPISLESS:
    cmpl $0xFF, %ebx # compare exponenet to 0xFF
    jge END11
    addl $2, %ebx # add 2 to the exponent
    cmpl $0xFF, %ebx # compare it again 
    jge EXPGREATER # if greater then jump
    jmp END11 # otherwise end 

    EXPGREATER:
    movl $0xFF, %ebx # set both to zero 
    movl $0, %edi
    jmp END11

    END11:

    movl $31, %ecx # shift all the values that you got 
    shll %ecx, %edx # sign by 31
    movl $23, %ecx
    shll %ecx, %ebx # shift exp by 23 
    
    orl %edx, %ebx # or all of them for the correct values (one of them has it)
    orl %ebx, %edi

    movl %edi, %eax # put value in eax for return 

    popl %esi # shrink stack 
    popl %edi
    popl %ebx

    ret
